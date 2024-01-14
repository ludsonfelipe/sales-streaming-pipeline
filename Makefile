infra:
	terraform -chdir=./terraform init
infra_database:
	terraform -chdir=./terraform apply -target module.database 
infra_storage: 
	terraform -chdir=./terraform apply -target module.buckets
infra_cdc:
	terraform -chdir=./terraform apply -target module.datastreams
infra_instance:
	terraform -chdir=./terraform apply -target module.instances
infra_pubsub:
	terraform -chdir=./terraform apply -target module.pubsub

containers:
	docker-compose up -d

database_ingestion: 
	docker exec -it local-python bash -c "python python/database_ingestion.py"