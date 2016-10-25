# AWS EC2 Gaming

Quick-start configuration for macOS based on Larry Gadea's excellent work here:

http://lg.io/2015/07/05/revised-and-much-faster-run-your-own-highend-cloud-gaming-service-on-ec2.html

# Bootstrap

From a terminal:

- Install required components:
    brew install awscli jq
    brew cask install steam tunnelblick
- Install Microsoft Remote Desktop from the App Store
- From the terminal, run `aws configure` to configure your AWS credentials and region
- Clone this repository
- Run `./ec2gaming start`

Once the instance is running, a RDP session will be opened automatically. Login using the `administrator` account with the password `rRmbgYum8g`, change the password.

# First-time Configuration

The goal is to create a solid baseline that can be snapshotted to an AMI for future use, that requires zero intervention on startup and takes the minimum amount of time to install games.

- Update Steam and login
- Install several of the games you intend to play to install the redists
- Run Windows Update

## Automatic login

Use Autologin to set the instance to automatically login - https://technet.microsoft.com/en-us/sysinternals/autologon.aspx

## Remote install

The Steam remote install feature assumes the default Stream library, even if a second library is available and set to deafult. So, to install games to the emphemeral storage on `Z:\` remotely, we create a junction on instance startup:

- Copy `bootstrap/steamapps-junction.bat` to `C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`

Unfortunately, you can't install games larger than the freespace on `C:` with this approach, but in that case you can use RDP, and this avoids having to RDP for every installation.

## Final steps

# Run `./ec2gaming snapshot` to snapshot the EBS volume, create a new AMI and shutdown the instance
# Create a file `ec2gaming.auth` file (it's `.gitignored`) with two lines, it'll be used to authenticate the VPN for gaming:
    administrator
    <new password>
# Put the repository on your `PATH` for convenience

# Gaming!

- Run `ec2gaming start`. The instance, VPN and Steam will automatically start
- Wait for the notification that the remote gaming host is available for home streaming
- When you're done, run `ec2gaming terminate`
