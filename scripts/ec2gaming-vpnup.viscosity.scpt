tell application "Viscosity"
    set currentState to "Unknown"
    repeat until (currentState = "Connected")
        if currentState = "Disconnected" then
            connect (connections where name is "ec2gaming")
        end if
        set currentState to state of connections where name is "ec2gaming"
        set currentState to currentState as string
	delay 1
    end repeat
end tell
