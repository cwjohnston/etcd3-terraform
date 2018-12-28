INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

cd /home/centos

curl -s https://packagecloud.io/install/repositories/sensu/stable/script.rpm.sh | sudo bash
sudo yum install -y sensu-go-backend sensu-go-agent sensu-go-cli epel-release
sudo yum install -y jq awslci nagios-plugins-all

cat << EOF > /etc/sensu/backend.yml
---
no-embed-etcd: true
etcd-advertise-client-urls: "$ETCD_ELB"
state-dir: "/var/lib/sensu/sensu-backend"
log-level: "debug"
EOF

cat << EOF > /etc/sensu/agent.yml
---
id: "demo-backend-${INSTANCE_ID:2}"
subscriptions:
  - rhel
  - backend
backend-url:
  - ws://127.0.0.1:8081

statsd-event-handlers: "cat"
log-level: "debug"
EOF

sudo mkdir /usr/local/share/ca-certificates/sensu

sudo update-ca-certificates
sudo systemctl enable sensu-backend
sudo systemctl enable sensu-agent
sudo systemctl start sensu-backend
sudo systemctl start sensu-agent
