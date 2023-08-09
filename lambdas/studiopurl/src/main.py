import boto3
import json, logging, os

def lambda_handler(event, context):
  client = boto3.client('sagemaker')
  logging.debug(boto3.__version__)

  domain_id = os.environ.get('STUDIO_DOMAIN_ID')
  user_profile_name = event.get('profile_name', 'default-user') 

  response = client.create_presigned_domain_url(
    DomainId = domain_id,
    UserProfileName = user_profile_name,
    SessionExpirationDurationInSeconds = 43200, # 12 hours
    ExpiresInSeconds = 300 # 5 mins
  )

  return {
    'statusCode': 302,
    'headers': {
      'Location': response['AuthorizedUrl']
    }
  }
