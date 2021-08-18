#!/bin/bash

# 下面介绍下本文所采用的整体架构
# 三个组织

# Org0 ---> 组织0
# Org1 ---> 组织1
# Org2 ---> 组织2
# 组织中的成员

# Org0: 一个orderer节点,一个Org0的Admin节点
# Org1: 两个Peer节点,一个Org1的Admin节点,一个Org1的User节点
# Org2: 两个Peer节点,一个Org2的Admin节点,一个Org2的User节点
# 四台CA服务器

# TLS服务器：为网络中所有节点颁发TLS证书，用于通信的加密
# Org1的CA服务器：为组织1中所有用户颁发证书
# Org2的Ca服务器：为组织2中所有用户颁发证书
# Org0的CA服务器：为组织0中所有用户颁发证书

mkdir /tmp/hyperledger
sudo chmod  -R 777 /tmp/hyperledger
sudo cp ./tlsbin/* /usr/local/bin/
# 3
docker-compose -f docker-compose/tls-ca.yaml  up -d
sleep 1
# /tmp/hyperledger/fabric-ca/ 下面会出现crypto文件夹
# 在/tmp/hyperledger/fabric-ca/crypto/路径下的ca-cert.pem文件。这是TLS CA服务器的签名根证书，目的是用来对CA的TLS证书进行验证，同时也需要持有这个证书才可以进行证书的颁发。 多环境下我们需要将它复制到每一台机器上

# 3.1
# 第一步是在TLS CA服务器中注册用户，经过注册的用户才拥有TLS证书。
sudo chmod  -R 777 /tmp/hyperledger/fabric-ca-tls
# 设置环境变量&登陆
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/fabric-ca-tls/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/fabric-ca-tls/admin
fabric-ca-client enroll -d -u https://tls-ca-admin:tls-ca-adminpw@0.0.0.0:7052 --tls.certfiles /tmp/hyperledger/fabric-ca-tls/crypto/ca-cert.pem 
 # 登陆成功后会在/tmp/hyperledger/fabric-ca-tls/目录下生车给你admin文件夹，这里面是 admin相关的证书文件，并且只有登陆了admin,才具有权限进行用户注册，因为该用户具有CA的全部权限，相当于CA服务的root用户。

fabric-ca-client register -d --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7052 --tls.certfiles /tmp/hyperledger/fabric-ca-tls/crypto/ca-cert.pem --home=/tmp/hyperledger/fabric-ca-tls/admin

fabric-ca-client register -d --id.name peer2-org1 --id.secret peer2PW --id.type peer -u https://0.0.0.0:7052 --tls.certfiles /tmp/hyperledger/fabric-ca-tls/crypto/ca-cert.pem --home=/tmp/hyperledger/fabric-ca-tls/admin

fabric-ca-client register -d --id.name orderer1-org0 --id.secret ordererPW --id.type orderer -u https://0.0.0.0:7052 --tls.certfiles /tmp/hyperledger/fabric-ca-tls/crypto/ca-cert.pem --home=/tmp/hyperledger/fabric-ca-tls/admin

fabric-ca-client register -d --id.name admin-org1 --id.secret org1AdminPW --id.type admin -u https://0.0.0.0:7052 --tls.certfiles /tmp/hyperledger/fabric-ca-tls/crypto/ca-cert.pem --home=/tmp/hyperledger/fabric-ca-tls/admin

# 这里我们为各个节点注册TLS证书，之后Fabric网络的通信则需要通过这一步骤注册过的用户的TLS证书来进行TLS加密通信。
# 到这里我们只是注册了各个节点的身份，还没有获取到他们的证书。证书可以通过登录获取，不过暂时不着急获取他们的TLS证书。
# 接下来，我们对其他几个CA服务器进行配置。


# 3.2 配置Org0的CA服务
# 再强调一下，本文中的几个CA服务器都是根服务器，彼此之间没有任何关系，所以上一步骤的TLS CA服务器在这一部分并没有用到。
# 同样，本文使用Docker容器启动CA服务器。
mkdir -p /tmp/hyperledger/org0/ca
sudo chmod -R 777 /tmp/hyperledger/org0/ca
docker-compose -f docker-compose/org0-ca.yaml up -d
sleep 1
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org0/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org0/ca/admin
 fabric-ca-client enroll -d -u https://org0-admin:org0-adminpw@0.0.0.0:7053 --tls.certfiles /tmp/hyperledger/org0/ca/crypto/ca-cert.pem
# 在本组织中共有两个用户：orderer节点和admin用户(这里的admin和管理员是不同的。)
# 将他们注册到org0的CA服务器
 fabric-ca-client register -d --id.name orderer1-org0 --id.secret ordererpw --id.type orderer -u https://0.0.0.0:7053 --tls.certfiles /tmp/hyperledger/org0/ca/crypto/ca-cert.pem 
 fabric-ca-client register -d --id.name admin-org0 --id.secret org0adminpw --id.type admin --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert" -u https://0.0.0.0:7053 --tls.certfiles /tmp/hyperledger/org0/ca/crypto/ca-cert.pem 
# 命令执行完之后，将会注册一个Orderer节点的身份和一个Admin的身份。同时在工作目录下的org0子文件夹中会有两个文件夹：crypto和admin。crypto中是CA服务器的配置信息，admin是服务器管理员的身份信息。

# 3.3 配置Org1的CA服务
mkdir -p /tmp/hyperledger/org1/ca
sudo chmod -R 777 /tmp/hyperledger/org1/ca
docker-compose -f docker-compose/org1-ca.yaml up -d
sleep 1
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/ca/crypto/ca-cert.pem

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org1/ca/admin

 fabric-ca-client enroll -d -u https://org1-admin:org1-adminpw@0.0.0.0:7054 --tls.certfiles /tmp/hyperledger/org1/ca/crypto/ca-cert.pem

# 组织一种共有四个用户：peer1,peer2,admin,user,分别注册他们
 fabric-ca-client register -d --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7054 --tls.certfiles /tmp/hyperledger/org1/ca/crypto/ca-cert.pem

 fabric-ca-client register -d --id.name peer2-org1 --id.secret peer2PW --id.type peer -u https://0.0.0.0:7054 --tls.certfiles /tmp/hyperledger/org1/ca/crypto/ca-cert.pem

 fabric-ca-client register -d --id.name admin-org1 --id.secret org1AdminPW --id.type admin -u https://0.0.0.0:7054 --tls.certfiles /tmp/hyperledger/org1/ca/crypto/ca-cert.pem

 fabric-ca-client register -d --id.name user-org1 --id.secret org1UserPW --id.type client -u https://0.0.0.0:7054 --tls.certfiles /tmp/hyperledger/org1/ca/crypto/ca-cert.pem


# 4、组织一节点配置
mkdir -p /tmp/hyperledger/org1/peer1/assets/ca/
sudo chmod -R 777 /tmp/hyperledger/org1/peer1/assets
cp /tmp/hyperledger/org1/ca/crypto/ca-cert.pem /tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem

export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org1/peer1
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

# 登陆peer1节点到org1 CA 服务器上
# will create msp floder under /tmp/hyperledger/org1/peer1 
fabric-ca-client enroll -d -u https://peer1-org1:peer1PW@0.0.0.0:7054 --tls.certfiles /tmp/hyperledger/org1/ca/crypto/ca-cert.pem 

# 这一步完成后在/tmp/hyperledger/org1/peer1下出现一个msp文件夹，这是peer1节点的msp证书。
# 接下来是TLS证书
mkdir -p /tmp/hyperledger/org1/peer1/assets/tls-ca
sudo chmod -R 777 /tmp/hyperledger/org1/peer1/assets/tls-ca
cp /tmp/hyperledger/fabric-ca-tls/crypto/ca-cert.pem  /tmp/hyperledger/org1/peer1/assets/tls-ca/tls-ca-cert.pem

export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/peer1/assets/tls-ca/tls-ca-cert.pem

fabric-ca-client enroll -d -u https://peer1-org1:peer1PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer1-org1 --tls.certfiles /tmp/hyperledger/org1/peer1/assets/tls-ca/tls-ca-cert.pem

# 这一步完成后，在/tmp/hyperledger/org1/peer1下会出现一个tls-msp文件夹，这是peer1节点的TLS证书。
# 修改秘钥文件名
# 为什么要修改呢，进入这个文件夹看一下就知道了,由服务器生成的秘钥文件名是一长串无规则的字符串，后期我们使用的时候难道要一个字符一个字符地输入？
mv /tmp/hyperledger/org1/peer1/tls-msp/keystore/*_sk /tmp/hyperledger/org1/peer1/tls-msp/keystore/key.pem


# # 4.2 peer2
# mkdir -p /tmp/hyperledger/org1/peer2/assets/ca/
# sudo chmod -R 777 /tmp/hyperledger/org1/peer2/assets/ca/
# cp /tmp/hyperledger/org1/ca/crypto/ca-cert.pem /tmp/hyperledger/org1/peer2/assets/ca/org1-ca-cert.pem
# export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org1/peer2
# export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/peer2/assets/ca/org1-ca-cert.pem
# export FABRIC_CA_CLIENT_MSPDIR=msp
# fabric-ca-client enroll -d -u https://peer2-org1:peer2PW@0.0.0.0:7054 --tls.certfiles /tmp/hyperledger/org1/ca/crypto/ca-cert.pem 

# # 这一步完成后在/tmp/hyperledger/org1/peer2下出现一个msp文件夹，这是peer2节点的msp证书。

# # 接下来是TLS证书
# mkdir -p /tmp/hyperledger/org1/peer2/assets/tls-ca/
# sudo chmod -R 777 /tmp/hyperledger/org1/peer2/assets/tls-ca/
# cp /tmp/hyperledger/fabric-ca-tls/crypto/ca-cert.pem  /tmp/hyperledger/org1/peer2/assets/tls-ca/tls-ca-cert.pem


# export FABRIC_CA_CLIENT_MSPDIR=tls-msp
# export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/peer2/assets/tls-ca/tls-ca-cert.pem
# # 登录peer2节点的TLS CA服务器上
# fabric-ca-client enroll -d -u https://peer2-org1:peer2PW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts peer2-org1 --tls.certfiles /tmp/hyperledger/org1/peer2/assets/tls-ca/tls-ca-cert.pem
# # 这一步完成后，在/tmp/hyperledger/org1/peer2下会出现一个tls-msp文件夹，这是peer2节点的TLS证书。
# # 修改秘钥文件名
# mv /tmp/hyperledger/org1/peer2/tls-msp/keystore/*_sk /tmp/hyperledger/org1/peer2/tls-msp/keystore/key.pem

# 4.3 admin
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org1/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
fabric-ca-client enroll -d -u https://admin-org1:org1AdminPW@0.0.0.0:7054 --tls.certfiles /tmp/hyperledger/org1/peer1/assets/ca/org1-ca-cert.pem

# 接下来是TLS证书
# 配置环境变量
export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/peer1/assets/tls-ca/tls-ca-cert.pem

fabric-ca-client enroll -d -u https://admin-org1:org1AdminPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts admin-org1 --tls.certfiles /tmp/hyperledger/org1/peer1/assets/tls-ca/tls-ca-cert.pem

mkdir /tmp/hyperledger/org1/peer1/msp/admincerts
cp /tmp/hyperledger/org1/admin/msp/signcerts/cert.pem /tmp/hyperledger/org1/peer1/msp/admincerts/org1-admin-cert.pem

mkdir /tmp/hyperledger/org1/peer2/msp/admincerts
cp /tmp/hyperledger/org1/admin/msp/signcerts/cert.pem /tmp/hyperledger/org1/peer2/msp/admincerts/org1-admin-cert.pem

# 4.4启动peer节点
# 到这里，已经配置好了一个节点，所以我们就可以启动这个节点了，当然在之后和orderer节点一起启动也可以，不过忙活了这么多，还是应该提前看到一下所做的工作的成果的！
# 附上peer1节点的容器配置信息：
# peer1节点
docker-compose -f docker-compose/org1-peer1.yaml up -d
sleep 1
# docker-compose -f docker-compose/org1-peer2.yaml up -d
# sleep 1

# 6.1 orderer
mkdir -p /tmp/hyperledger/org0/orderer/assets/ca/
cp /tmp/hyperledger/org0/ca/crypto/ca-cert.pem /tmp/hyperledger/org0/orderer/assets/ca/org0-ca-cert.pem 
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org0/orderer
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org0/orderer/assets/ca/org0-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp
# 登录order节点到org0 CA服务器上
fabric-ca-client enroll -d -u https://orderer1-org0:ordererpw@0.0.0.0:7053 --tls.certfiles /tmp/hyperledger/org0/orderer/assets/ca/org0-ca-cert.pem

# 接下来是TLS证书   
mkdir /tmp/hyperledger/org0/orderer/assets/tls-ca/
cp /tmp/hyperledger/fabric-ca-tls/crypto/ca-cert.pem  /tmp/hyperledger/org0/orderer/assets/tls-ca/tls-ca-cert.pem

export FABRIC_CA_CLIENT_MSPDIR=tls-msp
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org0/orderer/assets/tls-ca/tls-ca-cert.pem
fabric-ca-client enroll -d -u https://orderer1-org0:ordererPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts orderer1-org0 --tls.certfiles /tmp/hyperledger/org0/orderer/assets/tls-ca/tls-ca-cert.pem
mv /tmp/hyperledger/org0/orderer/tls-msp/keystore/*_sk /tmp/hyperledger/org0/orderer/tls-msp/keystore/key.pem


# 6.2 admin
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org0/admin
export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org0/orderer/assets/ca/org0-ca-cert.pem
export FABRIC_CA_CLIENT_MSPDIR=msp

# 登录admin 用户获取msp
fabric-ca-client enroll -d -u https://admin-org0:org0adminpw@0.0.0.0:7053 --tls.certfiles /tmp/hyperledger/org0/orderer/assets/ca/org0-ca-cert.pem
# 复制证书到admincerts文件夹:
mkdir /tmp/hyperledger/org0/orderer/msp/admincerts
cp /tmp/hyperledger/org0/admin/msp/signcerts/cert.pem /tmp/hyperledger/org0/orderer/msp/admincerts/orderer-admin-cert.pem

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
# 需要org0，org1, org2 下所有msp目录下都添加。

./config.sh

path=`pwd`
# 7、Fabric 网络
# 证书都生成好了，即将要启动网络了。不过在启动网络之前还是有很多准备工作需要做。
# org0
mkdir -p /tmp/hyperledger/configtx && cd /tmp/hyperledger/configtx
mkdir org0
cp -r ../org0/admin/msp org0/
cd  org0/msp && mkdir tlscacerts && cd tlscacerts
cp  /tmp/hyperledger/org0/orderer/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem ./

# org1
cd /tmp/hyperledger/configtx && mkdir org1 
cp -r ../org1/admin/msp org1/
cd org1/msp && mkdir tlscacerts && cd tlscacerts
cp /tmp/hyperledger/org1/admin/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem ./

cd $path
# 7.2 configtx.yaml文件配置
cp configtx.yaml /tmp/hyperledger/configtx

# 7.3 生成创世区块和通道信息
mkdir /tmp/hyperledger/configtx/system-genesis-block 
mkdir /tmp/hyperledger/configtx/channel-artifacts
configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock /tmp/hyperledger/configtx/system-genesis-block/genesis.block -configPath /tmp/hyperledger/configtx/


# 生成通道
export CHANNEL_NAME=mychannel
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx /tmp/hyperledger/configtx/channel-artifacts/${CHANNEL_NAME}.tx -channelID ${CHANNEL_NAME} -configPath /tmp/hyperledger/configtx/

# 锚节点更新配置
export orgmsp=org1MSP
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate /tmp/hyperledger/configtx/channel-artifacts/${orgmsp}anchors.tx -channelID ${CHANNEL_NAME} -asOrg ${orgmsp} -configPath /tmp/hyperledger/configtx/


# 创世区块文件通&道信息生成后启动orderer节
docker-compose -f docker-compose/org0-order.yaml up -d

# 启动组织一的cli
docker-compose -f docker-compose/org1-cli.yaml up -d


# 8、创建&加入通道
# -----------------------------cli-org1-------------------------------

# docker exec -it cli-org1 bash

# export CHANNEL_NAME=mychannel
# export ORDERER_CA=/tmp/hyperledger/org0/orderer/tls-msp/tlscacerts/tls-0-0-0-0-7052.pem
# export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp

# cd /tmp/hyperledger/configtx

# peer channel create -o orderer1-org0:7050 -c ${CHANNEL_NAME} --ordererTLSHostnameOverride orderer1-org0 -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block --tls --cafile ${ORDERER_CA}


# export CORE_PEER_ADDRESS=peer1-org1:7051
# peer channel join -b ./channel-artifacts/mychannel.block

# export CORE_PEER_ADDRESS=peer2-org1:7051
# peer channel join -b ./channel-artifacts/mychannel.block


# export CORE_PEER_LOCALMSPID=org1MSP
# peer channel update -o orderer1-org0:7050 --ordererTLSHostnameOverride orderer1-org0 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile $ORDERER_CA

# -----------------------------cli-org1-end-------------------------------
# installChaincode
# -----------------------------------------------
# docker exec -it cli-org1 bash
# cd /tmp/hyperledger/org1/peer1/assets/chaincode
# export CORE_PEER_MSPCONFIGPATH=/tmp/hyperledger/org1/admin/msp

# peer lifecycle chaincode install chaincodeTest.tar.gz



# -----------------------------------------------