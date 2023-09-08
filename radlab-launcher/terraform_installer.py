#!/usr/bin/python3

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

#https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform

import os
import platform
import requests
from bs4 import BeautifulSoup


def main():
    
    system = platform.system().lower()
    machine = platform.machine().lower()

    url = 'https://www.terraform.io/downloads.html'
    reqs = requests.get(url)
    soup = BeautifulSoup(reqs.text, 'html.parser')

    if('darwin' in system or 'linux' in system):
        if('x86_64' in machine):
            machine = 'amd64'
        else:
            machine = '386'

        for link in soup.find_all('a'):
            # print(link.get('href'))
            if("https://releases.hashicorp.com/terraform/" in str(link.get('href')) and ".zip" in str(link.get('href')) and system in str(link.get('href'))):

                if(machine in str(link.get('href'))):
                    downloadlink = link.get('href')
                    # print(downloadlink)
                    break
        os.system("curl "+downloadlink+ " --output terraform_download.zip")
        os.system("unzip terraform_download.zip")
        print("\nPlease enter your machine's credentials to complete installation (if requested)...\n")
        os.system("sudo mv " +os.getcwd()+"/terraform /usr/local/bin/")
        os.remove("terraform_download.zip")

    elif('windows' in system):
        # Run Command Prompt as adminstrator

        # Create installChocolatey.cmd
        f=open('installChocolatey.cmd', 'w+')
        f.write('@echo off\n\nSET DIR=%~dp0%\n\n::download install.ps1\n%systemroot%\System32\WindowsPowerShell\\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('"'https://community.chocolatey.org/install.ps1'"','"'%DIR%install.ps1'"'))"\n::run installer\n%systemroot%\System32\WindowsPowerShell\\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '"'%DIR%install.ps1'"' %*"')
        f.close()

        # Install Chocolatey & Terraform
        os.system('installChocolatey.cmd')
        os.system('choco install terraform -y')

        # Delete installChocolatey.cmd & install.ps1
        os.remove('install.ps1')
        os.remove('installChocolatey.cmd')
    
if __name__ == "__main__":
    main()