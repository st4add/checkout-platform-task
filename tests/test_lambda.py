# tests/test_lambda.py
import json
import re
import pytest
from checkout_lambda import lambda_handler, FACTS

class DummyContext:
    function_name = "test"

def test_lambda_returns_time_and_fact():
    # Invoke with an empty event (GET / doesn’t require payload)
    response = lambda_handler({}, DummyContext())
    print("DEBUG RESPONSE →", response)

    # 1) Should return HTTP 200
    assert response["statusCode"] == 200

    # 2) Body must be valid JSON with time & fact
    body = json.loads(response["body"])
    assert "time" in body and "fact" in body

    # 3) Time matches HH:MM:SS (UTC only)
    assert re.match(r"^\d{2}:\d{2}:\d{2}$", body["time"])
        
    # 4) Fact must be one of our pre-defined FACTS
    assert body["fact"] in FACTS