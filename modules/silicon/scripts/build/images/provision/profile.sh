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

. /opt/conda/etc/profile.d/conda.sh
conda activate base
conda activate silicon

export OPENLANE_ROOT=/OpenLane
export PDK_ROOT=/opt/conda/envs/silicon/share/pdk
export TCLLIBPATH=/opt/conda/envs/silicon/lib/tcllib1.20
export OL_INSTALL_DIR=/OpenLane/install
export OPENLANE_LOCAL_INSTALL=1
export TEST_MISMATCHES=none
export PATH=$OPENLANE_ROOT:/OpenLane/scripts:$PATH
