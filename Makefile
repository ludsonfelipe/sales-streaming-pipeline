infra:
	terraform -chdir=./terraform init
infra_storage: 
	terraform -chdir=./terraform apply -target module.buckets
infra_database:
	terraform -chdir=./terraform apply -target module.database 
infra_pubsub:
	terraform -chdir=./terraform apply -target module.pubsub
infra_instances:
	terraform -chdir=./terraform apply -target module.instances
infra_cdc:
	terraform -chdir=./terraform apply -target module.datastreams


containers:
	sudo docker-compose up -d

create_tables: 
	sudo docker exec local-python bash -c "python python/create_tables.py"