#!/bin/bash

# Exit on error
set -e

echo "Starting Grafana OSS Stack deployment..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "Docker is not running. Please start Docker Desktop first."
    exit 1
fi

# Create directory structure
mkdir -p grafana-stack/{terraform,configs}
cd grafana-stack

# Create network
docker network create grafana-net 2>/dev/null || true

# Create OpenTofu configuration file
cat > terraform/main.tf << 'EOF'
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {}

# Create volumes
resource "docker_volume" "grafana_data" {
  name = "grafana_data"
}

resource "docker_volume" "loki_data" {
  name = "loki_data"
}

resource "docker_volume" "mimir_data" {
  name = "mimir_data"
}

resource "docker_volume" "tempo_data" {
  name = "tempo_data"
}

resource "docker_volume" "pyroscope_data" {
  name = "pyroscope_data"
}

# Deploy Grafana
resource "docker_container" "grafana" {
  name  = "grafana"
  image = "grafana/grafana:latest"
  
  networks_advanced {
    name = "grafana-net"
  }
  
  ports {
    internal = 3000
    external = 3000
  }
  
  volumes {
    volume_name = docker_volume.grafana_data.name
    container_path = "/var/lib/grafana"
  }

  env = [
    "GF_AUTH_ANONYMOUS_ENABLED=true",
    "GF_AUTH_ANONYMOUS_ORG_ROLE=Admin"
  ]
}

# Deploy Loki
resource "docker_container" "loki" {
  name  = "loki"
  image = "grafana/loki:latest"
  
  networks_advanced {
    name = "grafana-net"
  }
  
  ports {
    internal = 3100
    external = 3100
  }
  
  volumes {
    volume_name = docker_volume.loki_data.name
    container_path = "/loki"
  }
}

# Deploy Mimir
resource "docker_container" "mimir" {
  name  = "mimir"
  image = "grafana/mimir:latest"
  
  networks_advanced {
    name = "grafana-net"
  }
  
  ports {
    internal = 9009
    external = 9009
  }
  
  volumes {
    volume_name = docker_volume.mimir_data.name
    container_path = "/data"
  }

  command = ["--config.file=/etc/mimir/config.yaml"]
}

# Deploy Tempo
resource "docker_container" "tempo" {
  name  = "tempo"
  image = "grafana/tempo:latest"
  
  networks_advanced {
    name = "grafana-net"
  }
  
  ports {
    internal = 3200
    external = 3200
  }
  
  volumes {
    volume_name = docker_volume.tempo_data.name
    container_path = "/tmp/tempo"
  }
}

# Deploy Pyroscope
resource "docker_container" "pyroscope" {
  name  = "pyroscope"
  image = "grafana/pyroscope:latest"
  
  networks_advanced {
    name = "grafana-net"
  }
  
  ports {
    internal = 4040
    external = 4040
  }
  
  volumes {
    volume_name = docker_volume.pyroscope_data.name
    container_path = "/var/lib/pyroscope"
  }
}
EOF

# Create Mimir config
mkdir -p configs/mimir
cat > configs/mimir/config.yaml << 'EOF'
multitenancy_enabled: false

blocks_storage:
  backend: filesystem
  filesystem:
    dir: /data/blocks
  bucket_store:
    sync_dir: /data/sync

compactor:
  data_dir: /data/compactor
  sharding_ring:
    kvstore:
      store: memberlist

distributor:
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: memberlist

ingester:
  lifecycler:
    ring:
      kvstore:
        store: memberlist
      replication_factor: 1

ruler_storage:
  backend: filesystem
  filesystem:
    dir: /data/rules

server:
  http_listen_port: 9009
EOF

# Initialize and apply OpenTofu configuration
cd terraform
tofu init
tofu apply -auto-approve

echo "Grafana OSS Stack deployment complete!"
echo "Access Grafana at: http://localhost:3000"
echo "Default ports:"
echo "- Loki: 3100"
echo "- Mimir: 9009"
echo "- Tempo: 3200"
echo "- Pyroscope: 4040

