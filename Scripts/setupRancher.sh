#!/usr/bin/env bash

echo "========================================="
echo "Initiating Ubuntu package repo updation.."
echo "========================================="
sudo apt-get update

echo "========================================="
echo "Let's open up some firewalls!"
echo "========================================="
sudo iptables -A INPUT -p tcp --dport 9345 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport $RANCHER_PORT -j ACCEPT
sudo iptables -A INPUT -p udp --dport 500 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 4500 -j ACCEPT
sudo service iptables restart && sudo service iptables status

echo "========================================="
echo "Installing Linux kernel patches.."
echo "========================================="
sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual

echo "========================================="
echo "Installing helper packages for adding package repos.."
echo "========================================="
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

echo "========================================="
echo "Adding the Docker package repo.."
echo "========================================="
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

echo "========================================="
echo "Installing Docker CE, and adding the current user to the docker group.."
echo "========================================="
sudo apt-get update && sudo apt-get install -y docker-ce
sudo groupadd docker
sudo gpasswd -a $USER docker
sudo service docker restart

echo "========================================="
echo "Installing Rancher in HA mode.."
echo "========================================="
docker run -d --restart=unless-stopped -p $RANCHER_PORT:8080 -p 9345:9345 rancher/server \
     --db-host $RANCHER_DB_HOST --db-port 3306 --db-user $RANCHER_DB_USER --db-pass $RANCHER_DB_PASSWD --db-name $RANCHER_DB_NAME \
     --advertise-address $RANCHER_HOST_IP

echo "========================================="
echo "Docker CE and the Rancher orchestration system are now installed. Please head over to the Rancher dashboard to add all nodes to your new cluster."
echo "========================================="