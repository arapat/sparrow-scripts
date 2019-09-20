
mapfile -t servers < servers.txt

sampler=${servers[0]}
scanners=("${servers[@]:1}")
SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i $1 ubuntu@"

echo "Start training"
RUN_COMMAND="/mnt/sparrow-scripts/experiments/run-exp.sh /mnt/sparrow/examples/config_splice.yaml y"
$SSH_COMMAND$sampler "$RUN_COMMAND" &
for addr in "${scanners[@]}"
do
    $SSH_COMMAND$addr "$RUN_COMMAND" &
done

wait

echo "Training is done."