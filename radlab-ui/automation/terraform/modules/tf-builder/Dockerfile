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

FROM alpine:3.15

ARG TERRAFORM_VERSION
ARG TERRAFORM_VERSION_SHA256SUM

COPY terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN echo "${TERRAFORM_VERSION_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > checksum && sha256sum -c checksum
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip

FROM gcr.io/cloud-builders/gcloud

RUN apt-get -y -qq update && \
    apt-get install -y -qq curl && \
    apt-get install -y -qq python3-pip && \
    apt-get install -y -qq python3-venv && \
    apt-get clean

RUN curl -o /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq && \
      chmod +x /usr/local/bin/jq

COPY --from=0 terraform /usr/bin/terraform
COPY entrypoint.bash /builder/entrypoint.bash

ENTRYPOINT ["/builder/entrypoint.bash"]


