# How to Deploy the Local Demo Application

This guide explains how to deploy a local demo application using a Kubernetes cluster managed by KinD (Kubernetes in Docker). The demo includes a frontend, a backend, and a database service for monitoring and testing purposes.

---

## **Prerequisites**

Ensure the following tools are installed on your system:

1. **KinD** (Kubernetes in Docker)
   - Installation guide: [KinD Installation](https://kind.sigs.k8s.io/docs/user/quick-start/)
2. **kubectl** (Kubernetes CLI)
   - Installation guide: [kubectl Installation](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

Verify that both tools are installed:
```bash
kind --version
kubectl version --client
```

---

## **Steps to Deploy the Demo Application**

### 1. Download the Deployment Script

Save the deployment script to your local system as `deploy_demo_app.sh`.

### 2. Run the Deployment Script

Open a terminal, navigate to the directory containing the script, and run:
```bash
bash deploy_demo_app.sh
```

This script will:
- Create a local Kubernetes cluster named `demo-cluster`.
- Deploy the demo application with the following services:
  - **Frontend**: An NGINX server.
  - **Backend**: A simple HTTP echo service.
  - **Database**: A PostgreSQL database.

### 3. Monitor the Deployment Progress

After running the script, the terminal will display the status of the deployed services. To check the status manually:
```bash
kubectl get all -n demo-app
```

### 4. Access the Application

#### Frontend
- The frontend service is accessible at:
  ```
  http://localhost:30001
  ```

#### Backend and Database
- The backend and database services are available inside the Kubernetes cluster for further testing or integration.

---

## **Common Commands**

Here are some helpful commands to manage and troubleshoot the application:

- **List all resources in the namespace:**
  ```bash
  kubectl get all -n demo-app
  ```

- **View logs of a specific pod:**
  ```bash
  kubectl logs <pod-name> -n demo-app
  ```

- **Delete the demo application:**
  ```bash
  kind delete cluster --name demo-cluster
  ```

---

## **Troubleshooting**

### Problem: KinD or kubectl is not installed
- Verify the tools are installed by running:
  ```bash
  kind --version
  kubectl version --client
  ```
- Follow the installation links provided in the prerequisites.

### Problem: Services are not running
- Check the status of pods:
  ```bash
  kubectl get pods -n demo-app
  ```
- View logs for errors:
  ```bash
  kubectl logs <pod-name> -n demo-app
  ```

---

## **Next Steps**

Once the demo application is deployed, you can:
- Begin monitoring the application using Grafana and the Observability Stack.
- Simulate incidents or perform chaos testing to observe how the system behaves under stress.

For any issues or questions, contact the @kyle 

