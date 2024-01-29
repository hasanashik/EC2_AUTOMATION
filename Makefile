# Makefile for Terraform Initialization, Planning, and Apply

# Targets
.PHONY: tf_dev_init tf_dev_plan tf_dev_apply

# Initialization target
tf_dev_init:
	@ echo "Initializing Terraform..."
	@ terraform fmt -recursive
	@ terraform init

# Planning target
tf_dev_plan:
	@ echo "Planning Terraform..."
	@ terraform fmt -recursive
	@ terraform plan

# Apply target
tf_dev_apply:
	@ echo "Applying Terraform changes..."
	@ terraform fmt -recursive
	@ terraform apply




# Help target
help:
	@ echo "Usage: make <target>"
	@ echo "Targets:"
	@ echo "  tf_dev_init   - Initialize Terraform"
	@ echo "  tf_dev_plan   - Plan Terraform changes"
	@ echo "  tf_dev_apply  - Apply Terraform changes"
	@ echo "  help      - Display this help message"
