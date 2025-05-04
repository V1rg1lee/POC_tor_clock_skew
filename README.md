# Tor-Proof-Of-Concept

## Installation (Linux)

1. Install Tor:
```bash
sudo apt update
sudo apt-get install tor
```

2. Configure Tor:
```bash
sudo nano /etc/tor/torrc
```
Add the following lines to the end of the file:
```
ControlPort 9051
HashedControlPassword 16:<YOUR_HASHED_PASSWORD>
SocksPort 9050
CookieAuthentication 1
```

3. Generate a hashed password:
```bash
tor --hash-password <YOUR_PASSWORD>
```
Replace `<YOUR_HASHED_PASSWORD>` in the `torrc` file with the output from the above command.

4. Restart Tor:
```bash
sudo systemctl restart tor
```

5. Create a virtual environment:
```bash
python3 -m venv venv
```

6. Install Python dependencies:
```bash
pip install -r requirements.txt
```