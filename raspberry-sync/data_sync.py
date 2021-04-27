import os
import requests

DUMP_ROOT_FOLDER = "dumps"
FILE_NAME = "dump"
MAIN_SERVER_SYNC_ENDPOINT = "https://hdss.bandim.sdu.dk:5000/api/survey/sync_with_dk"
#MAIN_SERVER_SYNC_ENDPOINT = "http://192.168.1.10:5000/api/survey/sync_with_dk"
FULL_PATH = os.path.dirname(__file__) + "/dumps"


def check_and_create_folder(dir_):
    if not os.path.exists(dir_):
        os.makedirs(dir_)


def data_sync(tablet_id, dump):
    file_path = DUMP_ROOT_FOLDER + "/" + tablet_id + "_" + FILE_NAME
    check_and_create_folder(DUMP_ROOT_FOLDER)
    dump_file = open(file_path, "wb")
    dump_file.write(dump)
    dump_file.close()
    return "Sync succesful!"


def read_text_file(file_path):
    print(file_path)
    with open(file_path, 'rb') as f:
        bytes = f.read()
        return bytes


def get_all_dumps():
    dumps = []
    owd = os.getcwd()
    os.chdir(FULL_PATH)
    for file in os.listdir():
        file_path = f"{FULL_PATH}/{file}"
        dumps.append(read_text_file(file_path))
    os.chdir(owd)

    return dumps


def sync_main_server(token):
    dumps = get_all_dumps()
    if len(dumps) == 0:
        return "No dumps", 204
    
    sync_success = True
    for dump in dumps:
        s = requests.Session()
        req = requests.Request("POST", MAIN_SERVER_SYNC_ENDPOINT, data=dump)
        prepped = req.prepare()
        prepped.headers["Content-Type"] = "application/octet-stream"
        prepped.headers["Accept"] = "*/*"
        prepped.headers["Accept-Encoding"] = "gzip, deflate, br"
        prepped.headers["Connection"] = "keep-alive"
        prepped.headers["Cookie"] = token
        response = s.send(prepped)

        if response.status_code != 200:
            sync_success = False
    

    if sync_success:
        from subprocess import call
        import os
        if not os.path.exists(os.getcwd() + "/transferred-dumps"):
            os.mkdir("transferred-dumps")
        call("sudo mv {} {}".format(os.getcwd() + "/dumps/*", os.getcwd() + "/transferred-dumps"), shell=True)
        print("all good")
        return "All went well", 200
    print("oh shit")
    return "One or more DB transfers failed", 400