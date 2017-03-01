from flask import Flask, render_template, request, url_for
from flask import jsonify
import subprocess
import thread
import time
import re

app = Flask(__name__)


data = {}

@app.route('/')
def index():
    return jsonify(data)

def runtop():
    topscript = "bash runtop.sh".split()
    while True:
        output = subprocess.Popen(topscript, stdout=subprocess.PIPE).communicate()[0]
        now = time.time()
        seconds = now % 60
        data[str(int(seconds))] = output
        time.sleep(1)

if __name__ == "__main__":
    thread.start_new_thread(runtop, ())
    app.run('0.0.0.0')
