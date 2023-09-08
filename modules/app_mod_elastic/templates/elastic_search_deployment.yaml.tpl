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

apiVersion: v1
kind: Namespace
metadata:
  name: ${NAMESPACE}
  annotations:
    name: ${NAMESPACE}
  labels:
    workload: ${NAMESPACE}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${IDENTITY_NAME}
  namespace: ${NAMESPACE}
  annotations:
    iam.gke.io/gcp-service-account: ${GCP_SERVICE_ACCOUNT}
---
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: elastic-search
  namespace: ${NAMESPACE}
spec:
  version: ${VERSION}
  serviceAccountName: ${IDENTITY_NAME}
  nodeSets:
  - name: default
    count: ${COUNT}
    config:
      node.store.allow_mmap: false
---
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: kibana
  namespace: ${NAMESPACE}
spec:
  version: ${VERSION}
  count: ${COUNT}
  serviceAccountName: ${IDENTITY_NAME}
  elasticsearchRef:
    name: elastic-search
