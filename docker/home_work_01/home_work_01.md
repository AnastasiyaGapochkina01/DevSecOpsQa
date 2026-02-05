# 1. Одиночный контейнера на базе nginx
Запустить простое веб-приложение в контейнере Nginx с монтированием локальной папки `html`  и пробросом портов. Структура проекта:
```
task1/
├── Dockerfile
└── html/
    └── index.html
```
содержимое файла `index.html`
```html
<!DOCTYPE html>
<html>
<head><title>Docker Task 1</title></head>
<body>
<h1>✅ Контейнер запущен!</h1>
<p>Время: <span id="time"></span></p>
<script>document.getElementById('time').innerText = new Date().toLocaleString();</script>
</body>
</html>
```
# 2. Одиночный контейнера с приложением на python
Запустить Flask-приложение, сохраняющее логи в volume на хосте и маппингом портов. Структура проекта
```
task2/
├── Dockerfile
├── app.py
└── logs/
```
содержимое файла `app.py`
```python
from flask import Flask
import os, datetime
app = Flask(__name__)

@app.route('/')
def hello():
    log_path = '/logs/app.log'
    with open(log_path, 'a') as f:
        f.write(f"Request at {datetime.datetime.now()}\n")
    with open(log_path, 'r') as f:
        logs = f.read()
    return f"<h1>Hello Docker!</h1><pre>{logs}</pre>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```
**Поверка**
```bash
curl http://localhost:5000
```
вывести соддержимое файла `./logs/app.log`
# 3. Docker Compose для двух контейнеров
Запустить Flask + Redis через Compose с срхранением данных redis с помощью docker volume. Структура проекта
```
task3/
├── docker-compose.yml
├── app/
│   ├── Dockerfile
│   └── app.py
└── requirements.txt
```
содержимое файла
- `app.py`
```python
from flask import Flask
import redis, os, datetime
app = Flask(__name__)
r = redis.Redis(host='redis', port=6379)

@app.route('/')
def hello():
    count = r.incr('hits')
    return f'<h1>Hello Docker Compose! Посещений: {count}</h1>'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```
- `requirements.txt`
```
flask
redis
```
# 4. Многокомпонентное приложение (WordPress)
Развернуть полноценное приложение: WordPress с MySQL с помощью docker compose
