import os

import boto3


def map_key_to_body(s3):
    def inner(key: str):
        obj = s3.Object(os.getenv('BUCKET'), key)
        read = obj.get()['Body'].read()
        return read.decode('utf-8')

    return inner


def s3_read(keys: str):
    s3 = boto3.resource('s3')

    return list(map(map_key_to_body(s3), keys))
