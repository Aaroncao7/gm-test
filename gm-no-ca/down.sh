
docker-compose -f docker-compose/orderer.yaml down
docker-compose -f docker-compose/org0-cli.yaml down
docker-compose -f docker-compose/org0-peer1.yaml down

sudo rm -rf crypto-config