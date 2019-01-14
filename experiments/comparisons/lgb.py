#!/usr/bin/env python3
# coding: utf-8
import sys
import pickle
import yaml
import lightgbm as lgb
import multiprocessing
import numpy as np
from sklearn.metrics import auc
from sklearn.metrics import precision_recall_curve
from sklearn.metrics import roc_curve
from time import time

if len(sys.argv) != 2:
    print("Wrong parameters. Usage: ./xgb.py <config-file>")
    sys.exit()
with open(sys.argv[1]) as f:
    config = yaml.load(f.read())
trainingpath = config["training_filename"]
testingpath = config["testing_filename"]
num_leaves = config["max_leaves"]
rounds = int(config["num_iterations"])
thread = multiprocessing.cpu_count()
max_bin = int(config["max_bin_size"])

# for performance
t0 = time()


def logger(s, show_time=False):
    if show_time:
        print("Current time: %.2f" % time())
    print("[%.5f] %s" % (time() - t0, s))
    sys.stdout.flush()


def print_ts(period=1):
    """Create a callback that prints the tree is generated.

    Parameters
    ----------
    period : int, optional (default=1)
        The period to print the evaluation results.

    Returns
    -------
    callback : function
        The callback that prints the evaluation results every ``period`` iteration(s).
    """
    def callback(env):
        """internal function"""
        if period > 0 and (env.iteration + 1) % period == 0:
            logger('Tree %d' % (env.iteration + 1))
    callback.order = 10
    return callback


def train_lgb():
    logger('Load data...')
    train_data = lgb.Dataset(trainingpath)

    # specify your configurations as a dict
    sum_wpos = sum_wneg = 0.0
    with open(trainingpath) as f:
        for line in f:
            if line.strip()[0] == '0':
                sum_wneg += 1.0
            else:
                sum_wpos += 1.0
    params = {
        'objective': 'binary',
        'boosting_type': 'goss',  # 'goss',
        'max_bin': max_bin,
        'num_leaves': num_leaves,
        'learning_rate': 0.3,
        'tree_learner': 'voting',  # 'serial'
        'task': 'train',
        'num_thread': thread,
        'min_data_in_leaf': 5000,  # This is min bound for stopping rule in Sparrow
        'two_round': False,
        # 'is_unbalance': True,
        'scale_pos_weight': sum_wneg / sum_wpos,
    }

    logger('Start training...')
    gbm = lgb.train(params, train_data, num_boost_round=rounds, fobj=expobj, callbacks=[print_ts()])
    logger('Training completed.')

    # save model to file
    gbm.save_model('model.txt')

    with open('model.pkl', 'wb') as fout:
        pickle.dump(gbm, fout)


def validate():
    logger('Load data...')
    testing_path = testingpath
    with open(testing_path) as f:
        true = np.array([int(line.split(' ', 1)[0]) for line in f])
    true = (true > 0) * 2 - 1

    # load model with pickle to predict
    with open('model.pkl', 'rb') as fin:
        pkl_bst = pickle.load(fin)

    # can predict with any iteration when loaded in pickle way
    for i in range(rounds):
        preds = pkl_bst.predict(testing_path, num_iteration=(i + 1))
        logger('finished prediction')

        # compute auprc
        scores = preds
        loss = np.mean(np.exp(-true * scores))
        precision, recall, _ = precision_recall_curve(true, scores, pos_label=1)
        # precision[-1] = np.sum(true > 0) / true.size
        auprc = auc(recall, precision)
        fpr, tpr, _ = roc_curve(true, scores, pos_label=1)
        auroc = auc(fpr, tpr)
        logger("eval, {}, {}, {}, {}".format(i + 1, loss, auprc, auroc))


def expobj(preds, dtrain):
    # Labels must be 1 or -1
    labels = ((dtrain.get_label() > 0) * 2 - 1).astype("float16")
    # margin = labels * preds
    # hess = np.exp(-margin)
    hess = np.exp(-labels * preds)
    # grad = -labels * hess
    return -labels * hess, hess


def main():
    logger("Program starts")
    # train_lgb()
    validate()


if __name__ == '__main__':
    main()
