# Remember to upload config for head manually

# Run sparrow
killall sparrow
cd /mnt/sparrow
mkdir -p models
export RUST_BACKTRACE=1
export RUST_LOG="sparrow=debug,tmsn=debug"
./target/release/sparrow train examples/config_splice.yaml > log1.txt 2> log2.txt
