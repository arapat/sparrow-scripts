if [ "$#" -ne 1 ]; then
    echo "Wrong paramters. Usage: ./auto-run-exp.sh <identity_file>"
    exit
fi

mapfile -t servers < servers.txt
kill -9 $(ps aux | grep StrictHostKeyChecking |  awk '{print $2}')

sampler=${servers[0]}
scanners=("${servers[@]:1}")
scanners_list=""
for addr in "${scanners[@]}"
do
    scanners_list=$scanners_list", \""$addr"\""
done
scanners_list="["$(echo $scanners_list | sed -e "s/, //")"]"

SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i $1 ubuntu@"
echo "Kill existing trainings"
KILL_COMMAND="killall -9 sparrow"
$SSH_COMMAND$sampler "$KILL_COMMAND" &
for addr in "${scanners[@]}"
do
    $SSH_COMMAND$addr "$KILL_COMMAND" &
done

wait

echo "Done."
