# OpenShift NFS Server exporting CVMFS mounts

This project deploys an NFS server in a stateful set exposing a defined list of CVMFS mounts. It functions in a similar fasion as the cvmfs-csi approach but doesn't make use of privileged DaemonSets.

NOTE: Scalability has not been tested, but a HorizontalPodAutoScaler mechanism is put in place for the StatefulSet in case the pod(s) start running low on resources
Server is based on the configuration at <https://github.com/mappedinn/kubernetes-nfs-volume-on-gke>.

## Usage (for Openshift)
* A privileged service account is needed for this setup to work. It will only be used to manage the server since user pods will not need to do any fuse-related operations.

* An Openshift template is provided under the kubernetes folder. To list the parameters for the template run: 
```
$ oc process --parameters -f nfs-server-template.yaml
NAME                 DESCRIPTION                                                                             GENERATOR           VALUE
CVMFS_REPOSITORIES   A space ' ' separated string of CVMFS repositories to provision                                             config-osg.opensciencegrid.org cms.cern.ch oasis.opensciencegrid.org singularity.opensciencegrid.org
STORAGE_CLASS_NAME   The storage class name to provision NFS cache                                                               ocs-storagecluster-cephfs
SERVICE_ACCT         Which service account will be used for this deploymet (Might need special privileges)                       nfs-serviceaccount
EXPERIMENT           Ideally, we should have one of these per experiment, or VO                                                  genericVo
```
* To instantiate the template:
```
oc process -f kubernetes/nfs-server-template.yaml -p CVMFS_REPOSITORIES="config-osg.opensciencegrid.org cms.cern.ch oasis.opensciencegrid.org singularity.opensciencegrid.org unpacked.cern.ch" -p EXPERIMENT=cms | oc apply -f -
```
* This will result in the creation of a statefulSet capable of exporting CVMFS mounts via NFS inside your Openshift/Kubernetes cluster
