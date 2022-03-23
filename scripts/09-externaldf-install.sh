#!/bin/bash

source "./scripts/functions.sh"
source "./scripts/00b-load-env-variables.sh"

exec > >(tee -i generated/$(basename $0).log)
exec 2>&1
date

#Install some basic tools
for XDFHOST in `cat ./generated/novalist |grep $PROJECT_ID|grep externaldf-host-1| awk '{ split($12, v, "="); print v[2]}'`
do
echo "Installing basic pre-reqs"
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo apt-get -y install cloud-init docker git wget apache2 dpkg-dev openjdk-11-jdk nfs-common"
echo "Creating group/usr mapr"
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo groupadd mapr -g 5000 || true # ignore error"
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo useradd mapr -u 5000 -g mapr || true # ignore error"
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo mkdir /home/mapr;sudo chown mapr:mapr /home/mapr|| true # ignore error"  
scp  -o StrictHostKeyChecking=no -i ./generated/controller.prv_key ./files/mapr-pass.sh ubuntu@$XDFHOST:/tmp/
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo chmod +x /tmp/mapr-pass.sh;sudo /tmp/mapr-pass.sh"
done

for XDFHOST in `cat ./generated/novalist |grep $PROJECT_ID|grep externaldf-host-1| awk '{ split($12, v, "="); print v[2]}'`
do
#echo "Creating Directories for local repo"
#ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo mkdir /var/www/html/xdf700;sudo chmod o+w /var/www/html/xdf700"
#ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo mkdir /var/www/html/eep810;sudo chmod o+w /var/www/html/eep810"

#echo "Copying Core 7.0 and EEP 8.1.0 files from mac to external-df-host-1"
#rsync --progress --partial --recursive -avz -e 'ssh -i ./generated/controller.prv_key' ~/Ezmeral/0210-70/xdf700/dfaf.mip.storage.hpecorp.net/artifactory/prestage/releases-dev/v7.0.0/ubuntu ubuntu@$XDFHOST:/var/www/html/xdf700/
#rsync --progress --partial --recursive -avz -e 'ssh -i ./generated/controller.prv_key' ~/Ezmeral/0210-70/eep810/dfaf.mip.storage.hpecorp.net/artifactory/list/prestage/releases-dev/MEP/MEP-8.1.0/ubuntu ubuntu@$XDFHOST:/var/www/html/eep810/

#echo "Setup Local Repo for Core 7.0 and EEP 8.1.0"
#ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo chmod 666 /etc/apt/sources.list"
#ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo echo 'deb [trusted=yes] http://localhost/xdf700/ubuntu binary bionic' >> /etc/apt/sources.list"
#ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo echo 'deb [trusted=yes] http://localhost/eep810/ubuntu binary bionic' >> /etc/apt/sources.list"
#ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo systemctl restart apache2"
#ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo systemctl status apache2"

echo "Setup Repo for Core 7.0 and EEP 8.1.0"
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo chmod 777 /etc/apt/sources.list.d"
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo echo 'deb https://package.mapr.hpe.com/releases/v7.0.0/ubuntu/ binary bionic' >> /etc/apt/sources.list.d/package_mapr_hpe_com_releases_v7_0_0_ubuntu.list"
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo echo 'deb https://package.mapr.hpe.com/releases/MEP/MEP-8.1//ubuntu/ binary bionic' >> /etc/apt/sources.list.d/package_mapr_hpe_com_releases_MEP_MEP_8_1_ubuntu.list"
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "wget -O - https://package.mapr.hpe.com/releases/pub/maprgpg.key | sudo apt-key add -"
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo apt-get update"

echo "Finished with Repo Setup!!"
echo "Installing DF packages"
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo apt-get install -y mapr-hadoop-client mapr-apiserver mapr-cldb mapr-core mapr-fileserver mapr-gateway mapr-nfs mapr-mastgateway mapr-s3server mapr-webserver mapr-zookeeper mapr-data-access-gateway mapr-collectd mapr-grafana mapr-opentsdb"
echo "Done Installing DF packages"

#echo "Restart http"
#ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo systemctl restart apache2"
#ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo systemctl status apache2"

echo "Installing EEP packages"
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo apt-get install -y  mapr-spark mapr-spark-master mapr-spark-historyserver mapr-spark-thriftserver mapr-livy mapr-ksql mapr-kafka mapr-hivemetastore mapr-hive mapr-hiveserver2 mapr-hivewebhcat mapr-nodemanager mapr-resourcemanager"
echo "Done Installing DF packages"
echo "Finished Installing DF packages. Please Run Configure.sh"
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo echo /dev/sdb >> /home/ubuntu/disklist"
echo "Running Configure.sh"
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo /opt/mapr/server/configure.sh -Z $XDFHOST -C $XDFHOST -HS $XDFHOST -F /home/ubuntu/disklist -N xdf.demo.com -dare -secure -genkeys -u mapr -g mapr -v -no-autostart"
echo "Starting Zookeeper and Warden"
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo systemctl restart mapr-zookeeper"
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo /opt/mapr/initscripts/zookeeper qstatus"
ssh -q -o StrictHostKeyChecking=no -i ./generated/controller.prv_key -T ubuntu@$XDFHOST "sudo systemctl restart mapr-warden"
echo "Started Zookeeper and Warden"
echo "Please obtain and apply a License to the Eternal DF Cluster."
done