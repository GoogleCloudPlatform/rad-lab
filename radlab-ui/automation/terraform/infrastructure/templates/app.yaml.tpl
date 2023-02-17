# Copyright 2023 Google LLC
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

runtime: nodejs16

service_account: ${UI_IDENTITY}

env_variables:
  PORT: 3000
  MODULE_DEPLOYMENT_BUCKET_NAME: ${MODULE_DEPLOYMENT_BUCKET_NAME}

automatic_scaling:
  max_instances: 10

handlers:
- url: /.*
  secure: always
  script: auto
