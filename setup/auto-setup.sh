
if [ "$#" -ne 4 ]; then
    echo "Wrong paramters. Usage: ./auto-setup.sh <identity_file> <dataset-name> <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY>"
    exit
fi

SETUP_DIR="/home/ubuntu/sparrow-scripts/setup"
SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i $1 ubuntu@"
mapfile -t servers < servers.txt

sampler=${servers[0]}
scanners=("${servers[@]:1}")
scanners_list=""
for addr in "${scanners[@]}"
do
    scanners_list=$scanners_list", \""$addr"\""
done
scanners_list="["$(echo $scanners_list | sed -e "s/, //")"]"

echo "Setup" $sampler
$SSH_COMMAND$sampler "$SETUP_DIR/setup.sh $2 $3 $4 > /dev/null 2> /dev/null" &
for addr in "${scanners[@]}"
do
    echo "Setup the scanner" $addr
    $SSH_COMMAND$addr "$SETUP_DIR/setup.sh nodata $3 $4 > /dev/null 2> /dev/null" &
done

echo "Waiting for the setup scripts to be finished"
wait

echo "Set up config splice"
$SSH_COMMAND$sampler \
    "sed -i 's/network: \[\]/network: $scanners_list/' /mnt/sparrow/examples/config_splice.yaml; \
     sed -i 's/local_worker/sampler/' /mnt/sparrow/examples/config_splice.yaml;
     sed -i 's/: sampler/: sampler/' /mnt/sparrow/examples/config_splice.yaml;
     sed -i 's/five-scanner/twenty-scanner/' /mnt/sparrow/examples/config_splice.yaml;
     sed -i 's/resume-training: false/resume-training: false/' /mnt/sparrow/examples/config_splice.yaml" &
iter=0
for addr in "${scanners[@]}"
do
    iter=$(expr $iter + 1)
    $SSH_COMMAND$addr \
        "sed -i 's/network: \[\]/network: \[\]/' /mnt/sparrow/examples/config_splice.yaml; \
        sed -i 's/local_worker/local_worker_$iter/' /mnt/sparrow/examples/config_splice.yaml;
        sed -i 's/: sampler/: scanner/' /mnt/sparrow/examples/config_splice.yaml;
        sed -i 's/five-scanner/twenty-scanner/' /mnt/sparrow/examples/config_splice.yaml;
        sed -i 's/resume-training: false/resume-training: false/' /mnt/sparrow/examples/config_splice.yaml" &
done

wait
echo "Done."