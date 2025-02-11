import json
import boto3
import string
import random

def lambda_handler(event, context):
    
    N = 10

    newPassword = ''.join(random.choices(string.ascii_uppercase + 
                                string.digits, k=N))

    client = boto3.client('secretsmanager')
 

    getRes = client.get_secret_value(
        SecretId = 'prod/lambda'
    )
    current_secrets = json.loads(getRes['SecretString'])
    
    current_secrets.update({
        "KEY_TO_ROTATE" : newPassword
    })
    
 
    
    response = client.put_secret_value(
        SecretId = 'prod/lambda',
        SecretString=str(json.dumps(current_secrets))
    )



