package main

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"sort"
	"strconv"
	"time"
)

type SpotPriceHistory []*ec2.SpotPrice

func (spotPriceHistory SpotPriceHistory) Len() int {
	return len(spotPriceHistory)
}

func (spotPriceHistory SpotPriceHistory) Less(i, j int) bool {
	price1, err := strconv.ParseFloat(*spotPriceHistory[i].SpotPrice, 32)
	if err != nil {
		panic(err)
	}
	price2, err := strconv.ParseFloat(*spotPriceHistory[j].SpotPrice, 32)
	if err != nil {
		panic(err)
	}
	return price1 < price2
}

func (spotPriceHistory SpotPriceHistory) Swap(i, j int) {
	spotPriceHistory[i], spotPriceHistory[j] = spotPriceHistory[j], spotPriceHistory[i]
}

func SpotPrice() (string, error) {
	now := time.Now()
	then := time.Now().Add(time.Duration(-1) * time.Hour)
	instanceTypes := []*string{&InstanceType}
	productDescriptions := []*string{&ProductDescriptionWindows}
	session, err := session.NewSession()
	if err != nil {
		fmt.Println(err)
		return "", err
	}

	svc := ec2.New(session, &aws.Config{Region: aws.String(UsWest1)})

	result, err := svc.DescribeSpotPriceHistory(&ec2.DescribeSpotPriceHistoryInput{
		StartTime:           &then,
		EndTime:             &now,
		InstanceTypes:       instanceTypes,
		ProductDescriptions: productDescriptions,
	})
	if err != nil {
		fmt.Println(err)
		return "", err
	}
	sort.Sort(SpotPriceHistory(result.SpotPriceHistory))
	return *result.SpotPriceHistory[0].SpotPrice, nil
}
