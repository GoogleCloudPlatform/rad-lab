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

#https://cloud.google.com/sdk/docs/downloads-interactive

import os
import platform

def main():
  # CURL & Bash should already be installed on the Local OS
  # Not requied for Cloud Shell

  system = platform.system().lower()
  node = platform.node().lower()

  if('linux' in system and 'cs-' in node):
    print("Detected Cloud Shell, skipping cloud sdk & kubectl installation...")
  else:
    os.system("curl https://sdk.cloud.google.com > install.sh")
    os.system("bash install.sh --disable-prompts")
    os.system("sudo gcloud components install kubectl")


if __name__ == "__main__":
  main()