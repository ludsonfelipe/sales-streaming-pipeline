infra:
	terraform -chdir=./terraform init
infra_database:
	terraform -chdir=./terraform apply -target module.database 
infra_storage: 
	terraform -chdir=./terraform apply -target module.buckets
infra_cdc:
	terraform -chdir=./terraform apply -target module.datastreams
database_ingestion: 
	docker exec -it local-python bash -c "python python/database_ingestion.py"