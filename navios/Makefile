
install: install_system_modems install_system_weather install_autoconnect

install_system_weather:
	@echo Installing systemd system service...
	sudo install -o root -g wheel system/weather-autoupdate.timer /etc/systemd/system
	sudo install -o root -g wheel system/weather-autoupdate.service /etc/systemd/system
	sudo systemctl daemon-reload
	sudo systemctl enable weather-autoupdate.timer
	sudo systemctl start weather-autoupdate.timer


install_autoconnect:
	@echo Installing systemd user service... 
	install ../baseod/user/network-autoconnect.service ~/.config/systemd/user
	systemctl --user daemon-reload
	systemctl --user enable network-autoconnect.service
	systemctl --user start network-autoconnect.service

status:
	sudo systemctl status modems.service
	systemctl --user status modems.service

