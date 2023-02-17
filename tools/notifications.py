#!/usr/bin/env python3

# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import json
import requests
from pprint import pprint
from requests.exceptions import URLRequired


def main():

    TOKEN             = os.getenv('GITHUB_TOKEN')
    WEBHOOK           = os.getenv('WEBHOOK') 
    GITHUB_REPOSITORY = os.getenv('GITHUB_REPOSITORY')

    response = open_issue(GITHUB_REPOSITORY)
    # pprint(response.json())
    
    try:
        for issue in response.json():

            commentcheck = issuecommentcheck(GITHUB_REPOSITORY, issue['number'])

            if(commentcheck == False):

                if ("pull_request") in issue.keys():
                    print("Pull Request: "+ str(issue['number']))
                    header = 'Pull Request'
                else:
                    print("Issue: "+ str(issue['number']))
                    header = 'Issue'
                
                labels = ''
                assignees = ''
                number = issue['number']
                title  = issue['title']
                user   = issue['user']['login']
                url    = issue['html_url']
                
                try:
                    for label in issue['labels']:
                        labels = labels + label['name'] + ','
                    labels = labels[:-1]
                except:
                    labels = ''

                try:
                    for assignee in issue['assignees']:
                        assignees = assignees + assignee['login'] + ','
                    assignees = assignees[:-1]
                except:
                    assignees = ''

                # print(number)
                # print(title)
                # print(user)
                # print(labels)
                # print(assignees)
                # print(url)

                rawdata = setdata(header, str(number), title, user, labels, assignees, url)
                # pprint(rawdata)

                try:
                    comment = sendmsg(WEBHOOK, rawdata)
                    if(comment != ''):
                        print('Message sent for: ' + str(issue['number']) + ' ! Commenting Issue ...')
                        commentissue(GITHUB_REPOSITORY, issue['number'], comment, TOKEN)
                    else:
                        print('Message not sent for: ' + str(issue['number']) + ' ! SKIPPING Commenting Issue...')
                except requests.exceptions.RequestException as e: 
                    raise SystemExit(e)
            else:
                print('Notifications already sent for: #' + str(issue['number']))

    except requests.exceptions.RequestException as e: 
        print("No Issue in the repo ")
        raise SystemExit(e)    

def open_issue(GITHUB_REPOSITORY):
    print('Fetching open Issues...')
    try:
        response = requests.get('https://api.github.com/repos/'+ GITHUB_REPOSITORY +'/issues')
        return response
    except requests.exceptions.RequestException as e: 
        raise SystemExit(e)    

def issuecommentcheck(GITHUB_REPOSITORY, number):
    print('Checking if the notification has already been sent...')
    try:
        status = False
        response = requests.get('https://api.github.com/repos/'+ GITHUB_REPOSITORY +'/issues/'+ str(number) +'/comments')
        for comment in response.json():
            body = comment['body']
            if(body.startswith('<!-- Notification Check -->')):
                # print(body)
                status = True
                break
        return status
    except requests.exceptions.RequestException as e: 
        raise SystemExit(e)

def setdata(header, number, title, user, labels, assignees, url):

    rawdata = {
        "cards": [
            {
                "header": {
                    "title": header + " Tracker",
                    "subtitle": header + " No: #"+number
                },
                "sections": [
                    {
                        "widgets": [
                            {
                                "keyValue": {
                                    "topLabel": "Creator",
                                    "content": user
                                },
                            },
                            {
                                "keyValue": {
                                    "topLabel": "Title",
                                    "content": title
                                }
                            },
                            {
                                "keyValue": {
                                    "topLabel": "Assigned Lables",
                                    "content": "- " + labels
                                }
                            },
                            {
                                "keyValue": {
                                    "topLabel": "Assignees",
                                    "content": "- " + assignees
                                }
                            },
                            {
                                "buttons": [
                                    {
                                        "textButton": {
                                            "text": "OPEN " + header,
                                            "onClick": {
                                                "openLink": {
                                                    "url": url
                                                }
                                            }
                                        }
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        ]
    }

    # print(type(rawdata))
    rawdata = json.dumps(rawdata)
    # print(type(rawdata))
    return rawdata

def sendmsg(WEBHOOK, rawdata):
    comment = ''
    headers = {'Content-Type': 'application/json'}
    try:
        response = requests.post(WEBHOOK, headers=headers, data=rawdata)
        comment = '<!-- Notification Check -->\nThank you for raising the request! RAD Lab admins have been notified.'
        # print(response.text)
    except requests.exceptions.RequestException as e: 
        print('ERROR: Error Occured posting a message on Webhook!')
        raise SystemExit(e)
    return comment

def commentissue(GITHUB_REPOSITORY, number, comment, TOKEN):
    headers = {'Authorization': f'token {TOKEN}', 'Accept': 'application/vnd.github.v3+json'}
    # print(comment)
    data = {"body":comment}
    try:
        response  = requests.post('https://api.github.com/repos/'+ GITHUB_REPOSITORY +'/issues/'+ str(number) +'/comments', data=json.dumps(data), headers=headers)
        # print(response.text)
    except requests.exceptions.RequestException as e: 
        raise SystemExit(e)

if __name__ == '__main__':
    main()