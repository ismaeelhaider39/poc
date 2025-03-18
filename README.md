terraform plan -target=module.vnet -target=module.acr -target=module.aks -var-file=stage/stage.tfvars -out=staging.tfplan
terraform plan -target=helm_release.argocd -var-file=stage/stage.tfvars -out=staging.tfplan 
terraform plan -var-file=stage/stage.tfvars -out=staging.tfplan 