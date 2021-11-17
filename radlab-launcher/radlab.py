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

#  PREREQ: installer_prereq.py

import os
import shutil
import sys
import json
import glob
import random
import string
import platform
from os import path
from google.cloud import storage
from googleapiclient import discovery
from colorama import Fore, Back, Style
from python_terraform import Terraform
from oauth2client.client import GoogleCredentials

STATE_CREATE_DEPLOYMENT = "1"
STATE_UPDATE_DEPLOYMENT = "2"
STATE_DELETE_DEPLOYMENT = "3"
STATE_LIST_DEPLOYMENT = "4"

OPTION_MODULE_APP_MOD_ELASTIC_SEARCH = "1"
OPTION_MODULE_DATA_SCIENCE = "2"
OPTION_QUIT = ""

def main():
    
    orgid           = ""
    folderid        = ""
    billing_acc     = ""
    domain          = ""
    selected_module = ""
    state           = ""

    setup_path = os.getcwd()

    # Setting Credentials for non Cloud Shell CLI
    if(platform.system() != 'Linux' and platform.processor() !='' and not platform.system().startswith('cs-')):
        # countdown(5)
        print("Login with Cloud Admin account...")
        os.system("gcloud auth application-default login")

    modules, c = list_modules()
    OPTION_QUIT = c

    selected_module = input("\nList of available RAD Lab modules:\n"+modules+"["+ str(c) +"] Exit\n"+ Fore.YELLOW + Style.BRIGHT + "Choose a number for the RAD Lab Module"+ Style.RESET_ALL + ': ').strip()
    
    if(selected_module == OPTION_MODULE_DATA_SCIENCE):
        print("\nRAD Lab Module (selected) : "+ Fore.GREEN + Style.BRIGHT +"Data Science"+ Style.RESET_ALL)
        module_name = 'data_science'
        notebook_count  = ""
        trusted_users   = []
        state,env_path,tfbucket,orgid,billing_acc,folderid,domain,randomid = module_deploy_common_settings(module_name,setup_path)
        notebook_count, trusted_users = module_deploy_specific_setting(selected_module,state,domain,notebook_count,trusted_users)
        env(state, orgid, billing_acc, folderid, domain, env_path, randomid, tfbucket, selected_module, trusted_users, notebook_count)

    elif(selected_module ==  OPTION_MODULE_APP_MOD_ELASTIC_SEARCH):
        print("\nRAD Lab Module (selected) : "+ Fore.GREEN + Style.BRIGHT +"(APP MOD) Elasticsearch"+ Style.RESET_ALL)
        module_name = 'app_mod_elastic'
        state,env_path,tfbucket,orgid,billing_acc,folderid,domain,randomid = module_deploy_common_settings(module_name,setup_path)
        env(state, orgid, billing_acc, folderid, domain, env_path, randomid, tfbucket, selected_module)

    elif(selected_module == OPTION_QUIT):
        sys.exit(Fore.GREEN + "\nExiting Installer")

    else:
        print(OPTION_QUIT)
        sys.exit(Fore.RED + "\nInvalid module")


    # env(state, orgid, billing_acc, folderid, domain, env_path, randomid, tfbucket, selected_module, trusted_users, notebook_count)
    print("\nGCS Bucket storing Terrafrom Configs: "+ tfbucket +"\n")
    print("\nTERRAFORM DEPLOYMENT COMPLETED!!!\n")
	

