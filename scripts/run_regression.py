#!/usr/bin/env python3

import argparse
import yaml
import subprocess
import os
import logging
import re
from pathlib import Path

def parse_args():
    parser = argparse.ArgumentParser(
        description="Run regression tests based on YAML-defined test groups."
    )

    # Positional argument: test group
    parser.add_argument(
        "target",
        type=str,
        help="Name of the test or test_group to run (e.g., 'default', 'branching')"
    )

    # Optional argument: output directory
    parser.add_argument(
        "--single",
        action="store_true",
        help="Set if the test is an individual unit test rather than a test group (default: False)"
    )

    # Optional argument: output directory
    parser.add_argument(
        "--output_dir",
        type=str,
        default="../sim_results",
        help="Directory to write test outputs (default: ../sim_results)"
    )

    # Optional flag: verbose output
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Print full command output for each test"
    )

    return parser.parse_args()

def setup_logger(log_name, log_file_path, level=logging.INFO):
    """
    Creates and returns a logger with console and file output.

    Args:
        log_name: Unique name for the logger (e.g., "regression", "alu_tb").
        log_file_path: Path to the log file to write to.
        level: Logging level (default: logging.INFO)

    Returns:
        A configured logging.Logger object.
    """
    logger = logging.getLogger(log_name)
    logger.setLevel(level)

    # Prevent duplicate handlers if the logger is called multiple times
    if logger.hasHandlers():
        return logger

    # Ensure log directory exists
    Path(log_file_path).parent.mkdir(parents=True, exist_ok=True)

    # File handler
    file_handler = logging.FileHandler(log_file_path, mode='w')
    file_handler.setFormatter(logging.Formatter(
        "%(asctime)s [%(levelname)s] %(message)s"
    ))

    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(logging.Formatter(
        "[%(levelname)s] %(message)s"
    ))

    logger.addHandler(file_handler)
    logger.addHandler(console_handler)

    return logger

def setup(yaml_path):
    """
    Loads in the a YAML file safely

    Args:
        yaml_path: Path to the yaml file
    
    Returns:
        yaml_data: Data contained within the yaml    
    """
    args = parse_args()
    regression_logger = setup_logger("regression_logger", f"{args.output_dir}/regression.log")

    try:
        with open(yaml_path, "r") as f:
            yaml_data = yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Error: File not found at {yaml_path}")
    except yaml.YAMLError as e:
        print(f"Error parsing YAML: {e}")
    
    return args, regression_logger, yaml_data

def resolve_target(target, test_data, single):

    run_info = {}
    try:
        if (single == True):
            for category, local_tests in test_data["TESTS"].items():
                if (target in local_tests):
                    run_info[target] = test_data["TESTS"][category][target]

            if (not run_info):
                raise ValueError(f"Test {target} not found in any category.")
        else:
            categories = test_data["TEST_GROUPS"][target]["modules"]

            for category, tests in test_data["TESTS"].items():

                if (category in categories):
                    for test in tests.keys():
                        run_info[test] = test_data["TESTS"][category][test]
                    
    except Exception as e:
        print(f"Unable to find test in yaml file: {e}")

    return run_info

def get_module_paths(rtl_dir, module_path, module_paths=None):
    """
    Parses file for the instantiaion of modules.
    Requires module instance names to start with "u_"

    Args:
        rtl_dir: Location of all RTL files
        module_path: Path to the module currently being parsed
        module_paths: running list of paths to included modules
    """
    if module_paths is None:
        module_paths = []

    pattern = re.compile(r"u_[^\s]+\s\(")

    with open(module_path, "r") as f:
        for line in f:
            if (re.search(pattern, line)):
                module = line.split()[0]
                sub_module_path = rtl_dir.joinpath(f"{module}.sv")

                if sub_module_path.exists():
                    module_paths.append(sub_module_path.resolve())
                    get_module_paths(rtl_dir, sub_module_path, module_paths)

    #Remove duplicates while preserving order
    module_paths = list(dict.fromkeys(module_paths))

    return module_paths

