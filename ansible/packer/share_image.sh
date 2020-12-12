#!/bin/bash

if [ $# -ne 1 ]
then
  echo "Usage: $0 image_id"
  exit 1
elif [[ "$OS_TENANT_NAME" != "paas-images" ]]
then
  echo "Error: Must be run from paas-images project."
  exit 2
fi
IMAGE_ID=$1
PAAS_IMAGES=3983ad6bb0824316a9c9e22ec3c0f261
DEV_ADMIN=114b166823b24104bc933cfee6dec112
DEV_MESOS=9cae3d5140094e51b3c5a4ed7f567adb
PROD_ADMIN=8ca297c686194bc28b69898e3712384e
PROD_MESOS=7a9340800b9f4b9ea75c02fb938841c7
STAGING_ADMIN=494a4b03b541408ba09ea82ea7ceea30
STAGING_MESOS=72b069d1b7e2479c83fa41c026abffed

echo "Ignore 409s for images that are already shared..."

for PROJECT
in \
   $DEV_ADMIN \
   $DEV_MESOS \
   $PROD_ADMIN \
   $PROD_MESOS \
   $STAGING_ADMIN \
   $STAGING_MESOS
do
  OS_REGION_NAME=NCE openstack image add project $IMAGE_ID $PROJECT
  OS_REGION_NAME=NCW openstack image add project $IMAGE_ID $PROJECT
done
