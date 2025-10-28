terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "~> 0.11"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

variable "repo_url" {
  description = "GitHub repo that contains the n8n-ai source"
  default     = "https://github.com/dewars30/n8n-ai.git"
}

variable "disk_size" {
  description = "Disk size (GB)"
  default     = 50
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "coder" {
}

resource "coder_agent" "main" {
  os   = "linux"
  arch = "amd64"

  dir = "/home/coder"

  startup_script = <<-EOT
    #!/bin/bash
    set -e
    cd /home/coder

    # Install Node 20, pnpm, task
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    export PNPM_HOME="/home/coder/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"

    # Install task to user bin directory (no sudo needed)
    mkdir -p ~/.local/bin
    curl -sL https://taskfile.dev/install.sh | sh -s -- -b ~/.local/bin
    export PATH="$HOME/.local/bin:$PATH"

    # Add coder user to docker group and fix socket permissions
    sudo usermod -aG docker coder
    sudo chgrp docker /var/run/docker.sock
    sudo chmod 660 /var/run/docker.sock

    # Clone the repo (or use existing)
    if [ ! -d "n8n-ai" ]; then
      if git clone "${var.repo_url}" n8n-ai 2>/dev/null; then
        echo "✅ Repository cloned successfully"
        cd n8n-ai
        pnpm install
        echo "✅ Ready—run 'task dev' to start n8n-ai"
      else
        echo "⚠️  Could not clone repository (may need GitHub authentication)"
        echo "To clone manually: git clone ${var.repo_url}"
        echo "✅ Workspace ready - pnpm and task are installed"
      fi
    else
      cd n8n-ai
      pnpm install
      echo "✅ Ready—run 'task dev' to start n8n-ai"
    fi
  EOT
}

resource "docker_image" "coder" {
  name = "coder-workspace"
  build {
    context    = path.module
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "workspace" {
  count  = data.coder_workspace.me.start_count
  image  = docker_image.coder.name
  name   = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
  hostname = data.coder_workspace.me.name

  cpu_shares = 2048
  memory     = 4096

  # Use the replace pattern from official example for Docker gateway
  command = [
    "sh", "-c",
    replace(coder_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")
  ]

  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}"
  ]

  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }

  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
  }

  volumes {
    container_path = "/home/coder"
    volume_name = docker_volume.workspace.id
  }
}

resource "docker_volume" "workspace" {
  name = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
}

data "coder_workspace" "me" {}
