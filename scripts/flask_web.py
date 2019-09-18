#! /usr/bin env python3

from flask import Flask
from flask import request, jsonify

app = Flask(__name__)


@app.route('/route/exist', methods=['GET'])
def route_exist():
    _map = {"192.168.110.101": "aa:24:27:b2:2a:36",
            "192.168.110.102": "f2:94:ab:9d:84:21"}
    data = {'Allow': True, 'Error': None,
            'dstMac': _map.get(request.args.get('dstIP'))}
    if request.args.get('dstPort') == '9099':
        data['Allow'] = False
    return jsonify(data)


if __name__ == '__main__':
    # app.debug = True
    app.run('::', 9013)
