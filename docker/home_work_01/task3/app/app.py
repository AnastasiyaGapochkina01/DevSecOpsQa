from flask import Flask
import redis
import time
import sys

app = Flask(__name__)

def wait_for_redis(max_retries=30, delay=1):
    """Wait for Redis to become available"""
    for i in range(max_retries):
        try:
            r = redis.Redis(
                host='redis',
                port=6379,
                socket_connect_timeout=2,
                socket_timeout=2,
                decode_responses=True
            )
            r.ping()
            print(f"Redis connected successfully after {i+1} attempts")
            return r
        except redis.ConnectionError as e:
            if i == max_retries - 1:
                print(f"Failed to connect to Redis after {max_retries} attempts: {e}")
                sys.exit(1)
            print(f"Waiting for Redis... (attempt {i+1}/{max_retries})")
            time.sleep(delay)
    
    # Should not reach here
    sys.exit(1)

# Initialize Redis connection at startup
redis_client = wait_for_redis()

@app.route('/')
def hello():
    try:
        count = redis_client.incr('hits')
        return f'<h1>Hello Docker Compose! Visits: {count}</h1>'
    except Exception as e:
        return f'<h1>Error: {str(e)}</h1>', 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False, threaded=False)
