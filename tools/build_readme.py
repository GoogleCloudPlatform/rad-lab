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
import glob

def main():

    GITHUB_WORKSPACE  = os.getenv('GITHUB_WORKSPACE')
    GITHUB_REPOSITORY = os.getenv('GITHUB_REPOSITORY')
    WORKFLOW_EMAIL    = os.getenv('WORKFLOW_EMAIL')
    WORKFLOW_USERNAME = os.getenv('WORKFLOW_USERNAME')
    WORKFLOW_PAT      = os.getenv('WORKFLOW_PAT')

    # print(GITHUB_WORKSPACE)

    modules_dir = GITHUB_WORKSPACE + '/modules'

    for module in glob.glob(modules_dir + '/*'):

        # print(module)

        try:
            # run the tfdoc.py
            os.system('python3 tfdoc.py ' + module)

        except Exception as e:
            raise SystemExit(e)
    
    try: 
        # commit files
        os.system('git config --local user.email ' + WORKFLOW_EMAIL)
        os.system('git config --local user.name ' + WORKFLOW_USERNAME)
        os.system('git add -A')
        os.system('git commit -m "[WORKFLOW] Auto updating RAD-Lab Modules README.md" -a')

        remote_repo="https://"+WORKFLOW_USERNAME+":"+WORKFLOW_PAT+"@github.com/"+GITHUB_REPOSITORY+".git"

        # push changes
        os.system('git push ' + remote_repo + ' HEAD:main --force')

    except Exception as e:
        raise SystemExit(e)


if __name__ == '__main__':
    main()