# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0

import boto3
import logging
from ctypes import *
import pandas as pd
import numpy as np
import argparse

from sklearn.model_selection import train_test_split
from sklearn.datasets import fetch_california_housing

parser = argparse.ArgumentParser()
parser.add_argument("--prefix", type=str, default="demodata")
parser.add_argument("--bucket", type=str, default="demobucket")
args = parser.parse_args()
prefix = args.prefix
bucket = args.bucket

def get_logger():
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    return logger

logger = get_logger()

if __name__ == "__main__":

    logger.info('we use the California housing dataset')
    print("we use the California housing dataset")
    # we use the California housing dataset
    data = fetch_california_housing()

    X_train, X_test, y_train, y_test = train_test_split(data.data, data.target, test_size=0.25, random_state=42
                                                        )

    trainX = pd.DataFrame(X_train, columns=data.feature_names)
    trainX["target"] = y_train

    testX = pd.DataFrame(X_test, columns=data.feature_names)
    testX["target"] = y_test

    train_df = trainX
    test_df = testX

    logger.info('Data is processed.')
    print('Data is processed.')

    from io import StringIO  # python3; python2: BytesIO
    s3_resource = boto3.resource('s3')

    csv_buffer = StringIO()
    train_df.to_csv(csv_buffer)
    s3_resource.Object(
        bucket, f'{prefix}/train/california_housing_train.csv').put(Body=csv_buffer.getvalue())

    csv_buffer = StringIO()
    test_df.to_csv(csv_buffer)
    s3_resource.Object(
        bucket, f'{prefix}/test/california_housing_test.csv').put(Body=csv_buffer.getvalue())

    print("Job done!")
    logger.info('Data is saved to S3.')