def env(state, orgid, billing_acc, folderid, domain, env_path, randomid, tfbucket, selected_module, trusted_users = [], notebook_count = ""):
    tr = Terraform(working_dir=env_path)
    return_code, stdout, stderr = tr.init_cmd(capture_output=False)
    
    if(state == STATE_CREATE_DEPLOYMENT or state == STATE_UPDATE_DEPLOYMENT):
        return_code, stdout, stderr = tr.apply_cmd(capture_output=False,auto_approve=True,var={'organization_id':orgid, 'billing_account_id':billing_acc, 'folder_id':folderid, 'domain':domain, 'file_path':env_path, 'notebook_count':notebook_count, 'trusted_users': trusted_users, 'random_id':randomid})
    elif(state == STATE_DELETE_DEPLOYMENT):
        return_code, stdout, stderr = tr.destroy_cmd(capture_output=False,auto_approve=True,var={'organization_id':orgid, 'billing_account_id':billing_acc, 'folder_id':folderid, 'file_path':env_path,'random_id':randomid})

    # return_code - 0 Success & 1 Error
    if(return_code == 1):
        print(stderr)
        sys.exit(Fore.RED + Style.BRIGHT + "\nError Occured - Deployment failed for ID: "+ randomid+"\n"+ "Retry using above Deployment ID" +Style.RESET_ALL )
    else:
        target_path = 'gs://'+ tfbucket +'/radlab/'+ env_path.split('/')[len(env_path.split('/'))-1] +'/deployments'
        if(state == STATE_CREATE_DEPLOYMENT or state == STATE_UPDATE_DEPLOYMENT):
            os.system('gsutil -q -m cp -r ' + env_path + '/*.tf ' + target_path)
            os.system('gsutil -q -m cp -r ' + env_path + '/*.json ' + target_path)

            if(selected_module == OPTION_MODULE_APP_MOD_ELASTIC_SEARCH): # Module specific folders
                os.system('gsutil -q -m cp -r ' + env_path + '/elk ' + target_path)
                os.system('gsutil -q -m cp -r -P ' + env_path + '/scripts ' + target_path)
                os.system('gsutil -q -m cp -r ' + env_path + '/templates ' + target_path)

        elif(state == STATE_DELETE_DEPLOYMENT):
            deltfgcs(tfbucket, 'radlab/'+ env_path.split('/')[len(env_path.split('/'))-1])

    # Deleting Local deployment config
    shutil.rmtree(env_path)

def select_state():
    state = input("\nAction to perform for RAD Lab Deployment ?\n[1] Create New\n[2] Update\n[3] Delete\n[4] List\n" + Fore.YELLOW + Style.BRIGHT + "Choose a number for the RAD Lab Module Deployment Action"+ Style.RESET_ALL + ': ').strip()
    if(state == STATE_CREATE_DEPLOYMENT or state == STATE_UPDATE_DEPLOYMENT or state == STATE_DELETE_DEPLOYMENT or state == STATE_LIST_DEPLOYMENT):
        return state
    else: 
        sys.exit(Fore.RED + "\nError Occured - INVALID choice.\n")

def basic_input():

    print("\nEnter following info to start the setup and use the user which have Project Owner & Billing Account User roles:-")

    # Selecting Org ID
    orgid = getorgid()
    print("\nOrg ID (Selected) : " + Fore.GREEN + Style.BRIGHT + orgid + Style.RESET_ALL )

    # Org ID Validation
    if (orgid.strip().isdecimal() == False) :
        sys.exit(Fore.RED + "\nError Occured - INVALID ORG ID\n")
    
    # Selecting Billing Account
    billing_acc = getbillingacc()
    print("\nBilling Account (Selected) : " + Fore.GREEN + Style.BRIGHT + billing_acc + Style.RESET_ALL )  
    
    # Billing Account Validation
    if (billing_acc.count('-') != 2) :
        sys.exit(Fore.RED + "\nError Occured - INVALID Billing Account\n")

    # Selecting Folder ID
    folderid = input(Fore.YELLOW + Style.BRIGHT + "\nFolder ID [Optional]"+ Style.RESET_ALL + ': ')

    # Folder ID Validation
    if (folderid.strip() and folderid.strip().isdecimal() == False):
        sys.exit(Fore.RED + "\nError Occured - INVALID FOLDER ID ACCOUNT\n")

    # Fetching Domain name 
    domain = getdomain(orgid)
    
    # Create Random Deployment ID
    randomid = get_random_alphanumeric_string(4)

    return orgid, billing_acc, folderid, domain, randomid

