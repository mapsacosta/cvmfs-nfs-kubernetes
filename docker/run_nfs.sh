#!/bin/bash

# Copyright 2019 Maria Acosta Flechas.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#----------------------------------
# Create a directory if it doesn't exist
#------------------------------------
create_dir() {
    if [ ! -d $1 ]
        then
        mkdir -p $1
    fi
}

#CVMFS_REPOSITORIES="config-osg.opensciencegrid.org cms.cern.ch oasis.opensciencegrid.org singularity.opensciencegrid.org"
echo Starting cvmfs-nfs server for $CVMFS_REPOSITORIES
echo "CVMFS_REPOSITORIES=$(echo $CVMFS_REPOSITORIES | tr ' ' ,)" >> /etc/cvmfs/default.local
cat /etc/cvmfs/default.local

n_fsid=0

for repo in $CVMFS_REPOSITORIES; 
   do echo "Processing -- $repo " ; 
      create_dir /cvmfs/$repo >/dev/null 2>&1
      echo "$repo /cvmfs/$repo cvmfs defaults,_netdev,nodev 0 0" >> /etc/fstab;  
      mount -t cvmfs $repo /cvmfs/$repo;
      repo_name=$(echo $repo | awk -F '.' '{print $1}');
      n_fsid=`expr $n_fsid + 1`
      echo "/cvmfs/$repo *(ro,sync,no_subtree_check,all_squash,fsid=$n_fsid)" >> /etc/exports;
done 

chmod o+rw /dev/fuse
cvmfs_config probe

#####

# Mini unit tests
## Source some CMS/VOMS specific setup scripts
if [ -f "/cvmfs/cms.cern.ch/cmsset_default.sh" ]; then
    source /cvmfs/cms.cern.ch/cmsset_default.sh
else
    echo -e "Unable to source /cvmfs/cms.cern.ch/cmsset_default.sh"
fi
if [ -f "/cvmfs/oasis.opensciencegrid.org/mis/osg-wn-client/current/el6-x86_64/setup.sh" ]; then
    source /cvmfs/oasis.opensciencegrid.org/mis/osg-wn-client/current/el6-x86_64/setup.sh
else
    echo -e "Unable to setup the grid utilities from /cvmfs/oasis.opensciencegrid.org/"
fi
#
## Needed to access FNAL EOS
export XrdSecGSISRVNAMES="cmseos.fnal.gov"
#
#####

function start_cvmfs_nfs()
{

    # start rpcbind if it is not started yet
    /usr/sbin/rpcinfo 127.0.0.1 > /dev/null 2>&1 ; s=$?
    if [ $s -ne 0 ]; then
       echo "Starting rpcbind"
       /usr/sbin/rpcbind -w
    fi

    mount -t nfsd nfsd /proc/fs/nfsd

    # -V 3: enable NFSv3
    /usr/sbin/rpc.mountd -N 2 -V 3

    /usr/sbin/exportfs -rav
    # -G 10 to reduce grace time to 10 seconds (the lowest allowed)
    /usr/sbin/rpc.nfsd -G 10 -N 2 -V 3
    /usr/sbin/rpc.statd --no-notify
    echo "NFS started"
}

function stop()
{
    echo "Stopping NFS"

    /usr/sbin/rpc.nfsd 0
    /usr/sbin/exportfs -au
    /usr/sbin/exportfs -f

    kill $( pidof rpc.mountd )
    umount /proc/fs/nfsd
    echo > /etc/exports
    exit 0
}


trap stop TERM

start_cvmfs_nfs
exportfs -rav

# Ugly hack to do nothing and wait for SIGTERM
while true; do
    sleep 5
done
