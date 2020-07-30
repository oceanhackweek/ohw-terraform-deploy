#! /bin/bash
echo "Running start-up script as root"

# Auto-Mount EFS Drive  
yum install -y amazon-efs-utils
MOUNTPOINT=/mnt/efs
mkdir $MOUNTPOINT

sudo mount -t efs fs-cea205cb:/ $MOUNTPOINT
echo "Ephemeral disk mounted to $MOUNTPOINT"