def create_env(env_path, orgid, billing_acc, folderid):

    my_path  = env_path + '/env.json'
    envjson = [
        {
            "orgid"         : orgid,
            "billing_acc"   : billing_acc,
            "folderid"      : folderid
        }
    ]
    with open(my_path , 'w') as file:
        json.dump(envjson, file, indent=4)

def get_env(env_path):

    # Read orgid / billing acc / folder id from env.json
    my_path  = env_path + '/env.json'
    # Opening JSON file
    f = open(my_path,)
    # returns JSON object as a dictionary
    data = json.load(f)
    
    orgid       = data[0]['orgid']
    billing_acc = data[0]['billing_acc']
    folderid    = data[0]['folderid']

    # Closing file
    f.close()

    return orgid, billing_acc, folderid

def setlocaldeployment(tfbucket,prefix, env_path):

    if(blob_exists(tfbucket, prefix)):

        # Checking if 'deployment' folder exist in local. If YES, delete the same.
        delifexist(env_path)

        # Creating Local directory
        os.makedirs(env_path)

        # Copy Terraform deployment configs from GCS to Local
        if(os.system('gsutil -q -m cp -r -P gs://'+ tfbucket +'/radlab/'+ prefix +'/deployments/* ' + env_path) == 0):
            print("Terraform state downloaded to local...")
        else:
            print(Fore.RED + "\nError Occured whiled downloading Deployment Configs from GCS. Checking if the deployment exist locally...\n")

    elif(os.path.isdir(env_path)):
        print("Terraform state exist locally...")
    
    else:
        sys.exit(Fore.RED + "\nThe deployment with the entered ID do not exist !\n")

def get_random_alphanumeric_string(length):
	letters_and_digits = string.ascii_lowercase + string.digits
	result_str = ''.join((random.choice(letters_and_digits) for i in range(length)))
	# print("Random alphanumeric String is:", result_str)
	return result_str

def getdomain(orgid):
    credentials = GoogleCredentials.get_application_default()
    service = discovery.build('cloudresourcemanager', 'v1', credentials=credentials)
    # The resource name of the Organization to fetch, e.g. "organizations/1234".
    name = 'organizations/'+orgid

    request = service.organizations().get(name=name)
    response = request.execute()
    # print(response['displayName'])
    return response['displayName']

def getbillingacc():

    x = input("\nHow would you like to fetch the Billing Account ?\n[1] Enter Manually\n[2] Select from the List\n" + Fore.YELLOW + Style.BRIGHT + "Choose a number for your choice"+ Style.RESET_ALL + ': ').strip()

    if(x == '1'):
        billing_acc = input(Fore.YELLOW + Style.BRIGHT + "Enter the Billing Account ( Example format - ABCDEF-GHIJKL-MNOPQR )" + Style.RESET_ALL + ': ').strip()
        return billing_acc
    
    elif(x == '2'):
        credentials = GoogleCredentials.get_application_default()
        service = discovery.build('cloudbilling', 'v1', credentials=credentials)
    
        request = service.billingAccounts().list()
        response = request.execute()

        print("\nList of Billing account you have access to: \n")
        billing_accounts = []    
        # Print out Billing accounts
        for x in range(len(response['billingAccounts'])):
            print("[" + str(x+1) + "] " + response['billingAccounts'][x]['name'] + "    " + response['billingAccounts'][x]['displayName'])
            billing_accounts.append(response['billingAccounts'][x]['name'])

        # Take user input and get the corresponding item from the list
        inp = int(input(Fore.YELLOW + Style.BRIGHT + "Choose a number for Billing Account" + Style.RESET_ALL + ': '))
        if inp in range(1, len(billing_accounts)+1):
            inp = billing_accounts[inp-1]

            billing_acc = inp.split('/')        
            # print(billing_acc[1])
            return billing_acc[1]
        else:
            sys.exit(Fore.RED + "\nError Occured - INVALID BILLING ACCOUNT\n")
    else:
        sys.exit(Fore.RED + "\nError Occured - INVALID CHOICE\n"+ Style.RESET_ALL)

