#!/bin/bash
sudo apt-get -y update
cd /home/ubuntu && git clone ${repo}
sudo apt -y install make > output.txt

sudo snap install docker >> output.txt
sudo snap refresh docker --channel=latest/edge
while ! docker info > /dev/null 2>&1; do
    echo "Aguardando a inicialização do Docker..."
    sleep 1
done

cd sales-streaming-pipeline

sudo make -B containers > output.txt

cd source/scripts/python
echo ${address} >> address.txt
sudo make create_tables

