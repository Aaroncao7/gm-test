mkdir /tmp/hyperledger
sudo chmod  -R 777 /tmp/hyperledger
sudo cp ./gmbin/* /usr/local/bin/


# 3.2 配置Org0的CA服务
# 再强调一下，本文中的几个CA服务器都是根服务器，彼此之间没有任何关系，所以上一步骤的TLS CA服务器在这一部分并没有用到。
# 同样，本文使用Docker容器启动CA服务器。
mkdir -p /tmp/hyperledger/org0/ca
sudo chmod -R 777 /tmp/hyperledger/org0/ca
docker-compose -f docker-compose/org0-ca.yaml up -d
sleep 1
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org0/ca/admin
 fabric-ca-client enroll -d -u http://org0-admin:org0-adminpw@0.0.0.0:7053 --tls.certfiles /tmp/hyperledger/org0/ca/crypto/ca-cert.pem
# 在本组织中共有两个用户：orderer节点和admin用户(这里的admin和管理员是不同的。)
# 将他们注册到org0的CA服务器
 fabric-ca-client register -d --id.name orderer1-org0 --id.secret ordererpw --id.type orderer -u http://0.0.0.0:7053 --tls.certfiles /tmp/hyperledger/org0/ca/crypto/ca-cert.pem 
 fabric-ca-client register -d --id.name admin-org0 --id.secret org0adminpw --id.type admin --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert" -u http://0.0.0.0:7053 --tls.certfiles /tmp/hyperledger/org0/ca/crypto/ca-cert.pem 
# 命令执行完之后，将会注册一个Orderer节点的身份和一个Admin的身份。同时在工作目录下的org0子文件夹中会有两个文件夹：crypto和admin。crypto中是CA服务器的配置信息，admin是服务器管理员的身份信息。

# 3.3 配置Org1的CA服务
mkdir -p /tmp/hyperledger/org1/ca
sudo chmod -R 777 /tmp/hyperledger/org1/ca
docker-compose -f docker-compose/org1-ca.yaml up -d
sleep 1
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/ca/crypto/ca-cert.pem

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org1/ca/admin

 fabric-ca-client enroll -d -u http://org1-admin:org1-adminpw@0.0.0.0:7054 --tls.certfiles /tmp/hyperledger/org1/ca/crypto/ca-cert.pem

# 组织一种共有四个用户：peer1,peer2,admin,user,分别注册他们
 fabric-ca-client register -d --id.name peer1-org1 --id.secret peer1PW --id.type peer -u http://0.0.0.0:7054 --tls.certfiles /tmp/hyperledger/org1/ca/crypto/ca-cert.pem

 fabric-ca-client register -d --id.name peer2-org1 --id.secret peer2PW --id.type peer -u http://0.0.0.0:7054 --tls.certfiles /tmp/hyperledger/org1/ca/crypto/ca-cert.pem

 fabric-ca-client register -d --id.name admin-org1 --id.secret org1AdminPW --id.type admin -u http://0.0.0.0:7054 --tls.certfiles /tmp/hyperledger/org1/ca/crypto/ca-cert.pem

 fabric-ca-client register -d --id.name user-org1 --id.secret org1UserPW --id.type client -u http://0.0.0.0:7054 --tls.certfiles /tmp/hyperledger/org1/ca/crypto/ca-cert.pem


# 4、组织一节点配置
mkdir -p /tmp/hyperledger/org1/peer1/assets/ca/
sudo chmod -R 777 /tmp/hyperledger/org1/peer1/assets
cp /tmp/hyperledger/org1/ca/crypto/ca-cert.pem /tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org1/peer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

# 登陆peer1节点到org1 CA 服务器上
# will create msp floder under /tmp/hyperledger/org1/peer1 
fabric-ca-client enroll -d -u http://peer1-org1:peer1PW@0.0.0.0:7054 --tls.certfiles /tmp/hyperledger/org1/ca/crypto/ca-cert.pem 

# 4.3 admin
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org1/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u http://admin-org1:org1AdminPW@0.0.0.0:7054 --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert" --tls.certfiles /tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem

mkdir /tmp/hyperledger/org1/peer1/msp/admincerts
cp /tmp/hyperledger/org1/admin/msp/signcerts/cert.pem /tmp/hyperledger/org1/peer1/msp/admincerts/org1-admin-cert.pem

mkdir /tmp/hyperledger/org1/admin/msp/admincerts
cp /tmp/hyperledger/org1/admin/msp/signcerts/cert.pem /tmp/hyperledger/org1/admin/msp/admincerts/org1-admin-cert.pem

# 4.4启动peer节点
# 到这里，已经配置好了一个节点，所以我们就可以启动这个节点了，当然在之后和orderer节点一起启动也可以，不过忙活了这么多，还是应该提前看到一下所做的工作的成果的！
# 附上peer1节点的容器配置信息：
# peer1节点
docker-compose -f docker-compose/org1-peer1.yaml up -d
sleep 1


mkdir -p /tmp/hyperledger/org0/orderer/assets/ca/
cp /tmp/hyperledger/org0/ca/crypto/ca-cert.pem /tmp/hyperledger/org0/orderer/assets/ca/org0-ca-cert.pem 
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org0/orderer
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org0/orderer/assets/ca/org0-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

# 登录order节点到org0 CA服务器上
fabric-ca-client enroll -d -u http://orderer1-org0:ordererpw@0.0.0.0:7053 --tls.certfiles /tmp/hyperledger/org0/orderer/assets/ca/org0-ca-cert.pem

# 6.2 admin
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org0/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org0/orderer/assets/ca/org0-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

# 登录admin 用户获取msp
fabric-ca-client enroll -d -u http://admin-org0:org0adminpw@0.0.0.0:7053 --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert" --tls.certfiles /tmp/hyperledger/org0/orderer/assets/ca/org0-ca-cert.pem
# 复制证书到admincerts文件夹:
mkdir /tmp/hyperledger/org0/orderer/msp/admincerts
cp /tmp/hyperledger/org0/admin/msp/signcerts/cert.pem /tmp/hyperledger/org0/orderer/msp/admincerts/orderer-admin-cert.pem

mkdir /tmp/hyperledger/org0/admin/msp/admincerts
cp /tmp/hyperledger/org0/admin/msp/signcerts/cert.pem /tmp/hyperledger/org0/admin/msp/admincerts/org0-admin-cert.pem


# 证书都准备好了之后我们还需要在每个msp文件下添加一个config.yaml
# NodeOUs:
#   Enable: true
#   ClientOUIdentifier:
#     #修改对应的证书名称
#     Certificate: cacerts/0-0-0-0-7053.pem
#     OrganizationalUnitIdentifier: client
#   PeerOUIdentifier:
#     Certificate: cacerts/0-0-0-0-7053.pem
#     OrganizationalUnitIdentifier: peer
#   AdminOUIdentifier:
#     Certificate: cacerts/0-0-0-0-7053.pem
#     OrganizationalUnitIdentifier: admin
#   OrdererOUIdentifier:
#     Certificate: cacerts/0-0-0-0-7053.pem
#     OrganizationalUnitIdentifier: orderer
# 需要org0，org1 下所有msp目录下都添加。
# ./config.sh

mkdir /tmp/hyperledger/configtx/ 
mkdir -p /tmp/hyperledger/configtx/org0/msp
mkdir -p /tmp/hyperledger/configtx/org1/msp

cp -r /tmp/hyperledger/org0/admin/msp /tmp/hyperledger/configtx/org0/
cp -r /tmp/hyperledger/org1/admin/msp /tmp/hyperledger/configtx/org1/

# 7.3 生成创世区块和通道信息
cp configtx.yaml /tmp/hyperledger/configtx/
mkdir /tmp/hyperledger/configtx/system-genesis-block 
mkdir /tmp/hyperledger/configtx/channel-artifacts
configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock /tmp/hyperledger/configtx/system-genesis-block/genesis.block -configPath /tmp/hyperledger/configtx/

# 生成通道
export CHANNEL_NAME=mychannel
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx /tmp/hyperledger/configtx/channel-artifacts/${CHANNEL_NAME}.tx -channelID ${CHANNEL_NAME} -configPath /tmp/hyperledger/configtx/

# 锚节点更新配置
export orgmsp=org1MSP
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate /tmp/hyperledger/configtx/channel-artifacts/${orgmsp}anchors.tx -channelID ${CHANNEL_NAME} -asOrg ${orgmsp} -configPath /tmp/hyperledger/configtx/


echo '创世区块文件通&道信息生成后启动orderer节'
docker-compose -f docker-compose/org0-order.yaml up -d

docker-compose -f docker-compose/org1-cli.yaml up -d
docker exec -it cli-org1 bash

export CHANNEL_NAME=mychannel
export ORDERER_CA=/tmp/hyperledger/org0/orderer/msp/admincerts/orderer-admin-cert.pem
export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp
cd /tmp/hyperledger/configtx

# peer channel create -o orderer1-org0:7050 -c ${CHANNEL_NAME} --ordererTLSHostnameOverride orderer1-org0 -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block --tls --cafile ${ORDERER_CA}