def getorgid():

    x = input("\nHow would you like to fetch the Org ID ?\n[1] Enter Manually\n[2] Select from the List\n" + Fore.YELLOW + Style.BRIGHT + "Choose a number for your choice"+ Style.RESET_ALL + ': ').strip()
    
    if(x == '1'):
        orgid = input(Fore.YELLOW + Style.BRIGHT + "Enter the Org ID ( Example format - 1234567890 )" + Style.RESET_ALL + ': ').strip()
        return orgid

    elif(x == '2'):
        credentials = GoogleCredentials.get_application_default()
        service = discovery.build('cloudresourcemanager', 'v1beta1', credentials=credentials)

        request = service.organizations().list()
        response = request.execute()

        # pprint(response)

        print("\nList of Org ID you have access to: \n")
        org_ids = []    
        # Print out Org IDs accounts
        for x in range(len(response['organizations'])):
            print("[" + str(x+1) + "] " + response['organizations'][x]['organizationId'] + "    " + response['organizations'][x]['displayName']+ "    " + response['organizations'][x]['lifecycleState'])
            org_ids.append(response['organizations'][x]['organizationId'])

        # Take user input and get the corresponding item from the list
        inp = int(input(Fore.YELLOW + Style.BRIGHT + "Choose a number for Organization ID" + Style.RESET_ALL + ': '))
        if inp in range(1, len(org_ids)+1):
            orgid = org_ids[inp-1]   
            # print(orgid)
            return orgid
        else:
            sys.exit(Fore.RED + "\nError Occured - INVALID ORG ID SELECTED\n"+ Style.RESET_ALL)
    else:
        sys.exit(Fore.RED + "\nError Occured - INVALID CHOICE\n"+ Style.RESET_ALL)

def delifexist(env_path):
    # print(os.path.isdir(env_path))
    if(os.path.isdir(env_path)):
        shutil.rmtree(env_path)

def getbucket(state):
    """Lists all buckets."""

    storage_client = storage.Client()
    bucketoption = ''

    if(state == '1'):
        bucketoption = input("\nWant to use existing GCS Bucket for Terraform configs or Create Bucket ?:\n[1] Use Existing Bucket\n[2] Create New Bucket\n"+ Fore.YELLOW + Style.BRIGHT + "Choose a number for your choice"+ Style.RESET_ALL + ': ')
    
    if(bucketoption == '1' or state == '2' or state == '3' or state == '4'):
        try:
            buckets = storage_client.list_buckets()

            barray = []    
            x = 0
            print("\nSelect a bucket for Terraform Configs & States... \n")
            # Print out Buckets in the default project
            for bucket in buckets:
                print("[" + str(x+1) + "] " + bucket.name)
                barray.append(bucket.name)
                x=x+1
            
            # Take user input and get the corresponding item from the list
            try:
                inp = int(input(Fore.YELLOW + Style.BRIGHT + "Choose a number for Bucket Name" + Style.RESET_ALL + ': '))
            except:
                print(Fore.RED + "\nINVALID or NO OPTION SELECTED FOR BUCKET NAME.\n\nEnter the Bucket name Manually...\n"+ Style.RESET_ALL)
            
            if inp in range(1, len(barray)+1):
                tfbucket = barray[inp-1]
                return tfbucket
            else:
                print(Fore.RED + "\nINVALID or NO OPTION SELECTED FOR BUCKET NAME.\n\nEnter the Bucket name Manually...\n"+ Style.RESET_ALL)
                sys.exit(1)

        except:
            tfbucket = input(Fore.YELLOW + Style.BRIGHT +"Enter the GCS Bucket name where Terraform Configs & States will be stored"+ Style.RESET_ALL + ": ")
            tfbucket = tfbucket.lower().strip()
            return tfbucket

    elif(bucketoption == '2'):
        print("CREATE BUCKET")
        bucketprefix = input(Fore.YELLOW + Style.BRIGHT + "\nEnter the prefix for the bucket name i.e. radlab-[PREFIX] " + Style.RESET_ALL + ': ')
        # Creates the new bucket
        # Note: These samples create a bucket in the default US multi-region with a default storage class of Standard Storage. 
        # To create a bucket outside these defaults, see [Creating storage buckets](https://cloud.google.com/storage/docs/creating-buckets).
        projid = input(Fore.YELLOW + Style.BRIGHT + "\nEnter the project ID under which the bucket is to be created " + Style.RESET_ALL + ': ')
        bucket = storage_client.create_bucket('radlab-'+bucketprefix,project=projid)

        print("Bucket {} created.".format(bucket.name))
        return bucket.name
    else:
        sys.exit(Fore.RED + "\nInvalid Choice")

