FROM mendix/rootfs:ubi8

RUN set -e; set -x ;\
  rpm -ivh http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-8-6.el8.noarch.rpm ;\
  rpm -ivh http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-8-6.el8.noarch.rpm ;\
  rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm ;\
  microdnf install ImageMagick ;\
  microdnf clean all ;

