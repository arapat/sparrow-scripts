#!/usr/bin/env python3

# Incldue XGBoost in $PYTHONPATH:
# ```
#     export PYTHONPATH=~/xgboost/python-package:$PYTHONPATH
# ```

import math
import multiprocessing
import sys
import pickle
import yaml
import numpy as np
import xgboost as xgb
from datetime import datetime as dt
from time import time
from os.path import expanduser
from sklearn.metrics import auc
from sklearn.metrics import precision_recall_curve
from sklearn.metrics import roc_curve


if len(sys.argv) != 3:
    print("Wrong parameters. Usage: ./xgb.py <config-file> <disk|mem>")
    sys.exit()
with open(sys.argv[1]) as f:
    config = yaml.load(f.read())
on_disk = sys.argv[2].lower() == "disk"
trainingpath = config["training_filename"]
testingpath = config["testing_filename"]
thread = multiprocessing.cpu_count()
max_leaves = float(config["max_leaves"])
max_depth = math.ceil(math.log2(max_leaves))
rounds = int(config["num_iterations"])

# for performance
t0 = time()


def logger(s, show_time=False):
    if show_time:
        print("Current time: %.2f" % time())
    ts = time() - t0
    print("%s,%s" % (ts, s))
    sys.stdout.flush()


def log_time(t):
    logger("new tree,%d" % t.iteration)


def compute_ratio():
    sum_wpos = sum_wneg = 0.0
    with open(trainingpath) as f:
        for line in f:
            if line.strip()[0] == '0':
                sum_wneg += 1.0
            else:
                sum_wpos += 1.0
    return (sum_wpos, sum_wneg)


def run_xgb():
    # print weight statistics
    logger("Computing weight statistics")
    sum_wpos, sum_wneg = compute_ratio()
    logger('weight statistics: wpos=%g, wneg=%g, ratio=%g' % (sum_wpos, sum_wneg, sum_wpos / sum_wneg))

    # construct xgboost.DMatrix from numpy array
    if on_disk:
        logger('now loading in libsvm on disk')
        xgmat = xgb.DMatrix(trainingpath + "#dtrain.cache")
    else:
        logger('now loading in libsvm in memory')
        xgmat = xgb.DMatrix(trainingpath)
    logger('finish loading from libsvm')

    # setup parameters for xgboost
    param = {}
    # scale weight of positive examples
    param['scale_pos_weight'] = sum_wneg/sum_wpos
    # param['eta'] = 0.1
    param['max_depth'] = max_depth
    param['eval_metric'] = 'auc'
    # param['silent'] = 1
    param['nthread'] = thread
    # Optimize
    param['max_bin'] = 2
    param['tree_method'] = 'approx'
    param['lambda'] = 0.0

    watchlist = ()
    logger('loading data end, start to boost trees')

    logger("training xgboost", True)
    ts = time()
    plst = param.items()
    bst = xgb.train(plst, xgmat, rounds, watchlist, obj=expobj, callbacks=[log_time])
    duration = time() - ts
    logger("XGBoost %d rounds with %d thread costs: %.2f seconds" % (rounds, thread, duration))
    bst.save_model("xgb-r%d-t%d.model" % (rounds, thread))

    logger('quit running xgb')


def validate():
    # construct xgboost.DMatrix from numpy array
    bst = xgb.Booster({'nthread': thread})  # init model
    bst.load_model('xgb-r%d-t%d.model' % (rounds, thread))  # load data
    if on_disk:
        logger('now loading in testing libsvm on disk')
        dtest = xgb.DMatrix(testingpath + "#dtest.cache")
    else:
        logger('now loading in testing libsvm in memory')
        dtest = xgb.DMatrix(testingpath)
    logger('finished loading')

    # prediction
    logger('start prediction')
    true = []
    with open(testingpath) as f:
        for line in f:
            true.append(int(line.split(' ', 1)[0]))
    true = np.array(true)
    true = (true > 0) * 2 - 1
    for i in range(rounds):
        preds = bst.predict(dtest, ntree_limit=(i + 1))
        logger('finished prediction')

        # compute auprc
        scores = preds
        loss = np.mean(np.exp(-true * scores))
        precision, recall, _ = precision_recall_curve(true, scores, pos_label=1)
        # precision[-1] = np.sum(true > 0) / true.size  -- WHY?
        auprc = auc(recall, precision)
        fpr, tpr, _ = roc_curve(true, scores, pos_label=1)
        auroc = auc(fpr, tpr)
        logger("eval, {}, {}, {}, {}".format(i + 1, loss, auprc, auroc))


def expobj(preds, dtrain):
    labels = (dtrain.get_label() > 0) * 2 - 1  # Labels must be 1 or -1
    margin = labels * preds
    hess = np.exp(-margin)
    grad = -labels * hess
    return grad, hess


def main():
    logger("Program starts")
    run_xgb()
    validate()


if __name__ == '__main__':
    main()