def settfstategcs(env_path, prefix, tfbucket):

    prefix   = "radlab/"+prefix+"/terraform_state"

    # Validate Terraform Bucket ID
    client = storage.Client()
    try:
        bucket = client.get_bucket(tfbucket)
        # print(bucket)
    except:
        sys.exit(Fore.RED + "\nError Occured - INVALID BUCKET NAME or NO ACCESS\n"+ Style.RESET_ALL)
    
    # Create backend.tf file
    f=open( env_path+'/backend.tf', 'w+')
    f.write('terraform {\n  backend "gcs"{\n    bucket="'+tfbucket+'"\n    prefix="'+prefix+'"\n  }\n}')
    f.close()

def deltfgcs(tfbucket, prefix):
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(tfbucket)

    blobs = bucket.list_blobs(prefix=prefix)

    for blob in blobs:
        blob.delete()

def blob_exists(tfbucket, prefix):
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(tfbucket)
    blob = bucket.blob('radlab/'+ prefix+'/deployments/main.tf')
    # print(blob.exists())
    return blob.exists()

def list_radlab_deployments(tfbucket, module_name):
    """Lists all the blobs in the bucket that begin with the prefix."""

    storage_client = storage.Client()
    bucket = storage_client.get_bucket(tfbucket)
    iterator = bucket.list_blobs(prefix='radlab/',delimiter='/')
    response = iterator._get_next_page_response()
    print("\nPlease find the list of "+ module_name + " module below:\n")

    for prefix in response['prefixes']:
        if module_name in prefix:
            print(Fore.GREEN + Style.BRIGHT + prefix.split('/')[1] + Style.RESET_ALL)


def list_modules():
    modules = [s.replace(os.path.dirname(os.getcwd()) + '/modules/', "") for s in glob.glob(os.path.dirname(os.getcwd()) + '/modules/*')]
    modules = sorted(modules)
    c = 1
    print_list = ''
    for module in modules:
        print_list = print_list + "["+ str(c) +"] " + module + "\n"
        # print("["+ str(c) +"] " + module + "\n")
        c = c+1
    # print(print_list)
    return print_list, str(c)


