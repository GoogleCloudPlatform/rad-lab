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

#  PREREQ: installer_prereq.py

import os
import re
import sys
import json
import glob
import shutil
import string
import random
import requests
import argparse
import platform
import subprocess
from art import *
from os import path
from pprint import pprint
from google.cloud import storage
from googleapiclient import discovery
from colorama import Fore, Back, Style
from python_terraform import Terraform
from oauth2client.client import GoogleCredentials

ACTION_CREATE_DEPLOYMENT = "1"
ACTION_UPDATE_DEPLOYMENT = "2"
ACTION_DELETE_DEPLOYMENT = "3"
ACTION_LIST_DEPLOYMENT = "4"


def main(varcontents={}, module_name=None, action=None, projid=None, tfbucket=None, check=None):
    orgid = ""
    folderid = ""
    billing_acc = ""
    currentusr = ""

    setup_path = os.getcwd()

    # Setting "gcloud auth application-default" to deploy RAD Lab Modules
    currentusr = radlabauth(currentusr)

    # Setting up Project-ID
    projid = set_proj(projid)

    # Checking for User Permissions
    if check == True:
        launcherperm(projid, currentusr)

    # Listing / Selecting from available RAD Lab modules
    if module_name is None:
        module_name = list_modules()

    # Checking Module specific permissions
    if check == True:
        moduleperm(projid, module_name, currentusr)

    # Validating user input Terraform variables against selected module
    validate_tfvars(varcontents, module_name)

    # Select Action to perform
    if action is None or action == "":
        action = select_action().strip()

    # Setting up required attributes for any RAD Lab module deployment
    env_path, tfbucket, orgid, billing_acc, folderid, randomid = module_deploy_common_settings(action, module_name, setup_path, varcontents, projid, tfbucket)

    # Utilizing Terraform Wrapper for init / apply / destroy
    env(action, orgid, billing_acc, folderid, env_path, randomid, tfbucket, projid)

    print("\nGCS Bucket storing Terrafrom Configs: " + tfbucket + "\n")
    print("\nTERRAFORM DEPLOYMENT COMPLETED!!!\n")


