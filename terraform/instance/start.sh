#!/bin/bash
sudo apt-get -y update
cd /home/ubuntu && git clone ${repos}
sudo apt -y install make > output.txt

# install docker and waiting until it is installed
sudo snap install docker >> output.txt
sudo snap refresh docker --channel=latest/edge
while ! docker info > /dev/null 2>&1; do
    echo "Aguardando a inicialização do Docker..."
    sleep 1
done

# principal folder
cd sales-streaming-pipeline

# starting containers
sudo make -B containers > output.txt

# saving ip-database in the python folder
cd source/scripts/python
echo ${address} >> address.txt

# using make in the principal folder
cd ../../../ && sudo make create_tables > output_create_tables.txt

