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

# 🔧 Запрос уровня сложности
echo ""
echo "🎚️  Выберите уровень сложности:"
echo "1) SMALL         - Базовые задачи (2-4 ядра, 4-8 GB RAM)"
echo "2) SMALL_MEDIUM  - Стандарт (4-6 ядер, 8-12 GB RAM)"
echo "3) MEDIUM        - Средний (6-8 ядер, 12-16 GB RAM)"
echo "4) LARGE         - Высокий (8+ ядер, 16+ GB RAM)"
echo "5) EXTRA_LARGE   - Максимальный (12+ ядер, 24+ GB RAM)"
echo ""

while true; do
  read -rp "Введите номер (1-5) [по умолчанию 2]: " DIFFICULTY_CHOICE
  
  # Если пользователь нажал Enter без ввода, используем значение по умолчанию
  if [ -z "$DIFFICULTY_CHOICE" ]; then
    DIFFICULTY_CHOICE="2"
  fi
  
  case $DIFFICULTY_CHOICE in
    1) MAX_DIFFICULTY="small"; break ;;
    2) MAX_DIFFICULTY="small_medium"; break ;;
    3) MAX_DIFFICULTY="medium"; break ;;
    4) MAX_DIFFICULTY="large"; break ;;
    5) MAX_DIFFICULTY="extra_large"; break ;;
    *) echo "⚠️  Неверный выбор. Пожалуйста, введите число от 1 до 5." ;;
  esac
done

echo "✅ Выбранный уровень сложности: $MAX_DIFFICULTY"

echo "⚙️ Делаю бинарник исполняемым..."
chmod +x "$INSTALL_DIR/nexus-network"

echo "🧹 Убиваю старую tmux-сессию (если была)..."
tmux kill-session -t "$TMUX_SESSION" 2>/dev/null || true

echo "🚀 Запускаю ноду в новой tmux-сессии '$TMUX_SESSION'..."
tmux new-session -d -s "$TMUX_SESSION" "cd $INSTALL_DIR && ./nexus-network start --node-id $NODE_ID --max-difficulty $MAX_DIFFICULTY"

echo "✅ Всё готово. Открываю сессию..."
sleep 1
tmux attach -t "$TMUX_SESSION"
