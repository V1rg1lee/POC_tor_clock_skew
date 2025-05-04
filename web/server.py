from flask import Flask, jsonify, request
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

AUTH_TOKEN = os.getenv("AUTH_TOKEN")

@app.route('/')
def index():
    return jsonify({'status':'OK', 'message':'Hello, World!'}), 200

@app.route('/admin/data', methods=['GET'])
def get_data():
    token = request.headers.get('Authorization', '')
    if token != f"Bearer {AUTH_TOKEN}":
        return jsonify({'error':'Unauthorized'}), 401
    
    return jsonify({'status':'OK', 'data':'42'}), 200

if __name__ == "__main__":
    app.run(host='127.0.0.1', port=8443)
