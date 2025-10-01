#!/bin/bash
INSTALL_DIR="/root/nexus-node"
NODE_ID_FILE="$INSTALL_DIR/node_id.txt"
REPO_URL="https://github.com/VaniaHilkovets/nexus-binaries.git"
TMUX_SESSION="nexus"

echo "📦 Устанавливаю зависимости..."
apt update -y
DEBIAN_FRONTEND=noninteractive apt install -y curl git tmux nano

# 🔍 Проверка наличия tmux
if ! command -v tmux >/dev/null; then
  echo "❌ tmux не установлен. Выход."
  exit 1
fi

echo "📁 Клонирую или обновляю бинарник..."
if [ -d "$INSTALL_DIR/.git" ]; then
  cd "$INSTALL_DIR" && git pull
else
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

# 🔐 Получение или ввод node-id
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

echo "🧹 Убиваю старую tmux-сессию (если была)..."
tmux kill-session -t "$TMUX_SESSION" 2>/dev/null || true

echo "🚀 Запускаю ноду с автоматической адаптацией сложности..."
tmux new-session -d -s "$TMUX_SESSION" "cd $INSTALL_DIR && ./nexus-network start --node-id $NODE_ID"

echo "✅ Всё готово. Открываю сессию..."
sleep 1
tmux attach -t "$TMUX_SESSION"
