ServerName="mongodb-digital-security-services-b"
ClusterName="mongodb-digital-security-services"
# 01 - Configurar Propmt
cat > .bashrc << EOF
PS1="[\u@$ServerName \W]# " 

# User specific aliases and functions
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
EOF

cat .bashrc

# 02 - Configurar permissão para pasta /var/run/mongodb
cat > /usr/lib/tmpfiles.d/mongodb.conf << EOF
d /run/mongodb 0750 mongod mongod -
EOF

# 03 - Criar pasta /var/run/mongodb
mkdir /var/run/mongodb
chown -Rv mongod:mongod /var/run/mongodb
ls -ld /var/run/mongodb

# 04 - Configurar o mongod.conf
cat > /etc/mongod.conf << EOF
# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  quiet: false
  verbosity: 0
  traceAllExceptions: false
  syslogFacility: daemon
  path: /var/log/mongodb/mongod.log
  logAppend: true
  destination: file
  timeStampFormat: iso8601-utc
  logRotate: reopen

# Where and how to store data.
storage:
   dbPath: /var/lib/mongo
   directoryPerDB: false
   #indexBuildRetry: true
   syncPeriodSecs: 60
   journal:
     enabled: true
#     commitIntervalMs: 100
   engine: wiredTiger
   wiredTiger:
     engineConfig:
        journalCompressor: snappy
        directoryForIndexes: true
     collectionConfig:
        blockCompressor: snappy
     indexConfig:
        prefixCompression: true

#  engine:
#  wiredTiger:

# how the process runs
processManagement:
# fork: true
  timeZoneInfo: /usr/share/zoneinfo
  pidFilePath: /var/run/mongodb/mongod.pid

# network interfaces
net:
  port: 27017
  bindIp: 0.0.0.0
  maxIncomingConnections: 1000000
  wireObjectCheck: true
  ipv6: false
  unixDomainSocket:
    enabled: true
    pathPrefix: /var/run/mongodb
#  ssl:
#    mode: preferSSL
  tls:
    mode: preferTLS
#    PEMKeyFile: /etc/mongodb/ssl/mongodb.pem
    certificateKeyFile: /etc/mongodb/ssl/mongodb.pem
#    weakCertificateValidation: false
#    allowConnectionsWithoutCertificates: false
#    allowInvalidCertificates: true


#security:
security:
 authorization: enabled
 javascriptEnabled: true
 keyFile: /etc/mongodb/ssl/clusterdigital-services.key
 clusterAuthMode: keyFile

#operationProfiling:
operationProfiling:
  slowOpThresholdMs: 100
  mode: slowOp

#replication:
replication:
  oplogSizeMB: 5120
  replSetName: $ClusterName


#sharding:

## Enterprise-Only Options

#auditLog:

#snmp:
EOF

grep "replSetName" /etc/mongod.conf 
# 05 - Cria o certificado do REPLICASET
# Copiar o conteudo do certificado em A
cat > /etc/mongodb/ssl/clusterdigital-services.key << EOF
MiTxhsHQsg/+moGk3sn9uKIygy6GE7xyeitMeaSpYHcDQvJcnlzOzfz3rBXnBIZQ
i119aAOFmmSYaIbX5G0dT4wIiF8jxWxAdy/LwG7lCfnCxlu01M3OqFgIeNDzKftD
WQqgai8SH56HBM70DAgAM8Rmx/x/gpnZn7bWZIkXjzJTP4/dTQQoWnMJybGc+tCf
h6Sq/MPeM3k3cB9d317390xedC0A/6PAMKa/qUCXoNXZqQGGv2z0yr+BYNXT4vMW
u7Thxc6NylMHJsFrhbK0wzsuMxqBHfUimsyTPQ1xeJZnDEO3i1f+oc9eqcnQu6mI
L/H6IPK8diqFMJbdsEMoUOx3iH+tBo6x2tOe/WBcvHTQDHVIhKSBSQ23ztAtP1Pq
JQjr7sChgyEaarbgGWja4WWGVgCrF3+LT3RUaN1T1jAm9qY8kNACNxXBhISGTlwz
5sZGZf3QaJR1AL7W1ovWSVer7jQW5Cknj2qe4IrTksbH78nw2bbSo0VHqys5vzIA
XdP1Zru76yDpeZVv4dqv6UCpfrtAuLLTJCeWebOfWhjhbWWTOa3dzo2IPTU/7mA1
Xg/0BPJ5zDFXX0FmqUDn9QhZQvGiuBJBWkWzhWZn0TPUGJMvDRKSvAlstaFv+jLH
aarEwTpBP7FJQ3eD5xSCBwATcthl6J8HpMSX7H61ARYbgFRC0p9MjOIjpSW+T1al
INnYMXh6C2k9ueVQVolhIVOfcZTDPeIMzsjVK2wlldV84PS2MlICjrZZIKCYfNK4
k5r7LkNYBpqw9gdMsuN5F0vrd5DNolqLgehgnvN4s46CUT03StdlRNRArNUKfn53
rI8rAgEJsh28u4OjnxTU28umy+7Mb0aaC3Z5kdck0m3BFsAcyvFYD0WKMNexlu61
BNeJgoe544qrIhZWLMW2qa3e+6IqVb9gIH7+biP424tGMhALSSmmn6wOGuD0e0FX
Msfi4mBXB05K5QfTBVbdcTvffQKt+usP5up4OlLly3ytet8D
EOF

cat /etc/mongodb/ssl/clusterdigital-services.key
chmod 400 /etc/mongodb/ssl/clusterdigital-services.key
chown -v mongod:mongod /etc/mongodb/ssl/clusterdigital-services.key

# 06 - Ativar o serviço de Mongo
systemctl start mongod
systemctl enable mongod
systemctl status mongod

# 07 - Instalar MongoSH
yum install -y mongodb-mongosh