# ec2gaming - macOS EC2 Gaming

Scripts and first-time setup instructions to make macOS EC2 gaming simple and reliable, based on [Larry Gadea's](http://lg.io/) excellent work.

# Features

These scripts improve the ergonomics of gaming on EC2, and simplify the [first-time setup](#first-time-configuration) of your AMI. After following the first-time configuration below, the instance requires zero intervention on startup, allows Steam remote installs and minimizes the amount of time game install take.

On first `start` the scripts:

- Bootstrap an instance from the public ec2gaming AMI, including creating security groups
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

    Remote access commands
    rdp       Remote desktop connection (no VPN, requires login)
    vnc       VNC session (requires VPN, automatic login)

    EC2 commands
    instance  Get the instance id
    ip        Get the IP address of the instance
    price     Get the current lowest spot price
    reboot    Reboot the instance
    snapshot  Snapshot the instance and recreate AMI
    terminate Terminate the instance

    All supported commands
    instance
    ip
    price
    rdp
    reboot
    snapshot
    start
    stop
    terminate
    vnc
    vpndown
    vpnup

    For help, go to https://www.reddit.com/r/cloudygamer/

# Configuration

Use `ec2gaming.cfg` to configure options such as the bid price over the minimum price.

# First-time configuration

The goal is to take the base [ec2gaming AMI](http://lg.io/2015/07/05/revised-and-much-faster-run-your-own-highend-cloud-gaming-service-on-ec2.html) and create a reusable image. This configuration differs from the original blog post, in that the goal is to keep the AMI immutable from session to session (call it an [institituional bias](http://techblog.netflix.com/2016/03/how-we-build-code-at-netflix.html) ;)

These steps assume that you already have:

- Homebrew and Homebrew Cask (but feel free to install the required software any way you like)
- An Amazon AWS account, and have generated credentials from the AWS Console

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
- Create a `ec2gaming.auth` file in the `ec2gaming` location (it's `.gitignored`) with two lines, the `administrator` username and the password you plan to use to login to the instance. It's used for later configuration and needs to be available before you proceed to the next step:

    ```
    administrator
    <new password>
    ```

- Run `ec2gaming start` to bootstrap an instance

## EC2 Spot Instances

Keep in mind that everything runs on Spot instances, so your instance can be terminated at any time the price outpaces your bid, so:

- Consider running your first-time setup in the evening, where demand is low; or in a region with lower demand, and then copy the AMI using the AWS Console to your preferred gaming region
- Temporarily increasing the `SPOT_PRICE_BUFFER` setting to increase your bid over the current minimum spot bid
- Snapshot after each significant step

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

## Ephemeral storage

The `Z:\` is SSD instance storage, that's destroyed when the instance is stopped, but is the ideal place for installing games and data for your gaming session thanks to it's high performance.

The Steam remote install feature assumes the default Stream library, even if a second library is available and set to default. So, to install games to the emphemeral storage on `Z:\` remotely, we create a junction on instance startup. Unfortunately, you can't install games larger than the freespace on `C:` with this approach, but in that case you can use RDP/VNC to install the game.

Steam Cloud will also do a decent job of saving, but it's good to have coverage for games that don't cloud save, or if your instance terminates and Steam doesn't have a chance to perform the cloud sync. So, we also want to configure a periodic sync to S3 to save Documents from `Z:\Documents`.

- Install the 64-bit AWS CLI from https://aws.amazon.com/cli/
- Copy `ec2gaming.bat` to `C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`. This file creates the junction, performs an initial one-way S3 sync, and schedules a task that runs every minute to keep the directory in sync
- Right-click the Documents folder from the file explorer, and set the location to `Z:\Documents`

## Windows automatic login

Use Autologin to set the instance to automatically login, so Steam starts automatically and it's not necessary to RDP into the instance to start gaming:

https://technet.microsoft.com/en-us/sysinternals/autologon.aspx

## Install TightVNC

There are several advantages to using VNC over RDP:

- You don't need to use the logout shortcut to preserve the console session, you just close the VNC viewer
- It turns out to be really difficult persist the password for an RDP session to allow automatic login using an rdp file
- The NVIDIA control panel won't work via a RDP session, and it can be useful to have it available
- Some games (such as [Civilization 6](https://www.reddit.com/r/cloudygamer/comments/58uaic/resolution_locked_on_civ_6/)) can't change the resolution above 1024x768 by default, and you need to set the Windows resolution via VNC instead (detailed in the next step)

TightVNC appears best choice, both UltraVNC and Open RealVNC were super flaky, so:

- Install TightVNC from http://www.tightvnc.com/download.php
- Configure the password to match your administrator password. Note that it seems like setting the password during initial setup doesn't always work ("Server is not configured properly"), so you might need to go to the TightVNC tray icon, unset and reset the passwords to get a connection

## Configure Display Driver

The GRID K520 is a Virtual GPU which has support for a wide range of resolutions, but is notably missing a configuration for effective resolutions on retina displays (such as 1440x900 on a 15" MacBook Pro) which are usually the best resolutions for gaming on a Retina display to get the right UI scale, etc. The driver also identifies a large number of refresh rates supported, which makes selecting resolutions in games tedious, and it's not possible to use the NVIDIA Control Panel to add custom resolutions, I'm assuming because of the virtual nature of the display.

Thanks to [this great page](http://derrick.mameworld.info/docs/Tutorial/VideoModes/Custom_Video_Modes.html), I created `NV_Modes` settings for the most common 16:9 and 16:10 resolutions:

Driver 373.06 is the latest driver version that has the K520 included in the device list, later versions are missing `DEV_118A` completely:

- Download the driver from http://www.nvidia.com/download/driverResults.aspx/108323/en-us
- Run the installer
- Run regedit and under `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Video` locate the device with the `NV_Modes` setting (it'll in a `{guid}/0000` key)
- Edit the `NV_Modes` key and set it to:

```
{*}S 1024x640x16,32 1280x720x16,32 1280x800x16,32 1440x900x16,32 1680x1050x16,32 1920x1080x16,32 1920x1200x16,32 2880x1800x16,32=1;
```
- Restart Windows and attach a VNC session (`ec2gaming vnc`)
- Right-click the desktop, select Screen resolution and select the highest available resolution

## Image cleanup

Before creating an AMI, Amazon recommends deleting temporary files, defragmenting your hard drive, and zeroing out free space to reduce start times. This step is pretty time consuming and you can come back and do this at any time, so it's a good idea to wait until you're confident your image is in a good baseline state before you do this step. Reducing the size of your snapshot will also keep you in the free tier, and keeping free space high means you won't run into the remote install limitation mentioned above.

### Free Space

    - Follow the `Dism.exe` steps in this article to clean up the WinSxS to free space: https://technet.microsoft.com/en-us/library/dn251565.aspx
    - Use WinDirStat to look for other low hanging fruit, such as temporary files, installers, logs, etc.

### Defragment

- Optimize `C:\` with the defragmenter tool.

### Zero free space

- Run https://technet.microsoft.com/en-us/sysinternals/sdelete.aspx with the `-z` parameter

## Final steps

- Run `ec2gaming snapshot` to snapshot the EBS volume and create your AMI
- Run `ec2gaming terminate` to terminate the instance

## Steam client configuration

On your Mac, go to Steam Home-Streaming settings and:

- Set the client options to 'Beautiful'
- Under Advanced Client Options:
    - Limit bandwidth to 30MBit/s; I've found that the automatic setting is far too conservative when remote streaming
    - Ensure that 'Enable hardware decoding' is enabled
    - Optionally limit the resolution

# Gaming!

- Run `ec2gaming start`. The instance, VPN and Steam will automatically start
- Wait for the notification that the remote gaming host is available for home streaming
- Enjoy!
- When you're done, run `ec2gaming stop`

# Periodic maintenance

Because we treat the AMI as immutable, you'll want to periodically update Steam, run Windows Update etc. and re-snapshot and replace your AMI using the `ec2gaming snapshot` command.

# Help

The original blog posts and the cloudygamer subreddit are great resources:

- http://lg.io/2015/07/05/revised-and-much-faster-run-your-own-highend-cloud-gaming-service-on-ec2.html
- https://www.reddit.com/r/cloudygamer/
