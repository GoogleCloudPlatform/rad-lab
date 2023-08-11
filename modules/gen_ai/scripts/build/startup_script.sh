#!/bin/bash

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

echo "Startup script started."

mkdir -p -m 777 /home/jupyter/genai-git
cd /home/jupyter/genai-git
git clone https://github.com/GoogleCloudPlatform/generative-ai.git
umask 000
chmod -R 777 /home/jupyter/genai-git

echo "Startup script finished."

#auto-shutdown script - enable if needed

# wget https://raw.githubusercontent.com/GoogleCloudPlatform/ai-platform-samples/master/notebooks/tools/auto-shutdown/install.sh
# wget https://raw.githubusercontent.com/GoogleCloudPlatform/ai-platform-samples/master/notebooks/tools/auto-shutdown/ashutdown.service
# wget https://raw.githubusercontent.com/GoogleCloudPlatform/ai-platform-samples/master/notebooks/tools/auto-shutdown/ashutdown

# ./install.sh
