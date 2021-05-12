from flask import Flask, request
from data_sync import data_sync, sync_main_server
import subprocess
import threading

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




def delayed_restart_func():
    import time
    time.sleep(5)
    subprocess.call("sudo reboot", shell=True)

@app.route("/restart", methods=["GET"])
def restart():
    #subprocess.call("sudo reboot", shell=True)
    threading.Thread(target=delayed_restart_func).start()
    return "Restart initaited", 200


def delayed_shutdown_func():
    import time
    time.sleep(5)
    subprocess.call("sudo shutdown now", shell=True)

@app.route("/shutdown", methods=["GET"])
def shutdown():
    #subprocess.call("sudo shutdown now", shell=True)
    threading.Thread(target=delayed_shutdown_func).start()
    return "Shutdown initiated", 200







if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", threaded=True, port=5000)
