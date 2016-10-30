# ec2gaming - EC2 Gaming on macOS

Provides command line tools that makes gaming on EC2 simple and reliable. Includes steps to create an AMI that requires no intervention on startup, allows Steam remote installs and minimizes the amount of time game installs take.

Full documentation is available on the [wiki](https://github.com/DanielThomas/ec2gaming/wiki). Based on [Larry Gadea's](http://lg.io/) excellent work.

# Before you begin

Follow the [first time configuration](https://github.com/DanielThomas/ec2gaming/wiki/First-time-configuration) steps. They help you setup the tools, and streamline creation of your personalized AMI.

# Gaming!

- Run `ec2gaming start`. The instance, VPN and Steam will automatically start
- Wait for the notification that the remote gaming host is available for home streaming
- Enjoy!
- When you're done, run `ec2gaming stop`

# Help

The original blog posts and the cloudygamer subreddit are great resources:

- http://lg.io/2015/07/05/revised-and-much-faster-run-your-own-highend-cloud-gaming-service-on-ec2.html
- https://www.reddit.com/r/cloudygamer/
