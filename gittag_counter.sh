#!/usr/bin/env bash

# Проверяем наличие двух аргументов
if [ $# -lt 2 ]; then
  echo "Использование: $0 <N> <repo_path>"
  echo "  <N> — номер коммита, считая от HEAD назад (1 — это HEAD)"
  echo "  <repo_path> — путь к локальному Git-репозиторию"
  exit 1
fi

# Считываем аргументы
N=$1
REPO_PATH=$2

# Проверяем, что <repo_path> существует
if [ ! -d "$REPO_PATH" ]; then
  echo "Ошибка: директория '$REPO_PATH' не существует."
  exit 2
fi

# Проверяем, что в <repo_path> действительно есть .git
if [ ! -d "$REPO_PATH/.git" ]; then
  echo "Ошибка: в директории '$REPO_PATH' не найден .git (не является репозиторием)."
  exit 3
fi

# Проверяем, есть ли хотя бы один коммит
TOTAL_COMMITS=$(git -C "$REPO_PATH" rev-list --count HEAD 2>/dev/null)
if [ -z "$TOTAL_COMMITS" ] || [ "$TOTAL_COMMITS" -eq 0 ]; then
  echo "Ошибка: в репозитории '$REPO_PATH' нет ни одного коммита."
  exit 4
fi

# Проверяем, что N не превышает общее число коммитов
if [ "$N" -gt "$TOTAL_COMMITS" ]; then
  echo "Ошибка: запрошен коммит номер $N, но всего в ветке $TOTAL_COMMITS коммит(ов)."
  exit 5
fi

# Получаем хеш N-го коммита от HEAD (HEAD = N=1, предыдущий = N=2 и т.д.)
TARGET_COMMIT=$(git -C "$REPO_PATH" rev-list HEAD --max-count=1 --skip=$((N-1)) 2>/dev/null)

echo "Общее количество коммитов в ветке: $TOTAL_COMMITS"
echo "Хеш $N-го коммита от HEAD: $TARGET_COMMIT"
