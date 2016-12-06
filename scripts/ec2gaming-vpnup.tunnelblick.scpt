tell application "Tunnelblick"
    connect "ec2gaming"
    get state of first configuration where name = "ec2gaming"
    repeat until result = "CONNECTED"
        delay 1
        get state of first configuration where name = "ec2gaming"
    end repeat
end tell
