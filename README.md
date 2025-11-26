
### Swiss Exam  ###
### Audie Ryan Alcid ###

### src/ ###
This contains the Python source code (web.py) used to create the web applicaion that has two api endpoints /api/health and /api/mirror
It also contains the source code (test_app.py) that is used for testing for the Azure Devops Build Pipeline

### terraform/ ###
This directory houses the terraform files used to build the following resources needed for the application (Azure K8s, Azure Key Vault, Postgres , Secrets Etc)

### helmchart/ ###
This directory contains the helmchart template that contains object/manifests that is required to run the application in Azure K8s environemnt

### Dockerfile ###
File to build the application into a portable docker image

### azure-pipelines.yml ###
CI pipeline used to build the application code into a docker image and push to Github Container Registry

https://github.com/users/jabronie0002/packages/container/package/swiss




