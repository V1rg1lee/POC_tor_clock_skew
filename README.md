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
HiddenServiceVersion 3
HiddenServicePort 80 unix:/var/lib/tor/hs_admin/flask.sock
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
sudo ./launch_web.sh
```

This will start the web server in a unix socket, which is only accessible from the Tor network. You can access it via 
- the Tor browser using `http://<ONION_ADDRESS>/admin/data`, this will reply "Unauthorized", because you need to send the request with the "Authorization" header with your cookie. You can access `http://<ONION_ADDRESS>` without the cookie.
- with the command:
```bash
python3 web/client.py
```
This will send a request to the web server and print the response.


## Skew demo
To run the skew demo, the web server must be running. Follow the previous steps to start the web server.

The first step is to capture packets to the suspected device. You can use the `skew_demo/normal_flux.sh` to achieve this. You can edit the url in the script to target a specific device.

Then, you have to capture packets to the hidden service. You can use the `skew_demo/tor_flux.sh` to achieve this. You can edit the tor hostname in the script to target a specific hidden service.

Finally, you can run the skew calculation with the `skew_demo/skew_calc.py` script. This will calculate the skew between the two captured packets and print the result.
