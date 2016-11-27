tell application "Viscosity"
    connect (connections where name is "ec2gaming")
    set currentState to state of connections where name is "ec2gaming"
    repeat until currentState = "Connected"
        delay 1
        set currentState to state of connections where name is "ec2gaming"
    end repeat
end tell
