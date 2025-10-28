#!/bin/bash
# Helper script to access the n8n-ai Coder workspace via docker exec
# This bypasses the SSH connection issues

docker exec -u coder -it coder-Dewars30-n8n-ai-workspace bash -c '
export PATH="$HOME/.local/bin:$HOME/.local/share/pnpm:$PATH"
cd /home/coder/n8n-ai
echo "✅ n8n-ai workspace ready!"
echo "📁 Current directory: $(pwd)"
echo "🔧 Available commands:"
echo "   - task init     # One-time setup"
echo "   - task dev      # Start development environment"
echo "   - pnpm install  # Install dependencies"
echo "   - docker ps     # List Docker containers"
echo ""
exec bash
'
