import re
import json

partitions = []
with open("re2.json") as f:
    lines = f.readlines()

current = {}
for line in lines:
    line = line.strip()
    if line.startswith("topic"):
        current["topic"] = re.search(r'topic (.+?) partition', line).group(1)
        current["partition"] = int(re.search(r'partition (\d+)', line).group(1))
        current["replicas"] = list(map(int, re.findall(r'replicas ([\d\s]+)', line)[0].split()))
        current["log_dirs"] = re.findall(r'log_dirs ([\w\s"]+)', line)[0].replace('"', '').split()
        partitions.append(current)
        current = {}

output = {
    "version": 1,
    "partitions": partitions
}

with open("reassignment_clean.json", "w") as out:
    json.dump(output, out, indent=2)