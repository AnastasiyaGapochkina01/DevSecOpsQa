#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

VERIFICATION_FILE="verification_results.txt"

# Функция для проверки
check_status() {
    local task_name="$1"
    local command="$2"
    local expected="$3"
    
    echo -e "\n=== Проверка: $task_name ===" | tee -a "$VERIFICATION_FILE"
    
    if eval "$command" 2>/dev/null; then
        echo -e "${GREEN}✓ УСПЕХ${NC}" | tee -a "$VERIFICATION_FILE"
        return 0
    else
        echo -e "${RED}✗ ОШИБКА${NC}" | tee -a "$VERIFICATION_FILE"
        echo "Ожидалось: $expected" | tee -a "$VERIFICATION_FILE"
        return 1
    fi
}

# Очистка предыдущих результатов
> "$VERIFICATION_FILE"

echo "=== НАЧАЛО ВЫПОЛНЕНИЯ СКРИПТА ===" | tee -a "$VERIFICATION_FILE"
echo "Дата и время: $(date)" | tee -a "$VERIFICATION_FILE"

# Задача 1: Создание директории и файла system-info
echo -e "\n${YELLOW}=== ЗАДАЧА 1: Создание practice/system-info ===${NC}" | tee -a "$VERIFICATION_FILE"
mkdir -p ~/practice
touch ~/practice/system-info

# Запись информации в файл system-info
{
    echo "=== Current date and time ==="
    date
    echo ""
    
    echo "=== Disk size for root mount ==="
    df -h / | tail -1
    echo ""
    
    echo "=== Total RAM ==="
    free -h | grep Mem | awk '{print $2}'
    echo ""
    
    echo "=== CPU cores ==="
    nproc
    echo ""
    
    echo "=== Load average ==="
    uptime | awk -F'load average:' '{print $2}'
    echo ""
    
    echo "=== Top 3 directories by size ==="
    sudo du -h / 2>/dev/null | sort -rh | head -4 | tail -3
} > ~/practice/system-info

# Проверка задачи 1
check_status "Файл ~/practice/system-info создан" "[ -f ~/practice/system-info ]" "Файл должен существовать"
check_status "Директория ~/practice создана" "[ -d ~/practice ]" "Директория должна существовать"
check_status "Файл содержит данные" "[ -s ~/practice/system-info ]" "Файл не должен быть пустым"

# Задача 3: Создание пользователя и группы
echo -e "\n${YELLOW}=== ЗАДАЧА 3: Создание пользователя devops и группы external ===${NC}" | tee -a "$VERIFICATION_FILE"
sudo groupadd external 2>/dev/null || true
sudo useradd -m -s /bin/bash devops 2>/dev/null || true
sudo usermod -aG external devops

# Проверка пользователя и группы
check_status "Пользователь devops создан" "id devops" "Пользователь должен существовать"
check_status "Группа external создана" "getent group external" "Группа должна существовать"
check_status "devops в группе external" "id devops | grep -q external" "Пользователь должен быть в группе external"

# Создание директории projects и файлов
echo -e "\n${YELLOW}=== Создание /opt/projects ===${NC}" | tee -a "$VERIFICATION_FILE"
sudo mkdir -p /opt/projects
sudo touch /opt/projects/{app.py,run.sh,main.go}

# Назначение владельца и группы
sudo chown -R devops:adm /opt/projects

# Права для run.sh
sudo chmod a+x /opt/projects/run.sh

# Права для app.py
sudo chmod 760 /opt/projects/app.py

# Права для main.go
sudo chmod 654 /opt/projects/main.go

# Проверка файлов и прав
check_status "Директория /opt/projects создана" "[ -d /opt/projects ]" "Директория должна существовать"
check_status "Файл app.py существует" "[ -f /opt/projects/app.py ]" "Файл должен существовать"
check_status "Файл run.sh существует" "[ -f /opt/projects/run.sh ]" "Файл должен существовать"
check_status "Файл main.go существует" "[ -f /opt/projects/main.go ]" "Файл должен существовать"

