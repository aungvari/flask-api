This repository contains a simple python http endpoint to a mirror-time coding challenge packaged in a docker image.

## Build the image
- clone  this repository to your machine running docker and use:
```
docker build -t flask-api:latest .
```
- you can run a test locally with 
```
docker run -d -p 80:80 flask-api
```
- the API only works properly with valid time formats in HH:MM or H:MM. Though it will give an answer for hours > 24 and minutes > 60, it will crash for anything else :) - error handling needs to be implemented
- you can only POST JSON data format and only one value at a time to the endpoint like this:
```
curl --location --request POST '0.0.0.0/mirror_clock/api/v1.0/convert' \
--header 'Content-Type: application/json' \
--data-raw '{ 
   "time":"10:10"
}'
```

## Upload to ECR
- you need to have an AWS account and AWS CLI installed on your machine
- run `aws configure` to set up your keys
- go to https://eu-central-1.console.aws.amazon.com/ecr/create-repository?region=eu-central-1 and create your repository
- when it is created you can select it on the console and get the instructions on how to upload you image with the button "View push commands"
- after successfully pushing the image, open the repository and note down the Image URI for you Docker image as this will be used with terraform

## Terraform
- using locally stored credentials under ~/.aws/credentials and a local state file
- run `terraform init` in the same directory as your main.tf file
- change the value of "image" in line 150 to your Image URI from ECR
- verify if your account is in eu-central-1
- run `terraform apply`

## Possible improvements
- error handling in python for invalid inputs
- at least some basic authorization for the endpoint
- use HTTPS for the API
- use more variables in terraform in a seperate variables.tf, for the image value, names for resources, port numbers, cpu/memory in the task definition
- put the state file into an s3 bucket or vault and encrypt it
- split main.tf into modules like network.tf and iam.tf to be more dynamic
- use a loadbalancer if there is need for HA and running multiple instances

##
- you can currently test with
```
curl --location --request POST '18.197.35.113/mirror_clock/api/v1.0/convert' \
--header 'Content-Type: application/json' \
--data-raw '{ 
   "time":"11:11"
}'
```
