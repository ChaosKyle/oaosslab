# Grafana OSS Stack Deployment Guide

This guide explains how to deploy the complete Grafana OSS Stack using Docker Desktop and OpenTofu.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Components Overview](#components-overview)
- [Installation Steps](#installation-steps)
- [Post-Installation Configuration](#post-installation-configuration)
- [Troubleshooting](#troubleshooting)
- [Clean Up](#clean-up)

## Prerequisites

Before starting the deployment, ensure you have the following installed:

1. **Docker Desktop**
   - Download from [Docker's official website](https://www.docker.com/products/docker-desktop)
   - Minimum requirements:
     - 4GB RAM
     - 20GB disk space

2. **OpenTofu**
   - Installation commands:
     ```bash
     # MacOS
     brew install opentofu

     # Linux
     curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh | bash

     # Verify installation
     tofu version
     ```

## Components Overview

The stack includes the following components:

| Component  | Purpose                  | Default Port | Data Persistence |
|-----------|--------------------------|--------------|------------------|
| Grafana   | Visualization & UI       | 3000        | grafana_data    |
| Loki      | Log Aggregation         | 3100        | loki_data       |
| Mimir     | Metrics                 | 9009        | mimir_data      |
| Tempo     | Distributed Tracing     | 3200        | tempo_data      |
| Pyroscope | Continuous Profiling    | 4040        | pyroscope_data  |

## Installation Steps

1. **Prepare the Environment**
   ```bash
   # Create a new directory for the deployment
   mkdir grafana-stack
   cd grafana-stack
   ```

2. **Deploy Using the Script**
   ```bash
   # Make the script executable
   chmod +x deploy-grafana.sh

   # Run the deployment script
   ./deploy-grafana.sh
   ```

3. **Verify Deployment**
   ```bash
   # Check if all containers are running
   docker ps | grep -E 'grafana|loki|mimir|tempo|pyroscope'

   # Check container logs
   docker logs grafana
   ```

## Post-Installation Configuration

### 1. Configure Data Sources

Access Grafana at `http://localhost:3000` and add the following data sources:

1. **Loki**
   - URL: `http://loki:3100`
   - Type: Loki

2. **Mimir**
   - URL: `http://mimir:9009/prometheus`
   - Type: Prometheus

3. **Tempo**
   - URL: `http://tempo:3200`
   - Type: Tempo

4. **Pyroscope**
   - URL: `http://pyroscope:4040`
   - Type: Pyroscope

### 2. Default Credentials
- Username: admin
- Password: admin (you'll be prompted to change on first login)
- Note: Anonymous access is enabled by default for testing

## Troubleshooting

### Common Issues and Solutions

1. **Docker Network Issues**
   ```bash
   # Recreate the network
   docker network rm grafana-net
   docker network create grafana-net
   ```

2. **Permission Issues**
   ```bash
   # Fix volume permissions
   sudo chown -R 472:472 /var/lib/docker/volumes/grafana_data
   ```

3. **Container Won't Start**
   ```bash
   # Check container logs
   docker logs [container_name]

   # Restart container
   docker restart [container_name]
   ```

### Health Checks
```bash
# Check Grafana health
curl http://localhost:3000/api/health

# Check Loki health
curl http://localhost:3100/ready

# Check Mimir health
curl http://localhost:9009/ready

# Check Tempo health
curl http://localhost:3200/ready
```

## Clean Up

To remove the entire stack:

```bash
# Stop and remove containers
docker-compose down

# Remove volumes
docker volume rm grafana_data loki_data mimir_data tempo_data pyroscope_data

# Remove network
docker network rm grafana-net

# Clean up OpenTofu state
cd terraform
tofu destroy -auto-approve
```

## Additional Resources

- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/latest/)
- [Mimir Documentation](https://grafana.com/docs/mimir/latest/)
- [Tempo Documentation](https://grafana.com/docs/tempo/latest/)
- [Pyroscope Documentation](https://grafana.com/docs/pyroscope/latest/)

## Support

For issues with:
- Deployment script: Create an issue in the repository
- Individual components: Visit respective Grafana documentation
- OpenTofu configuration: Check OpenTofu documentation

Remember to regularly backup your data and keep the stack updated with the latest security patches.