⣿⣿⣿⡿⢣⣶⣶⠀⣝⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢟⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣮⣙⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⢣⣿⣿⣿⠀⢻⡜⢿⣿⣿⣿⣿⣿⣿⣿⠟⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣮⡻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⡘⠻⠯⠵⣚⣿⣷⡹⡿⣿⣿⣿⣿⣿⢣⡾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣮⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣷⣶⣤⣤⣈⠛⢿⣮⡉⣿⣿⣿⣟⢧⣻⣿⡿⠛⠛⠛⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠛⠉⠉⠈⠇⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣛⢛⡻⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⠙⡿⣬⣿⢿⡩⠖⣥⢃⠀⠀⢀⠀⡀⠀⠉⠙⠛⠛⠛⢿⣿⣿⣿⣿⣁⣀⣡⣶⣶⣶⣶⣤⡀⠈⢿⣿⣿⣿⣿⣿⣿⠟⣵⠇⣰⣷⡝⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡘⠙⣎⣶⡱⣍⢆⡃⢎⣈⠤⠥⠐⢂⠀⠂⢀⠀⡰⢋⣿⣿⣿⡟⢯⣙⢯⡛⣟⣿⣿⣿⣿⣧⡌⣿⣿⣿⣿⢟⣡⣾⡻⣜⢿⣿⡧⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢁⢿⣾⣿⣿⣭⡔⠂⡁⠠⡆⠀⠀⠀⣤⠀⣠⡘⣴⣻⣾⣿⣿⣿⢬⡓⡦⠽⠶⠾⢥⣝⢿⣿⣷⣝⣛⣭⣾⣟⡿⠟⠓⠉⠓⠿⢃⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢃⢮⣿⣿⣿⣿⣿⣿⣦⣈⡑⠶⠖⠶⣦⡁⢤⣶⣿⣿⣿⣿⣿⣿⣿⡟⠁⡔⠀⠀⠀⣦⡌⠹⣿⣿⣿⣿⢟⣫⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⢠⢟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⠠⢀⣀⡀⢟⠛⣀⣸⣿⣿⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢃⠏⢾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠸⡿⣟⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣬⣩⣛⣛⣯⣿⣿⣿⣧⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⡈⢎⢣⢿⣿⡿⣟⠿⠛⠛⢛⣻⣿⡃⠀⠀⠐⠀⠉⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣇⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⡱⣈⠮⣝⣾⣽⣎⣀⣷⣾⣿⣿⣿⣿⣶⣶⣀⠀⠀⠈⢀⠉⠉⠉⠛⠛⠋⠉⠉⠙⡻⢮⣿⣿⣿⣿⣿⣿⣿⣿⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⠰⠱⣌⣷⣿⣿⣿⣿⣿⣿⠛⢿⣿⣿⣿⣿⣿⣿⣿⣶⣦⣄⣀⣂⣠⣤⣴⣶⣶⣶⣾⣿⣦⣉⠛⠻⣿⣿⣿⣿⣿⢋⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⡿⠟⠋⠐⠱⢪⣿⣿⣿⣿⣻⣿⣿⣷⣦⣈⠙⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⠙⣿⣿⣿⣿⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⡿⠟⠋⠉⠔⠋⠁⠘⢄⠫⣽⣿⣿⣿⣿⣿⣿⢾⣿⣿⣿⣶⣶⣬⣍⣉⡙⠻⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⢻⣿⣿⣯⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⠋⢀⠂⠀⠀⠀⠀⠀⢁⠂⡱⡘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣶⣤⣤⣬⣭⣭⣭⣭⣵⣾⣿⣿⣿⣿⣿⣿⡇⠙⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠁⠀⠂⠀⠀⠀⠀⠀⠀⢀⠒⠠⠙⢎⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡣⠀⠤⢂⠉⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠂⠁⠌⢂⡙⠼⣻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⡅⠆⠀⠀⢂⠂⠀⣍⠉⠉⠉⠙⠛⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠠⠀⢈⠢⠙⢎⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣱⠇⠀⠈⣜⡢⠀⢀⠘⡄⠀⠀⠀⠀⢸⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⡀⠉⡐⠤⢋⢟⡻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠏⣰⣿⠀⠀⠀⡘⠓⠂⠀⡀⠙⡄⠀⠀⢀⣾⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠐⠀⠀⠀⠀⡀⢃⠢⡁⠏⡽⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⣠⣾⡿⠋⠀⠀⠈⠹⠀⠀⠙⠆⠀⠱⠀⠀⠸⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠠⠀⠀⠀⠀⠀⠐⠠⠑⡈⢒⠹⡻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡛⢅⣬⣾⣿⡟⠁⠈⠀⢠⡈⠀⠰⠶⣆⣀⠀⠸⡄⠀⣸⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⡀⠄⠐⠀⠀⠀⠀⠀⠐⠠⠈⠄⡁⠆⢂⠱⡈⢍⠩⢋⠛⡛⢛⠻⠛⣍⣢⣴⣿⣿⣿⠟⠀⢠⠂⠀⠀⠈⠀⠐⠀⢀⠝⢁⠀⡇⠐⠦⣿⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⡐⠀⠀⠀⠀⠀⠠⠀⠂⠁⢀⠠⠀⠀⠀⠀⠀⠀⠈⠀⠂⠁⠌⡈⠅⢊⠰⣡⣾⣿⣿⣿⣿⡿⠋⠁⠀⡴⠁⢀⠈⠀⠠⠀⠫⠃⡈⠐⡣⢒⠂⠀⠎⣽⣿⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠀⠀⠀⢠⠀⠁⡄⠈⠀⠀⠀⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⢰⣬⣿⣿⣿⣿⣿⣿⠋⠁⠀⢠⣾⠃⠀⢣⠀⠐⠀⠐⠀⡄⠀⢠⠀⠁⠀⠁⠘⣴⢻⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢂⠀⠀⠀⠀⠄⢂⠀⢂⠐⠈⠀⠀⠄⠂⠀⠄⠀⠠⢀⢂⣵⣮⣿⣿⣿⣿⣿⣿⠻⠁⠈⠀⣼⣿⠏⠀⠢⠀⡄⠀⠀⢠⡀⠁⠀⡦⠀⠒⠨⠁⠢⢅⢯⣽
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠄⡀⠀⠀⠀⠈⠀⡀⠂⠁⠄⠂⡀⠂⢤⣘⣴⣯⣿⣿⣿⣿⠿⣫⢟⡉⠁⠀⢠⣼⣿⡿⠁⢸⠆⠀⠀⠐⠁⠠⠘⠂⠀⠾⠁⠀⢂⠌⡁⢂⠩⢶⣹
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠒⠀⠄⣀⠀⠀⢀⣀⢀⠀⣁⢢⣴⣾⣽⣿⣿⣿⣿⣿⣿⣿⡟⠞⠙⠀⣠⣐⣿⣾⡿⠋⠐⡗⠀⠀⠀⠃⢀⣚⠄⠀⠘⠂⠀⠀⠀⠀⠁⠀⠌⡘⢥⡓
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢈⠙⢻⣤⡙⢈⣋⣉⣻⡛⠿⠟⢻⢻⡻⠻⠟⠻⠏⠅⡀⣦⣶⣧⣿⣿⡿⠋⠐⠠⠄⠀⠀⠂⠀⠀⡼⠘⣤⠀⠀⠂⠀⠱⠀⠀⠀⠀⠂⠁⠂⠌
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣧⣶⡟⣻⣸⣦⣤⡀⣦⡴⣠⢂⣶⣥⣾⣿⣿⣿⡿⠋⢩⡄⠀⢆⠀⠐⠀⡐⠀⠻⠀⠀⠃⠃⠀⠐⠁⠀⠀⠀⠀⠀⠀⠀⠡⠉⠠
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣷⣿⣿⣻⣿⣷⣻⣿⣘⣿⣿⡿⠟⣛⢭⠁⠀⠀⠀⠓⠀⢀⠀⠀⠀⠀⠠⠀⠀⠆⠀⠆⢀⠀⠀⠀⠆⠀⠀⠀⠀⠀⠀⠀⡁
⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣧⣿⣿⠟⠋⠔⠂⠉⠀⠀⢀⡀⠀⠠⠀⠀⠈⠁⠀⡀⠀⠀⠄⠐⠠⠀⢄⠀⠀⠀⢤⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠛⠉⠀⠈⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠆⠀⢀⡀⠀⠀⠀⠀⠀⠀⠂⠀⠂⠀⠀⠠⠐⠀⠀⠂⠀⠀⠀⠀⠀⠀⠀

"
