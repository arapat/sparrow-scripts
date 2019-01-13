
if [ "$#" -ne 3 ]; then
    echo "Wrong paramters. Usage: ./test-template.sh <training-config-file> <mem/disk> <package-name>"
    exit
fi

CONFIG=$1
DISK_OR_MEM=$2

if [ "$3" = "sparrow" ]; then
    ./sparrow-scripts/experiments/run-exp.sh $CONFIG
else
if [ "$3" = "xgb" ]; then
    ./sparrow-scripts/experiments/comparisons/xgb.py $CONFIG $DISK_OR_MEM > xgboost.log 2> xgb-error.log
else
if [ "$3" = "lgb" ]; then
    ./sparrow-scripts/experiments/comparisons/lgb.py $CONFIG > lightgbm.log 2> lgb-error.log
else
    echo "Wrong package parameter. Exit."
    exit 1
fi
fi
fi

