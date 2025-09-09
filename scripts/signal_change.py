#!/usr/bin/env python3

import csv
import re
import os

def load_rename_map(csv_path):
    """
    Reads a CSV file of the form:
        old,new
        clk,clk_i
        reset,reset_n
    Returns a dictionary mapping old -> new.
    """
    rename_map = {}
    with open(csv_path, newline="") as f:
        reader = csv.reader(f)
        for row in reader:
            # skip blank lines or malformed rows
            if len(row) != 2:
                continue
            old, new = row
            rename_map[old.strip()] = new.strip()
    return rename_map

##########################################################################
#                            CORE FUNCTIONS                              #
##########################################################################

def parse_module(module_path, rename_map):
    input_pattern = re.compile(r"\binput\b")
    output_pattern = re.compile(r"\boutput\b")
    old_name_patterns = {}

    module_rename_map = {}

    for old_name in rename_map.keys():
        old_name_patterns[old_name] = re.compile(rf"\b{re.escape(old_name)}([FDEMW])?(?:_i|_o)?\b")

    #Pass to determine new names
    with open(module_path, "r") as f:
        for line in f:
            for old_name, pattern in old_name_patterns.items():
                match = pattern.search(line)
                if (match):
                    # preserve suffix if present
                    if match.group(1):
                        old_suffix = match.group(1)
                        suffix = f"_{match.group(1).lower()}"
                    else:
                        old_suffix = ""
                        suffix = ""

                    if ((old_name + old_suffix) in module_rename_map.keys()):
                        break

                    new_base = rename_map[old_name]
                    if input_pattern.search(line):
                        new_name = f"{new_base}{suffix}_i"
                    elif output_pattern.search(line):
                        new_name = f"{new_base}{suffix}_o"
                    else:
                        new_name = f"{new_base}{suffix}"

                    module_rename_map[old_name + old_suffix] = new_name
                    break
                
    return module_rename_map

def parse_directory(rtl_path, tb_path, csv_path):

    signal_map = load_rename_map(csv_path)
    files = {}
    for file in (os.listdir(rtl_path)):
        if (".sv" in file and not file.startswith(".")):
            files[file] = os.path.abspath(os.path.join(rtl_path, file))

    for file in (os.listdir(tb_path)):
        if (".sv" in file and not file.startswith(".")):
            files[file] = os.path.abspath(os.path.join(tb_path, file))

    module_rename_maps = {}

    
    for module, file_path in files.items():
            module = module.removesuffix(".sv")
            module_rename_maps[module] = {}
            module_rename_maps[module]["path"] = file_path
            module_rename_maps[module]["rename_map"] = parse_module(file_path, signal_map) 
            
    return module_rename_maps

def rename_apply(module_rename_maps, rtl_out_path="./rtl_test", tb_out_path="./tb_test"):

    modules = module_rename_maps.keys()

    for module in modules:
        module_path = module_rename_maps[module]["path"]
        internal_parse = False

        with open(module_path, "r") as f:
            text = f.readlines()

        if ("tb" in module):
            out_path = tb_out_path
        else:
            out_path = rtl_out_path

        os.makedirs(out_path, exist_ok=True)
        with open(f"{out_path}/{module}.sv", "w") as f:
            for line in text:
                if (not internal_parse):
                    internal_module = module_start(line, modules)
                    if (internal_module):
                        internal_parse = True
                else:
                    if (");" in line):
                        internal_parse = False
                    else:
                        for old, new in module_rename_maps[internal_module]["rename_map"].items():
                            pattern = re.compile(rf"\.{re.escape(old)}\b")
                            line = pattern.sub(f".{new}".ljust(32), line)
                    
                    line = pad_ports(line, 32)
                        

                for old, new in module_rename_maps[module]["rename_map"].items():
                    pattern = re.compile(rf"(?<!\.)\b{re.escape(old)}\b")
                    line = pattern.sub(new, line)

                f.write(line)

##########################################################################
#                       PARSING HELPER FUNCTIONS                         #
##########################################################################

def module_start(line, module_db):
    # strip comments
    line = line.split("//")[0].strip()
    if not line:
        return None

    tokens = line.split()
    if not tokens:
        return None

    first = tokens[0]

    # first token must be a known module
    if first not in module_db:
        return None

    # must have an opening parenthesis (could be later in line, not just right after)
    if "(" in line:
        return first   # return the module name

    return None

def pad_ports(line, padding_base=32):
    if ("//" in line or "." not in line):
        return line

    # count leading whitespace
    indent_count = len(line) - len(line.lstrip())
    indent = " " * indent_count

    tokens = line.strip().split()
    if not tokens:
        return line  # blank or comment line, leave unchanged

    padding = padding_base - len(tokens[0])
    rebuilt = tokens[0] +  (" " * padding) + (" ").join(tokens[1:])#(" " * padding).join(tokens)
    return indent + rebuilt + "\n"

##########################################################################
#                               MAIN                                     #
##########################################################################

if __name__ == "__main__":

    

    module_rename_maps = parse_directory("../rtl", "../tb", "./signal_change_list.csv")
    rename_apply(module_rename_maps, "../rtl", "../tb")