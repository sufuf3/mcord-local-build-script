# https://guide.opencord.org/cord-6.1/platform.html

mkdir ~/cord
cd ~/cord && git clone https://gerrit.opencord.org/automation-tools
cd ~/cord && git clone https://gerrit.opencord.org/helm-charts

# Install K8S, Helm, Openstack
sh ~/cord/automation-tools/openstack-helm/openstack-helm-dev-setup.sh

cd ~/cord/helm-charts && git checkout 6.0.4
ssh-keygen -t rsa
ssh-copy-id winlab@winlabciab
cp ~/.ssh/id_rsa ~/cord/helm-charts/xos-profiles/base-openstack/files/node_key

# Install the CORD Platform
helm repo add cord https://charts.opencord.org
helm repo update
helm install -n cord-platform cord/cord-platform --version=6.1.0

# base-openstack
cd ~/cord/helm-charts/ && helm dep update xos-profiles/base-openstack
cd ~/cord/helm-charts/ && helm install -n base-openstack xos-profiles/base-openstack \
    --set computeNodes.master.name=`hostname` \
    --set vtn-service.sshUser=`whoami`


helm install -n onos-fabric -f ~/cord/helm-charts/configs/onos-fabric.yaml onos
helm install -n onos-cord -f ~/cord/helm-charts/configs/onos-cord.yaml onos

# deploy the M-CORD profile
cd ~/cord/helm-charts/ && helm dep update xos-profiles/mcord
cd ~/cord/helm-charts/ && helm install -n mcord xos-profiles/mcord --set proxySshUser=winlab

# GUI is IP:30001 username/password is from ~/cord/helm-charts/xos-core/values.yaml
# Ref:
# 1. https://guide.opencord.org/cord-6.1/operating_cord/gui.html
# 2. https://guide.opencord.org/cord-6.1/charts/xos-core.html
