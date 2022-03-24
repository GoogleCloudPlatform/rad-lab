#!/usr/bin/env bash

/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

FLAGFILE=/slurm/slurm_configured_do_not_remove
if [ -f $FLAGFILE ]; then
  echo "Startup script - Slurm was already configured, exit startup script."
  exit 0
fi

INTERNET_CONNECTION="$(ping -q -w1 -c1 google.com &>/dev/null && echo online || echo offline)"
if [ $INTERNET_CONNECTION == "offline" ]; then
  echo "Startup script - A connection to the internet was not detected."
fi

SETUP_SCRIPT="/tmp/setup.py"
SETUP_SCRIPT_URL="http://metadata.google.internal/computeMetadata/v1/instance/attributes/setup-script"
HEADER="Metadata-Flavor: Google"

echo "Startup script - Downloading setup script ..."
if ! ( wget -nv --header "Metadata-Flavor: Google" SETUP_SCRIPT_URL -O $SETUP_SCRIPT ); then
  echo "Failed to download setup script from the metadata."
  exit 1
fi

echo "Running script to run the setup."
chmod +x $SETUP_SCRIPT
$SETUP_SCRIPT
