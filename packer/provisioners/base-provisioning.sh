#!/bin/bash

application_file_path="/vagrant/installed-application.md"
rke2_kubeconfig_file="/etc/rancher/rke2/rke2.yaml"
vagrant_kubeconfig_dir="/home/vagrant/.kube"
vagrant_kubeconfig_file="config"
root_kubeconfig_dir="/root/.kube"
rancher_cli_version="2.4.10"

# install rancher client
echo ">>>>>> rancher client"
sudo wget -q -O /tmp/rancher-linux-amd64-v${rancher_cli_version}.tar.gz https://releases.rancher.com/cli2/v${rancher_cli_version}/rancher-linux-amd64-v${rancher_cli_version}.tar.gz
sudo tar -xzf /tmp/rancher-linux-amd64-v${rancher_cli_version}.tar.gz -C /opt
sudo ln /opt/rancher-v${rancher_cli_version}/rancher /usr/bin/rancher
RANCHER_VERSION=$(rancher --version | awk  '{print $3}' | tr --delete v)
echo "rancher client = ${RANCHER_VERSION}"

# install rancherd
echo ">>>>>> rancherd"
sudo curl -sfL https://get.rancher.io | sh -

# enable rancherd service
echo ">>>>>> rancherd service"
sudo systemctl enable rancherd-server.service
sudo systemctl start rancherd-server.service
sudo systemctl status rancherd-server.service
retcode=$?
if [ $retcode -ne 0 ]; then
  exit 1
fi

# check kubeconfig file
echo "Wait kubeconfig ..."
while :
do
  if [ -f "${rke2_kubeconfig_file}" ]; then
    break;
  fi
  echo "."
  sleep 5
done

# copy kubeconfig for vagrant
if [ ! -d "${vagrant_kubeconfig_dir}" ]; then
  sudo mkdir -p ${vagrant_kubeconfig_dir}
fi
sudo cp ${rke2_kubeconfig_file} ${vagrant_kubeconfig_dir}/${vagrant_kubeconfig_file}
sudo chown -R vagrant:vagrant ${vagrant_kubeconfig_dir}

# copy kubeconfig for root
sudo cp -r ${vagrant_kubeconfig_dir} ${root_kubeconfig_dir}

# add rke2 bin directory to path
echo "export PATH=$PATH:/var/lib/rancher/rke2/bin" >> /home/vagrant/.bashrc
export PATH=$PATH:/var/lib/rancher/rke2/bin

# check installation
echo "Wait kubernetes cluster ..."
sleep 180
while :
do
  sudo rancherd reset-admin > /dev/null 2>&1
  retcode=$?
  if [ $retcode -eq 0 ]; then
    break
  fi
  echo "."
  sleep 30
done
sleep 10
echo "Kubernetes is up & running!"
# kubectl get daemonset rancher -n cattle-system
# kubectl get pod -n cattle-system
sudo rancherd reset-admin

# set version
RANCHERD_VERSION=$(rancherd --version | grep rancherd | awk  '{print $3}' | tr --delete v)
RANCHER_VERSION=$(rancher --version | awk  '{print $3}' | tr --delete v)
echo "# Installed application "  > $application_file_path
echo "***                     " >> $application_file_path
echo "> RancherD: $RANCHERD_VERSION" >> $application_file_path
echo "> Rancher Client: $RANCHER_VERSION" >> $application_file_path


