#!/bin/bash

# Определяем подсеть
SUBNET="10.10.65.32/27"

# Преобразуем подсеть в диапазон IP-адресов
IFS='/' read -r -a SUBNET_ARRAY <<< "$SUBNET"
NETWORK="${SUBNET_ARRAY[0]}"
PREFIX="${SUBNET_ARRAY[1]}"

# Вычисляем количество хостов в подсети
HOSTS=$((2**(32-PREFIX)-2))

# Преобразуем сетевой адрес в числовой формат
IFS='.' read -r -a NETWORK_OCTETS <<< "$NETWORK"
NETWORK_NUM=$(( (${NETWORK_OCTETS[0]}<<24) + (${NETWORK_OCTETS[1]}<<16) + (${NETWORK_OCTETS[2]}<<8) + ${NETWORK_OCTETS[3]} ))

# Сканируем каждый хост в подсети
for ((i=1; i<=HOSTS; i++)); do
    IP_NUM=$((NETWORK_NUM + i))
    IP=$(printf "%d.%d.%d.%d\n" $(( (IP_NUM>>24)&0xFF )) $(( (IP_NUM>>16)&0xFF )) $(( (IP_NUM>>8)&0xFF )) $(( IP_NUM&0xFF )))
    ping -c 1 -W 1 "$IP" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Host $IP is up"
    else
        echo "Host $IP is down"
    fi
done