echo -e "\n=== Проверка прав доступа ===" | tee -a "$VERIFICATION_FILE"
echo "Права для /opt/projects:" | tee -a "$VERIFICATION_FILE"
ls -ld /opt/projects | tee -a "$VERIFICATION_FILE"
echo "Права для файлов в /opt/projects:" | tee -a "$VERIFICATION_FILE"
ls -l /opt/projects/ | tee -a "$VERIFICATION_FILE"

check_status "Права для run.sh: 755" "[[ $(stat -c %a /opt/projects/run.sh) == '755' ]]" "Права должны быть 755"
check_status "Права для app.py: 760" "[[ $(stat -c %a /opt/projects/app.py) == '760' ]]" "Права должны быть 760"
check_status "Права для main.go: 654" "[[ $(stat -c %a /opt/projects/main.go) == '654' ]]" "Права должны быть 654"

# Создание резервной копии
echo -e "\n${YELLOW}=== Резервное копирование ===${NC}" | tee -a "$VERIFICATION_FILE"
sudo mkdir -p /opt/backups
BACKUP_FILE="/opt/backups/projects_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
sudo tar -czf "$BACKUP_FILE" -C /opt projects

check_status "Резервная копия создана" "[ -f $BACKUP_FILE ]" "Файл резервной копии должен существовать"
echo "Создан файл резервной копии: $BACKUP_FILE" | tee -a "$VERIFICATION_FILE"

# Сетевые интерфейсы UP с IPv4
echo -e "\n${YELLOW}=== Сетевые интерфейсы ===${NC}" | tee -a "$VERIFICATION_FILE"
echo "Сетевые интерфейсы UP с IPv4:" | tee -a "$VERIFICATION_FILE"
ip -4 -o addr show | grep -v "127.0.0.1" | awk '{print $2, $4}' | cut -d'/' -f1 | tee -a "$VERIFICATION_FILE"

# Запуск sleep процессов
echo -e "\n${YELLOW}=== Процессы sleep ===${NC}" | tee -a "$VERIFICATION_FILE"
bash -c 'sleep 300 & exec sleep 400' &
SLEEP_PID=$!

sleep 1

echo "Дерево процессов sleep:" | tee -a "$VERIFICATION_FILE"
pstree -p | grep sleep | tee -a "$VERIFICATION_FILE" || echo "Процессы sleep не найдены" | tee -a "$VERIFICATION_FILE"

echo "PID процессов sleep:" | tee -a "$VERIFICATION_FILE"
SLEEP_PIDS=$(pgrep sleep 2>/dev/null || echo "")
if [ -n "$SLEEP_PIDS" ]; then
    for pid in $SLEEP_PIDS; do
        echo "PID: $pid, PPID: $(ps -o ppid= -p $pid 2>/dev/null)" | tee -a "$VERIFICATION_FILE"
    done
else
    echo "Процессы sleep не запущены" | tee -a "$VERIFICATION_FILE"
fi

# Запуск yes процесса
echo -e "\n${YELLOW}=== Процесс yes ===${NC}" | tee -a "$VERIFICATION_FILE"
yes > /dev/null &
YES_PID=$!

sleep 2

# Топ 3 по CPU
echo "Топ-3 процесса по CPU:" | tee -a "$VERIFICATION_FILE"
ps aux --sort=-%cpu | head -4 | tee top_cpu | tee -a "$VERIFICATION_FILE"

# Топ 3 по памяти
echo "Топ-3 процесса по памяти:" | tee -a "$VERIFICATION_FILE"
ps aux --sort=-%mem | head -4 | tee top_mem | tee -a "$VERIFICATION_FILE"

# Убийство yes процесса
kill $YES_PID 2>/dev/null
check_status "Процесс yes завершен" "! kill -0 $YES_PID 2>/dev/null" "Процесс должен быть завершен"

# Установка nginx и memcached
echo -e "\n${YELLOW}=== Установка nginx и memcached ===${NC}" | tee -a "$VERIFICATION_FILE"
sudo apt-get update > /dev/null 2>&1
sudo apt-get install -y nginx memcached > /dev/null 2>&1

