import argparse
import json

from pathlib import Path
from collections import defaultdict

parser = argparse.ArgumentParser()
parser.add_argument("filename", nargs="?", default="06_input_simple.txt")
args = parser.parse_args()
filename = args.filename

data = defaultdict(list)
with Path(filename).open("r") as file:
    data["time"] = [int(s) for s in file.readline().split(":")[1].strip().split(" ") if len(s) > 0]
    data["distance"] = [int(s) for s in file.readline().split(":")[1].strip().split(" ") if len(s) > 0]

with Path(filename.replace(".txt", ".json")).open("w+") as file:
    json.dump(data, file, indent=4)