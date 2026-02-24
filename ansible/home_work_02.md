1) Написать роль, которая
- настроит на удаленной ВМ таймзону и локаль
- создаст пользователя admin с полными правами администратора на ВМ
- настроит конфигурацию сервера ssh - запрет на вход по root учеткой
2) Написать роль по установке docker на ВМ; роль так же должна
- настроить глобально следющие параметры `dockerd`
  - тип логирования (`log-driver`) - `json-file`
  - список registry (`insecure-registries`)
  - опции логирования
  ```
    "max-size": "10m"
    "max-file": "3"
  ```
- создать пользователя `deploer`, который может выполнять все команды docker без sudo и пароля
3) Написать роль, которая устанавливает
- node-exporter (НЕ в docker)
- postgres-exporter (НЕ в docker)
- blackbox exporter (в docker)
4) Написать роль, управляющую cron
- установка cron (если нет)
- создание нескольких cron‑задач (бэкапы, очищение директории temp)
- возможность отключать задания через `state: absent` по переменной `disable=true`
5) Написать роль, которая будет устанавливать переменные окружения для проекта из шаблона
```jinja2
DATABASE_URL = {{ db_url }}
APP_ENV = {{ env }}
FEATURE_FLAGS = {{ app_flags }}
```
6) Написать роль по установке и настройке fluentbit; роль должна
- установить fluentbit (НЕ в docker) и проверить что он установлен
```bash
fluent-bit -c /etc/fluent-bit/fluent-bit.conf -R /etc/fluent-bit/parsers.conf -t
```
- настроить с помощью файлов ниже
  - основной конфиг
    ```
    [SERVICE]
        Flush        1
        Daemon       Off
        Log_Level    info

    [INPUT]
        Name              tail
        Path              /var/lib/docker/containers/*/*-json.log
        Tag               docker.*
        Parser            docker
        DB                /var/log/flb_docker.db
        Mem_Buf_Limit     50MB
        Skip_Long_Lines   On
        Refresh_Interval  5

    [OUTPUT]
        Name        stdout
      Match       docker.*
      Format      json_lines 
    ```
  - парсер (`docker`)
    ```
    [PARSER]
        Name        docker
        Format      json
        Time_Key    time
        Time_Format %Y-%m-%dT%H:%M:%S.%L
        Time_Keep   On
    ```
