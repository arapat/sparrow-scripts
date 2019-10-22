
if [ "$#" -ne 3 ]; then
    echo "Wrong paramters. Usage: ./get-logs.sh <identity_file> <exp_name> <y|n for downloading models>"
    exit
fi

mapfile -t servers < servers.txt
export CREDENTIAL_PATH=$1
mkdir -p $2
cd $2

SAMPLER=${servers[0]}
SCANNERS=("${servers[@]:1}")

for i in "${!SCANNERS[@]}"; do
    let "j=i+1"
    scp -o "StrictHostKeyChecking=no" -i $CREDENTIAL_PATH ubuntu@${SCANNERS[$i]}:/mnt/training.log ./training-$j.log &
done

scp -o "StrictHostKeyChecking=no" -i $CREDENTIAL_PATH ubuntu@$SAMPLER:/mnt/training.log ./training-sampler.log &
scp -o "StrictHostKeyChecking=no" -i $CREDENTIAL_PATH ubuntu@$SAMPLER:/mnt/testing.log ./testing-sampler.log &
scp -o "StrictHostKeyChecking=no" -i $CREDENTIAL_PATH ubuntu@$SAMPLER:/mnt/models/performance.csv ./performance-sampler.csv &

if [ "$3" = "y" ]; then
    scp -o "StrictHostKeyChecking=no" -r -i ~/ddocuments/vault/aws/aws-brain.pem ubuntu@$SAMPLER:/mnt/models/ ./models &
fi

wait
echo "Done."
