from flask import Flask
import socket
import os

app = Flask(__name__)

@app.route("/")
def home():
    pod_name = socket.gethostname()
    version = os.getenv("APP_VERSION", "v1")
    return f"Hello from Day 20 Helm lab! Version={version}, Pod={pod_name}\n"

@app.route("/cpu")
def cpu():
    total = 0
    for i in range(5000000):
        total += i * i
    return f"CPU load generated: {total}\n"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
