source .cargo/env
cd /mnt/sparrow
git checkout grid
cargo build --release
cd /mnt/sparrow/examples

# CHANGE THIS
sed -i 's/two-scanner/50-scanner/' config_splice.yaml

sed -i 's/-20p//' config_splice.yaml

