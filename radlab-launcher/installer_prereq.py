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

def main():

    # Install production dependencies.
    os.system("pip3 install --no-cache-dir -r requirements.txt")
    os.system("python3 terraform_installer.py")
    os.system("python3 cloudsdk_kubectl_installer.py")
    print("\nPRE-REQ INSTALLTION COMPLETED\n")

if __name__ == "__main__":
    main()