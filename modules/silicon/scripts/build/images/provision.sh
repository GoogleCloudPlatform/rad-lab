#!/bin/bash
#
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

set -e
trap "echo DaisyFailure: trapped error" ERR

env
OPENLANE_VERSION=master
PROVISION_DIR=/provision

SYSTEM_NAME=$(dmidecode -s system-product-name || true)

if [ -n "$(echo ${SYSTEM_NAME} | grep 'Google Compute Engine')" ]; then
echo "DaisyStatus: fetching provisioning script"
DAISY_SOURCES_PATH=$(curl -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/daisy-sources-path)
mkdir -p ${PROVISION_DIR}
gsutil -m rsync ${DAISY_SOURCES_PATH}/provision/ ${PROVISION_DIR}/ || true
fi

echo "DaisyStatus: installing conda-eda environment"
curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -C /usr/local -xvj bin/micromamba
micromamba create --yes -r /opt/conda -n silicon
micromamba install --yes -r /opt/conda -n silicon \
	   -c nodefaults -c main -c litex-hub \
	   openlane \
	   open_pdks.sky130a \
	   xls \
	   iverilog \
	   jupyterlab \
	   python \
	   pip
micromamba install --yes -r /opt/conda -n silicon -c conda-forge \
	   pyspice \
	   pymeep=*=mpi_mpich_* \
	   gdstk \
	   gdsfactory
/opt/conda/bin/python -m pip install \
		      klayout \
		      scrapbook[gcs] \
		      google-cloud-aiplatform \
		      cloudml-hypertune

echo "DaisyStatus: adding profile hook"
cp ${PROVISION_DIR}/profile.sh /etc/profile.d/silicon-design-profile.sh

echo "DaisySuccess: done"
