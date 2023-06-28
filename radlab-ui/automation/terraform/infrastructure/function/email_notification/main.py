import json
from google.cloud import storage
from googleapiclient.errors import HttpError
from google.oauth2 import service_account
from googleapiclient.discovery import build
import google.auth
import os
import io
import functions_framework

import smtplib
import ssl
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from tabulate import tabulate


@functions_framework.cloud_event
def main(cloud_event):

    data = cloud_event.data

    deployment_id               = data["name"].split("/")[2]
    RADLABUI_DEPLOYMENT_BUCKET  = data["bucket"]
    output_file                 = f'deployments/{deployment_id}/output/output.json'
    variables_file              = f'deployments/{deployment_id}/files/terraform.tfvars.json'

    # creds = service_account.Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE)
    creds, _ = google.auth.default() #If you're using a cloud function directly

    if (blob_exists(creds, RADLABUI_DEPLOYMENT_BUCKET, output_file)):
        try:
            output_parsed_json = blob_contents(creds, RADLABUI_DEPLOYMENT_BUCKET, output_file)
            variables_parsed_json = blob_contents(creds, RADLABUI_DEPLOYMENT_BUCKET, variables_file)

            email_to = list(set(variables_parsed_json['owner_users'] + variables_parsed_json['trusted_users'] + variables_parsed_json['owner_groups'] + variables_parsed_json['trusted_groups']))

            # print("\n EMAIL TO:")
            # print(email_to)
            # print("\n OUTPUTS:")
            # print(type(output_parsed_json))
            # tabular_ouptputs = convert_dict_to_table(output_parsed_json)
            tabular_ouptputs = dict_to_html_table(output_parsed_json)

            # print(tabular_ouptputs)

            send_email(email_to, tabular_ouptputs, deployment_id)

            return "Ok"
        
        except HttpError as error:
            print(F'An error occurred: {error}')

    else:
        print(f'Outputs do not exist for RAD Lab deployment: {deployment_id}')


def blob_exists(creds, bucket, file):
    storage_client = storage.Client(credentials=creds)
    bucket = storage_client.get_bucket(bucket)
    blob = bucket.blob(file)
    return blob.exists()


def blob_contents(creds, bucket, file):
    storage_client = storage.Client(credentials=creds)
    bucket = storage_client.get_bucket(bucket)
    blob = bucket.blob(file)
    with io.BytesIO(blob.download_as_string()) as f:
        json_content = json.load(f)

    return json_content
    



def convert_dict_to_table(data):
    """Converts a dictionary into a table."""
    table_data = []
    for key, value in data.items():
        # print(key)
        # print(value['sensitive'])
        # print(value['type'])
        # print(value['value'])
        # table_data.append([key, value['sensitive'], value['type'], value['value']])
        table_data.append([key, value['value']])


    # headers = ["Key", "Sensitive", "Type", "Value"]
    headers = ["Key", "Value"]
    table = tabulate(table_data, headers, tablefmt="grid")

    return table


def dict_to_html_table(dictionary):
    table = "<table>\n"
    for key, value in dictionary.items():
        table += "  <tr>\n"
        table += f"    <td>{key}</td>\n"
        # table += f"    <td>{value['sensitive']}</td>\n"
        # table += f"    <td>{value['type']}</td>\n"
        table += f"    <td>{value['value']}</td>\n"
        table += "  </tr>\n"
    table += "</table>"
    return table


def send_email(email_to, tabular_ouptputs, deployment_id):
    """Responds to any HTTP request.
    Args:
        request (flask.Request): HTTP request object.
    Returns:
        The response text or any set of values that can be turned into a
        Response object using
        `make_response <http://flask.pocoo.org/docs/1.0/api/#flask.Flask.make_response>`.
    """
    gmail_user = 'gpsdemofactory@gmail.com'
    gmail_password = 'kltvxttqedzvsjdq'

    gmail_user = 'YOUR_GMAIL_USERNAME'
    gmail_password = 'YOUR_GMAIL_APPLICATION_PASSWORD'

    sent_from = gmail_user
    to = email_to

    msg = MIMEMultipart('alternative')
    msg['Subject'] = "RAD Lab Module is Ready!"
    msg['From'] = gmail_user
    msg['To'] = ", ".join(to)

    html = f"""\nHello! RAD Lab Module has been successfully deployed for you!\n
    Please use below output details to access the same:\n
    {tabular_ouptputs}"""
    
    # msg.attach(MIMEText(text, 'plain'))
    msg.attach(MIMEText(html, 'html'))
    
    context = ssl.create_default_context()
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.ehlo()
    server.starttls(context=context)
    server.login(gmail_user, gmail_password)
    # server.sendmail(sent_from, to, msg)

    server.sendmail(sent_from, to, msg.as_string())

    server.close()
    print(deployment_id + ': Email sent (print)!')
    return f'Email sent (return)!'

if __name__ == '__main__':
    main()