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


import os
import sys
import glob
import shutil
from colorama import Fore, Back, Style

def main():

    # List existing RADLab Modules
    module = list_modules()
    
    sc_path = os.getcwd() + '/radlab-service-catalog'

    # Creating RadLab Service Catalog Package folder
    os.system('mkdir -p ' + sc_path)

    # Pull specific folder from RADLab GitHub Repo
    shutil.copytree(os.path.dirname(os.getcwd()) + '/modules/'+ module, sc_path + '/' + module)

    for filename in os.listdir(sc_path + '/' + module):

        f = os.path.join(sc_path + '/' + module, filename)

        # Remove all non.tf files from the root of the module
        if os.path.isfile(f) and os.path.splitext(f)[1] != ".tf":
            os.remove(f)

    # Zip the module in such a way that .tf files are at the root of the zipped file
    os.system('cd ' + sc_path + '/' + module + '; zip -r ' + module + '.zip *')

    # Move thezip package to the RADLab Service Catalog Folder
    os.system('mv ' + sc_path + '/' + module + '/' + module + '.zip ' + sc_path )

    # Remove the downloaded module
    os.system('rm -r ' + sc_path + '/' + module)

    # Printing path to RADLab's Service Catalog Solution.
    print("Please find the zipped solution here: " + sc_path + '/' + module +'.zip')

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
            with open(os.path.dirname(os.getcwd()) + '/modules/'+ module + '/README.md', "r") as file:
                first_line = file.readline()
        except:
            print(Fore.RED +'Missing README.md file for module: ' + module + Style.RESET_ALL)
        print_list = print_list + "["+ str(c) +"] " + first_line.strip() + Fore.GREEN + " (" +module + ")\n" + Style.RESET_ALL
        c = c+1

    # Selecting Module
    try:
        selected_module = input("\nList of available RAD Lab modules:\n"+print_list+"["+ str(c) +"] Exit\n"+ Fore.YELLOW + Style.BRIGHT + "Choose a number for the RAD Lab Module"+ Style.RESET_ALL + ': ').strip()
        selected_module = int(selected_module)
    except:
        sys.exit(Fore.RED + "\nInvalid module")

    # Validating User Module selection
    if selected_module > 0 and selected_module < c:
        # print(modules)
        module_name = modules[selected_module-1]
        print("\nRAD Lab Module (selected) : "+ Fore.GREEN + Style.BRIGHT +module_name+ Style.RESET_ALL)
        return module_name
    elif selected_module == c:
        sys.exit(Fore.GREEN + "\nExiting Installer")
    else:
        sys.exit(Fore.RED + "\nInvalid module")



if __name__ == '__main__':
    main()