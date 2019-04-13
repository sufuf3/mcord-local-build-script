# https://github.com/opencord/cord-tester/blob/master/Jenkinsfile-mcord-local-build#L150

mkdir ~/cord
cd ~/cord && git clone https://gerrit.opencord.org/automation-tools

# Install K8S, Helm, Openstack
sh ~/cord/automation-tools/openstack-helm/openstack-helm-dev-setup.sh

# Install SR-IOV CNI and SR-IOV Network Device Plugin
kubectl apply -f  cord/helm-charts/mcord/cni-config/02-network-crd.yaml

# Install M-CORD Data Plane Services
helm install -n mcord-data-plane --namespace epc cord/mcord-data-plane

# Install M-CORD BBU Services
helm install -n mcord-bbu --namespace epc cord/mcord-bbu

# Install CDN Local Services
ngic_sgi_net_ip=$(kubectl exec -n epc ngic-dp-0 ifconfig sgi-net | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')
helm install -n cdn-local --set remote_ip="10.90.0.152" --set spgwu_sgiip=\$ngic_sgi_net_ip --namespace epc cord/mcord-cdn-local

# Install CORD Kafka
helm install --version 0.8.8 --set configurationOverrides."offsets\\.topic\\.replication\\.factor"=1 --set configurationOverrides."log\\.retention\\.hours"=4 --set configurationOverrides."log\\.message\\.timestamp\\.type"="LogAppendTime" --set replicas=1 --set persistence.enabled=false --set zookeeper.replicaCount=1 --set zookeeper.persistence.enabled=false -n cord-kafka incubator/kafka

# Install Monitoring Infrastructure
helm install -n nem-monitoring cord/nem-monitoring --version 1.0.1
sh ~/helm-repo-tools/wait_for_pods.sh

# Install Monitoring Infrastructure
helm install -n onos cord/onos --version 1.1.0

# Install ONOS progRAN
helm install -n onos-progran cord/onos-progran
kubectl get pods | grep -i onos-progran | grep -i running | grep 1/1 | wc -l

# Install xos-core
helm install -n xos-core cord/xos-core --version 2.3.3

# Install M-CORD Profile
helm install -n mcord cord/mcord

# Install SEBA Profile
helm install -n seba cord/seba-services --set fabric.enabled=false --set onos-service.enabled=false --version 1.0.5

# Install base-kubernetes
helm install -n base-kubernetes cord/base-kubernetes --version 1.0.2

# Install att workflow
helm install --set att-workflow-driver.kafkaService=cord-kafka -n att-workflow --version 1.0.2 cord/att-workflow

# Install voltha
helm install -n voltha cord/voltha --set etcd.cluster.enabled=false --version 1.0.3

# Configure MCORD - Fabric
# curl -s -H "xos-username:admin@opencord.org" -H "xos-password:letmein" -X POST --data-binary @${configFileName}-fabric.yaml http://${deployment_config.nodes[0].ip}:30007/run | grep -i "created models" | wc -l

# Configure SEBA - Fabric and whitelist
# curl -s -H "xos-username:admin@opencord.org" -H "xos-password:letmein" -X POST --data-binary @${configFileName}-fabric.yaml http://${deployment_config.nodes[0].ip}:30007/run | grep -i "created models" | wc -l

# Configure SEBA - Subscriber
# curl -s -H 'xos-username:admin@opencord.org' -H 'xos-password:letmein' -X POST --data-binary @${configFileName}-subscriber.yaml http://${deployment_config.nodes[0].ip}:30007/run | grep -i "created models" | wc -l

# Configure SEBA - OLT
# curl -H 'xos-username:admin@opencord.org' -H 'xos-password:letmein' -X POST --data-binary @${configFileName}-olt.yaml http://${deployment_config.nodes[0].ip}:30007/run | grep -i "created models" | wc -l
