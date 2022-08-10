#! /bin/bash
apt-get update
apt-get install -y python3-pip
pip3 install Flask
cat <<EOF > ./www_flask.py
from flask import Flask
import os
 
app = Flask(__name__)
cmd = 'hostname'
output = os.popen(cmd).read()
hostname = output.split('\n')[0]
@app.route('/')
def hello_gcp():
    return "Hello from instance:" + str(hostname)
 
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
EOF
chmod 700 www_flask.py
sudo python3 www_flask.py