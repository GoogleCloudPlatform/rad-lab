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

# [START getting_started_gce_startup_script]
# Install or update needed software
sudo apt-get update
sudo apt-get install -yq git python3 python3-pip python3-distutils wget postgresql-client

# Download Cloud SQL Proxy
wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy

# Setup Cloud SQL Proxy
chmod +x cloud_sql_proxy
nohup ./cloud_sql_proxy -instances=$INSTANCE_CONNECTION_NAME=tcp:5432 -ip_address_types=PRIVATE &

# Fetch source code
sudo git clone -b web-hosting https://github.com/GoogleCloudPlatform/rad-lab.git

# Deploy Web App
sudo pip3 install -r rad-lab/modules/web_hosting/scripts/build/startup_scripts/sample_app/requirements.txt
# sudo python3 rad-lab/modules/web_hosting/scripts/build/startup_scripts/sample_app/app.py

sudo chmod -R 777 rad-lab

# Connect with pssql
# psql "host=127.0.0.1 sslmode=disable dbname=$CLOUD_SQL_DATABASE_NAME user=$CLOUD_SQL_USERNAME"

cat <<EOF > ./rad-lab/modules/web_hosting/scripts/build/startup_scripts/sample_app/app.py
import os
import sqlalchemy
from google.cloud.sql.connector import Connector, IPTypes
from flask import Flask, render_template, request, url_for, flash, redirect

# initialize connector
connector = Connector()

db_conn_name = "${INSTANCE_CONNECTION_NAME}"
db_user = "${CLOUD_SQL_USERNAME}"
db_pass = "${CLOUD_SQL_PASSWORD}"
db_name = "${CLOUD_SQL_DATABASE_NAME}"

app = Flask(__name__)

@app.route('/')
def index():
    accounts = []
    accounts = get_db_accounts(accounts)
    return render_template('index.html', accounts=accounts)

@app.route('/create', methods=('GET', 'POST'))
def create():
    accounts = []
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        sector = request.form['sector']

        if not name:
            flash('Name is required!')
        elif not email:
            flash('Email is required!')
        elif not sector:
            flash('Sector is required!')
        else:
            # Insert record in DB
            create_db_accounts(name, email, sector)
            return redirect(url_for('index'))

    return render_template('create.html')

# getconn now set to private IP
def getconn():

    conn = connector.connect(
      db_conn_name,
      "pg8000",
      user=db_user,
      password=db_pass,
      db=db_name,
      ip_type=IPTypes.PRIVATE,
    )
    return conn

def get_db_accounts(accounts):
    pool = sqlalchemy.create_engine("postgresql+pg8000://",creator=getconn,)
    with pool.connect() as db_conn:
        # query database
        result = db_conn.execute("SELECT * from accounts").fetchall()

    # Do something with the results
    for row in result:
        accounts.append({'name': row.name,'email': row.email, 'sector': row.sector})
    
    return accounts

def create_db_accounts(name, email, sector):
    pool = sqlalchemy.create_engine("postgresql+pg8000://",creator=getconn,)

    # insert statement
    insert_stmt = sqlalchemy.text(
        "INSERT INTO accounts (name, email, sector) VALUES (:name, :email, :sector)",
    )
    with pool.connect() as db_conn:
        # query database
        db_conn.execute(insert_stmt, name=name, email=email, sector=sector)

@app.route('/hc')
def hello_gcp():
    cmd = 'hostname'
    output = os.popen(cmd).read()
    hostname = output.split('\n')[0]
    return "Hello from instance:" + str(hostname)

# cleanup connector
connector.close()

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=80)
EOF
chmod 700 rad-lab/modules/web_hosting/scripts/build/startup_scripts/sample_app/app.py
sudo python3 rad-lab/modules/web_hosting/scripts/build/startup_scripts/sample_app/app.py
