#!/bin/bash

# root
if [[ `whoami` != "root" ]];then
  echo "root permission required"
fi

# ip
export IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
echo 'Current ip:' ${IP}

# docker
yum install -y docker-ce
mkdir -p /etc/docker/tls
echo "{
    \"hosts\": [\"unix:///var/run/docker.sock\", \"tcp://${IP}:2376\"],
    \"tlsverify\": true,
    \"tlscacert\": \"/etc/docker/tls/ca.crt\",
    \"tlscert\": \"/etc/docker/tls/server.crt\",
    \"tlskey\": \"/etc/docker/tls/server.key\",
    \"cluster-store\": \"etcd://${ERU_ETCD}\"
}" > /etc/docker/daemon.json
sed 's/-H fd:\/\///' /usr/lib/systemd/system/docker.service
systemctl daemon-reload
openssl req -x509 -newkey rsa:2048 -nodes -keyout ca.key -out ca.crt -days 3650 -subj /C=CN
openssl req -newkey rsa:2048 -nodes -keyout server.key -out server.csr -subj /CN=${IP}
openssl x509 -req -CA ca.crt -CAkey ca.key -CAcreateserial -in server.csr -out server.crt -days 3650
openssl req -newkey rsa:2048 -nodes -keyout client.key -out client.csr -subj /CN=client
openssl x509 -req -CA ca.crt -CAkey ca.key -CAcreateserial -in client.csr -out client.crt -days 3650
chmod 600 ca.key client.key server.key
rm -rf server.csr client.csr
mv ca.* client.* server.* /etc/docker/tls
