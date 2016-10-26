# macOS EC2 Gaming

Scripts to make macOS EC2 gaming simple and reliable, based on [Larry Gadea's](http://lg.io/) excellent work.

# Features

The scripts streamline the first time setup, by bootstrapping from the ec2gaming AMI, creating security groups, and launching RDP settings. Once the first time setup is complete, the `start` command automatically brings up the gaming instance, connects the VPN and Steam.

It also provides helpful commands to automate repetitive tasks:

    macOS EC2 Gaming with Steam In-Home Streaming

    Usage: ec2gaming <command>

    To game, run start. For additional help, go to https://github.com/DanielThomas/ec2gaming#help

    Full list of supported commands:
    instance-ip
    instance
    rdp
    snapshot
    start
    stop
    terminate
    vpndown
    vpnup

# First-time configuration

The goal is to take the base [ec2gaming AMI](http://lg.io/2015/07/05/revised-and-much-faster-run-your-own-highend-cloud-gaming-service-on-ec2.html) and create an image that requires zero intervention on startup, allows Steam remote installs and minimizes the amount of time game install take.

From a terminal:

- Clone this repository to a convenient location and put it on the `PATH`
- Install required components using Homebrew:

    ```
    brew install awscli jq
    brew cask install steam tunnelblick
    ```

- Install Microsoft Remote Desktop from the App Store
- Run `aws configure` to configure your AWS credentials and region
- Run `ec2gaming start`

## Windows configuration

Once the instance is running, a RDP session will be opened automatically:

- Login using the `administrator` account with the password `rRmbgYum8g` and change the password.
- Run Windows Update

Note that EBS is super-slow at startup as blocks come off the snapshot, so expect the instance to be sluggish as it warms up. It only affects file operations on `C:\` and won't affect gaming performance later.

## OpenVPN configuration

Edit `C:\Program Files\OpenVPN\config\server.ovpn` and add `cipher none` to the end of the file. We're using the VPN for the tunnel, not security, and we don't want the overhead of encryption.

## Steam configuration

- Steam will run and update automatically
- Login and save your password
- Go to Settings -> In-Home Streaming -> Advanced Host Options and enable 'Hardware Encoding' and 'Prioritize network traffic'
- Install and run several of the games you intend to play to `Z:\`. This performs first-time installation, avoiding the redistributable installation overhead. Delete local files once you're done

## Steam remote install to ephemeral storage

The Steam remote install feature assumes the default Stream library, even if a second library is available and set to default. So, to install games to the emphemeral storage on `Z:\` remotely, we create a junction on instance startup:

- Copy `bootstrap/steamapps-junction.bat` to `C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`

Unfortunately, you can't install games larger than the freespace on `C:` with this approach, but in that case you can use RDP and this avoids having to RDP for every installation.

## Windows automatic login

Use Autologin to set the instance to automatically login, so Steam starts automatically and it's not necessary to RDP into the instance to start gaming:

https://technet.microsoft.com/en-us/sysinternals/autologon.aspx

## Update NVIDIA drivers

Driver 373.06 is the latest driver version that has the K520 included in the device list, later versions are missing `DEV_118A` completely:

http://www.nvidia.com/download/driverResults.aspx/108323/en-us

See here for background:

https://www.reddit.com/r/cloudygamer/comments/59245r/nvidia_driver_package_37563_unable_to_detect/

## Cloud sync My Documents

WIP - need to figure out how to allow sync that doesn't delete files if they're missing on the host.

Steam Cloud will do a decent job, but it's good to have coverage for games that don't cloud save, or if your instance terminates and Steam doesn't have a chance to perform the cloud sync.

## Steam client configuration

Back on your Mac, got to Steam Home-Streaming settings, and:

- Set the client options to 'Beautiful'
- Under Advanced Client Options:
    - Limit bandwidth to 30MBit/s; I've found that the automatic setting is far too conservative when remote streaming
    - Ensure that 'Enable hardware decoding' is enabled
    - Optionally limit the resolution

## Final steps

- Run `ec2gaming snapshot` to snapshot the EBS volume and create your AMI
- Run `ec2gaming terminate` to terminate the instance
- Create a `ec2gaming.auth` file in the `ec2gaming` location (it's `.gitignored`) with two lines, it'll be used to authenticate the VPN for gaming:

    ```
    administrator
    <new password>
    ```

# Gaming!

- Run `ec2gaming start`. The instance, VPN and Steam will automatically start
- Wait for the notification that the remote gaming host is available for home streaming
- Enjoy!
- When you're done, run `ec2gaming stop`

# Periodic maintenance

This configuration differs from the original blog post, in that the goal is to keep the AMI immutable from session to session (call it an instituional bias ;) ). You'll want to periodically update Steam, run Windows Update etc. and re-snapshot and replace your AMI using the `ec2gaming snapshot` command.

# Help

The original blog posts and the cloudygamer subreddit are great resources:

- http://lg.io/2015/07/05/revised-and-much-faster-run-your-own-highend-cloud-gaming-service-on-ec2.html
- https://www.reddit.com/r/cloudygamer/
