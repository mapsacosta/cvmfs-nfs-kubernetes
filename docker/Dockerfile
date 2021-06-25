FROM centos:8

RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    yum -y install https://repo.opensciencegrid.org/osg/3.5/osg-3.5-el8-release-latest.rpm

#Installing CVMFS and others
RUN yum -y install osg-oasis strace nfs-utils

# Configuring CVMFS and others
COPY cvmfs/default.local /etc/cvmfs/default.local
COPY cvmfs/osgstorage.org.conf /etc/cvmfs/domain.d/osgstorage.org.conf
COPY cvmfs/run.sh /run.sh
COPY cvmfs/mount_cvmfs.sh /mount_cvmfs.sh
COPY cvmfs/opensciencegrid.org.pub /etc/cvmfs/keys/opensciencegrid.org/opensciencegrid.org.pub 


COPY run_nfs.sh /usr/local/bin/run_nfs.sh
RUN chmod a+r /etc/cvmfs/keys/opensciencegrid.org/opensciencegrid.org.pub && chmod 775 /usr/local/bin/run_nfs.sh && echo "user_allow_other" >> /etc/fuse.conf

USER root
CMD ["/usr/local/bin/run_nfs.sh"]
