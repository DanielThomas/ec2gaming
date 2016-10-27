# ec2gaming - macOS EC2 Gaming

Scripts and first-time setup instructions to make macOS EC2 gaming simple and reliable, based on [Larry Gadea's](http://lg.io/) excellent work.

# Features

These scripts improve the ergonomics of gaming on EC2, and simplify the [first-time setup](#first-time-configuration) of your AMI. After following the first-time configuration below, the instance requires zero intervention on startup, allows Steam remote installs and minimizes the amount of time game install take.

On first `start` the scripts:

- Bootstrap from the public ec2gaming AMI
- Creates security groups
- Launches RDP automatically

Once the first time setup is complete, `start` then:

- Brings up the gaming instance
- Connects the VPN
- Starts Steam

The `ec2gaming` launcher provides helpful commands to ease starting a gaming session, and maintain the instance:

    macOS EC2 Gaming with Steam In-Home Streaming

    usage: ec2gaming <command>

    Gaming commands
    start     Start gaming
    stop      Stop gaming

    Maintenance commands
    rdp       Remote desktop connection
    snapshot  Snapshot the instance and recreate AMI

    All supported commands
    instance-ip
    instance
    rdp
    snapshot
    start
    stop
    terminate
    vpndown
    vpnup

    For additional help, go to https://github.com/DanielThomas/ec2gaming#help

# First-time configuration

The goal is to take the base [ec2gaming AMI](http://lg.io/2015/07/05/revised-and-much-faster-run-your-own-highend-cloud-gaming-service-on-ec2.html) and create a reusable image. These steps assume that you already have an Amazon AWS account, and have generated credentials from the AWS Console.

From a terminal:

- Clone this repository to a convenient location and put it on the `PATH`
    - Even if you're not familiar with `git`, it's useful to be able to `pull` to update
    - I use `~/.ec2gaming` via my [dotfiles](https://github.com/DanielThomas/dotfiles)
- Install required components using Homebrew:

    ```
    brew install awscli jq
    brew cask install steam tunnelblick
    ```

- Install Microsoft Remote Desktop from the App Store
- Run `aws configure` to configure your AWS credentials and region
- Run `ec2gaming start` to bootstrap an instance

Keep in mind that everything runs on Spot instances, so your instance can be terminated at any time the price outpaces your bid, so:

- Consider running your first-time setup in the evening, where demand is low; or in a region with lower demand, and then copy the AMI using the AWS Console to your preferred gaming region
- Temporarily increasing the value in the `ec2gaming.spot` file to increase your bid over the current minimum spot bid

## Windows configuration

Once the instance is running, a RDP session will be opened automatically:

- Login using the `administrator` account with the password `rRmbgYum8g` and change the password
- Run Windows Update

Note that EBS is super-slow at startup as blocks come off the snapshot, so expect the instance to be sluggish as it warms up. It only affects file operations on `C:\` and won't affect gaming performance later.

## OpenVPN configuration

Edit `C:\Program Files\OpenVPN\config\server.ovpn` and add `cipher none` to the end of the file. We're using the VPN for the tunnel, not security, and we don't want the overhead of encryption.

## Steam configuration

- Steam will run and update automatically
- Login and save your password
- Go to Settings -> In-Home Streaming -> Advanced Host Options and enable 'Hardware Encoding' and 'Prioritize network traffic'
- Install and run several of the games you intend to play to `Z:\`. This performs first-time installation, avoiding the redistributable installation overhead. Delete local files once you're done
- Exit Steam from the system tray, otherwise Steam will forget your password when the instance next starts

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

This configuration differs from the original blog post, in that the goal is to keep the AMI immutable from session to session (call it an institituional bias ;) ). You'll want to periodically update Steam, run Windows Update etc. and re-snapshot and replace your AMI using the `ec2gaming snapshot` command.

# Help

The original blog posts and the cloudygamer subreddit are great resources:

- http://lg.io/2015/07/05/revised-and-much-faster-run-your-own-highend-cloud-gaming-service-on-ec2.html
- https://www.reddit.com/r/cloudygamer/
