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
import glob
import json
import shutil
import requests
import check_boilerplate


def main(PR):

    TOKEN             = os.getenv('GITHUB_TOKEN')
    GITHUB_REPOSITORY = os.getenv('GITHUB_REPOSITORY')

    if PR == 'All':

        response = open_pr(GITHUB_REPOSITORY)

        # Looping through all Open PRs
        for pr in response.json():
            
            commentcheck = prcommentcheck(GITHUB_REPOSITORY, pr['number'])
            licensecheck(GITHUB_REPOSITORY, TOKEN, pr['number'],commentcheck)        

    else: 
        print('Manual License check for: ' + PR)
        licensecheck(GITHUB_REPOSITORY, TOKEN, int(PR),'false') 


def open_pr(GITHUB_REPOSITORY):
    print('Fetching open PRs...')
    try:
        response = requests.get('https://api.github.com/repos/'+ GITHUB_REPOSITORY +'/pulls')
        return response
    except requests.exceptions.RequestException as e: 
        raise SystemExit(e)


def licensecheck(GITHUB_REPOSITORY, TOKEN, pr, commentcheck):   

    # If commentcheck = 'false' i.e. License check has not run on the PR before.
    if(commentcheck == 'false'):
    # if(checkmindiff(pr['created_at']) and commentcheck == 'false'):

        print('PR # ' + str(pr) + ' : Run Licence check...')
        
        # Get all pr files
        prfiles = pr_files(GITHUB_REPOSITORY,pr)

        # Download all prf files locally into ./tools/temp/ folder in the same directory structure
        downloadprfiles(prfiles)

        print(os.getcwd()+'/temp')
        print(glob.glob(os.getcwd()+'/temp/*'))
        print(glob.glob(os.getcwd()+'/temp/*/*'))
        print(glob.glob(os.getcwd()+'/temp/*/*/*'))

        # Run lisence check on the downloaded files in temp directory
        pr_no_license_files = boilerplate(os.getcwd()+'/temp')

        # Delete temp directory and its contents
        shutil.rmtree(os.getcwd()+'/temp')

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


def boilerplate(local_temp):
    pr_no_license_files = []
    allfiles = check_boilerplate.main(local_temp)
    for x in range(len(allfiles)):
        pr_no_license_files.append(allfiles[x].replace(local_temp+'/', ""))
    # print(pr_no_license_files)
    return pr_no_license_files

def pr_files(GITHUB_REPOSITORY,pr):
    pr_files = []
    try:
        response = requests.get('https://api.github.com/repos/'+ GITHUB_REPOSITORY +'/pulls/'+ str(pr) +'/files')
        for file in response.json():
            if(file['status'] != 'removed'):
                pr_files.append(file)
            else:
                continue
        # print(pr_files)
        return pr_files

    except requests.exceptions.RequestException as e: 
        raise SystemExit(e)    

def downloadprfiles(prfiles):
    for file in prfiles:
        # print('Create Temp Directory')
        path = os.path.dirname(file['filename'])
        path = os.getcwd() + '/temp/' + path
        # print(path)

        if not os.path.exists(path):
            os.makedirs(path)

        # print('Beginning file download with requests')
        r = requests.get(file['raw_url'])

        with open(path + '/' + os.path.basename(file['filename']), 'wb') as f:
            f.write(r.content)

        # # Retrieve HTTP meta-data
        # print(r.status_code)
        # print(r.headers['content-type'])
        # print(r.encoding)


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