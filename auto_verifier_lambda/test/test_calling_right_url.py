import json
import os
import unittest
import main
import s3_notification_to_path
from unittest import mock


class MockResponse:
    def __init__(self, status_code):
        self.status_code = status_code


class MockS3Body:
    @staticmethod
    def read():
        with open('test/fixtures/s3_object.txt', 'r') as file:
            return file.read().encode('utf-8')


class MockS3Obj:
    @staticmethod
    def get():
        return {'Body': MockS3Body()}


class MockS3Resource:
    @staticmethod
    def Object(s3_bucket, s3_key):
        assert s3_bucket == 'test-bucket', f's3 bucket = {s3_bucket} not test-bucket' \
                                                               f'-ses-store '
        assert s3_key == 'emails/bounces/showcase.miquido.cloud/qf1vvob9ablb0pipag6s1ohi92kutulrukpq7781', f's3 key = {s3_key} not emails/bounces/showcase.miquido.cloud/qf1vvob9ablb0pipag6s1ohi92kutulrukpq7781 '
        return MockS3Obj()


def mocked_requests_get(*args, **kwargs):
    return MockResponse(200)


def mocked_s3_resource(*args, **kwargs):
    return MockS3Resource()


class MyTestCase(unittest.TestCase):

    @mock.patch('boto3.resource', side_effect=mocked_s3_resource)
    @mock.patch('requests.get', side_effect=mocked_requests_get)
    def test_simple_increment(self, mock_get, mock_s3):
        os.environ['BUCKET'] = 'test-bucket'
        with open('test/fixtures/s3_notification.json', 'r') as file:
            s3_notification = file.read()

        json.loads(s3_notification)
        main.lambda_handler(json.loads(s3_notification), None)

        self.assertEqual(
            "https://email-verification.eu-west-1.amazonaws.com/?Context=497964514030&X-Amz-Date=20210831T115309Z&Identity.IdentityName=noreply%40showcase.miquido.cloud&X-Amz-Algorithm=AWS4-HMAC-SHA256&Identity.IdentityType=EmailAddress&X-Amz-SignedHeaders=host&X-Amz-Credential=AKIAIR3TZ2R6DJQ4TMAA%2F20210831%2Feu-west-1%2Fses%2Faws4_request&Operation=ConfirmVerification&Namespace=Bacon&X-Amz-Signature=5f0936557070c31f9a8cd97cf7133300b412035c2e4edde74cdbde29c0bda1ec",
            mock_get.call_args[0][0])
