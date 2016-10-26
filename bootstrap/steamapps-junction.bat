@echo off
rmdir /Q /S  "C:\Program Files (x86)\Steam\steamapps"
md Z:\SteamLibrary\steamapps
cmd /c mklink /j "C:\Program Files (x86)\Steam\steamapps" Z:\SteamLibrary\steamapps