def module_deploy_common_settings(module_name,setup_path):
    # Select Action to perform
    state = select_state()

    # Get Terraform Bucket Details
    tfbucket = getbucket(state.strip())
    print("\nGCS bucket for Terraform config & state (Selected) : " + Fore.GREEN + Style.BRIGHT + tfbucket + Style.RESET_ALL )

    # Setting Org ID, Billing Account, Folder ID, Domain
    if(state == STATE_CREATE_DEPLOYMENT):

        # Getting Base Inputs
        orgid, billing_acc, folderid, domain, randomid = basic_input()

        # Set environment path as deployment directory
        prefix = module_name+'_'+randomid
        env_path = setup_path+'/deployments/'+prefix

        # Checking if 'deployment' folder exist in local. If YES, delete the same.
        delifexist(env_path)

        # Copy module directory
        shutil.copytree(os.path.dirname(os.getcwd()) + '/modules/'+module_name, env_path)
        
        # Set Terraform states remote backend as GCS
        settfstategcs(env_path,prefix,tfbucket)

        # Create file with billing/org/folder details
        create_env(env_path, orgid, billing_acc, folderid)

        return state,env_path,tfbucket,orgid,billing_acc,folderid,domain,randomid

    elif(state == STATE_UPDATE_DEPLOYMENT or state == STATE_DELETE_DEPLOYMENT):
        
        # Get Deployment ID
        randomid = input(Fore.YELLOW + Style.BRIGHT + "\nEnter RAD Lab Module Deployment ID (example 'l8b3' is the id for project with id - radlab-ds-analytics-l8b3)" + Style.RESET_ALL + ': ')
        randomid = randomid.strip()

        # Validating Deployment ID
        if(len(randomid) == 4 and randomid.isalnum()):
            
            # Set environment path as deployment directory
            prefix = module_name+'_'+randomid
            env_path = setup_path+'/deployments/'+prefix
            
            # Setting Local Deployment
            setlocaldeployment(tfbucket,prefix,env_path)

        else:
            sys.exit(Fore.RED + "\nInvalid deployment ID!\n")

        # Get env values
        orgid, billing_acc, folderid = get_env(env_path)

        # Fetching Domain name 
        domain = getdomain(orgid)
        
        # Set Terraform states remote backend as GCS
        settfstategcs(env_path,prefix,tfbucket)

        if(state == STATE_DELETE_DEPLOYMENT):
            print("DELETING DEPLOYMENT...")

        return state,env_path,tfbucket,orgid,billing_acc,folderid,domain,randomid

    elif(state == STATE_LIST_DEPLOYMENT):
        list_radlab_deployments(tfbucket, module_name)
        sys.exit()

    else:
        sys.exit(Fore.RED + "\nInvalid RAD Lab Module State selected")

def module_deploy_specific_setting(selected_module,state,domain,notebook_count,trusted_users):

    if(selected_module == OPTION_MODULE_DATA_SCIENCE):

        # No. of AI Notebooks and assigning trusted users
        if(state == STATE_CREATE_DEPLOYMENT or state == STATE_UPDATE_DEPLOYMENT):
            # Requesting Number of AI Notebooks
            notebook_count = input(Fore.YELLOW + Style.BRIGHT + "\nNumber of AI Notebooks required [Default is 1 & Maximum is 10]"+ Style.RESET_ALL + ': ')
            if(len(notebook_count.strip()) == 0):
                notebook_count = '1'
                print("\nNumber of AI Notebooks (Selected) : " + Fore.GREEN + Style.BRIGHT + notebook_count + "\n"+ Style.RESET_ALL)
            elif(int(notebook_count) > 0 and int(notebook_count) <= 10):
                print("\nNumber of AI Notebooks (Selected) : " + Fore.GREEN + Style.BRIGHT + notebook_count + "\n"+ Style.RESET_ALL)
            else:
                # shutil.rmtree(env_path)
                sys.exit(Fore.RED + "\nInvalid Notbooks count")

            # Requesting Trusted Users
            new_name = ''
            while new_name != 'quit':
                # Ask the user for a name.
                new_name = input(Fore.YELLOW + Style.BRIGHT + "Enter the username of trusted users needing access to AI Notebooks, or enter 'quit'"+ Style.RESET_ALL + ': ')
                new_name = new_name.strip()
                # Add the new name to our list.
                if(new_name != 'quit' and len(new_name.strip()) != 0):
                    if "@" in new_name:
                        new_name = new_name.split("@")[0]
                    trusted_users.append("user:" + new_name + "@" + domain)
            # print(trusted_users)
        return notebook_count,trusted_users

if __name__ == "__main__":
    main()