export SPARROW_REPO="https://github.com/arapat/sparrow.git"
export SPARROW_BRANCH="master"
export TMSN_REPO="https://github.com/arapat/tmsn.git"
export TMSN_BRANCH="master"
export DISK="/dev/nvme0n1"

sudo umount /mnt
yes | sudo mkfs.ext4 -L MY_DISK $DISK
sudo mount LABEL=MY_DISK /mnt
sudo chown -R ubuntu /mnt

sudo apt-get update
sudo apt-get install -y awscli gcc
echo "export EDITOR=vim" >> ~/.bashrc

git config --global user.name "Julaiti Alafate"
git config --global user.email "jalafate@gmail.com"
git config --global push.default simple

cd /mnt
curl https://sh.rustup.rs -sSf > rustup.sh
bash rustup.sh -y
git clone $SPARROW_REPO sparrow
git clone $TMSN_REPO tmsn
cd tmsn
git checkout $TMSN_BRANCH
cd /mnt/sparrow
git checkout $SPARROW_BRANCH
source ~/.cargo/env
cargo build --release > /dev/null 2> /dev/null &
cd /mnt
if [[ -z "${AWS_ACCESS_KEY_ID}" ]]; then
    echo "Data files are not downloaded because AWS credentials are not set."
else
    aws s3 cp s3://tmsn-data/splice/training/training-shuffled.libsvm .
    aws s3 cp s3://tmsn-data/splice/testing/testing-correct.libsvm .
fi
