# org0
echo  'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    #修改对应的证书名称
    Certificate: cacerts/0-0-0-0-7053.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/0-0-0-0-7053.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/0-0-0-0-7053.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/0-0-0-0-7053.pem
    OrganizationalUnitIdentifier: orderer' > /tmp/hyperledger/org0/admin/msp/config.yaml
sudo chmod -R 777 /tmp/hyperledger/org0/ca/crypto/msp/
echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    #修改对应的证书名称
    Certificate: cacerts/0-0-0-0-7053.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/0-0-0-0-7053.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/0-0-0-0-7053.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/0-0-0-0-7053.pem
    OrganizationalUnitIdentifier: orderer' > /tmp/hyperledger/org0/ca/crypto/msp/config.yaml

echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    #修改对应的证书名称
    Certificate: cacerts/0-0-0-0-7053.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/0-0-0-0-7053.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/0-0-0-0-7053.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/0-0-0-0-7053.pem
    OrganizationalUnitIdentifier: orderer' > /tmp/hyperledger/org0/ca/admin/msp/config.yaml

echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    #修改对应的证书名称
    Certificate: cacerts/0-0-0-0-7053.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/0-0-0-0-7053.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/0-0-0-0-7053.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/0-0-0-0-7053.pem
    OrganizationalUnitIdentifier: orderer' > /tmp/hyperledger/org0/orderer/msp/config.yaml

# org1
echo  'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    #修改对应的证书名称
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: orderer' > /tmp/hyperledger/org1/admin/msp/config.yaml
sudo chmod -R 777 /tmp/hyperledger/org1/ca/crypto/msp/
echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    #修改对应的证书名称
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: orderer' > /tmp/hyperledger/org1/ca/crypto/msp/config.yaml

    echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    #修改对应的证书名称
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: orderer' > /tmp/hyperledger/org1/ca/admin/msp/config.yaml

echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    #修改对应的证书名称
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: orderer' > /tmp/hyperledger/org1/peer1/msp/config.yaml

echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    #修改对应的证书名称
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/0-0-0-0-7054.pem
    OrganizationalUnitIdentifier: orderer' > /tmp/hyperledger/org1/peer2/msp/config.yaml
