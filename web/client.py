import requests
from stem import Signal
from stem.control import Controller
import time
import os
from dotenv import load_dotenv

load_dotenv()

ONION_URL = os.getenv("ONION_URL")
AUTH_TOKEN = os.getenv("AUTH_TOKEN")
PASSWORD = os.getenv("TOR_PASSWORD")

def get_via_tor(path: str):
    session = requests.Session()
    session.proxies = {
        'http':  'socks5h://127.0.0.1:9050',
        'https': 'socks5h://127.0.0.1:9050'
    }
    headers = {'Authorization': f'Bearer {AUTH_TOKEN}'}
    resp = session.get(f"http://{ONION_URL}{path}", headers=headers, timeout=15)
    return resp

def renew_identity(password):
    with Controller.from_port(port=9051) as c:
        c.authenticate(password=password)
        c.signal(Signal.NEWNYM)
        time.sleep(c.get_newnym_wait())

if __name__ == "__main__":
    print("Données admin :", get_via_tor('/admin/data').json())
    renew_identity(PASSWORD)
    print("Après rotation :", get_via_tor('/admin/data').json())
