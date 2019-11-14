cd /mnt
cd sparrow
git reset --hard
git checkout sid
git pull
source /home/ubuntu/.cargo/env
cargo build --release
