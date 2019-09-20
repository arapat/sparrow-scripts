if [ "$#" -ne 1 ]; then
    echo "Wrong paramters. Usage: ./auto-run-exp.sh <identity_file>"
    exit
fi

mapfile -t servers < servers.txt

sampler=${servers[0]}
scanners=("${servers[@]:1}")
SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i $1 ubuntu@"

echo "Set up config splice"
$SSH_COMMAND$sampler \
    "sed -i 's/num_iterations: 10/num_iterations: 1000/' /mnt/sparrow/examples/config_splice.yaml" &
iter=0
for addr in "${scanners[@]}"
do
    iter=$(expr $iter + 1)
    $SSH_COMMAND$addr \
        "sed -i 's/num_iterations: 10/num_iterations: 1000/' /mnt/sparrow/examples/config_splice.yaml" &
done

wait

echo "Start training"
RUN_COMMAND="cd /mnt; ./sparrow-scripts/experiments/run-exp.sh ./sparrow/examples/config_splice.yaml y"
$SSH_COMMAND$sampler "$RUN_COMMAND" &
for addr in "${scanners[@]}"
do
    $SSH_COMMAND$addr "$RUN_COMMAND" &
done

wait

echo "Training is done."
