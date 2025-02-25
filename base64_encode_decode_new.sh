#!/bin/bash

process_string() {
    local input="$1"

    # Попытка декодировать строку как Base64
    if echo "$input" | base64 -d &>/dev/null; then
        decoded=$(echo "$input" | base64 -d)
        echo "Строка была закодирована в Base64. Декодированная строка: $decoded"
    else
        # Если декодирование не удалось, кодируем строку в Base64
        encoded=$(echo -n "$input" | base64)
        echo "Строка не была закодирована в Base64. Закодированная строка: $encoded"
    fi
}

# Пример использования
echo "Введите строку:"
read input_str
process_string "$input_str"
