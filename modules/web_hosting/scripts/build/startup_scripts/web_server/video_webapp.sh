#!/bin/bash

# Copyright 2022 Google LLC
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

sudo apt-get update
sudo apt-get install -y postgresql-client
sudo apt-get install -y python3-pip
pip3 install Flask
cat <<EOF > ./video_flask.py
from flask import Flask
import os
 
app = Flask(__name__)
cmd = 'hostname'
output = os.popen(cmd).read()
hostname = output.split('\n')[0]
@app.route('/')
def hello_gcp():
    return "Hello healthcheck from instance:" + str(hostname)
 
@app.route('/video')
def hello_gcp_video():
    return "Hello from instance:" + str(hostname)
 
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
EOF
chmod 700 video_flask.py
sudo python3 video_flask.py