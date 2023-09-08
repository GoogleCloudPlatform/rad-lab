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

sudo apt-get update
sudo apt-get install -y postgresql-client

# Creating Tables and dummy data in Postgres DB
PGPASSWORD=${DB_PASS} psql "host=${DB_IP} port=5432 sslmode=disable dbname=${DB_NAME} user=${DB_USER}" psql <<EOF
\x
DROP TABLE IF EXISTS accounts;
\x
CREATE TABLE IF NOT EXISTS accounts ( 
      name VARCHAR ( 50 ) NOT NULL, 
      email VARCHAR ( 50 ) UNIQUE NOT NULL,
      sector VARCHAR ( 50 ) NOT NULL); 
\x
GRANT SELECT, UPDATE, INSERT, DELETE ON accounts TO PUBLIC;
\x
ALTER TABLE accounts OWNER TO postgres;
\x
INSERT INTO accounts (name, email, sector)
VALUES
    ('Kris Marrier','kris@myfoo.gov','Federal'),
    ('Fatima Saylors','fsaylors@myfoo.gov','State & Local'),
    ('James Baker','jbaker@baz.edu','EdTech'),
    ('Jose Stockham','jose@mybar.gov','State & Local'),
    ('Tonette Williams','twilliams@myqux.edu','EdTech');
\x
SELECT * FROM accounts;
EOF