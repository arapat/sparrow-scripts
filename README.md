# Sparrow-Scripts

This repository contains scripts for running experiments using [Sparrow](https://github.com/arapat/sparrow).

## A quickstart

1. Launch a cluster with one head node (e.g. a r3.2xlarge instance) and multiple scanner nodes (e.g. m6gd.large instances).

2. Copy the IPv4 addresses of the launched instances, and paste to a text file named `servers.txt` in the following format:
```
35.168.9.219
3.81.70.165
54.204.169.225
```
where the first line is the IP address of the head node, and the following lines are the IP addresses of the scanners.

3. Run the auto setup script:
```bash
./setup/auto-setup.sh <ec2_identity_file.pem> <dataset_name> <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY>
```
The script read the server addresses from the `servers.txt` file, install `Sparrow` on all instances, and download the dataset to the head node.
The `<dataset_name>` supports two datasets, `splice` and `bathymetry`. The script downloads data from our S3 bucket.

4. Set up the right config file
The purpose of this step is to put [a config file](https://github.com/arapat/sparrow-experiments/tree/master/configs) on all instances, and (optionally) make changes if needed (e.g. change the number of trees). Some example scripts are given at `setup/1-build-script.sh` and `setup-1b-update-example.sh`. 
```bash
cd setup/
cp 1-build-script.sh script.sh
./auto-run-script.sh <ec2_identity_file.sh>
```

5. Start experiment
```
cd setup/
cp 2-run-script.sh script.sh
./auto-run-script.sh <ec2_identity_file.sh>
```
