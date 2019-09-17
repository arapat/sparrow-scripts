## Deterministic
if [ "$1" = "sd" ]; then
CONFIG="./sparrow/examples/config_synthetic_det.yaml"
NUM_TREES=16
else if [ "$1" = "sp" ]; then
## Probabilistic
CONFIG="./sparrow/examples/config_synthetic_prob.yaml"
NUM_TREES=200
else if [ "$1" = "td" ]; then
## Tree Deterministic
CONFIG="./sparrow/examples/config_synthetic_tree_det.yaml"
NUM_TREES=32
else if [ "$1" = "tp" ]; then
## Tree Probabilistic
CONFIG="./sparrow/examples/config_synthetic_tree_prob.yaml"
DEPTH=2
NUM_TREES=100
else
    echo "Wrong experiment parameter. Exit."
    exit 1
fi
fi
fi
fi

CONFIG="./sparrow/examples/config_synthetic.yaml"
NUM_TREES=16


if [ "$2" = "sparrow" ]; then
    ./sparrow-scripts/experiments/run-exp.sh $CONFIG
else
if [ "$2" = "xgb" ]; then
    ./sparrow-scripts/experiments/comparisons/xgb.py $CONFIG mem > xgboost.log
else
    echo "Wrong package parameter. Exit."
    exit 1
fi
fi

