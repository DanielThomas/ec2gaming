tell application "Tunnelblick"
    disconnect "ec2gaming"
    get state of first configuration where name = "ec2gaming"
    repeat until result = "EXITING"
        delay 1
        get state of first configuration where name = "ec2gaming"
    end repeat
end tell
