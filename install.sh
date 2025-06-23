#!/bin/bash

INSTALL_DIR="/root/nexus-node"
NODE_ID_FILE="$INSTALL_DIR/node_id.txt"
REPO_URL="https://github.com/VaniaHilkovets/nexus-binaries.git"

echo "📦 Устанавливаю зависимости..."
apt update -y
apt install -y curl git

echo "📁 Клонирую бинарник..."
rm -rf "$INSTALL_DIR"
git clone "$REPO_URL" "$INSTALL_DIR"

echo "🔐 Получаю node-id..."
if [ -f "$NODE_ID_FILE" ]; then
  NODE_ID=$(cat "$NODE_ID_FILE")
  echo "✅ Найден node-id: $NODE_ID"
else
  read -rp "📝 Введи node-id: " NODE_ID
  echo "$NODE_ID" > "$NODE_ID_FILE"
  echo "✅ Сохранён в $NODE_ID_FILE"
fi

echo "⚙️ Делаю бинарник исполняемым..."
chmod +x "$INSTALL_DIR/nexus-network"

echo "🚀 Запускаю ноду..."
cd "$INSTALL_DIR"
./nexus-network start --node-id "$NODE_ID"
