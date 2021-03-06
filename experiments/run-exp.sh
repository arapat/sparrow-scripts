export RUST_BACKTRACE=1
RUN_SPARROW="./sparrow/target/release/sparrow"
RUN_METRICS="./metricslib/target/release/run_metrics"

LOG_FILE="./training.log"
PREDICTION_LOG="./testing.log"

export RUST_LOG=sparrow=DEBUG,tmsn=DEBUG
export RUST_BACKTRACE=1

if [ "$#" -ne 2 ]; then
    echo "Wrong paramters. Usage: ./run-exp.sh <training-config-file> <y|n>"
    exit
fi
CONFIG_FILE="$1"
MACHINE_NAME=$(grep local_name $CONFIG_FILE | sed 's/local_name: //')

if [[ ! -f $RUN_SPARROW ]]; then
    echo "sparrow does not exist. Terminated."
    exit
fi
if [[ ! -f $RUN_METRICS ]]; then
    echo "metricslib does not exist. Terminated."
    exit
fi

if [ "$2" != "y" ]; then
    echo "Should I run training? (y/n)"
    read proceed
else
    proceed="y"
fi
if [ "$proceed" != "y" ]; then
    echo "Training is skipped."
else
    if [[ -d models ]]; then
        if [ "$2" != "y" ]; then
            echo "./models exists. Should I remove it? (y/n)"
            read proceed
        else
            proceed="y"
        fi
        if [ "$proceed" = "y" ]; then
            rm -rf ./models
            echo "./models Removed."
        fi
    fi

    mkdir -p models
    echo "Training the model. Logs are being written to $LOG_FILE."
    $RUN_SPARROW train $CONFIG_FILE 2> $LOG_FILE
    echo "$MACHINE_NAME: Training done!"
fi
echo

if grep -q "sampler_scanner: sampler" $CONFIG_FILE; then
    if [ -f ./models_table.txt ]; then
        if [ "$2" != "y" ]; then
            echo "./models_table.txt exists. Should I remove it? (y/n)"
            read proceed
        else
            proceed="y"
        fi
        if [ "$proceed" = "y" ]; then
            rm -f all_models_table.txt models_table.txt
            echo "./models_table.txt Removed."
        fi
    fi
    for filename in $( ls -rt models/model_*-v*.json ); do
        echo $filename >> all_models_table.txt
    done
    awk 'NR == 1 || NR % 10 == 0' all_models_table.txt > models_table.txt

    echo "Evaluating the models on the testing data..."
    if ! $RUN_SPARROW test $CONFIG_FILE 2> $PREDICTION_LOG; then
        echo "Evaluation failed."
        cat $PREDICTION_LOG
        exit
    fi
fi

echo "$MACHINE_NAME: All done."

