@echo off
rem Creating ephemeral Steam library...
rd "C:\Program Files (x86)\Steam\steamapps"
md Z:\SteamLibrary\steamapps
cmd /c mklink /j "C:\Program Files (x86)\Steam\steamapps" Z:\SteamLibrary\steamapps
rem Starting Steam...
start "" "C:\Program Files (x86)\Steam\Steam.exe"
