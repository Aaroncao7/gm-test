mkdir /tmp/hyperledger
sudo chmod  -R 777 /tmp/hyperledger
sudo cp ./gmbin/* /usr/local/bin/

cryptogen generate --config=./docker-compose/crypto-config.yaml

docker-compose -f docker-compose/org0-peer1.yaml up -d
configtxgen -profile OrdererSoloGenesis -channelID system-channel -outputBlock ./artifacts/orderer.genesis.block
docker-compose -f docker-compose/orderer.yaml up -d

