#!/usr/bin/env python3
import os
import sys
from subprocess import call, Popen, PIPE


COMMAND = {
    "sparrow": "scp -o StrictHostKeyChecking=no -r -i {cred} ubuntu@{serv}:/mnt/t*.log ubuntu@{serv}:/mnt/models* {dirn}",
    "xgbd":    "scp -o StrictHostKeyChecking=no -i {cred} ubuntu@{serv}:/mnt/xgb* {dirn}",
    "xgbm":    "scp -o StrictHostKeyChecking=no -i {cred} ubuntu@{serv}:/mnt/xgb* {dirn}",
    "lgb":     "scp -o StrictHostKeyChecking=no -i {cred} ubuntu@{serv}:/mnt/lgb-error.log ubuntu@{serv}:/mnt/model.* ubuntu@{serv}:/mnt/lightgbm.log {dirn}",
}

  
def main(datasize, datasetname, cred_file):
    f = open("input.txt")
    instances = {}
    machines = f.readline().split(", ")
    for machine in machines:
        name, config = machine.strip().split(' ', 1)
        dataset, package, memsize = config[1:-1].split()
        instances[name] = {
            "dataset": dataset.lower(),
            "package": package.lower(),
            "memsize": memsize.lower(),
        }
    for line in f:
        name, url = line.strip().split(": ", 1)
        instances[name]["url"] = url

    procs = []
    for key, vals in instances.items():
        dataset = vals["dataset"]
        if dataset != datasetname:
            continue
        memsize = vals["memsize"]
        package = vals["package"]
        download_command = COMMAND[package]
        dirname = "new-logs/{}/mem{}/{}/{}".format(
            datasize, memsize, dataset, package)
        command = COMMAND[package].format(
            cred=cred_file, serv=vals["url"], dirn=dirname)
        if not os.path.exists(dirname):
            os.makedirs(dirname)
        p = Popen(command.split())
        name = "{}-{}-{}".format(vals["dataset"], vals["package"], vals["memsize"])
        procs.append((p, name))

    msgs = []
    for p, name in procs:
        if p.wait() != 0:
            msgs.append("{} failed".format(name))

    print("\n\n\n")
    for msg in msgs:
        print(msg)


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print("Usage: ./collect-logs <dataset-size> <dataset-name> <cred-file>")
        sys.exit(1)
    datasize = sys.argv[1]
    dataset = sys.argv[2]
    cred_file = sys.argv[3]
    main(datasize, dataset, cred_file)

