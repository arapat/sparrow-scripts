
if [ "$#" -ne 4 ]; then
    echo "Wrong paramters. Usage: ./auto-setup.sh <identity_file> <dataset-name> <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY>"
    exit
fi

SETUP_DIR="/home/ubuntu/sparrow-scripts/setup"
SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i $1 ubuntu@"
GIT_COMMAND="git clone https://github.com/arapat/sparrow-scripts.git"
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
$SSH_COMMAND$sampler "$GIT_COMMAND; $SETUP_DIR/setup.sh $2 $3 $4 > /dev/null 2> /dev/null" &
for addr in "${scanners[@]}"
do
    echo "Setup the scanner" $addr
    $SSH_COMMAND$addr "$GIT_COMMAND; $SETUP_DIR/setup.sh nodata $3 $4 > /dev/null 2> /dev/null" &
done

echo "Waiting for the setup scripts to be finished"
wait

echo "Done."
