# Sparrow-Scripts

This repository contains scripts for running experiments using [Sparrow](https://github.com/arapat/sparrow).

## Setting up cluster

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
* `<ec2_identity_file.pem>`: the path to [your EC2 key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
* `<dataset_name>`: which dataset to download to the head node, currently supports two datasets, `splice` and `bathymetry`
* `AWS_ACCESS_KEY_ID>` and `<AWS_SECRET_ACCESS_KEY>`: your [AWS credentials](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html)

This script reads the server addresses from the `servers.txt` file, installs `Sparrow` on all instances, and downloads the dataset to the head node.
The script downloads data from our S3 bucket.

Now you are ready to run an experiment on the cluster.

## Run an experiment

In this example, we give two sample scripts under `setup/` directory which runs an experiment with Sparrow.

1. Distribute a configuration file

The experiment setup is set by a `config.yaml` file (learn about its fields [here](https://github.com/arapat/sparrow/blob/master/configuration.md)).

To launch this experiment, we need to put [a config file](https://github.com/arapat/sparrow-experiments/tree/master/configs) on all instances.

```bash
cd setup/
cp 1-build-script.sh script.sh
./auto-run-script.sh <ec2_identity_file.sh>
```

* `<ec2_identity_file.pem>`: the path to [your EC2 key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)

Read [configuration.md](https://github.com/arapat/sparrow/blob/master/configuration.md) for how to set `config.yaml` file.

2. Start experiment

Now we can run Sparrow, which reads the `config.yaml` distributed in the last step, and starts the model training.

```
cd setup/
cp 2-run-script.sh script.sh
./auto-run-script.sh <ec2_identity_file.sh>
```

* `<ec2_identity_file.pem>`: the path to [your EC2 key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
