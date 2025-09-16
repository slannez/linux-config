install:
	sudo install -o root -g wheel wwan-setup.sh /usr/local/sbin 
	sudo install -o root -g wheel modems.service /etc/systemd/system
	sudo systemctl daemon-reload
	sudo systemctl enable modems.service
	sudo systemctl start modems.service

status:
	sudo systemctl status modems.service

