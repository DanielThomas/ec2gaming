tell application "Viscosity"
    disconnect (connections where name is "ec2gaming")
    set currentState to state of connections where name is "ec2gaming"
    repeat until currentState = "Disconnected"
        delay 1
        set currentState to state of connections where name is "ec2gaming"
	set currentState to currentState as string
    end repeat
end tell
