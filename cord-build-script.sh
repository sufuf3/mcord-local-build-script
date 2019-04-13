# https://guide.opencord.org/cord-6.1/platform.html

mkdir ~/cord
cd ~/cord && git clone https://gerrit.opencord.org/automation-tools
cd ~/cord && git clone https://gerrit.opencord.org/helm-charts

# Install K8S, Helm, Openstack
sh ~/cord/automation-tools/openstack-helm/openstack-helm-dev-setup.sh

# Install the CORD Platform
helm repo add cord https://charts.opencord.org
helm repo update
helm install -n cord-platform cord/cord-platform --version=6.1.0

# GUI is IP:30001 username/password is from ~/cord/helm-charts/xos-core/values.yaml
# Ref:
# 1. https://guide.opencord.org/cord-6.1/operating_cord/gui.html
# 2. https://guide.opencord.org/cord-6.1/charts/xos-core.html
