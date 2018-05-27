# AWS Best Practices

The best way to learn things is by doing it. This playground should contain all best practices for using amazon.

# Set Up the Environment

Terraform provisions the whole infrastructure, e.g.:
  - set up of a network with vpc, subnets, endpoints
  - creation of lambda function and triggers for s3
  - configuration of roles

There are still a lot to do, like:
  - use auto.tfvars and variables.tf for terraform
  - create makefile
  - use username and password as input
  - automate the db endpoint
  - create api gateway with swagger
  - create different environments, like staging, development, production
  - test out message broker
  - improve go code and do not hardcoded stuffs
  - do not use full permission for everything
  - limit the security group
  - create public and external vpc
  - etc..

# How to Use

In order to create the environment, run:

```bash
terraform init
terraform apply
```

When you are done with it, clean up everything with:

```bash
terraform destroy
```