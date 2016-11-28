#!/bin/bash
# install nuxeo in a smartos LX zone
# for further info also see: http://blog.smartcore.net.au/nuxeo-ecm-smartos-lx-zone-setup/

# block fuse install because it will fail due to kernel module
cat >>/etc/apt/preferences <<EOF
Package: fuse
Pin: origin ""
Pin-Priority: -1
EOF


# install current Java JDK
mkdir /usr/lib/jvm/ 
F=jdk-8u112-linux-x64.tar.gz
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u112-b15/$F"
tar -xzf $F -C /usr/lib/jvm/
rm $F
update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.8.0_112/bin/java 99999

# nuxeo prerequirements
locale-gen en_US.UTF-8
dpkg-reconfigure locales
wget -q -O- http://apt.nuxeo.org/nuxeo.key | sudo apt-key add -
echo "deb http://apt.nuxeo.org/ $(lsb_release -cs) releases" >/etc/apt/sources.list.d/nuxeo.list
apt-get update

# install nuxeo
F=nuxeo_8.3-01_all.deb
wget http://apt.nuxeo.org/pool/fasttracks/${F}

cat >>/tmp/nuxeo.config.dat <<EOF
Name: nuxeo/bind-address
Template: nuxeo/bind-address
Value: 0.0.0.0
Owners: nuxeo
Flags: seen

Name: nuxeo/database
Template: nuxeo/database
Value: Autoconfigure PostgreSQL
Owners: nuxeo
Flags: seen

Name: nuxeo/http-port
Template: nuxeo/http-port
Value: 8080
Owners: nuxeo
Flags: seen
EOF
env DEBIAN_FRONTEND=noninteractive DEBCONF_DB_FALLBACK='File{/tmp/nuxeo.config.dat}'  dpkg -i ${F}
env DEBIAN_FRONTEND=noninteractive DEBCONF_DB_FALLBACK='File{/tmp/nuxeo.config.dat}'  apt-get install -f -y

# clean up
rm ${F}
apt-get autoclean
apt-get autoremove

# apply performance tuning per: http://public.dev.nuxeo.com/~ben/bench-10m/
F=/etc/postgresql/9.3/nuxeodb/postgresql.conf
cp $F $F.orig
for i in effective_cache_size=16GB shared_buffers=10GB max_prepared_transactions=128 work_mem=64MB maintenance_work_mem=1GB wal_buffers=24MB checkpoint_completion_target=0.8 checkpoint_segments=32 checkpoint_timeout=15min fsync=off full_page_writes=off log_min_duration_statement=80ms log_rotation_size=100MB synchronous_commit=off track_activities=on track_counts=on max_connections=64 random_page_cost=2 ; 
do 
  if grep -q "^${i/=*}" ${F}; then
    sed -i "s/^${i/=*}.*/$i/p" ${F};
  else 
    echo $i >> ${F};
  fi
done
# double check values:
for i in effective_cache_size=16GB shared_buffers=10GB max_prepared_transactions=128 work_mem=64MB maintenance_work_mem=1GB wal_buffers=24MB checkpoint_completion_target=0.8 checkpoint_segments=32 checkpoint_timeout=15min fsync=off full_page_writes=off log_min_duration_statement=80ms log_rotation_size=100MB synchronous_commit=off track_activities=on track_counts=on max_connections=64 random_page_cost=2 ; do echo; echo "${i}: "; grep "^${i/=*}" ${F}; done

F=/etc/nuxeo/nuxeo.conf
cp $F $F.orig
sed -i 's/JAVA_OPTS=-Xms.*/JAVA_OPTS=-Xms3g -Xmx3g -XX:MaxPermSize=256m -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000 -XX:SoftRefLRUPolicyMSPerMB=0 -Djava.net.preferIPv4Stack=true/' $F

/etc/init.d/nuxeo restart
