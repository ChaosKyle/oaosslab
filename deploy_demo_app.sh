#!/bin/bash

# Define variables
CLUSTER_NAME="demo-cluster"
NAMESPACE="demo-app"

# Function to create a KinD cluster
create_kind_cluster() {
    echo "Creating KinD cluster: $CLUSTER_NAME"
    kind create cluster --name $CLUSTER_NAME
    echo "KinD cluster created."
}

# Function to deploy demo application
deploy_demo_app() {
    echo "Setting up namespace: $NAMESPACE"
    kubectl create namespace $NAMESPACE

    echo "Deploying demo application..."

    # Apply Kubernetes manifests for the demo application
    cat <<EOF | kubectl apply -n $NAMESPACE -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: demo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo-app
      tier: frontend
  template:
    metadata:
      labels:
        app: demo-app
        tier: frontend
    spec:
      containers:
      - name: frontend
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  labels:
    app: demo-app
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30001
  selector:
    app: demo-app
    tier: frontend
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels:
    app: demo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo-app
      tier: backend
  template:
    metadata:
      labels:
        app: demo-app
        tier: backend
    spec:
      containers:
      - name: backend
        image: hashicorp/http-echo:latest
        args:
          - "-text=Hello from Backend"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  labels:
    app: demo-app
spec:
  type: ClusterIP
  ports:
  - port: 5678
    targetPort: 5678
  selector:
    app: demo-app
    tier: backend
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database
  labels:
    app: demo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo-app
      tier: database
  template:
    metadata:
      labels:
        app: demo-app
        tier: database
    spec:
      containers:
      - name: database
        image: postgres:latest
        env:
        - name: POSTGRES_USER
          value: demo
        - name: POSTGRES_PASSWORD
          value: demo
        - name: POSTGRES_DB
          value: demo_db
        ports:
        - containerPort: 5432
---
apiVersion: v1
kind: Service
metadata:
  name: database
  labels:
    app: demo-app
spec:
  type: ClusterIP
  ports:
  - port: 5432
    targetPort: 5432
  selector:
    app: demo-app
    tier: database
EOF

    echo "Demo application deployed."
}

# Main script execution
if ! command -v kind &> /dev/null; then
    echo "KinD is not installed. Please install KinD and retry."
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install kubectl and retry."
    exit 1
fi

create_kind_cluster
deploy_demo_app

# Display application status
echo "Fetching application status..."
kubectl get all -n $NAMESPACE

# Success message
echo "
=========================================
Demo application successfully deployed! 🎉
=========================================
Access the frontend at: http://localhost:30001
=========================================
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡾⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣸⡏⠀⡈⢿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⣿⠀⣸⡇⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡶⢶
⠀⠀⠀⠀⠀⠀⠀⣼⡇⢰⡿⠀⢀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠉⡀⣾
⠀⠀⠀⠀⠀⠀⣰⡟⢠⣿⠿⠁⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⡾⠋⣠⠞⢷⡏
⠀⠀⠀⠀⠀⣴⡟⢁⣾⣿⡭⠀⣼⠃⠀⠀⠀⠀⠀⠀⣀⡴⠛⠁⣠⣾⠋⠀⣾⠃
⠀⠀⠀⢀⣾⠟⠀⣼⣿⣿⠃⢰⡟⠀⠀⠀⠀⠀⣠⡾⠋⠀⢀⣾⣿⠃⢀⣾⠏⠀
⠀⠀⠀⣼⡿⠀⢰⣿⡿⠁⢠⡟⠀⠀⠀⠀⠀⣼⡟⠁⠀⣴⣿⠿⢀⣴⣿⠋⠀⠀
⠀⠀⠀⣿⠇⠀⣾⡟⠁⣰⡟⠀⠀⠀⠀⠀⣸⡟⠀⠀⣼⣿⠉⣴⣿⠟⠁⠀⠀⠀
⠀⠀⠀⣿⡀⠀⣿⡇⢰⡿⠀⠀⠀⠀⠀⠀⣿⠃⠀⣸⡿⢁⣾⠟⠁⠀⠀⠀⠀⠀
⠀⠀⠀⢻⣇⠀⢿⡇⢸⡇⠀⠀⠀⠀⠀⠀⣿⠀⢠⡟⢠⣿⠋⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠈⣿⡀⠸⡇⣿⢄⡀⣀⣀⣀⣀⣰⣿⡄⣼⢁⣾⠃⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠘⣷⠀⣷⢿⠿⡿⡟⡿⢟⠉⢉⣿⣿⡟⢸⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣿⡀⠸⢸⣷⣴⣤⣤⣾⣶⣈⢙⡿⠃⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢸⡇⠀⠘⠇⡹⠟⠋⠉⠉⠉⠻⡀⠰⣧⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣸⠇⠀⠀⠀⣠⡶⠟⠛⠛⠛⠀⠀⠀⣀⣭⣝⣷⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⢉⠔⣊⣁⠂⠀⠀⢀⡾⢆⠈⢹⡿⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣰⠟⠀⠀⠀⠀⢀⡾⢱⡤⢹⠀⠀⢸⣟⣲⢡⡏⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⣠⠟⠀⠀⠀⠀⠀⢈⠑⠒⠒⠋⠀⠀⠘⣯⡎⢾⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⢀⣴⠋⠀⠀⠀⠀⠀⠀⠀⠙⠛⠉⢀⠀⠠⠤⠼⢷⣄⠹⣄⠀⠀⠀⠀⠀⠀⠀
⢠⡾⠃⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠖⠁⠀⠀⠀⠀⠀⠈⠙⠻⣄⠀⠀⠀⠀⠀⠀
⣼⡇⠀⠀⠀⠀⢰⠃⡾⢋⠑⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠈⢷⣄⠀⠀⠀⠀
⣿⡇⠀⠀⠀⠀⡏⠀⠀⢹⡇⠀⠀⠀⠀⠀⠀⢿⣄⡀⠀⠀⠀⠀⠀⢻⡄⠀⠀⠀
⢹⡇⢠⠀⠀⠀⠁⠀⠀⢸⣇⠀⠀⠀⠀⠀⠈⠒⠉⠁⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀
⠈⢿⡌⢷⣤⠀⠀⠀⠀⢸⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡇⠀⠀⠀
⠀⠘⢷⣦⠙⠷⣄⠀⠀⠸⣏⠙⣮⡢⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠇⠀⠀⠀
⠀⠀⠀⠙⠷⠶⣦⣀⣠⠀⢹⡷⢌⡻⣦⣁⠀⠀⠀⠀⠀⠀⠀⢤⣶⠟⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠈⠙⠿⣧⡀⠻⣎⣁⡀⢉⠙⠒⠶⠶⠶⣲⡞⠉⠁⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢷⡄⢈⠻⢷⣤⣀⣁⣀⣛⡻⢹⠇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣷⠀⠁⠀⠉⣉⣉⣉⣉⡴⠏⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠷⠦⣤⣤⠴⠟⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
"