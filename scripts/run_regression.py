import argparse
import yaml
import subprocess
import os
import logging
from pathlib import Path
import glob

def flatten_filelist(filelist_path, visited=None):
    """
    Recursively flattens a hierarchical Verilog filelist, resolving `-f <file>` inclusions.
    Returns a list of absolute file paths with duplicates removed and order preserved.

    Args:
        filelist_path (str): Path to the top-level .f file.
        visited (set): Internal use for recursion to avoid circular references.

    Returns:
        List[str]: Flattened, deduplicated list of Verilog source file paths.
    """
    filelist_path = os.path.abspath(filelist_path)
    base_dir = os.path.dirname(filelist_path)
    visited = visited or set()
    result = []

    if filelist_path in visited:
        return []  # Prevent circular includes

    visited.add(filelist_path)

    with open(filelist_path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("//"):
                continue  # Skip comments and empty lines

            if line.startswith("-f"):
                # Recursively process included filelists
                include_path = line[2:].strip()
                include_path = os.path.abspath(os.path.join(base_dir, include_path))
                result.extend(flatten_filelist(include_path, visited))
            else:
                # Resolve relative paths
                full_path = os.path.abspath(f"../{line}")
                if full_path not in result:
                    result.append(full_path)

    return result
    
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

def run_test(test, tb, filelist, output_dir):

    proj_dir = Path(__file__).resolve().parent.parent

    test_output_dir = f"{output_dir}/{test}"
    os.makedirs(test_output_dir, exist_ok=True)

    tb_file = f"{proj_dir}/tb/{tb}"
    includes = glob.glob(f"{proj_dir}/includes/*v*", recursive=True)
    common = glob.glob(f"{proj_dir}/tb/common/*v*", recursive=True)

    source_files = [tb_file]
    source_files.extend(includes)
    source_files.extend(common)

    defines = [f'DUMP_PATH="{test_output_dir}/{test}.vcd"']

    #Initial
    run_cmd = ["iverilog", "-g2012"]

    #Includes
    run_cmd.extend(["-I", f"{proj_dir}/includes"])

    #Defines
    for define in defines:
        run_cmd.extend(["-D", define])
    
    rtl_files = flatten_filelist(f"{proj_dir}/filelists/{filelist}")
    for path in rtl_files:
        source_files.append(path)

    #Source files
    run_cmd.extend(source_files)

    #Output file
    run_cmd.extend(["-o", f"{test_output_dir}/{test}.vvp"])

    with open(f"{test_output_dir}/{test}.log", "w") as log_file:
        subprocess.run(run_cmd, text=True, stdout=log_file, stderr=subprocess.STDOUT, cwd=proj_dir)
        subprocess.run([f"{test_output_dir}/{test}.vvp"], text=True, stdout=log_file, stderr=subprocess.STDOUT, cwd=proj_dir)

    return

def main():

    args, regression_logger, test_data = setup("regression_tests.yml")
    run_info = resolve_target(args.target, test_data, args.single)

    output_dir = os.path.abspath(args.output_dir)
    
    for test in run_info.keys():
        run_test(test, run_info[test]["tb"], run_info[test]["filelist"], output_dir)

if __name__ == "__main__":
    main()