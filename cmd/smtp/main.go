package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"net/http"
	"net/smtp"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	svc "github.com/aws/aws-sdk-go/service/lambda"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"

	"github.com/aws/aws-sdk-go-v2/aws/external"
)

var (

	// ErrNameNotProvided is thrown when a name is not provided
	ErrNameNotProvided = errors.New("no name was provided in the HTTP body")

	// ErrBadRequest ...
	ErrBadRequest = errors.New(http.StatusText(http.StatusBadRequest))
)

func main() {

	cfg, err := external.LoadDefaultAWSConfig()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(cfg.Region)

	// Initialize a session in us-west-2 that the SDK will use to load
	// credentials from the shared credentials file ~/.aws/credentials.
	sess, err := session.NewSession(&aws.Config{Region: aws.String("eu-west-1")})
	if err != nil {
		log.Fatalf("wrong session: %v", err)
	}

	lc := &LambdaService{svc.New(sess)}

	lambda.Start(lc.Handler)
}

type LambdaService struct {
	client *svc.Lambda
}

// Handler is your Lambda function handler
// It uses Amazon API Gateway request/responses provided by the aws-lambda-go/events package,
// However you could use other event sources (S3, Kinesis etc), or JSON-decoded primitive types such as 'string'.
func (lc *LambdaService) Handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

	// stdout and stderr are sent to AWS CloudWatch Logs
	log.Printf("Processing Lambda request %s\n", request.RequestContext.RequestID)

	// If no name is provided in the HTTP request body, throw an error
	if len(request.Body) < 1 {
		return response("", http.StatusBadRequest, ErrNameNotProvided)
	}

	client, err := smtp.Dial(fmt.Sprintf("mail.%s:25", request.Body))
	if err != nil {
		return response("", http.StatusInternalServerError, ErrNameNotProvided)
	}
	err = client.Hello(request.Body)

	if err != nil {
		return response("", http.StatusInternalServerError, ErrNameNotProvided)
	}

	return response("OK", http.StatusOK, nil)

}

func response(body string, statusCode int, err error) (events.APIGatewayProxyResponse, error) {
	return events.APIGatewayProxyResponse{
		Body:       body,
		StatusCode: statusCode,
	}, err
}
