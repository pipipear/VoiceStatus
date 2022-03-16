# VoiceStatus
Shows users in a Discord voice channel

# Installation
## Server
go version 1.17 or higher required
```bash
go install -v github.com/pipipear/VoiceStatus/VoiceServer@latest
wget github.com/pipipear/VoiceStatus/raw/main/VoiceServer.desktop -P ~/.config/autostart/

nano ~/.config/VoiceStatus.json
```
Add the following to the config file  
[How To Get Your Discord Token](https://pcstrike.com/how-to-get-discord-token/#:~:text=Right%2Dclick%20the%20value%20on,edit%20value%2C%20then%20copy%20it.)  
[How to Get a Discord Bot Token](https://www.writebots.com/discord-bot-token/#:~:text=You%E2%80%99ll%20also%20see%20a%20%E2%80%9CToken%E2%80%9D%20and%20a%20blue%20link%20you%20can%20click%20called%20%E2%80%9CClick%20to%20Reveal%20Token%E2%80%9D)
```json
{
  "PORT": "5462",
  "TOKEN": "discord-token"
}
```
Start the server
```bash
~/go/bin/VoiceServer
```

## Plasmoid
A websockets package for qml is required i.e.
```bash
sudo apt-get install qml-module-qtwebsockets
sudo pacman -S qt5-websockets
sudo dnf install qt5-qtwebsockets
```
The plasmoid can be installed from [https://www.pling.com/p/1735750/](https://www.pling.com/p/1735750/)