def radlabauth(currentusr):
    try:
        token = subprocess.Popen(["gcloud auth application-default print-access-token"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL).stdout.read().strip().decode('utf-8')
        r = requests.get('https://www.googleapis.com/oauth2/v3/tokeninfo?access_token=' + token)
        currentusr = r.json()["email"]

        # Setting Credentials for non Cloud Shell CLI
        if (platform.system() != 'Linux' and platform.processor() != '' and not platform.system().startswith('cs-')):
            # countdown(5)

            # Adding Execution handling if GOOGLE_APPLICATION_CREDENTIALS is set to Empty.
            try:
                del os.environ['GOOGLE_APPLICATION_CREDENTIALS']
            except:
                pass

            x = input("\nWould you like to proceed the RAD Lab deployment with user - " + Fore.YELLOW + currentusr + Style.RESET_ALL + ' ?\n[1] Yes\n[2] No\n' + Fore.YELLOW + Style.BRIGHT + 'Choose a number : ' + Style.RESET_ALL).strip()
            if (x == '1'):
                pass
            elif (x == '2'):
                print("\nLogin with User account with which you would like to deploy RAD Lab Modules...\n")
                os.system("gcloud auth application-default login")
            else:
                currentusr = '0'

    except:
        # Adding Execution handling if GOOGLE_APPLICATION_CREDENTIALS is set to Empty.
        if (platform.system() != 'Linux' and platform.processor() != '' and not platform.system().startswith('cs-')):
            try:
                del os.environ['GOOGLE_APPLICATION_CREDENTIALS']
            except:
                pass
        print("\nLogin with User account with which you would like to deploy RAD Lab Modules...\n")
        os.system("gcloud auth application-default login")

    finally:
        if (currentusr == '0'):
            sys.exit(Fore.RED + "\nError Occured - INVALID choice.\n")
        else:
            token = subprocess.Popen(["gcloud auth application-default print-access-token"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL).stdout.read().strip().decode('utf-8')
            r = requests.get('https://www.googleapis.com/oauth2/v3/tokeninfo?access_token=' + token)
            currentusr = r.json()["email"]
            os.system("gcloud config set account " + currentusr)
            print(
                "\nUser to deploy RAD Lab Modules (Selected) : " + Fore.GREEN + Style.BRIGHT + currentusr + Style.RESET_ALL)
            return currentusr


def set_proj(projid):
    if projid is None:
        projid = os.popen("gcloud config list --format 'value(core.project)' 2>/dev/null").read().strip()
        if (projid != ""):
            select_proj = input("\nWhich Project would you like to use for RAD Lab management (Example - Creating/Utilizing GCS bucket where Terraform states will be stored) ? :" + "\n[1] Currently set project - " + Fore.GREEN + projid + Style.RESET_ALL + "\n[2] Enter a different Project ID" + Fore.YELLOW + Style.BRIGHT + "\nChoose a number for the RAD Lab management Project" + Style.RESET_ALL + ': ').strip()
            if (select_proj == '2'):
                projid = input(Fore.YELLOW + Style.BRIGHT + "Enter the Project ID" + Style.RESET_ALL + ': ').strip()
            elif (select_proj != '1' and select_proj != '2'):
                sys.exit(Fore.RED + "\nError Occured - INVALID choice.\n")
        else:
            projid = input(Fore.YELLOW + Style.BRIGHT + "\nEnter the Project ID for RAD Lab management" + Style.RESET_ALL + ': ').strip()
    else:
        pass

    os.system("gcloud config set project " + projid)
    os.system("gcloud auth application-default set-quota-project "  + projid )
    print("\nProject ID (Selected) : " + Fore.GREEN + Style.BRIGHT + projid + Style.RESET_ALL)

    return projid


def launcherperm(projid, currentusr):
    # Hardcoded Project level required RAD Lab Launcher roles
    launcherprojroles = ['roles/storage.admin', 'roles/serviceusage.serviceUsageConsumer']
    # Hardcoded Org level required RAD Lab Launcher roles
    launcherorgroles = ['roles/iam.organizationRoleViewer']

    credentials = GoogleCredentials.get_application_default()

    service0 = discovery.build('cloudresourcemanager', 'v3', credentials=credentials)
    request0 = service0.projects().getIamPolicy(resource='projects/' + projid)
    response0 = request0.execute()

    projiam = True
    for role in launcherprojroles:
        rolefound = False
        ownerrole = False
        for y in range(len(response0['bindings'])):
            # print("ROLE --->")
            # print(response0['bindings'][y]['role'])
            # print("MEMBERS --->")
            # print(response0['bindings'][y]['members'])

            # Check for Owner role on RAD Lab Management Project
            if (response0['bindings'][y]['role'] == 'roles/owner' and 'user:' + currentusr in response0['bindings'][y]['members']):
                rolefound = True
                ownerrole = True
                print("\n" + currentusr + " has roles/owner role for RAD Lab Management Project: " + projid)
                break
            # Check for Required roles on RAD Lab Management Project
            elif (response0['bindings'][y]['role'] == role):
                rolefound = True
                if ('user:' + currentusr not in response0['bindings'][y]['members']):
                    projiam = False
                    sys.exit(
                        Fore.RED + "\nError Occured - RADLAB LAUNCHER PERMISSION ISSUE | " + role + " permission missing...\n(Review https://github.com/GoogleCloudPlatform/rad-lab/tree/main/radlab-launcher#iam-permissions-prerequisites for more details)\n" + Style.RESET_ALL)
                else:
                    pass

        if rolefound == False:
            sys.exit(
                Fore.RED + "\nError Occured - RADLAB LAUNCHER PERMISSION ISSUE | " + role + " permission missing...\n(Review https://github.com/GoogleCloudPlatform/rad-lab/tree/main/radlab-launcher#iam-permissions-prerequisites for more details)\n" + Style.RESET_ALL)

        if (ownerrole == True):
            break

    if projiam == True:
        print(Fore.GREEN + '\nRADLAB LAUNCHER - Project Permission check passed' + Style.RESET_ALL)

    service1 = discovery.build('cloudresourcemanager', 'v3', credentials=credentials)
    request1 = service1.projects().get(name='projects/' + projid)
    response1 = request1.execute()

    if 'parent' in response1.keys():
        service2 = discovery.build('cloudresourcemanager', 'v3', credentials=credentials)
        org = findorg(response1['parent'])
        request2 = service2.organizations().getIamPolicy(resource=org)
        response2 = request2.execute()

        orgiam = True
        for role in launcherorgroles:
            rolefound = False
            for x in range(len(response2['bindings'])):
                # print("ROLE --->")
                # print(response2['bindings'][x]['role'])
                # print("MEMBERS --->")
                # print(response2['bindings'][x]['members'])
                if (role == response2['bindings'][x]['role']):
                    rolefound = True
                    if ('user:' + currentusr not in response2['bindings'][x]['members']):
                        orgiam = False
                        sys.exit(Fore.RED + "\nError Occured - RADLAB LAUNCHER PERMISSION ISSUE | " + role + " permission missing...\n(Review https://github.com/GoogleCloudPlatform/rad-lab/tree/main/radlab-launcher#iam-permissions-prerequisites for more details)\n" + Style.RESET_ALL)
                    else:
                        pass

            if rolefound == False:
                sys.exit(Fore.RED + "\nError Occured - RADLAB LAUNCHER PERMISSION ISSUE | " + role + " permission missing...\n(Review https://github.com/GoogleCloudPlatform/rad-lab/tree/main/radlab-launcher#iam-permissions-prerequisites for more details)\n" + Style.RESET_ALL)

        if orgiam == True:
            print(Fore.GREEN + '\nRADLAB LAUNCHER - Organization Permission check passed' + Style.RESET_ALL)
    else:
        print(Fore.YELLOW + '\nRADLAB LAUNCHER - Skipping Organization Permission check. No Organization associated with the project: ' + projid + Style.RESET_ALL)


def findorg(parent):
    if 'folders' in parent:
        credentials = GoogleCredentials.get_application_default()
        s = discovery.build('cloudresourcemanager', 'v3', credentials=credentials)
        req = s.folders().get(name=parent)
        res = req.execute()
        return findorg(res['parent'])
    else:
        # print(Fore.GREEN + "Org identified: " + Style.BRIGHT + parent + Style.RESET_ALL)
        return parent


def moduleperm(projid, module_name, currentusr):
    # Check if any of the org policy is used in orgpolicy.tf
    setorgpolicy = True
    try:
        ## Finding policy variables in orgpolicy.tf
        with open(os.path.dirname(os.getcwd()) + '/modules/' + module_name + '/orgpolicy.tf', "r") as file:
            policy_vars = []
            for line in file:
                if ('count' in line and 'var.' in line and '||' not in line):
                    policy_vars.append(line[line.find("var.") + len("var."):line.find("?")].strip())
        # print("Org Policy Variables:")
        # print(policy_vars)

        ## [CHECK 1] Checking for commented orgpolicy resource in orgpolicy.tf
        numCommentedOrgPolicy = 0
        for policy in policy_vars:
            with open(os.path.dirname(os.getcwd()) + '/modules/' + module_name + '/orgpolicy.tf', "r") as file:
                for line in file:
                    # Finding Org policy resource block
                    if ('count' in line and 'var.' + policy in line and '?' in line):
                        # Checking for commented resource block line
                        if (line.startswith('#') or line.startswith('//')):
                            numCommentedOrgPolicy = numCommentedOrgPolicy + 1

        # If No. of commented Org Policies are equal to total policies; No Org policy set
        if (numCommentedOrgPolicy == len(policy_vars)):
            setorgpolicy = False

        ## [CHECK 2] Checking if policy variables in variables.tf are set to 'false'
        numDisabledOrgPolicyVar = 0
        for var in policy_vars:
            varblock = ""
            block = False
            with open(os.path.dirname(os.getcwd()) + '/modules/' + module_name + '/variables.tf', "r") as file:
                for line in file:
                    if (var in line):
                        block = True
                    elif ('}' in line):
                        block = False

                    if (block == True):
                        varblock = varblock + line

            # print(varblock + '}')

            # Count number of disabled policies
            if ('false' in varblock.split('default')[1]):
                numDisabledOrgPolicyVar = numDisabledOrgPolicyVar + 1

        # If No. of disabled Org Policies are equal to total policies; No Org policy set
        if (numDisabledOrgPolicyVar == len(policy_vars)):
            setorgpolicy = False

        ## [CHECK 3] Checking if policy variables in variables.tf are commented
        numCommentedOrgPolicyVar = 0
        for var in policy_vars:
            with open(os.path.dirname(os.getcwd()) + '/modules/' + module_name + '/variables.tf', "r") as file:
                for line in file:
                    # Finding Org policy resource block
                    if ('variable' in line and policy in line):
                        # Checking for commented resource block line
                        if (line.startswith('#') or line.startswith('//') or line.startswith('/*')):
                            numCommentedOrgPolicyVar = numCommentedOrgPolicyVar + 1

        # If No. of commented Org Policies Variables are equal to total policies; No Org policy set
        if (numCommentedOrgPolicyVar == len(policy_vars)):
            setorgpolicy = False

    except:
        setorgpolicy = False

    # Check if reusing project
    create_project = True
    try:
        ## Finding 'create_project' variable in variables.tf
        varblock = ""
        block = False
        with open(os.path.dirname(os.getcwd()) + '/modules/' + module_name + '/variables.tf', "r") as file:
            for line in file:
                if ('create_project' in line):
                    block = True
                elif ('}' in line):
                    block = False

                if (block == True):
                    varblock = varblock + line

        # print(varblock + '}')
        if ('false' in varblock.split('default')[1]):
            create_project = False

    except Exception as e:
        print(e)

    print("\nSET ORG POLICY: " + str(setorgpolicy))
    print("CREATE PROJECT: " + str(create_project))

    # Scrape out Module specific permissions for the module
    try:
        with open(os.path.dirname(os.getcwd()) + '/modules/' + module_name + '/README.md', "r") as file:
            section = False
            orgroles = []
            projroles = []

            for line in file:
                if (line.startswith("## IAM Permissions Prerequisites")):
                    section = True

                # Identifying Roles if New Project is supposed to be created
                if (create_project == True):
                    if (section == True and line.startswith('- Parent: `')):
                        orgroles.append(re.search("\`(.*?)\`", line).group(1))
                    if (section == True and line.startswith('- Project: `')):
                        projroles.append(re.search("\`(.*?)\`", line).group(1))

                        # Identifying Roles if Reusing any Existing project
                else:
                    if (section == True and (line.startswith('- `') or line.startswith('- `'))):
                        projroles.append(re.search("\`(.*?)\`", line).group(1))

                if (line.startswith('#') and not line.startswith("## IAM Permissions Prerequisites")):
                    section = False

        # Removing optional role 'roles/orgpolicy.policyAdmin' if Org Policy is not set
        if (setorgpolicy == False and 'roles/orgpolicy.policyAdmin' in orgroles):
            orgroles.remove('roles/orgpolicy.policyAdmin')

    except:
        print(Fore.RED + 'IAM Permissions Prerequisites are missing in the README.md or the README.md file do not exisits for module : ' + module_name + Style.RESET_ALL)

    # Check Module permissions permission
    credentials = GoogleCredentials.get_application_default()
    service = discovery.build('cloudresourcemanager', 'v3', credentials=credentials)

    # Check Project level permissions
    if len(projroles) != 0:
        # print("Project Roles to check:")
        # print(projroles)
        # print("/*************** PROJECT IAM POLICY *************/")
        request1 = service.projects().getIamPolicy(resource='projects/' + projid)
        response1 = request1.execute()
        projiam = True

        for role in projroles:
            rolefound = False
            for y in range(len(response1['bindings'])):
                # print("ROLE --->")
                # print(response1['bindings'][y]['role'])
                # print("MEMBERS --->")
                # print(response1['bindings'][y]['members'])
                if (role == response1['bindings'][y]['role']):
                    rolefound = True
                    if ('user:' + currentusr not in response1['bindings'][y]['members']):
                        projiam = False
                        sys.exit(Fore.RED + "\nError Occured - RADLAB MODULE PERMISSION ISSUE | " + role + " permission missing...\n(Review https://github.com/GoogleCloudPlatform/rad-lab/tree/main/modules/" + module_name + "#iam-permissions-prerequisites for more details)\n" + Style.RESET_ALL)
                    else:
                        pass

            if rolefound == False:
                sys.exit(Fore.RED + "\nError Occured - RADLAB MODULE PERMISSION ISSUE | " + role + " permission missing...\n(Review https://github.com/GoogleCloudPlatform/rad-lab/tree/main/modules/" + module_name + "#iam-permissions-prerequisites for more details)\n" + Style.RESET_ALL)

        if projiam == True:
            print(Fore.GREEN + '\nRADLAB MODULE (' + module_name + ')- Project Permission check passed' + Style.RESET_ALL)

    # Check Org level permissions 
    if len(orgroles) != 0:
        # print("Org Roles to check:")
        # print(orgroles)
        request = service.projects().get(name='projects/' + projid)
        response = request.execute()

        if 'parent' in response.keys():
            # print("/*************** ORG IAM POLICY *************/")
            org = findorg(response['parent'])
            request2 = service.organizations().getIamPolicy(resource=org)
            response2 = request2.execute()
            # pprint(response2)
            orgiam = True
            for role in orgroles:
                rolefound = False
                for x in range(len(response2['bindings'])):
                    # print("ROLE --->")
                    # print(response2['bindings'][x]['role'])
                    # print("MEMBERS --->")
                    # print(response2['bindings'][x]['members'])

                    if (role == response2['bindings'][x]['role']):
                        rolefound = True
                        if ('user:' + currentusr not in response2['bindings'][x]['members']):
                            orgiam = False
                            sys.exit(Fore.RED + "\nError Occured - RADLAB MODULE (" + module_name + ") PERMISSION ISSUE | " + role + " permission missing...\n(Review https://github.com/GoogleCloudPlatform/rad-lab/tree/main/modules/" + module_name + "#iam-permissions-prerequisites for more details)\n" + Style.RESET_ALL)
                        else:
                            pass

                if rolefound == False:
                    sys.exit(Fore.RED + "\nError Occured - RADLAB MODULE (" + module_name + ") PERMISSION ISSUE | " + role + " permission missing...\n(Review https://github.com/GoogleCloudPlatform/rad-lab/tree/main/modules/" + module_name + "#iam-permissions-prerequisites for more details)\n" + Style.RESET_ALL)

            if orgiam == True:
                print(Fore.GREEN + '\nRADLAB MODULE (' + module_name + ') - Organization Permission check passed' + Style.RESET_ALL)
        else:
            print(Fore.YELLOW + '\nRADLAB LAUNCHER - Skipping Organization Permission check. No Organization associated with the project: ' + projid + Style.RESET_ALL)


def env(action, orgid, billing_acc, folderid, env_path, deployment_id, tfbucket, projid):
    tr = Terraform(working_dir=env_path)
    return_code, stdout, stderr = tr.init_cmd(capture_output=False)

    if (action == ACTION_CREATE_DEPLOYMENT or action == ACTION_UPDATE_DEPLOYMENT):
        return_code, stdout, stderr = tr.apply_cmd(capture_output=False, auto_approve=True, var={'organization_id': orgid, 'billing_account_id': billing_acc, 'deployment_id': deployment_id})
        return_code, stdout, stderr = tr.apply_cmd(refresh=True, capture_output=False, auto_approve=True, var={'organization_id': orgid, 'billing_account_id': billing_acc, 'deployment_id': deployment_id})

    elif (action == ACTION_DELETE_DEPLOYMENT):
        return_code, stdout, stderr = tr.destroy_cmd(capture_output=False, auto_approve=True, var={'organization_id': orgid, 'billing_account_id': billing_acc, 'deployment_id': deployment_id})

    # return_code - 0 Success & 1 Error
    if (return_code == 1):
        print(stderr)
        sys.exit(Fore.RED + Style.BRIGHT + "\nError Occured - Deployment failed for ID: " + deployment_id + "\n" + "Retry using above Deployment ID" + Style.RESET_ALL)
    else:
        target_path = 'radlab/' + env_path.split('/')[len(env_path.split('/')) - 1] + '/deployments'

        if (action == ACTION_CREATE_DEPLOYMENT or action == ACTION_UPDATE_DEPLOYMENT):

            if glob.glob(env_path + '/*.tf'):
                upload_from_directory(projid, env_path, '/*.tf', tfbucket, target_path)
            if glob.glob(env_path + '/*.json'):
                upload_from_directory(projid, env_path, '/*.json', tfbucket, target_path)
            if glob.glob(env_path + '/elk'):
                upload_from_directory(projid, env_path, '/elk/**', tfbucket, target_path)
            if glob.glob(env_path + '/scripts'):
                upload_from_directory(projid, env_path, '/scripts/**', tfbucket, target_path)
            if glob.glob(env_path + '/templates'):
                upload_from_directory(projid, env_path, '/templates/**', tfbucket, target_path)

        elif (action == ACTION_DELETE_DEPLOYMENT):
            deltfgcs(tfbucket, 'radlab/' + env_path.split('/')[len(env_path.split('/')) - 1], projid)

    # Deleting Local deployment config
    shutil.rmtree(env_path)


def upload_from_directory(projid, directory_path: str, content: str, dest_bucket_name: str, dest_blob_name: str):
    rel_paths = glob.glob(directory_path + content, recursive=True)

    bucket = storage.Client(project=projid).get_bucket(dest_bucket_name)
    for local_file in rel_paths:
        file = local_file.replace(directory_path, '')
        remote_path = f'{dest_blob_name}/{"/".join(file.split(os.sep)[1:])}'

        if os.path.isfile(local_file):
            blob = bucket.blob(remote_path)
            blob.upload_from_filename(local_file)


def select_action():
    action = input(
        "\nAction to perform for RAD Lab Deployment ?\n[1] Create New\n[2] Update\n[3] Delete\n[4] List\n" + Fore.YELLOW + Style.BRIGHT + "Choose a number for the RAD Lab Module Deployment Action" + Style.RESET_ALL + ': ').strip()
    if (action == ACTION_CREATE_DEPLOYMENT or action == ACTION_UPDATE_DEPLOYMENT or action == ACTION_DELETE_DEPLOYMENT or action == ACTION_LIST_DEPLOYMENT):
        return action
    else:
        sys.exit(Fore.RED + "\nError Occured - INVALID choice.\n")


def basic_input(orgid, billing_acc, folderid, randomid):
    print("\nEnter following info to start the setup and use the user which have Project Owner & Billing Account User roles:-")

    # Selecting Org ID
    if (orgid == ''):
        orgid = getorgid()

    # Org ID Validation
    if (orgid.strip() and orgid.strip().isdecimal() == False):
        sys.exit(Fore.RED + "\nError Occured - INVALID ORG ID\n")

    print("\nOrg ID (Selected) : " + Fore.GREEN + Style.BRIGHT + orgid + Style.RESET_ALL)

    # Selecting Folder ID
    if (folderid == ''):
        x = input("\nSet Folder ID ?\n[1] Enter Manually\n[2] Skip setting Folder ID\n" + Fore.YELLOW + Style.BRIGHT + "Choose a number for your choice" + Style.RESET_ALL + ': ').strip()
        if (x == '1'):
            folderid = input(Fore.YELLOW + Style.BRIGHT + "\nFolder ID" + Style.RESET_ALL + ': ').strip()
        elif (x == '2'):
            print("Skipped setting Folder ID...")
        else:
            sys.exit(Fore.RED + "\nError Occured - INVALID CHOICE\n" + Style.RESET_ALL)

    # Folder ID Validation
    if (folderid.strip() and folderid.strip().isdecimal() == False):
        sys.exit(Fore.RED + "\nError Occured - INVALID FOLDER ID ACCOUNT\n")

    print("\nFolder ID (Selected) : " + Fore.GREEN + Style.BRIGHT + folderid + Style.RESET_ALL)

    # Selecting Billing Account
    if (billing_acc == ''):
        billing_acc = getbillingacc()
    print("\nBilling Account (Selected) : " + Fore.GREEN + Style.BRIGHT + billing_acc + Style.RESET_ALL)

    # Billing Account Validation
    if (billing_acc.count('-') != 2):
        sys.exit(Fore.RED + "\nError Occured - INVALID Billing Account\n")

    # Create Random Deployment ID
    if (randomid == ''):
        randomid = get_random_alphanumeric_string(4)

    return orgid, billing_acc, folderid, randomid


def create_env(env_path, orgid, billing_acc, folderid):
    my_path = env_path + '/env.json'
    envjson = [
        {
            "orgid": orgid,
            "billing_acc": billing_acc,
            "folderid": folderid
        }
    ]
    with open(my_path, 'w') as file:
        json.dump(envjson, file, indent=4)


def get_env(env_path):
    # Read orgid / billing acc / folder id from env.json
    my_path = env_path + '/env.json'
    # Opening JSON file
    f = open(my_path, )
    # returns JSON object as a dictionary
    data = json.load(f)

    orgid = data[0]['orgid']
    billing_acc = data[0]['billing_acc']
    folderid = data[0]['folderid']

    # Closing file
    f.close()

    return orgid, billing_acc, folderid


def setlocaldeployment(tfbucket, prefix, env_path, projid):
    if (blob_exists(tfbucket, prefix, projid)):

        # Checking if 'deployment' folder exist in local. If YES, delete the same.
        delifexist(env_path)

        # Creating Local directory
        os.makedirs(env_path)

        # Copy Terraform deployment configs from GCS to Local
        if (download_blob(projid, tfbucket, prefix, env_path) == True):
            print("Terraform state downloaded to local...")
        else:
            print(Fore.RED + "\nError Occured whiled downloading Deployment Configs from GCS. Checking if the deployment exist locally...\n")

    elif (os.path.isdir(env_path)):
        print("Terraform state exist locally...")

    else:
        sys.exit(Fore.RED + "\nThe deployment with the entered ID do not exist !\n")


def download_blob(projid, tfbucket, prefix, env_path):
    """Downloads a blob from the bucket."""
    try:
        bucket_dir = 'radlab/' + prefix + '/deployments/'
        local_dir = env_path + '/'

        storage_client = storage.Client(project=projid)
        bucket = storage_client.get_bucket(tfbucket)
        blobs = bucket.list_blobs(prefix=bucket_dir)  # Get list of files

        for blob in blobs:
            content = blob.name.replace(bucket_dir, '')
            # Create Nested Folders structure in Local Directory
            if '/' in content:
                if (os.path.isdir(local_dir + os.path.dirname(content)) == False):
                    os.makedirs(local_dir + os.path.dirname(content))
                    # Download file
            blob.download_to_filename(local_dir + content)  # Download
        return True

    except:
        return False


def get_random_alphanumeric_string(length):
    letters_and_digits = string.ascii_lowercase + string.digits
    result_str = ''.join((random.choice(letters_and_digits) for i in range(length)))
    # print("Random alphanumeric String is:", result_str)
    return result_str


def getbillingacc():
    x = input("\nSet Billing Account ?\n[1] Enter Manually\n[2] Select from the List\n" + Fore.YELLOW + Style.BRIGHT + "Choose a number for your choice" + Style.RESET_ALL + ': ').strip()

    if (x == '1'):
        billing_acc = input(Fore.YELLOW + Style.BRIGHT + "Enter the Billing Account ( Example format - ABCDEF-GHIJKL-MNOPQR )" + Style.RESET_ALL + ': ').strip()
        return billing_acc

    elif (x == '2'):
        credentials = GoogleCredentials.get_application_default()
        service = discovery.build('cloudbilling', 'v1', credentials=credentials)

        request = service.billingAccounts().list()
        response = request.execute()
        # print(response['billingAccounts'])

        print("\nList of Billing account you have access to: \n")
        billing_accounts = []
        # Print out Billing accounts
        for x in range(len(response['billingAccounts'])):
            print("[" + str(x + 1) + "] " + response['billingAccounts'][x]['name'] + "    " + response['billingAccounts'][x]['displayName'])
            billing_accounts.append(response['billingAccounts'][x]['name'])

        # Take user input and get the corresponding item from the list
        inp = int(input(Fore.YELLOW + Style.BRIGHT + "Choose a number for Billing Account" + Style.RESET_ALL + ': '))
        if inp in range(1, len(billing_accounts) + 1):
            inp = billing_accounts[inp - 1]

            billing_acc = inp.split('/')
            # print(billing_acc[1])
            return billing_acc[1]
        else:
            sys.exit(Fore.RED + "\nError Occured - INVALID BILLING ACCOUNT\n")
    else:
        sys.exit(Fore.RED + "\nError Occured - INVALID CHOICE\n" + Style.RESET_ALL)


def getorgid():
    x = input("\nSet Org ID ?\n[1] Enter Manually\n[2] Select from the List\n[3] Skip setting Org ID\n" + Fore.YELLOW + Style.BRIGHT + "Choose a number for your choice" + Style.RESET_ALL + ': ').strip()

    if (x == '1'):
        orgid = input(Fore.YELLOW + Style.BRIGHT + "Enter the Org ID ( Example format - 1234567890 )" + Style.RESET_ALL + ': ').strip()
        return orgid

    elif (x == '2'):
        credentials = GoogleCredentials.get_application_default()
        service = discovery.build('cloudresourcemanager', 'v1beta1', credentials=credentials)

        request = service.organizations().list()
        response = request.execute()

        # pprint(response)

        print("\nList of Org ID you have access to: \n")
        org_ids = []
        # Print out Org IDs accounts
        for x in range(len(response['organizations'])):
            print("[" + str(x + 1) + "] " + response['organizations'][x]['organizationId'] + "    " + response['organizations'][x]['displayName'] + "    " + response['organizations'][x]['lifecycleState'])
            org_ids.append(response['organizations'][x]['organizationId'])

        # Take user input and get the corresponding item from the list
        inp = int(input(Fore.YELLOW + Style.BRIGHT + "Choose a number for Organization ID" + Style.RESET_ALL + ': '))
        if inp in range(1, len(org_ids) + 1):
            orgid = org_ids[inp - 1]
            # print(orgid)
            return orgid
        else:
            sys.exit(Fore.RED + "\nError Occured - INVALID ORG ID SELECTED\n" + Style.RESET_ALL)

    elif (x == '3'):
        print("Skipped setting Org ID...")
        return ''

    else:
        sys.exit(Fore.RED + "\nError Occured - INVALID CHOICE\n" + Style.RESET_ALL)


def delifexist(env_path):
    # print(os.path.isdir(env_path))
    if (os.path.isdir(env_path)):
        shutil.rmtree(env_path)


def getbucket(action, projid):
    """Lists all buckets."""
    storage_client = storage.Client(project=projid)
    bucketoption = ''

    if (action == ACTION_CREATE_DEPLOYMENT):
        bucketoption = input("\nWant to use existing GCS Bucket for Terraform configs or Create Bucket ?:\n[1] Use Existing Bucket\n[2] Create New Bucket\n" + Fore.YELLOW + Style.BRIGHT + "Choose a number for your choice" + Style.RESET_ALL + ': ').strip()

    if (bucketoption == '1' or action == ACTION_UPDATE_DEPLOYMENT or action == ACTION_DELETE_DEPLOYMENT or action == ACTION_LIST_DEPLOYMENT):
        try:
            buckets = storage_client.list_buckets()

            barray = []
            x = 0
            print("\nSelect a bucket for Terraform Configs & States... \n")
            # Print out Buckets in the default project
            for bucket in buckets:
                print("[" + str(x + 1) + "] " + bucket.name)
                barray.append(bucket.name)
                x = x + 1

            # Take user input and get the corresponding item from the list
            try:
                inp = int(input(Fore.YELLOW + Style.BRIGHT + "Choose a number for Bucket Name" + Style.RESET_ALL + ': '))
            except:
                print(Fore.RED + "\nINVALID or NO OPTION SELECTED FOR BUCKET NAME.\n\nEnter the Bucket name Manually...\n" + Style.RESET_ALL)

            if inp in range(1, len(barray) + 1):
                tfbucket = barray[inp - 1]
                return tfbucket
            else:
                print(Fore.RED + "\nINVALID or NO OPTION SELECTED FOR BUCKET NAME.\n\nEnter the Bucket name Manually...\n" + Style.RESET_ALL)
                sys.exit(1)

        except Exception as e:
            print(e)

        # except:
        #     tfbucket = input(Fore.YELLOW + Style.BRIGHT +"Enter the GCS Bucket name where Terraform Configs & States will be stored"+ Style.RESET_ALL + ": ")
        #     tfbucket = tfbucket.lower().strip()
        #     return tfbucket

    elif (bucketoption == '2'):
        print("CREATE BUCKET")
        bucketprefix = input(Fore.YELLOW + Style.BRIGHT + "\nEnter the prefix for the bucket name i.e. radlab-[PREFIX] " + Style.RESET_ALL + ': ')
        # Creates the new bucket
        # Note: These samples create a bucket in the default US multi-region with a default storage class of Standard Storage. 
        # To create a bucket outside these defaults, see [Creating storage buckets](https://cloud.google.com/storage/docs/creating-buckets).
        bucket = storage_client.create_bucket('radlab-' + bucketprefix)

        print("Bucket {} created.".format(bucket.name))
        return bucket.name
    else:
        sys.exit(Fore.RED + "\nInvalid Choice")


def settfstategcs(env_path, prefix, tfbucket, projid):
    prefix = "radlab/" + prefix + "/terraform_state"

    # Validate Terraform Bucket ID
    client = storage.Client(project=projid)
    try:
        bucket = client.get_bucket(tfbucket)
        # print(bucket)
    except:
        sys.exit(Fore.RED + "\nError Occured - INVALID BUCKET NAME or NO ACCESS\n" + Style.RESET_ALL)

    # Create backend.tf file
    f = open(env_path + '/backend.tf', 'w+')
    f.write('terraform {\n  backend "gcs"{\n    bucket="' + tfbucket + '"\n    prefix="' + prefix + '"\n  }\n}')
    f.close()


def deltfgcs(tfbucket, prefix, projid):
    storage_client = storage.Client(project=projid)
    bucket = storage_client.get_bucket(tfbucket)

    blobs = bucket.list_blobs(prefix=prefix)

    for blob in blobs:
        blob.delete()


def blob_exists(tfbucket, prefix, projid):
    storage_client = storage.Client(project=projid)
    bucket = storage_client.get_bucket(tfbucket)
    blob = bucket.blob('radlab/' + prefix + '/deployments/main.tf')
    # print(blob.exists())
    return blob.exists()


def list_radlab_deployments(tfbucket, module_name, projid):
    """Lists all the blobs in the bucket that begin with the prefix."""

    storage_client = storage.Client(project=projid)
    bucket = storage_client.get_bucket(tfbucket)
    iterator = bucket.list_blobs(prefix='radlab/', delimiter='/')
    response = iterator._get_next_page_response()
    print("\nPlease find the list of existing " + module_name + " module deployments below:\n")

    for prefix in response['prefixes']:
        if module_name in prefix:
            print(Fore.GREEN + Style.BRIGHT + prefix.split('/')[1] + Style.RESET_ALL)


def list_modules():
    modules = [s.replace(os.path.dirname(os.getcwd()) + '/modules/', "") for s in glob.glob(os.path.dirname(os.getcwd()) + '/modules/*')]
    modules = sorted(modules)
    c = 1
    print_list = ''

    # Printing List of Modules
    for module in modules:
        first_line = ''
        # Fetch Module name
        try:
            with open(os.path.dirname(os.getcwd()) + '/modules/' + module + '/README.md', "r") as file:
                first_line = file.readline()
        except:
            print(Fore.RED + 'Missing README.md file for module: ' + module + Style.RESET_ALL)
        print_list = print_list + "[" + str(c) + "] " + first_line.strip() + Fore.GREEN + " (" + module + ")\n" + Style.RESET_ALL
        c = c + 1

    # Selecting Module
    try:
        selected_module = input("\nList of available RAD Lab modules:\n" + print_list + "[" + str(c) + "] Exit\n" + Fore.YELLOW + Style.BRIGHT + "Choose a number for the RAD Lab Module" + Style.RESET_ALL + ': ').strip()
        selected_module = int(selected_module)
    except:
        sys.exit(Fore.RED + "\nInvalid module")

    # Validating User Module selection
    if selected_module > 0 and selected_module < c:
        # print(modules)
        module_name = modules[selected_module - 1]
        print("\nRAD Lab Module (selected) : " + Fore.GREEN + Style.BRIGHT + module_name + Style.RESET_ALL)
        return module_name
    elif selected_module == c:
        sys.exit(Fore.GREEN + "\nExiting Installer")
    else:
        sys.exit(Fore.RED + "\nInvalid module")


def module_deploy_common_settings(action, module_name, setup_path, varcontents, projid, tfbucket):
    # Get Terraform Bucket Details
    if tfbucket is None:
        tfbucket = getbucket(action, projid)
    print("\nGCS bucket for Terraform config & state (Selected) : " + Fore.GREEN + Style.BRIGHT + tfbucket + Style.RESET_ALL)

    # Setting Org ID, Billing Account, Folder ID
    if (action == ACTION_CREATE_DEPLOYMENT):

        # Check for any overides of basic inputs from terraform.tfvars file
        orgid, billing_acc, folderid, randomid = check_basic_inputs_tfvars(varcontents)

        # Getting Base Inputs
        orgid, billing_acc, folderid, randomid = basic_input(orgid, billing_acc, folderid, randomid)

        # Set environment path as deployment directory
        prefix = module_name + '_' + randomid
        env_path = setup_path + '/deployments/' + prefix

        # Checking if 'deployment' folder exist in local. If YES, delete the same.
        delifexist(env_path)

        # Copy module directory
        shutil.copytree(os.path.dirname(os.getcwd()) + '/modules/' + module_name, env_path)

        # Set Terraform states remote backend as GCS
        settfstategcs(env_path, prefix, tfbucket, projid)

        # Create file with billing/org/folder details
        create_tfvars(env_path, varcontents)

        # Create file with billing/org/folder details
        create_env(env_path, orgid, billing_acc, folderid)

        print("\nCREATING DEPLOYMENT...")

        return env_path, tfbucket, orgid, billing_acc, folderid, randomid

    elif (action == ACTION_UPDATE_DEPLOYMENT or action == ACTION_DELETE_DEPLOYMENT):

        # List Existing Deployments
        list_radlab_deployments(tfbucket, module_name, projid)

        # Get Deployment ID
        randomid = input(Fore.YELLOW + Style.BRIGHT + "\nEnter RAD Lab Module Deployment ID (example 'l8b3' is the id for module deployment with name - data_science_l8b3)" + Style.RESET_ALL + ': ')
        randomid = randomid.strip()

        # Validating Deployment ID
        if (len(randomid) == 4 and randomid.isalnum()):

            # Set environment path as deployment directory
            prefix = module_name + '_' + randomid
            env_path = setup_path + '/deployments/' + prefix

            # Setting Local Deployment
            setlocaldeployment(tfbucket, prefix, env_path, projid)

        else:
            sys.exit(Fore.RED + "\nInvalid deployment ID!\n")

        # Get env values
        orgid, billing_acc, folderid = get_env(env_path)

        # Set Terraform states remote backend as GCS
        settfstategcs(env_path, prefix, tfbucket, projid)

        # Create file with billing/org/folder details and user input variables
        if os.path.exists(env_path + '/terraform.tfvars'):
            os.remove(env_path + '/terraform.tfvars')
        create_tfvars(env_path, varcontents)

        if (action == ACTION_UPDATE_DEPLOYMENT):
            print("\nUPDATING DEPLOYMENT...")

        if (action == ACTION_DELETE_DEPLOYMENT):
            print("\nDELETING DEPLOYMENT...")

        return env_path, tfbucket, orgid, billing_acc, folderid, randomid

    elif (action == ACTION_LIST_DEPLOYMENT):
        list_radlab_deployments(tfbucket, module_name, projid)
        sys.exit()

    else:
        sys.exit(Fore.RED + "\nInvalid RAD Lab Module Action selected")


def validate_tfvars(varcontents, module_name):
    keys = list(varcontents.keys())
    if keys:
        print("Variables in file:")
        print(keys)

    for key in keys:
        status = False
        try:
            with open(os.path.dirname(os.getcwd()) + '/modules/' + module_name + '/variables.tf', 'r') as myfile:
                for line in myfile:
                    if ('variable "' + key + '"' in line):
                        # print (key + ": Found")
                        status = True
                        break
        except:
            sys.exit(Fore.RED + 'variables.tf missing for module: ' + module_name)

        # Check if an invalid variable is passed! 
        if (status == False):
            sys.exit(
                Fore.RED + 'Variable: ' + key + ' passed in input file, do not exist in variables.tf file of ' + module_name + ' module.')
    # print(varcontents)
    return True


def create_tfvars(env_path, varcontents):
    # Check if any variable exist
    if (bool(varcontents) == True):
        # Creating terraform.tfvars file in deployment folder
        f = open(env_path + "/terraform.tfvars", "w+")
        for var in varcontents:
            f.write(var.strip() + "=" + varcontents[var].strip() + "\n")
        f.close()
    else:
        print("Skipping creation of terraform.tfvars as no input file for variables...")


def check_basic_inputs_tfvars(varcontents):
    try:
        orgid = varcontents['organization_id'].strip('"')
    except:
        orgid = ''
    try:
        billing_acc = varcontents['billing_account_id'].strip('"')
    except:
        billing_acc = ''
    try:
        folderid = varcontents['folder_id'].strip('"')
    except:
        folderid = ''
    try:
        randomid = varcontents['deployment_id'].strip('"')
    except:
        randomid = ''

    return orgid, billing_acc, folderid, randomid


def fetchvariables(filecontents):
    variables = {}
    # Check if there is any variable; If NOT do not create terraform.tfvars file
    for x in filecontents:
        # Skipping for commented lines
        if x.startswith('#') or x.startswith('//'):
            continue
        elif (len(x.split("=")) == 2):
            x = x.strip()
            # print(x)
            variables[x.split("=")[0].strip()] = x.split("=")[1].strip()

    # print(variables)
    if (bool(variables) == True):
        return variables
    else:
        sys.exit(Fore.RED + 'No variables in the input file')


if __name__ == "__main__":
    try:
        print('\n' + text2art("RADLAB", font="larry3d"))

        parser = argparse.ArgumentParser()
        parser.add_argument('-p', '--rad-project', dest="projid", help="RAD Lab management GCP Project.", required=False)
        parser.add_argument('-b', '--rad-bucket', dest="tfbucket", help="RAD Lab management GCS Bucket where Terraform states for the modules will be stored.", required=False)
        parser.add_argument('-m', '--module', dest="module_name", choices=sorted([s.replace(os.path.dirname(os.getcwd()) + '/modules/', "") for s in glob.glob(os.path.dirname(os.getcwd()) + '/modules/*')]), help="RADLab Module name under ../../modules folder", required=False)
        parser.add_argument('-a', '--action', dest="action", choices=['create', 'update', 'delete', 'list'], help="Type of action you want to perform for the selected RADLab module.", required=False)
        parser.add_argument('-f', '--varfile', dest="file", type=argparse.FileType('r', encoding='UTF-8'), help="Input file (with complete path) for terraform.tfvars contents.", required=False)
        parser.add_argument('-dc', '--disable-perm-check', dest="disable_perm_check", action='store_false', help="Flag to disable RAD Lab permissions pre-check.", required=False)

        args = parser.parse_args()

        # File Argument
        if args.file is not None:
            print("Checking input file...")
            filecontents = args.file.readlines()
            variables = fetchvariables(filecontents)
        else:
            variables = {}

        # Action Argument
        if args.action == 'create':
            action = ACTION_CREATE_DEPLOYMENT
        elif args.action == 'update':
            action = ACTION_UPDATE_DEPLOYMENT
        elif args.action == 'delete':
            action = ACTION_DELETE_DEPLOYMENT
        elif args.action == 'list':
            action = ACTION_LIST_DEPLOYMENT
        else:
            action = None

        main(variables, args.module_name, action, args.projid, args.tfbucket, args.disable_perm_check)

    except Exception as e:
        print(e)
