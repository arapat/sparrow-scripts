TEST_DATA="./small/bal_bathymetry-testing.libsvm"
PERFORMANCE_FILE="./performance.txt"

RUN_SPARROW="./sparrow/target/release/sparrow"
RUN_METRICS="./metricslib/target/release/run_metrics"

TRAINING_CONFIG_FILE="./sparrow/examples/config_small_bal_bathymetry.yaml"
TESTING_CONFIG_FILE="./sparrow/examples/config_testing_small_bal_bathymetry.yaml"
LOG_FILE="./bal_bathymetry_small.log"
PREDICTION_LOG="./scores.log"

if [[ ! -d sparrow ]]; then
    echo "./sparrow does not exist. Terminated."
    exit
fi
if [[ ! -d sparrow ]]; then
    echo "./sparrow does not exist. Terminated."
    exit
fi

echo "Should I proceed? (y/n)"
read proceed
if [ "$proceed" != "y" ]; then
    echo "Terminated."
    exit
fi

echo
echo "Training the model. Logs are being written to $LOG_FILE."
if [[ -d models ]]; then
    echo "./models exists. Should I remove it? (y/n)"
    read proceed
    if [ "$proceed" = "y" ]; then
        rm -rf ./models
        echo "./models Removed."
    fi
fi

mkdir -p models
$RUN_SPARROW train $TRAINING_CONFIG_FILE 2> $LOG_FILE
echo "Training done!"
echo

if [ -f ./models_table.txt ]; then
    rm models_table.txt
fi
for filename in $( ls -rt models/model_*-v*.json ); do
    echo $filename >> models_table.txt
done

echo "Evaluating the models on the testing data..."
if ! $RUN_SPARROW test $TESTING_CONFIG_FILE 2> $PREDICTION_LOG; then
    echo "Evaluation failed."
    exit
fi

echo "All done."

