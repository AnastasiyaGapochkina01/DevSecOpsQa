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
