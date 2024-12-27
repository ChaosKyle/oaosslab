#!/bin/bash

# Function to check if required tools are installed
check_prerequisites() {
    local tools=("kind" "tofu" "kubectl")
    
    for tool in "${tools[@]}"; do
        if ! command -v $tool &> /dev/null; then
            echo "Error: $tool is not installed."
            exit 1
        fi
    done
}

# Function to create kind cluster
create_kind_cluster() {
    if ! kind get clusters | grep -q "oa-lab"; then
        echo "Creating kind cluster..."
        kind create cluster --name oa-lab --config ./deploy/kubernetes/kind-config.yaml
        echo "Installing nginx ingress controller..."
        kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
        
        # Wait for ingress controller to be ready
        echo "Waiting for ingress controller to be ready..."
        kubectl wait --namespace ingress-nginx \
          --for=condition=ready pod \
          --selector=app.kubernetes.io/component=controller \
          --timeout=90s
    else
        echo "Cluster 'oa-lab' already exists"
    fi
}

# Function to initialize OpenTofu
init_tofu() {
    cd ./deploy/opentofu
    echo "Initializing OpenTofu..."
    tofu init
}

# Function to apply OpenTofu configuration
apply_tofu() {
    cd ./deploy/opentofu
    echo "Applying OpenTofu configuration..."
    tofu apply -auto-approve
}

# Function to destroy infrastructure
destroy_infra() {
    cd ./deploy/opentofu
    echo "Destroying infrastructure..."
    tofu destroy -auto-approve
    kind delete cluster --name oa-lab
}

# Main script
check_prerequisites

case "$1" in
    "init")
        create_kind_cluster
        init_tofu
        ;;
    "apply")
        create_kind_cluster
        apply_tofu
        ;;
    "destroy")
        destroy_infra
        ;;
    *)
        echo "Usage: $0 {init|apply|destroy}"
        echo "  init    : Initialize the cluster and OpenTofu"
        echo "  apply   : Apply the OpenTofu configuration"
        echo "  destroy : Destroy all infrastructure"
        exit 1
        ;;
esac

exit 0
