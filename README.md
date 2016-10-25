# macOS EC2 Gaming

Quick-start configuration for macOS EC2 gaming, based on Larry Gadea's excellent work here:

http://lg.io/2015/07/05/revised-and-much-faster-run-your-own-highend-cloud-gaming-service-on-ec2.html

# First-time configuration

The goal is to create a solid baseline that can be snapshotted to an AMI for future use, that requires zero intervention on startup and takes the minimum amount of time to install games.

From a terminal:

- Install required components:

    ```
    brew install awscli jq
    brew cask install steam tunnelblick
    ```

- Install Microsoft Remote Desktop from the App Store
- From the terminal, run `aws configure` to configure your AWS credentials and region
- Clone this repository to a convenient location (I use `~/.ec2gaming` and put it on the `PATH`)
- Run `./ec2gaming start`

## Windows configuration

Once the instance is running, a RDP session will be opened automatically. Login using the `administrator` account with the password `rRmbgYum8g` and change the password.

- Update Steam and login
- Install several of the games you intend to play to install the redists
    - EBS is super-slow to start due to initialization overhead, so you want to avoid this overhead later
    - Make sure you install to `Z:`
- Run Windows Update

## Windows automatic login

Use Autologin to set the instance to automatically login: https://technet.microsoft.com/en-us/sysinternals/autologon.aspx

## Steam remote install

The Steam remote install feature assumes the default Stream library, even if a second library is available and set to default. So, to install games to the emphemeral storage on `Z:\` remotely, we create a junction on instance startup:

- Copy `bootstrap/steamapps-junction.bat` to `C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`

Unfortunately, you can't install games larger than the freespace on `C:` with this approach, but in that case you can use RDP, and this avoids having to RDP for every installation.

## Final steps

- Run `./ec2gaming snapshot` to snapshot the EBS volume, create a new AMI and shutdown the instance
- Create a `ec2gaming.auth` file in the `ec2gaming` location (it's `.gitignored`) with two lines, it'll be used to authenticate the VPN for gaming:

    ```
    administrator
    <new password>
    ```

- Put the repository on your `PATH` for convenience

# Gaming!

- Run `ec2gaming start`. The instance, VPN and Steam will automatically start
- Wait for the notification that the remote gaming host is available for home streaming
- When you're done, run `ec2gaming terminate`

# Resources

- The cloudygamer subreddit is a great resource - https://www.reddit.com/r/cloudygamer/
