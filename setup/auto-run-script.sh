
if [ "$#" -ne 1 ]; then
    echo "Wrong paramters. Usage: ./auto-setup.sh <identity_file>"
    exit
fi

SCP_COMMAND="scp -o StrictHostKeyChecking=no -i $1 script.sh ubuntu@"
SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i $1 ubuntu@"
oifs=$IFS # save a copy of the input field separator character list
IFS=$'\n' servers=( $(< servers.txt) )
IFS=$oifs

sampler=${servers[0]}
scanners=("${servers[@]:1}")

echo "Setup" $sampler
scp -o StrictHostKeyChecking=no -i $1 script.sh ubuntu@$sampler:script.sh &
for addr in "${scanners[@]}"
do
    echo "Setup the scanner" $addr
    $SCP_COMMAND$addr:. &
done
wait

echo "Start" $sampler
$SSH_COMMAND$sampler "bash /home/ubuntu/script.sh" &
for addr in "${scanners[@]}"
do
    echo "Start the scanner" $addr
    $SSH_COMMAND$addr "bash /home/ubuntu/script.sh" &
done

echo "Waiting for the scripts to be finished"
wait

echo "Done."
