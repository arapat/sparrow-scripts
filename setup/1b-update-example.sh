cd /mnt/sparrow/examples
sed -i 's/num_trees: 1000/num_trees: 5000/' config_splice.yaml
sed -i 's/num_splits: 3/num_splits: 5/' config_splice.yaml
sed -i 's/buffer_size: 1/buffer_size: 3/' config_splice.yaml

