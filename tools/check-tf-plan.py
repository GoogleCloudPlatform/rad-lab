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
import sys
import json
import glob
import shutil
import requests
from python_terraform import Terraform

def main(PR):

    TOKEN             = os.getenv('GITHUB_TOKEN')
    GITHUB_WORKSPACE  = os.getenv('GITHUB_WORKSPACE')
    GITHUB_REPOSITORY = os.getenv('GITHUB_REPOSITORY')


    # Get Added / Modified files in PR
    modified_files, modified_files_raw, removed_files = pr_files(GITHUB_REPOSITORY, PR)

    # Get Working directories to run TF Plan on
    working_directories = get_updated_modules(modified_files, removed_files)

    # Loop through all the identified working directories
    # Deleting added/modified & removed files
    try:
        for dir in working_directories:
            print("----------> RUN FOR: " + dir)


            try:
                # IF MODULE EXISTS: Copying main directory in temp folder
                shutil.copytree(GITHUB_WORKSPACE+'/'+dir, os.getcwd()+'/temp/'+dir)

                # Deleting added/modified & removed files
                for mfile in modified_files:
                    if os.path.exists(os.getcwd()+'/temp/'+mfile):
                        print("Deleting file: " + mfile)
                        os.remove(os.getcwd()+'/temp/'+mfile)

                for rfile in removed_files:
                    if os.path.exists(os.getcwd()+'/temp/'+rfile):
                        print("Deleting file: " + rfile)
                        os.remove(os.getcwd()+'/temp/'+rfile)
            except:
                # IF MODULE DONOT EXISTS: Creating temp module folder
                os.makedirs(os.getcwd()+'/temp/'+dir)

    except requests.exceptions.RequestException as e: 
        print('No working directory with TF configs in PR.')
        raise SystemExit(e)

    # Loop through all the identified working directories
    # Download added/modified files
    try:
        for dir in working_directories:

            # Download added/modified files
            for file in modified_files:
        
                if dir in file:
                    for raw in modified_files_raw:

                        if file in raw:
                            print("Downloading file: " + raw)
                            downloadprfiles(raw, file, os.getcwd()+'/temp/'+os.path.dirname(file))
                            break

    except requests.exceptions.RequestException as e: 
        print('No working directory with TF configs in PR.')
        raise SystemExit(e)


    # Loop through all the identified working directories
    # Run Terraform Plan
    try:
        for dir in working_directories:

            # print('****************************')
            # print(glob.glob(os.getcwd() + '/temp/' + dir+'/*'))
            # print('****************************')
            # print(glob.glob(os.getcwd() + '/temp/' + dir+'/*/*'))

            # Running Terraform Init & Terraform Plan
            comment, status = tf(os.getcwd() + '/temp/' + dir)
            comment = comment + ' for: **' + dir + '** !'

            # Commenting on the PR
            commentpr(GITHUB_REPOSITORY, PR, comment, TOKEN)
            if(status == 'fail'):
                sys.exit('Terraform Init or Terraform Plan FAILED for: '+ dir)

    except requests.exceptions.RequestException as e: 
        print('No working directory with TF configs in PR.')
        raise SystemExit(e)

def pr_files(GITHUB_REPOSITORY,pr):
    removed_files = []
    modified_files = []
    modified_files_raw = []
    try:
        response = requests.get('https://api.github.com/repos/'+ GITHUB_REPOSITORY +'/pulls/'+ str(pr) +'/files')
        for file in response.json():
            if(file['status'] == 'removed'):
              print("Removed File: " + file['filename'])
              removed_files.append(file['filename'])
            else:
              print("Added/Modified File: " + file['filename'])
              modified_files.append(file['filename'])
              modified_files_raw.append(file['raw_url'])

        return modified_files, modified_files_raw, removed_files
    except requests.exceptions.RequestException as e: 
        raise SystemExit(e)  


def downloadprfiles(raw, file, path):

  # print(path)
  if not os.path.exists(path):
      os.makedirs(path)

  # print('Beginning file download with requests')
  r = requests.get(raw)
  with open(path + '/' + os.path.basename(file), 'wb') as f:
      f.write(r.content)

  # Retrieve HTTP meta-data
  # print(r.status_code)
  # print(r.headers['content-type'])
  # print(r.encoding)


def get_updated_modules(modified_files, removed_files):
  modified_files_dir = []
  removed_files_dir = []

  for file in modified_files:
    modified_files_dir.append(os.path.dirname(file))

  for file in removed_files:
    removed_files_dir.append(os.path.dirname(file))

  working_directories = modified_files_dir + removed_files_dir
  working_directories = list(set(working_directories))

#   print("Working Directories:")
#   print(working_directories)
  
  modules = [x for x in working_directories if x.startswith('modules/')]
  modules = [x for x in modules if x.count('/') == 1]
  print("Modules Updated:")
  print(modules)

  return modules


def tf(dir):
  tr = Terraform(working_dir=dir)

  return_code_init, stdout_init, stderr_init = tr.init_cmd(capture_output=False)
  return_code_plan, stdout_plan, stderr_plan = tr.plan_cmd(capture_output=False,var={'billing_account_id':'ABCD-EFGH-IJKL-MNOP', 'organization_id':'1234567890', 'random_id': '1234'})
  
  path = os.getcwd()+'/temp/'
  if(return_code_init == 1):
    comment = 'Terraform Init FAILED'
    status = 'fail'
  if(return_code_plan == 1):
    comment = 'Terraform Plan FAILED'
    status = 'fail'
  else: 
    comment = 'Terraform Init & Terraform Plan SUCCESSFUL'
    status = 'pass'
  
  return comment, status


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

  if len(sys.argv) != 2:
    raise SystemExit('No PR passed.')
  main(sys.argv[1])