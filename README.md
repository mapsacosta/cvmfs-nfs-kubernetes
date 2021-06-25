# OpenShift NFS Server exporting CVMFS mounts

This project deploys an NFS server in a stateful set exposing a defined list of CVMFS mounts. It functions in a similar fasion as the cvmfs-csi approach but doesn't make use of privileged DaemonSets.

NOTE: Scalability has not been tested, but a HorizontalPodAutoScaler mechanism is put in place for the StatefulSet in case the pod(s) start running low on resources
Server is based on the configuration at <https://github.com/mappedinn/kubernetes-nfs-volume-on-gke>.
