from pathlib import Path
from collections import defaultdict

import argparse
import json

parser = argparse.ArgumentParser()
parser.add_argument("file_name", default="08_input_simple.txt", nargs="?")
args = parser.parse_args()
file_name = args.file_name

config = defaultdict(list)

with Path(file_name).open("r") as file:
    config["directions"] = file.readline().strip()
    file.readline()
    for line in file.readlines():
        node_name, directions, *_ = line.split("=")
        l, r, *_ = directions.strip().replace("(", "").replace(")", "").split(",")
        config["nodes"].append([node_name.strip(), l.strip(), r.strip()])

with Path(file_name.replace(".txt", ".json")).open("w+") as file:
    json.dump(config, file, indent=4)