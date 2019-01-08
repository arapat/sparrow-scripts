export SPARROW_REPO="https://github.com/arapat/sparrow.git"
export SPARROW_BRANCH="master"
export S3_BUCKET="tmsn-data"
export TMSN_REPO="https://github.com/arapat/tmsn.git"
export TMSN_BRANCH="master"
export METRICS_REPO="https://github.com/arapat/metricslib.git"

if [ "$#" -ne 2 ]; then
    echo "Wrong paramters. Usage: ./setup.sh <ssd-device-path> <dataset-name>"
    exit
fi
export DISK=$1
SETUP_DIR="$(dirname "$0")"

# Install AWS CLI tools
sudo apt-get update
sudo apt-get install -y awscli
# Prepare AWS credentials
aws s3 ls s3://$S3_BUCKET/ > /dev/null
if [ $? -eq 0 ]; then
    echo "AWS was set up correctly."
else
    echo "AWS needs to be set up."
    aws configure
fi


# Format disk
sudo umount /mnt
yes | sudo mkfs.ext4 -L MY_DISK $DISK
sudo mount LABEL=MY_DISK /mnt
sudo chown -R ubuntu /mnt

# Install packages
sudo apt-get install -y gcc python3 python3-pip
echo "export EDITOR=vim" >> ~/.bashrc

# Set up git
git config --global user.name "Julaiti Alafate"
git config --global user.email "jalafate@gmail.com"
git config --global push.default simple

# Install Rust
cd /mnt
$SETUP_DIR/download-data.sh $2 > /dev/null 2> /dev/null &
curl https://sh.rustup.rs -sSf > rustup.sh
bash rustup.sh -y

# Clone packages
git clone $SPARROW_REPO sparrow
git clone $TMSN_REPO tmsn
git clone $METRICS_REPO

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
sudo pip3 install xgboost sklearn

# Wrap up
echo "Waiting Rust compiler and data downloader..."
wait
echo "All done."