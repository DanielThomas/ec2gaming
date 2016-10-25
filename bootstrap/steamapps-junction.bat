@echo off
rd "C:\Program Files (x86)\Steam\steamapps"
md Z:\SteamLibrary\steamapps
cmd /c mklink /j "C:\Program Files (x86)\Steam\steamapps" Z:\SteamLibrary\steamapps
