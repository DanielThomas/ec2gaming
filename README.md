# macOS EC2 Gaming

Ready-made configuration for macOS EC2 gaming, based on [Larry Gadea's](http://lg.io/) excellent work.

# First-time configuration

The goal is to create a solid baseline that can be snapshotted to an AMI for future use, that requires zero intervention on startup and takes the minimum amount of time to install games.

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

## Steam configuration

- Steam will run and update automatically
- Login and save your password
- Go to Settings -> In-Home Streaming -> Advanced Host Options and enable 'Hardware Encoding' and 'Prioritize network traffic'
- Install and run several of the games you intend to play to `Z:\`. This performs first-time installation, avoiding the redistributable installation overhead. Delete local files once you're done

## Steam remote install to ephemeral storage

The Steam remote install feature assumes the default Stream library, even if a second library is available and set to default. So, to install games to the emphemeral storage on `Z:\` remotely, we create a junction on instance startup:

- Copy `bootstrap/steamapps-junction.bat` to `C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`

Unfortunately, you can't install games larger than the freespace on `C:` with this approach, but in that case you can use RDP, and this avoids having to RDP for every installation.

## Windows automatic login

Use Autologin to set the instance to automatically login: https://technet.microsoft.com/en-us/sysinternals/autologon.aspx

## Cloud sync My Documents

Use Dropbox, OneDrive or similar to sync My Documents. Steam Cloud will do a decent job, but it's good to have coverage for games that don't cloud save, or if your instance terminates and Steam doesn't have a chance to perform the cloud sync.

## Final steps

- Run `ec2gaming snapshot` to snapshot the EBS volume and create your AMI
- Run `ec2gaming terminate` to terminate the instance
- Create a `ec2gaming.auth` file in the `ec2gaming` location (it's `.gitignored`) with two lines, it'll be used to authenticate the VPN for gaming:

    ```
    administrator
    <new password>
    ```

- Put the repository on your `PATH` for convenience

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
