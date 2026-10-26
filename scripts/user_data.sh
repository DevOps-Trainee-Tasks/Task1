#!/bin/bash
set -Eeuo pipefail

exec > >(tee -a /var/log/ollama-init.log) 2>&1
trap 'echo "Ollama initialization failed on line $LINENO" >&2' ERR

echo "Installing Ollama"
curl -fsSL https://ollama.com/install.sh -o /tmp/ollama-install.sh
sh /tmp/ollama-install.sh

install -d -m 0755 /etc/systemd/system/ollama.service.d
cat > /etc/systemd/system/ollama.service.d/listen.conf <<'EOF'
[Service]
Environment="OLLAMA_HOST=0.0.0.0:${ollama_port}"
EOF

systemctl daemon-reload
systemctl enable ollama
systemctl restart ollama

for attempt in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:${ollama_port}/api/tags" >/dev/null; then
    break
  fi
  sleep 2
done

curl -fsS "http://127.0.0.1:${ollama_port}/api/tags" >/dev/null
ollama pull "${ollama_model}"
echo "Ollama initialization completed"
