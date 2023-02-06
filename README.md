# Docker Assignment 1
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)
[![Build Status](https://github.com/terraform-linters/tflint/workflows/build/badge.svg?branch=master)](https://github.com/terraform-linters/tflint/actions)

The repository demonstrates how to build and deploy your first containerized application using github action workflows.

# Objections of the Project
The goal of this project is to push docker images of an application to ECR repositories using github action workflow. I have created infrastructure using terraform.
The project also assesses technical proficiency in Terraform, Docker Commands, Load Balancers, AWS identity and access management and the efficient use of git source control along with Github Actions .

## Tools and technologies learnt from working on this project
1. Terraform
2. Terragrunt
3. Github Actions
4. Github pre commits
5. Load Balancers

# Pre-commit hooks

This repo defines Git pre-commit hooks intended for use with [pre-commit](http://pre-commit.com/). The currently
supported hooks are:

* **terraform-fmt**: Automatically run `terraform fmt` on all Terraform code (`*.tf` files).
* **terraform-validate**: Automatically run `terraform validate` on all Terraform code (`*.tf` files).
* **detect-aws-credentials**: Detects if any keys are present in the repository

## Pre - Requisites
### Step - 1 (Github Repository Clone)
Clone the repository to your local environment of Cloud9 

```git clone git@github.com:nisalikularatne/CLO835-Assignment-Docker-1.git```

### Step - 2 (Create key to login to instance)
In your AWS console in EC2 service under key pairs create one individual key for prod since for this project we are dealing with prod env to show the working of docker
```
prod environment - prod-project
```
### Step - 3 (S3 Settings)
In the AWS portal under the S3 service create 1 bucket with the naming as shown below:

prod-clo835-docker-assignment1

## Deployment and Destruction of Infrastructure
We have created the following modules
1. networking
2. securityGroup
3. instance
4. ecr
5. alb

In order to make the deployment faster we have integrated terragrunt.hcl files
which will rapidly deploy the infrastructure in the environment s using the commands below.
Run this command in the root of the project in CLI. This applies to all resources in prod environment
```terraform
 terragrunt run-all init
 terragrunt run-all apply
```
//Edit
