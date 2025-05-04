sudo apt update
sudo apt install tor -y

echo "HiddenServiceDir /var/lib/tor/hidden_service_mail/" | sudo tee -a /etc/tor/torrc
echo "HiddenServicePort 587 127.0.0.1:587" | sudo tee -a /etc/tor/torrc
echo "HiddenServicePort 993 127.0.0.1:993" | sudo tee -a /etc/tor/torrc

sudo systemctl restart tor

sudo apt install postfix dovecot-core dovecot-imapd -y

sudo sed -i 's/^inet_interfaces *= *.*/inet_interfaces = loopback-only/' /etc/postfix/main.cf
sudo sed -i 's/^listen *= *.*/listen = 127.0.0.1/' /etc/dovecot/dovecot.conf

sudo systemctl restart postfix
sudo systemctl restart dovecot

echo "Tor hostname:"
sudo cat /var/lib/tor/hidden_service_mail/hostname

echo "Mail server is set up and running on the Tor network."
