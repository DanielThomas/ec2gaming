package main

import (
	"os"
	"fmt"
	"github.com/urfave/cli"
)

func main() {
	app := cli.NewApp()
	app.Name = "ec2gaming"
	app.Usage = "macOS EC2 Gaming with Steam In-Home Streaming"
	app.Commands = []cli.Command{
		{
			Name: "start",
			Usage: "starts instance, VPN and Steam",
			Action: func(*cli.Context) error {
				fmt.Println("start")
				return nil

			},
		},
		{
			Name: "stop",
			Usage: "stops instance & vpn",
			Action: func(*cli.Context) error {
				fmt.Println("stop")
				return nil

			},
		},
	}

	app.Run(os.Args)

}
