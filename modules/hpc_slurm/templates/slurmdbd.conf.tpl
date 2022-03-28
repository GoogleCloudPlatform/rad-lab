# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

AuthType=auth/munge
AuthAltTypes=auth/jwt
AuthAltParameters=jwt_key=${STATE_SAVE_LOCATION}/jwt_hs256.key

DbdHost=${CONTROLLER_HOST_NAME}
DebugLevel=debug

LogFile=${LOG_DIRECTORY}/slurmdbd.log
PidFile=/var/run/slurm/slurmdbd.pid

SlurmUser=slurm

StorageLoc=${SLURM_DB_NAME}

StorageType=accounting_storage/mysql
StorageHost=${SLURM_DB_HOST}
StoragePort=${SLURM_DB_PORT}
StorageUser=${SLURM_DB_USER}
StoragePass=${SLURM_DB_PASSWORD}
