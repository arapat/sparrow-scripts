export SPARROW_REPO="https://github.com/arapat/sparrow.git"
export SPARROW_BRANCH="tmsn-stable"
export S3_BUCKET="tmsn-data"
export TMSN_REPO="https://github.com/arapat/tmsn.git"
export TMSN_BRANCH="master"
export METRICS_REPO="https://github.com/arapat/metricslib.git"
export SCRIPTS_REPO="https://github.com/arapat/sparrow-scripts.git"

export ENV="SPARROW_REPO=$SPARROW_REPO SPARROW_BRANCH=$SPARROW_BRANCH S3_BUCKET=$S3_BUCKET TMSN_REPO=$TMSN_REPO TMSN_BRANCH=$TMSN_BRANCH METRICS_REPO=$METRICS_REPO SCRIPTS_REPO=$SCRIPTS_REPO"

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
$SSH_COMMAND$sampler "$GIT_COMMAND; $ENV $SETUP_DIR/setup.sh $2 $3 $4 > /dev/null 2> /dev/null" &
for addr in "${scanners[@]}"
do
    echo "Setup the scanner" $addr
    $SSH_COMMAND$addr "$GIT_COMMAND; $ENV $SETUP_DIR/setup.sh nodata $3 $4 > /dev/null 2> /dev/null" &
done

echo "Waiting for the setup scripts to be finished"
wait

echo "Done."
