
docker-compose -f docker-compose/org0-ca.yaml down
docker-compose -f docker-compose/org1-ca.yaml down
docker-compose -f docker-compose/org1-peer1.yaml down
docker-compose -f docker-compose/org0-order.yaml down
docker-compose -f docker-compose/org1-cli.yaml down

sudo rm -rf /tmp/hyperledger
