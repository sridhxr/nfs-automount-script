#!/bin/sh
#########################################################################
# Script: automount_nim.sh
# Purpose: Automatically mount NIM server on AIX client servers
#
# Description:
# - This script attempts to connect to NIM servers using telnet on ports 111 and 2049
#   to verify NFS service availability.
# - If connectivity is successful, it tries to mount the following in order:
#     1. NIM Server Mount Point 01: 10.119.uv.xy:/mount01
#     2. NIM Server Mount Point 02 : 10.119.uv.xy:/mount02
#     3. NIM Server 02: 10.119.ab.cd.:/nim2mount01
# - If all mount attempts fail, it will display an error: "All mount attempts failed."
#
#
#########################################################################
#
##### NIM SERVER DETAILS #####
# NIM Server 01:	NIM01	-	10.119.uv.xy
# NIM Server 02 :	NIM02	-	10.119.ab.cd
#
################################
 
### Variables ###
MOUNT_POINTS="10.119.uv.xy:/mount01 10.119.uv.xy:/mount02 10.119.ab.cd.:/nim02mount01"
MOUNT_DIR="/mnt"
 
### Check if mount directory exists, or else create it ###
if [ ! -d "$MOUNT_DIR" ]; then
  echo "$MOUNT_DIR does not exist. Creating it..."
  mkdir -p "$MOUNT_DIR"
  if [ $? -ne 0 ]; then
    echo "Failed to create directory $MOUNT_DIR. Exiting."
    exit 1
  fi
fi
 
#Checking if mount directory is already mounted and Exiting ###
if df -gt | grep -iq "$MOUNT_DIR"; then
  echo "$MOUNT_DIR is already mounted. Exiting.."
  exit 1
fi
 
### Attempting to mount each NIM server ###
for MOUNT_SRC in $MOUNT_POINTS; do
  SERVER=$(echo $MOUNT_SRC | cut -d: -f1)
 
  echo "Checking NFS port connectivity with NIM server: $SERVER"
 
  ## Check port 111 connectivity ###
  echo "Checking port 111 connectivity..."
  if ! echo | telnet $SERVER 111 | grep -iq "Connected"; then
    echo "Port 111 is not connecting to $SERVER"
    continue
  fi
 
  ## Check port 2049 connectivity ###
  echo "Checking port 2049 connectivity..."
  if ! echo | telnet $SERVER 2049 | grep -iq "Connected"; then
    echo "Port 2049 is not connecting to $SERVER"
    continue
  fi
 
  ## Attempting to mount the NFS mount point ###
  echo "Attempting to mount $MOUNT_SRC on $MOUNT_DIR"
  mount -o vers=4 "$MOUNT_SRC" "$MOUNT_DIR"
  if [ $? -eq 0 ]; then
    echo "Successfully mounted $MOUNT_SRC"
    exit 0
  else
    echo "Failed to mount $MOUNT_SRC"
  fi
done
 
echo "All mount attempts failed."
exit 1