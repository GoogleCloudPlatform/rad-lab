#
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

set ::env(PDK_ROOT) "$::env(CONDA_PREFIX)/share/pdk"
set ::env(TCLLIBPATH) "$::env(CONDA_PREFIX)/opt/conda/lib/tcllib1.20"
set ::env(OL_INSTALL_DIR) "$::env(OPENLANE_ROOT)/install"
set ::env(OPENLANE_LOCAL_INSTALL) 1
set ::env(TEST_MISMATCHES) none
set ::env(RUN_CVC) 0
set ::env(RUN_KLAYOUT_XOR) 0
set ::env(RUN_KLAYOUT_DRC) 0
set ::env(RUN_KLAYOUT) 0
# https://github.com/The-OpenROAD-Project/OpenLane/issues/1195
set ::env(DIODE_INSERTION_STRATEGY) 0
set ::env(USE_ARC_ANTENNA_CHECK) 0
