import os
import json
import base64
import requests
from requests.auth import HTTPBasicAuth

HEADERS  = {"Content-Type": "application/json", "Accept": "application/json"}
ENDPOINT = os.environ["KINESIS_STREAM_ENDPOINT"]  # "https://caesar-staging.zooniverse.org/kinesis"
USERNAME = os.environ["KINESIS_STREAM_USERNAME"]
PASSWORD = os.environ["KINESIS_STREAM_PASSWORD"]

def lambda_handler(event, context):
  payloads = [json.loads(base64.b64decode(record["kinesis"]["data"])) for record in event["Records"]]
  dicts    = [payload for payload in payloads if should_send(payload)]

  if dicts:
    data = json.dumps({"payload": dicts})
    r = requests.post(ENDPOINT, auth=HTTPBasicAuth(USERNAME, PASSWORD), headers=HEADERS, data=data)
    r.raise_for_status()

def should_send(payload):
  return payload["source"] == "panoptes" and payload["type"] == "classification"
