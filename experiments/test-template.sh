
if [ "$#" -ne 2 ]; then
    echo "Wrong paramters. Usage: ./test-template.sh <training-config-file> <package-name>"
    exit
fi

CONFIG=$1

if [ "$2" = "sparrow" ]; then
    ./sparrow-scripts/experiments/run-exp.sh $CONFIG
else
if [ "$2" = "xgbm" ]; then
    ./sparrow-scripts/experiments/comparisons/xgbm.py $CONFIG > xgboost.log 2> xgb-error.log
else
if [ "$2" = "xgbd" ]; then
    ./sparrow-scripts/experiments/comparisons/xgbd.py $CONFIG > xgboost.log 2> xgb-error.log
else
if [ "$2" = "lgb" ]; then
    ./sparrow-scripts/experiments/comparisons/lgb.py $CONFIG > lightgbm.log 2> lgb-error.log
else
    echo "Wrong package parameter. Exit."
    exit 1
fi
fi
fi

