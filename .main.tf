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

provider "coder" {
}

resource "coder_agent" "main" {
  os   = "linux"
  arch = "amd64"

  dir = "/workspace/n8n-ai"

  env = {
    TASK_REPO = var.repo_url
  }

  startup_script = <<-EOT
    set -e
    # install Node 20, pnpm, task
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    curl -sL https://taskfile.dev/install.sh | sh -s -- -b /usr/local/bin
    source /root/.bashrc
    # clone the repo (or use existing)
    if [ ! -d "n8n-ai" ]; then
      git clone "${var.repo_url}" n8n-ai
    fi
    cd n8n-ai
    pnpm install
    echo "✅ Ready—run 'task dev' to start n8n-ai"
  EOT
}

resource "docker_container" "workspace" {
  image = "codercom/code-server:4.19.1"
  name  = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
  # cpu / memory can be tuned
  cpus   = 2
  memory = 4096
  env = [
    "CODER_AGENT_TOKEN=${coder_agent.main.token}",
    "DOCKER_HOST=/var/run/docker.sock"
  ]
  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
  }
  volumes {
    container_path = "/workspace"
    # persistent volume so deps survive stop/start
    volume_name = docker_volume.workspace.id
  }
}

resource "docker_volume" "workspace" {
  name = "coder-${data.coder_workspace.me.owner}-${data.coder_workspace.me.name}"
}

data "coder_workspace" "me" {}
