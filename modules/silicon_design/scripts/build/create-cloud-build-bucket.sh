#!/bin/bash

# https://cloud.google.com/build/docs/configuring-builds/use-community-and-custom-builders

PROJECT=$1
REGION=$2

# If there is a resource location constraint (constraints/gcp.resourceLocations) 
# this script will fail unless you create a GCS Bucket named [PROJECT_ID]_cloudbuild 
# that is located in the region you are running it. This bucket needs to be created
# by means other than terraform because terraform complains that the naming violates the convention.
# See https://stackoverflow.com/questions/53206667/cloud-build-fails-with-resource-location-constraint
gsutil mb -p "$PROJECT" -l "$REGION" -b 'on' -c 'STANDARD' "gs://${PROJECT}_cloudbuild"
