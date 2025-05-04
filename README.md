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
HiddenServiceDir /var/lib/tor/hs_admin/
HiddenServicePort 8443 127.0.0.1:8443
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

5. Copy the .onion address:
```bash
sudo cat /var/lib/tor/hs_admin/hostname
```

6. Create a virtual environment:
```bash
python3 -m venv venv
```

7. Install Python dependencies:
```bash
pip install -r requirements.txt
```

## Web Server

To test the web server with Tor, run the following command:
```bash
./launch_web.sh
```

This will start the web server on port 8443. You can access it via 
- the Tor browser using `http://<ONION_ADDRESS>:8443/admin/data`, this will reply "Unauthorized", because you need to send the request with the "Authorization" header with your cookie. You can access `http://<ONION_ADDRESS>:8443` without the cookie.
- with the command:
```bash
python3 web/client.py
```
This will send a request to the web server and print the response.
