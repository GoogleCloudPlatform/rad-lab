#!/usr/bin/python3

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
import subprocess
from colorama import Fore, Back, Style

def main():

    # Install python dependencies.
    print(Fore.BLUE + "\nInstalling Libraries..." + Style.RESET_ALL)
    os.system("pip3 install --no-cache-dir -r requirements.txt")

    # Set up Terraform binaries
    tfOutput = subprocess.Popen(["terraform -version"],shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL).stdout.read().strip().decode('utf-8')
  
    ## Check if Terrafrom binaries are already installed
    if "command not found" in tfOutput:
        print(Fore.YELLOW + "\nTerraform binaries not installed. Starting installation...\n" + Style.RESET_ALL)
        os.system("python3 terraform_installer.py")
    else:
        print(Fore.YELLOW + "\nTerraform binaries already installed. Skipping installation...\n" + Style.RESET_ALL)
    
    # Printing Terraform Version
    os.system("terraform -version")

    # Set up Cloud sdk & Kubectl libraries
    os.system("python3 cloudsdk_kubectl_installer.py")

    print(Fore.BLUE + "\nPRE-REQ INSTALLTION COMPLETED\n" + Style.RESET_ALL)

if __name__ == "__main__":
    main()