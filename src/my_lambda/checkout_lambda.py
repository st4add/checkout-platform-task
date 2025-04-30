import json
import logging
from datetime import datetime
from zoneinfo import ZoneInfo
import random

logger = logging.getLogger()
logger.setLevel(logging.INFO)

FACTS = [
    "AWS is the biggest public cloud provider with 32% of the market share.",
    "In AWS Availability Zones map to different physical locations in different accounts.",
    "By 2025, there will be 200 zettabytes (a trillion gigabytes) of data in the world.",
    "50% of data will be stored in the cloud by 2025 (up from 25% in 2015)."
]

def lambda_handler(event, context):
    # Log the incoming event (helpful for debugging)
    logger.info("Received event: %s", event)

    # Current time in Europe/London timezone, no fractions
    now = datetime.now(ZoneInfo("Europe/London")).strftime("%H:%M:%S")
    fact = random.choice(FACTS)

    body = {
        "time": now,
        "fact": fact
    }

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json; charset=utf-8"
        },
        # ensure_unicode characters (em-dashes, smart quotes) aren’t escaped
        "body": json.dumps(body, ensure_ascii=False)
    }