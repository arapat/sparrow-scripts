
if [ "$#" -ne 1 ]; then
    echo "Wrong paramters. Usage: ./auto-setup.sh <identity_file>"
    exit
fi

SCP_COMMAND="scp -o StrictHostKeyChecking=no -i $1 ubuntu@"
SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i $1 ubuntu@"
oifs=$IFS # save a copy of the input field separator character list
IFS=$'\n' servers=( $(< servers.txt) )
IFS=$oifs

sampler=${servers[0]}
scanners=("${servers[@]:1}")

# echo "Setup" $sampler
# scp -o StrictHostKeyChecking=no -i $1 script.sh ubuntu@$sampler:script.sh &
ITER=0
for addr in "${scanners[@]}"
do
    echo "Setup the scanner" $addr
    ITER=$(expr $ITER + 1)
    $SCP_COMMAND$addr:/mnt/sparrow/log2.txt logs/log-scanner-$ITER.txt &
done
wait
exit

echo "Done."
