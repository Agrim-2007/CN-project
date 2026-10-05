from flask import Flask, jsonify, make_response
app = Flask(__name__)

@app.route('/')
def index():
    resp = make_response(jsonify({"message": "Service is running on Backend A"}))
    resp.headers['X-Backend'] = 'A'
    return resp

@app.route('/api/status')
def status():
    resp = make_response(jsonify({"backend": "A", "status": "ok"}))
    resp.headers['X-Backend'] = 'A'
    return resp

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3001)
