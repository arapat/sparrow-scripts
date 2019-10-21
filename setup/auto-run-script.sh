
if [ "$#" -ne 1 ]; then
    echo "Wrong paramters. Usage: ./auto-setup.sh <identity_file>"
    exit
fi

SCP_COMMAND="scp -o StrictHostKeyChecking=no -i $1 script.sh ubuntu@"
SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i $1 ubuntu@"
mapfile -t servers < servers.txt

sampler=${servers[0]}
scanners=("${servers[@]:1}")

echo "Setup" $sampler
$SCP_COMMAND$sampler:.
$SSH_COMMAND$sampler "bash /home/ubuntu/script.sh" &
for addr in "${scanners[@]}"
do
    echo "Setup the scanner" $addr
    $SCP_COMMAND$addr:.
    $SSH_COMMAND$addr "bash /home/ubuntu/script.sh" &
done

echo "Waiting for the scripts to be finished"
wait

echo "Done."
