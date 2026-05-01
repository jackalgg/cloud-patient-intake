import json
import os
import uuid
from datetime import datetime, timezone

import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])


def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body") or "{}")

        required = ["name", "email", "reason"]
        missing = [field for field in required if not body.get(field)]

        if missing:
            return response(400, {"error": f"Missing fields: {', '.join(missing)}"})

        item = {
            "id": str(uuid.uuid4()),
            "name": body["name"],
            "email": body["email"],
            "reason": body["reason"],
            "created_at": datetime.now(timezone.utc).isoformat(),
        }

        table.put_item(Item=item)

        return response(201, {"message": "Intake submitted", "id": item["id"]})

    except Exception as exc:
        print(f"Unhandled error: {exc}")
        return response(500, {"error": "Internal server error"})


def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "OPTIONS,POST",
        },
        "body": json.dumps(body),
    }