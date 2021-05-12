from flask import Flask, request
from data_sync import data_sync, sync_main_server
import subprocess

app = Flask(__name__)


@app.route("/sync", methods=["POST"])
def sync():
    tablet_id = request.args.get("tablet_id")
    dump = request.data
    return data_sync(tablet_id, dump)

@app.route("/sync_with_dk", methods=["POST"])
def sync_with_dk():
    token = request.json.get("jwt")
    return sync_main_server(token)


@app.route("/get_dump")
def get_dump():
    tablet_id = request.args.get("tablet_id")
    print(tablet_id)
    return 


@app.route("/ping", methods=["GET"])
def ping():
    return "Ping!"


@app.route("/restart", methods=["GET"])
def restart():
    subprocess.call("sudo reboot", shell=True)
    return

@app.route("/shutdown", methods=["GET"])
def shutdown():
    subprocess.call("sudo shutdown now", shell=True)
    return







if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", threaded=True, port=5000)