check_status "nginx установлен" "which nginx" "nginx должен быть установлен"
check_status "memcached установлен" "which memcached" "memcached должен быть установлен"

# Создание файла external_services
echo -e "\n${YELLOW}=== Файл external_services ===${NC}" | tee -a "$VERIFICATION_FILE"
VM_NAME=$(hostname)
CURRENT_DATETIME=$(date +"%Y-%m-%d_%H:%M:%S")

{
    echo "===> $VM_NAME $CURRENT_DATETIME <==="
    
    # Проверка memcached
    if systemctl is-active --quiet memcached; then
        MEMCACHED_STATUS="active"
    else
        MEMCACHED_STATUS="inactive"
    fi
    
    if systemctl is-enabled --quiet memcached 2>/dev/null; then
        MEMCACHED_ENABLED="and enabled"
    else
        MEMCACHED_ENABLED="and disabled"
    fi
    
    # Проверка nginx
    if systemctl is-active --quiet nginx; then
        NGINX_STATUS="active"
    else
        NGINX_STATUS="inactive"
    fi
    
    if systemctl is-enabled --quiet nginx 2>/dev/null; then
        NGINX_ENABLED="and enabled"
    else
        NGINX_ENABLED="and disabled"
    fi
    
    echo "memcached $MEMCACHED_STATUS $MEMCACHED_ENABLED"
    echo "nginx $NGINX_STATUS $NGINX_ENABLED"
} > external_services

cat external_services | tee -a "$VERIFICATION_FILE"

check_status "Файл external_services создан" "[ -f external_services ]" "Файл должен существовать"
check_status "Файл содержит имя ВМ" "grep -q $(hostname) external_services" "Файл должен содержать имя ВМ"

# Права для пользователя devops на управление сервисами
echo -e "\n${YELLOW}=== Права sudo для devops ===${NC}" | tee -a "$VERIFICATION_FILE"
SUDOERS_ENTRY="devops ALL=(ALL) NOPASSWD: /bin/systemctl stop nginx, /bin/systemctl start nginx, /bin/systemctl restart nginx, /bin/systemctl status nginx, /bin/systemctl stop memcached, /bin/systemctl start memcached, /bin/systemctl restart memcached, /bin/systemctl status memcached"

sudo bash -c "echo '$SUDOERS_ENTRY' > /etc/sudoers.d/devops-services"
sudo chmod 440 /etc/sudoers.d/devops-services

check_status "Файл sudoers создан" "[ -f /etc/sudoers.d/devops-services ]" "Файл должен существовать"
check_status "devops может выполнить systemctl status nginx" "sudo -u devops sudo -n systemctl status nginx 2>&1 | grep -q 'Active:'" "Пользователь должен иметь права"

# Финал
echo -e "\n${YELLOW}=== СВОДКА РЕЗУЛЬТАТОВ ===${NC}" | tee -a "$VERIFICATION_FILE"
echo "Все результаты сохранены в файл: $VERIFICATION_FILE" | tee -a "$VERIFICATION_FILE"
echo "Проверьте содержимое файлов:" | tee -a "$VERIFICATION_FILE"
echo "1. ~/practice/system-info - системная информация" | tee -a "$VERIFICATION_FILE"
echo "2. top_cpu - топ процессов по CPU" | tee -a "$VERIFICATION_FILE"
echo "3. top_mem - топ процессов по памяти" | tee -a "$VERIFICATION_FILE"
echo "4. external_services - статус сервисов" | tee -a "$VERIFICATION_FILE"
echo "5. $VERIFICATION_FILE - полные результаты проверки" | tee -a "$VERIFICATION_FILE"

echo -e "\n${GREEN}=== СКРИПТ УСПЕШНО ЗАВЕРШЕН ===${NC}" | tee -a "$VERIFICATION_FILE"
echo "Дата и время: $(date)" | tee -a "$VERIFICATION_FILE"

