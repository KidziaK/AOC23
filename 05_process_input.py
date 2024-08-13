import argparse
import json

from pathlib import Path
from collections import defaultdict


if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog='input_parser')
    parser.add_argument("filename")
    args = parser.parse_args()
    filename = args.filename

    data = defaultdict(list)

    with Path(filename).open("r") as file:
        seed_line = [int(s) for s in file.readline().split(":")[1].strip().split(" ")]
        i = 0
        while(i < len(seed_line)):
            data["seeds"].append([seed_line[i], seed_line[i+1]])
            i += 2

        while(line := file.readline()):
            if ":" in line:
                header = line.split(":")[0].replace(" map", "").replace("-", "_")

                while(new_line := file.readline()):
                    if len(new_line.strip()) == 0: break
                    data[header].append([int(s) for s in new_line.strip().split(" ")])

    
    with Path(filename.replace(".txt", ".json")).open("w+") as file:
        json.dump(data, file, indent=4)