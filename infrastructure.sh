#!/bin/bash

ACTION="$1"

GO=`which go`
KUBECTL=`which kubectl`
TERRAFORM=`which terraform`

echo "go: ${GO}"
echo "kubectl: ${KUBECTL}"
echo "terraform: ${TERRAFORM}"

if [ ! -f "${GO}" ]; then
    echo "ERROR: go executable not found at '${GO}'"
fi

if [ ! -f "${KUBECTL}" ]; then
    echo "ERROR: kubectl executable not found at '${KUBECTL}'"
fi

if [ ! -f "${TERRAFORM}" ]; then
    echo "ERROR: terraform executable not found at '${TERRAFORM}'"
fi

cd terraform-eks

if [ ! -d ".terraform" ]; then
    $TERRAFORM init
fi

if [ "$ACTION" = "start" ]; then
    $TERRAFORM plan -out production
    $TERRAFORM apply production
    
    echo 'export KUBECONFIG=$KUBECONFIG:~/.kube/config-production' >> ~/.zshrc
    source ~/.zshrc
    
    $TERRAFORM output config-map > config-map-aws-auth.yaml
    $KUBECTL apply -f config-map-aws-auth.yaml
    $KUBECTL get nodes --watch
fi

if [ "$ACTION" = "stop" ];  then
    $TERRAFORM destroy
    rm config-map-aws-auth.yaml terraform.tfstate terraform.tfstate.backup
fi
