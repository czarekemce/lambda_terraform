import boto3
import urllib.parse
import os

second_bucket = os.environ.get('SECOND_BUCKET')

s3_client = boto3.client('s3')

def handler_function(event, context):
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])
    first_bucket = event['Records'][0]['s3']['bucket']['name']
    try:
        response = s3_client.get_object(Bucket=first_bucket, Key=key)
        s3_client.copy_object(Bucket=second_bucket, CopySource={'Bucket': first_bucket, 'Key': key}, Key=key)
        print('Skopiowano')
    except Exception as e:
        print(e)