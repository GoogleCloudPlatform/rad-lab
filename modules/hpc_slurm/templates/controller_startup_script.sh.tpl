#!/usr/bin/env bash

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

FLAGFILE=/slurm/slurm_configured_do_not_remove
if [ -f $FLAGFILE ]; then
  echo "Startup script - Slurm was already configured, exit startup script."
  exit 0
fi

SLURM_CONFIG_PATH="/usr/local/etc/slurm/"

echo "Downloading Slurm configuration ..."
if ! (gsutil cp ${SLURM_CONFIG_FILE} $${SLURM_CONFIG_PATH}/slurm.conf); then
  echo "Failed to download Slurm configuration ..."
  exit 1
fi

chown slurm:slurm $${SLURM_CONFIG_PATH}/slurm.conf

mkdir -p ${SLURM_STATE_DIR}

chown slurm:slurm ${SLURM_STATE_DIR}

echo "Creating JWT key ..."
dd if=/dev/urandom bs=32 count=1 > ${SLURM_STATE_DIR}/jwt_hs256.key
chown slurm:slurm ${SLURM_STATE_DIR}/jwt_hs256.key

echo "Creating DB files ..."
if ! (gsutil cp ${SLURM_DB_CONFIG_FILE} $${SLURM_CONFIG_PATH}/slurmdbd.conf); then
  echo "Failed to download Slurm DB configuration ..."
  exit 1
fi
chown slurm:slurm $${SLURM_CONFIG_PATH}/slurmdbd.conf
chmod 0600 $${SLURM_CONFIG_PATH}/slurmdbd.conf

echo "Copying cgroup.conf configuration ..."
if ! (gsutil cp ${CGROUP_CONFIG_FILE} $${SLURM_CONFIG_TARGET}/cgroup.conf); then
  echo "Failed to download cgroup.conf ..."
  exit 1
fi
chown slurm:slurm $${SLURM_CONFIG_PATH}/cgroup.conf

echo "Enabling slurmdbd service ..."
systemctl enable slurmdbd
systemctl start slurmdbd

echo "Enabling Slurmctld service ..."
systemctl enable slurmctld
systemctl start slurmctld

echo "Startup completed, create flag file to stop re-running the startup script ..."
touch $${FLAGFILE}