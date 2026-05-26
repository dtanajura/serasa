ServerName="mongodb-account-iam-c"
ClusterName="mongodb-account-iam"
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
letra=$(echo $ServerName | awk '{split($0,a,"-"); print a[4]}')
if [ $letra = "a" ]; 
then 
    openssl rand -base64 756 > /etc/mongodb/ssl/clusterdigital-services.key
else
# Copiar o conteudo do certificado em A
    cat > /etc/mongodb/ssl/clusterdigital-services.key << EOF
56zHkJMdKfpcp2+qf9XoTKlVjz6KzIeVolZaJsFrWChDfBqI/F2b0l96fhMT7ood
WcYi85GklMFFLb7C5WUH5FRspyU1rRaQiK4CEXNf/5nK8rBsAl24Y17GYvjbbE/A
1ytSU9SiUoOgwuaOM2rB4GqB8G7tgcvrW9RQx5a1ExG60dkiMduYoFjfNKsZOMvV
cLC9QFTyBIyvuxfdzy82D18+PKwRXbHmx7OFBQaa5iwh/uu2e6RHQIYvWQx0Tcpy
hbVS5EU7QbDk7bfiTxS3GVo3Nvna2ysc6pr2Xqs6guzND8UU54tLkO5tKQmESzdW
axIDTxjihozrGi+po+stAjTu+UR2S+b+IgGdhrFOU41NK+uzCKL/dA6AMKyBD/mF
pqRnKSZMTvbmr6W1iRk1//6NYDk2NdXJjrYSvd0dRRooTWhGHNTkmkDMB80x44b+
zUng267FMG3IPe82By2O3BtNQngKDGzgqeP/nZ3s3W60/cOX5V0tYT7hh93Xe/+S
vJbUcu/uh7Yt0gfa1pajyIeoShAgagkhyHZQdltzp9WarbkZsjfbi6sgalVFhYUp
keTYFjxq6fHjwRd5KnKlgaM6kE+7mv5i7NV+iRFwpF9bnCs5HS7IcUdzqg0Zv9sa
l1ic5ZwbVISQs4vu6+00UiVBOO5UOkTopTIrqLAfTs30NcWuFhTK+0W+GsnQry0y
3lC/NdeN7uXSahRHSMYZX+MAYvrxBsKOYa2LHRSOrXhZGkAo1u7aznIKjetMaXAg
+BB6AfysfgdYdpnVJ6JNyo11bD3pLaFRyHWfPJR1KPOFaBzn0wfeKk5lOxoFsPe6
3HkQyGBAxrzhvBPe95MSTjwu8VJZgUHo5PtJNC+8Dv8ta+Q395CJ9hRxXjzF/WMs
9co4w414KSXlnwKz04fdRLSW1VcBAcBtCBG7I2TU/XIg88OEXzfQ7apWyBRc/gHc
++NWmNxHyCP8JhQX3EjBrjVphwS6/RKzUONmRDqtWNyi9BzC
EOF

fi
cat /etc/mongodb/ssl/clusterdigital-services.key
chmod 400 /etc/mongodb/ssl/clusterdigital-services.key
chown -v mongod:mongod /etc/mongodb/ssl/clusterdigital-services.key

# 06 - Ativar o serviço de Mongo
systemctl start mongod
systemctl enable mongod
systemctl status mongod

# 07 - Instalar MongoSH
yum install -y mongodb-mongosh