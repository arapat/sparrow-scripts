export SPARROW_REPO="https://github.com/arapat/sparrow.git"
export SPARROW_BRANCH="tmsn-dt"
export S3_BUCKET="tmsn-data"
export TMSN_REPO="https://github.com/arapat/tmsn.git"
export TMSN_BRANCH="master"
export METRICS_REPO="https://github.com/arapat/metricslib.git"
export SCRIPTS_REPO="https://github.com/arapat/sparrow-scripts.git"

if [ "$#" -ne 3 ]; then
    echo "Wrong paramters. Usage: ./setup.sh <dataset-name> <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY>"
    exit
fi
FREE_PART=("$(comm -3 <(lsblk | grep "xvd\|nvme" | cut -d' ' -f1 | sed 's/[^a-z0-9]*//g' | sort | uniq) \
                      <(mount | grep ^/dev | cut -d' ' -f1 | cut -d'/' -f3 | awk '{print $0; print substr($0, 1, length($0)-1)}' | sort | uniq))")
DISK="/dev/${FREE_PART[0]}"
SETUP_DIR="$(dirname "$0")"
PY_REQ_FILE="$(realpath $SETUP_DIR/../python/requirements.txt)"

# Install AWS CLI tools
sudo apt-get update
sudo apt-get install -y awscli
# Prepare AWS credentials
aws s3 ls s3://$S3_BUCKET/ > /dev/null
if [ $? -eq 0 ]; then
    echo "AWS was set up correctly."
else
    echo "AWS needs to be set up."
    mkdir -p /home/ubuntu/.aws
    echo "[default]" > /home/ubuntu/.aws/credentials
    echo "aws_access_key_id = $2" >> /home/ubuntu/.aws/credentials
    echo "aws_secret_access_key = $3" >> ~/.aws/credentials
fi


# Format disk
sudo umount /mnt
yes | sudo mkfs.ext4 -L MY_DISK $DISK
sudo mount LABEL=MY_DISK /mnt
sudo chown -R ubuntu /mnt

# Set up git
git config --global user.name "Julaiti Alafate"
git config --global user.email "jalafate@gmail.com"
git config --global push.default simple

# Clone packages
cd /mnt
git clone $SPARROW_REPO sparrow
git clone $TMSN_REPO tmsn
git clone $METRICS_REPO
git clone $SCRIPTS_REPO

# Install packages
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gcc python3 python3-pip pkg-config libssl-dev
echo "export EDITOR=vim" >> ~/.bashrc

# Install Rust
$SETUP_DIR/download-data.sh $1 > /dev/null 2> /dev/null &
curl https://sh.rustup.rs -sSf > rustup.sh
bash rustup.sh -y

# Compile Sparrow
cd tmsn
git checkout $TMSN_BRANCH
cd /mnt/sparrow
git checkout $SPARROW_BRANCH
source ~/.cargo/env
cargo build --release > /dev/null 2> /dev/null &
cd /mnt/metricslib
cargo build --release > /dev/null 2> /dev/null &

# Install Python packages
sudo pip3 install -r $PY_REQ_FILE

# Wrap up
echo "Waiting Rust compiler and data downloader..."
wait
echo "All done."