def run_test(test, tb_file, test_out_dir, result_info):
    """
    Runs a specific testbench using Icarus Verilog

    Args:
        test: Name of the test
        tb_file: Name of the testbench file
        test_out_dir: Where the outputs of the test are placed
    """
    regression_logger = logging.getLogger("regression_logger")
    # --- Project directories ---
    proj_dir     = Path(__file__).resolve().parent.parent
    rtl_dir      = proj_dir / "rtl"
    include_dir  = proj_dir / "common" / "includes"
    filelist_dir = proj_dir / "filelists"
    tb_path      = proj_dir / "tb" / tb_file
    tb_include_dir = proj_dir.joinpath("tb", "common")
    common_tb    = list(proj_dir.joinpath("tb", "common").rglob("*v*"))

    os.makedirs(filelist_dir, exist_ok=True)

    # --- Source files ---
    source_files = [tb_path, *common_tb]

    # --- Defines ---
    defines = [f'DUMP_PATH="{test_out_dir}/{test}.vcd"']

    # --- Build compile command ---
    run_cmd = [
        "iverilog", "-g2012",
        "-I", str(include_dir),
        "-I", str(tb_include_dir)
    ]

    # Add defines
    for d in defines:
        run_cmd.extend(["-D", d])

    # Write filelist for RTL modules
    module_paths = get_module_paths(rtl_dir, tb_path)
    filelist = filelist_dir / f"{test}.f"
    filelist.write_text("\n".join(map(str, module_paths)) + "\n")

    # Add filelist, sources, and output
    run_cmd.extend([
        "-f", str(filelist),
        *map(str, source_files),
        "-o", f"{test_out_dir}/{test}.vvp"
    ])

    # --- Run compilation and simulation ---
    test_passed = False
    warning_present = False
    log_path = Path(test_out_dir) / f"{test}.log"
    with open(log_path, "w") as log_file:

        try:
            log_file.write(f"Compilation command:\n {' '.join(run_cmd)}\n")
            process = subprocess.Popen(run_cmd, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, cwd=proj_dir)
            for line in process.stdout:
                log_file.write(f"{line}\n")
            log_file.write(f"Compilation of {test} complete\n")

            process.wait()

            log_file.write(f"Beginning simulation of test: {test}...\n")
            process = subprocess.Popen([f"{test_out_dir}/{test}.vvp"], text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, cwd=proj_dir)
            for line in process.stdout:
                log_file.write(f"{line}\n")
                if "TEST PASSED" in line:
                    test_passed = True
                if ("WARNING" in line.upper() and "VCD" not in line.upper()):
                    warning_present = True
            
            process.wait()
        except Exception as e:
            test_passed = False

    if (test_passed == True):
        result_info["PASSED_TESTS"][test] = test_out_dir
        regression_logger.info(f"{test} PASSED")
    else:
        result_info["FAILED_TESTS"][test] = test_out_dir
        regression_logger.info(f"{test} FAILED")
    if (warning_present == True):
        result_info["WARNING_TESTS"][test] = test_out_dir
        regression_logger.info(f"{test} CONTAINS WARNINGS")

    return

def main():

    args, regression_logger, test_data = setup("regression_tests.yml")
    run_info = resolve_target(args.target, test_data, args.single)

    top_out_dir = Path(os.path.abspath(args.output_dir))
    result_info = {"PASSED_TESTS": {}, "FAILED_TESTS": {}, "WARNING_TESTS": {}}

    regression_logger.info(f"Beginning regression for {args.target}")

    # Run all tests
    for test, config in run_info.items():
        test_out_dir = top_out_dir / test
        test_out_dir.mkdir(parents=True, exist_ok=True)
        subprocess.run(f"rm -rf {test_out_dir}/*", shell=True)
        run_test(test, config["tb"], test_out_dir, result_info)

    # Report results
    passed_tests = result_info["PASSED_TESTS"]
    failed_tests = result_info["FAILED_TESTS"]
    warning_tests = result_info["WARNING_TESTS"]

    if (len(passed_tests) != 0):
        regression_logger.info("====================PASSED TESTS ====================")
        for test in passed_tests.keys():
            regression_logger.info(f"{test}: {passed_tests[test]}")
    else:
        regression_logger.info("==================== NO TESTS PASS====================")

    if (len(failed_tests) != 0):
        regression_logger.info("====================FAILED TESTS ====================")
        for test in failed_tests.keys():
            regression_logger.info(f"{test}: {failed_tests[test]}")
    else:
        regression_logger.info("==================== NO TESTS FAILED ====================")
    
    if (len(warning_tests) != 0):
        regression_logger.info("==================== TESTS WITH WARNINGS ====================")
        for test in warning_tests.keys():
            regression_logger.info(f"{test}: {warning_tests[test]}")
    
    regression_logger.info(f"==================== SUMMARY ====================")
    regression_logger.info(f"Total PASSED tests: {len(passed_tests)}")
    regression_logger.info(f"Total FAILED tests: {len(failed_tests)}")

if __name__ == "__main__":
    main()