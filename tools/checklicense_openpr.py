#!/usr/bin/env python3

# Copyright 2021 Google LLC
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
import sys
import json
import requests
# import datetime
import check_boilerplate
from pprint import pprint
# import dateutil.parser
from pytz import timezone

# IGNOREPRABOVEMINUTES = 5

def main(PR):

    TOKEN             = os.getenv('GITHUB_TOKEN')
    GITHUB_WORKSPACE  = os.getenv('GITHUB_WORKSPACE')
    GITHUB_REPOSITORY = os.getenv('GITHUB_REPOSITORY')

    if PR == 'All':

        response = open_pr(GITHUB_REPOSITORY)

        # Looping through all Open PRs
        for pr in response.json():
            
            commentcheck = prcommentcheck(GITHUB_REPOSITORY, pr['number'])

            licensecheck(GITHUB_REPOSITORY,GITHUB_WORKSPACE, TOKEN, pr['number'],commentcheck)        

    else: 
        print('Manual License check for: ' + PR)
        licensecheck(GITHUB_REPOSITORY,GITHUB_WORKSPACE, TOKEN, int(PR),'false') 


def open_pr(GITHUB_REPOSITORY):
    print('Fetching open PRs...')
    try:
        response = requests.get('https://api.github.com/repos/'+ GITHUB_REPOSITORY +'/pulls')
        return response
    except requests.exceptions.RequestException as e: 
        raise SystemExit(e)


def licensecheck(GITHUB_REPOSITORY,GITHUB_WORKSPACE, TOKEN, pr, commentcheck):   

    # If commentcheck = 'false' i.e. License check has not run on the PR before.
    if(commentcheck == 'false'):
    # if(checkmindiff(pr['created_at']) and commentcheck == 'false'):
        print('PR # ' + str(pr) + ' : Run Licence check...')
        
        prfiles = pr_files(GITHUB_REPOSITORY,pr)
        all_no_license_files = boilerplate(GITHUB_WORKSPACE)
        pr_no_license_files = list(set.intersection(set(prfiles), set(all_no_license_files)))

        # print(files)
        if pr_no_license_files:
            comment = '<!-- Boilerplate Check -->\nApache 2.0 License check failed!\n\nThe following files are missing the license boilerplate:\n'
            for x in range(len(pr_no_license_files)):
                # print (files[x])
                comment = comment + '\n' + pr_no_license_files[x]
        else:
            comment = '<!-- Boilerplate Check -->\nApache 2.0 License check successful!'

        # comment PR
        commentpr(GITHUB_REPOSITORY, pr, comment, TOKEN)

    else:
        print('PR # ' + str(pr) + ' : Skip Licence check...')

# def checkmindiff(pr_created_at):
#     now = datetime.datetime.now().astimezone(timezone('America/Los_Angeles'))
#     now = now.replace(microsecond=0)
#     # print(now)
#     d1 = dateutil.parser.parse(pr_created_at).astimezone(timezone('America/Los_Angeles'))
#     # print(d1)
#     # print(now - d1)
#     minutes = (now - d1).total_seconds() / 60
#     # print(minutes)
#     if(minutes <= IGNOREPRABOVEMINUTES):
#         return True
#     else:
#         return False

def prcommentcheck(GITHUB_REPOSITORY, pr):
    print('Checking if the License check has already ran...')
    try:
        status = 'false'
        response = requests.get('https://api.github.com/repos/'+ GITHUB_REPOSITORY +'/issues/'+ str(pr) +'/comments')
        for comment in response.json():
            body = comment['body']
            if(body.startswith('<!-- Boilerplate Check -->')):
                # print(body)
                status = 'true'
                break
        return status
    except requests.exceptions.RequestException as e: 
        raise SystemExit(e)


def boilerplate(GITHUB_WORKSPACE):
    all_no_license_files = []
    allfiles = check_boilerplate.main(GITHUB_WORKSPACE)
    # print(files)
    for x in range(len(allfiles)):
        all_no_license_files.append(allfiles[x].replace(GITHUB_WORKSPACE+'/', ""))
    # print(all_no_license_files)
    return all_no_license_files

def pr_files(GITHUB_REPOSITORY,pr):
    pr_files = []
    try:
        response = requests.get('https://api.github.com/repos/'+ GITHUB_REPOSITORY +'/pulls/'+ str(pr) +'/files')
        for file in response.json():
            if(file['status'] != 'removed'):
                pr_files.append(file['filename'])
            else:
                continue
        # print(pr_files)
        return pr_files
    except requests.exceptions.RequestException as e: 
        raise SystemExit(e)    

def commentpr(GITHUB_REPOSITORY, pr, comment, TOKEN):
    headers = {'Authorization': f'token {TOKEN}', 'Accept': 'application/vnd.github.v3+json'}
    # print(comment)
    data = {"body":comment}
    try:
        response  = requests.post('https://api.github.com/repos/'+ GITHUB_REPOSITORY +'/issues/'+ str(pr) +'/comments', data=json.dumps(data), headers=headers)
        # print(response.text)
    except requests.exceptions.RequestException as e: 
        raise SystemExit(e)


if __name__ == '__main__':

    if len(sys.argv) == 2:
        main(sys.argv[1])
    else:
        main('All')