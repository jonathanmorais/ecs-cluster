.ONSHELL:
infra_init:
	cd infra/environments/ecs-prod
	terraform init	

infra_apply:
	terraform apply -target=module.ecr_proxy_nginx -auto-approve
	terraform apply -target=module.ecs_cluster -auto-approve
	terraform apply -target=module.ecs_capacity_provider -auto-approve
	terraform apply -target=module.ecs_service -auto-approve