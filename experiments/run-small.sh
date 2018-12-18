TEST_DATA="./small/bal_bathymetry-testing.libsvm"
PERFORMANCE_FILE="./performance.txt"

RUN_SPARROW="./sparrow/target/release/sparrow"
RUN_METRICS="./metricslib/target/release/run_metrics"

TRAINING_CONFIG_FILE="./sparrow/examples/config_small_bal_bathymetry.yaml"
TESTING_CONFIG_FILE="./sparrow/examples/config_testing_small_bal_bathymetry.yaml"
LOG_FILE="./bal_bathymetry_small.log"
PREDICTION_LOG="./scores.log"


echo "Listing the files and folders in current path:"
echo "------------------------------------------------------------"
ls
echo "------------------------------------------------------------"
echo
echo "There should be three folders listed: ./sparrow, ./metricslib, and ./data"
echo "Should I proceed? (y/n)"
read proceed

if [ "$proceed" != "y" ]; then
    echo "Terminated."
fi

echo
echo "Training the model. Logs are being written to $LOG_FILE."
$RUN_SPARROW train $TRAINING_CONFIG_FILE 2> $LOG_FILE
echo "Done!"
echo

mkdir -p models
for filename in $( ls -rt model-v* ); do
    echo models/$filename >> models_table.txt
done
mv model-v*.json models

echo "Evaluating the models on the testing data..."
$RUN_SPARROW test $TESTING_CONFIG_FILE 2> $PREDICTION_LOG

echo "Computing the performance scores..."
POSITIVE="1"
for score_file in $( ls -rt models/model-v*_scores ); do
    echo $score_file, $($RUN_METRICS --test $TEST_DATA --scores $score_file --positive $POSITIVE) >> $PERFORMANCE_FILE
done
echo "All done."


