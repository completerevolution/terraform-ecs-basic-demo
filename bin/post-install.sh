#! /bin/sh

ENDPOINT=$(terraform output alb_endpoint)

echo "Your ELB endpoint URL is http://$ENDPOINT\n\n"

curl -v $ENDPOINT