#!/bin/bash

is_base64() {
    # Проверка на допустимые символы base64
    if [[ "$1" =~ ^[A-Za-z0-9+/]+={0,2}$ ]]; then
        return 0
    else
        return 1
    fi
}

check_base64() {
    if is_base64 "$1"; then
        # Попытка декодирования
        decoded=$(echo "$1" | base64 --decode 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            # Проверка на наличие нечитаемых символов
            if echo "$decoded" | grep -q '[^[:print:][:space:]]'; then
                echo "Строка выглядит как base64, но содержит нечитаемые символы. Кодируем."
                encoded=$(printf "%s" "$1" | base64)
                echo "$encoded"
                return 1
            else
                echo "Строка успешно декодирована."
                echo "$decoded"
                return 0
            fi
        else
            echo "Строка выглядит как base64, но декодирование не удалось."
            return 1
        fi
    else
        # Кодирование, если строка не распознается как Base64
        encoded=$(printf "%s" "$1" | base64)
        echo "Строка не распознана как Base64. Кодируем."
        echo "$encoded"
        return 1
    fi
}

if [[ $# -ne 1 ]]; then
    echo "Использование: $0 <строка>"
    exit 1
fi

check_base64 "$1"
