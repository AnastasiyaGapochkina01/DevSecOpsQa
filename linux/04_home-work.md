Запустить приложение https://github.com/AnastasiyaGapochkina01/cyberpunk-devops

# Требования к разворачиванию
1) В системе должны быть пользователи

| Пользователь | UID  | Группа    | Назначение         | Создание                 |
| ------------ | ---- | --------- | ------------------ | ------------------------ |
| www-data     | 33   | www-data  | Nginx + Uvicorn    | apt install nginx (авто) |
| cyberpunk    | 1001 | cyberpunk | Разработчик/деплой | adduser cyberpunk        |

2) Пользователям должны быть выданы такие права
```
 cyberpunk-api/          # Владелец: www-data:www-data (755)
 ├── api/                # 755 www-data:www-data
 │   └── main.py         # 644 www-data:www-data
 ├── static/             # 755 www-data:www-data
 │   └── index.html      # 644 www-data:www-data
 ├── venv/               # 755 www-data:www-data
 └── logs/               # 755 www-data:adm (логи)

```
3) Приложение запущено как systemd сервис
4) Доступ к приложению через nginx
5) Разворачивание приложения реализовано через bash-скрипт
