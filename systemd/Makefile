
install: install_system_modems install_system_pamac install_autoconnect

install_system_modems:
	@echo Installing systemd system service...
	sudo install -o root -g wheel wwan-setup.sh /usr/local/sbin 
	sudo install -o root -g wheel system/modems.service /etc/systemd/system
	sudo systemctl daemon-reload
	sudo systemctl enable modems.service
	sudo systemctl start modems.service

install_system_pamac:
	@echo Installing systemd system service...
	sudo install -o root -g wheel system/pamac-autoupdate.timer /etc/systemd/system
	sudo install -o root -g wheel system/pamac-autoupdate.service /etc/systemd/system
	sudo systemctl daemon-reload
	sudo systemctl enable pamac-autoupdate.timer
	sudo systemctl start pamac-autoupdate.timer


install_autoconnect:
	@echo Installing systemd user service... 
	install user/network-autoconnect.service ~/.config/systemd/user
	systemctl --user daemon-reload
	systemctl --user enable network-autoconnect.service
	systemctl --user start network-autoconnect.service

status:
	sudo systemctl status modems.service
	systemctl --user status modems.service

