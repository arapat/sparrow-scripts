if [ "$#" -ne 1 ]; then
    echo "Wrong paramters. Usage: ./auto-run-exp.sh <identity_file>"
    exit
fi

mapfile -t servers < servers.txt

sampler=${servers[0]}
scanners=("${servers[@]:1}")
scanners_list=""
for addr in "${scanners[@]}"
do
    scanners_list=$scanners_list", \""$addr"\""
done
scanners_list="["$(echo $scanners_list | sed -e "s/, //")"]"

SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i $1 ubuntu@"
SED_COMMAND="
    cd /mnt/sparrow; git reset --hard; \
    sed -i 's/num_iterations: 10/num_iterations: 100/' /mnt/sparrow/examples/config_splice.yaml; \
    sed -i 's/num_trees: 20/num_trees: 20/' /mnt/sparrow/examples/config_splice.yaml; \
    sed -i 's/max_depth: 2/max_depth: 2/' /mnt/sparrow/examples/config_splice.yaml; \
    sed -i 's/five-scanner/twenty-scanner/' /mnt/sparrow/examples/config_splice.yaml; \
    sed -i 's/resume-training: false/resume-training: false/' /mnt/sparrow/examples/config_splice.yaml;"

echo "Set up config splice"
$SSH_COMMAND$sampler "$SED_COMMAND \
     sed -i 's/network: \[\]/network: $scanners_list/' /mnt/sparrow/examples/config_splice.yaml; \
     sed -i 's/local_worker/sampler/' /mnt/sparrow/examples/config_splice.yaml; \
     sed -i 's/: sampler/: sampler/' /mnt/sparrow/examples/config_splice.yaml;" &
iter=0
for addr in "${scanners[@]}"
do
    iter=$(expr $iter + 1)
    $SSH_COMMAND$addr "$SED_COMMAND \
        sed -i 's/network: \[\]/network: \[\]/' /mnt/sparrow/examples/config_splice.yaml; \
        sed -i 's/local_worker/local_worker_$iter/' /mnt/sparrow/examples/config_splice.yaml;
        sed -i 's/: sampler/: scanner/' /mnt/sparrow/examples/config_splice.yaml;" &
done

wait

echo "Start training"
RUN_COMMAND="killall -9 sparrow; cd /mnt; ./sparrow-scripts/experiments/run-exp.sh ./sparrow/examples/config_splice.yaml y"
$SSH_COMMAND$sampler "$RUN_COMMAND" &
for addr in "${scanners[@]}"
do
    $SSH_COMMAND$addr "$RUN_COMMAND" &
done

wait

echo "Training is done."
