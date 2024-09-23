package main

import (
	"apollo416/pkg/engine"
	"context"

	"github.com/aws/aws-lambda-go/lambda"
)

var service = engine.NewService()

func handler(_ context.Context, decision *engine.Decision) (*engine.Decision, error) {
	err := service.Execute(decision)
	if err != nil {
		return nil, err
	}
	return decision, nil
}

func main() {
	lambda.Start(handler)
}
