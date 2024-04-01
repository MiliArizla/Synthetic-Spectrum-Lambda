import json, os
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail

FROM_EMAIL = "sspswebsite@gmail.com"
TEMPLATE_ID = "d-c792dac8ad5940ee9075aaad5232821c"

sg = SendGridAPIClient(os.environ.get("SENDGRID_API_KEY"))

def handler(event, context):
    try:
        body = json.loads(event.body)
    except Exception as e:
        print(e.message)

    message = Mail(from_email=FROM_EMAIL, to_emails=body["email"])
    message.template_id = TEMPLATE_ID

    try:
        response = sg.send(message)

        print(response.status_code)
        print(response.headers)
        print(response.body)
    except Exception as e:
        print(e.message)