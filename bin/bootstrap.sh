#! /bin/sh

echo "\nInitialising TF...\n"
terraform init

echo "\nValidating TF...\n"
terraform validate

echo "\nFormatting TF...\n"
terraform fmt

echo "\nApplying TF...\n"
terraform apply

echo "\nPlease wait a few minutes for the ALB to pass healthchecks"