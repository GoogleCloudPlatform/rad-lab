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

ARG REPOSITORY_LOCATION
ARG PROJECT_ID
ARG REPOSITORY_ID
ARG OPENLANE_VERSION
FROM $REPOSITORY_LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_ID/openlane-pdk:$OPENLANE_VERSION

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -b -f -p /conda-env
# install openlane dependencies in conda environment
RUN /conda-env/bin/conda install -c conda-forge -y python pip
# install openlane dependencies in conda environment
RUN /conda-env/bin/python -m pip install click pyyaml matplotlib "jinja2<3.0.0" pandas install XlsxWriter
RUN /conda-env/bin/conda install -c conda-forge -y jupyterlab gdstk

RUN groupadd --gid 1001 jupyter
RUN useradd --uid 1000 --gid 1001 jupyter
USER jupyter
EXPOSE 8080
ENV JUPYTER_PORT 8080

WORKDIR /home/jupyter
ENTRYPOINT ["/bin/bash", "-c", "source /conda-env/bin/activate && jupyter lab --ip 0.0.0.0 --allow-root --ServerApp.token='' --ServerApp.allow_origin_pat='^https?://.*\\.notebooks\\.googleusercontent\\.com' --ServerApp.allow_remote_access=True"]
