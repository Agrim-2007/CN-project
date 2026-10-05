from flask import Flask, jsonify, make_response
app = Flask(__name__)

@app.route('/')
def index():
    resp = make_response(jsonify({"message": "Service is running on Backend B"}))
    resp.headers['X-Backend'] = 'B'
    return resp

@app.route('/api/status')
def status():
    resp = make_response(jsonify({"backend": "B", "status": "ok"}))
    resp.headers['X-Backend'] = 'B'
    return resp

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3002)
