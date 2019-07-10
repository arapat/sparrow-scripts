RUN_SPARROW="./sparrow/target/release/sparrow"
RUN_METRICS="./metricslib/target/release/run_metrics"

LOG_FILE="./training.log"
PREDICTION_LOG="./testing.log"

export RUST_LOG=sparrow=DEBUG,tmsn=DEBUG
export RUST_BACKTRACE=1

if [ "$#" -ne 1 ]; then
    echo "Wrong paramters. Usage: ./run-exp.sh <training-config-file>"
    exit
fi
CONFIG_FILE="$1"

if [[ ! -f $RUN_SPARROW ]]; then
    echo "sparrow does not exist. Terminated."
    exit
fi
if [[ ! -f $RUN_METRICS ]]; then
    echo "metricslib does not exist. Terminated."
    exit
fi

echo "Should I run training? (y/n)"
read proceed
if [ "$proceed" != "y" ]; then
    echo "Training is skipped."
else
    if [[ -d models ]]; then
        echo "./models exists. Should I remove it? (y/n)"
        read proceed
        if [ "$proceed" = "y" ]; then
            rm -rf ./models
            echo "./models Removed."
        fi
    fi

    mkdir -p models
    echo "Training the model. Logs are being written to $LOG_FILE."
    $RUN_SPARROW train $CONFIG_FILE 2> $LOG_FILE
    echo "Training done!"
fi
echo

if [ -f ./models_table.txt ]; then
    rm models_table.txt
fi
for filename in $( ls -rt models/model_*-v*.json ); do
    echo $filename >> models_table.txt
done

echo "Evaluating the models on the testing data..."
if ! $RUN_SPARROW test $CONFIG_FILE 2> $PREDICTION_LOG; then
    echo "Evaluation failed."
    cat $PREDICTION_LOG
    exit
fi

echo "All done."

