package main

import (
	"context"
	"encoding/json"
	"errors"
	"log"
	"math/rand"
	"net/http"
	"strconv"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kinesis"
	lambdaSvc "github.com/aws/aws-sdk-go/service/lambda"

	"github.com/rchicoli/aws-best-practices/api"
	"github.com/rchicoli/aws-best-practices/pkg/emailer"
)

var (

	// ErrNameNotProvided is thrown when a name is not provided
	ErrNameNotProvided = errors.New("no name was provided in the HTTP body")

	// ErrBadRequest ...
	ErrBadRequest = errors.New(http.StatusText(http.StatusBadRequest))
)

func main() {

	// Initialize a session in us-west-2 that the SDK will use to load
	// credentials from the shared credentials file ~/.aws/credentials.
	sess, err := session.NewSession(&aws.Config{Region: aws.String("eu-west-1")})
	if err != nil {
		log.Fatalf("wrong session: %v", err)
	}

	svc := &AWSService{
		LambdaService: &LambdaService{
			client: lambdaSvc.New(sess),
		},
		KinesisService: &KinesisService{
			client:      kinesis.New(sess),
			requestPool: make([]*kinesis.PutRecordsRequestEntry, 100),
			streamName:  "rc-playground",
			shards:      10,
		},
	}

	lambda.Start(svc.Handler)
}

type KinesisService struct {
	client      *kinesis.Kinesis
	streamName  string
	shards      int
	requestPool []*kinesis.PutRecordsRequestEntry
}

type LambdaService struct {
	client *lambdaSvc.Lambda
}

type AWSService struct {
	LambdaService  *LambdaService
	KinesisService *KinesisService
}

// Handler is your Lambda function handler
// It uses Amazon API Gateway request/responses provided by the aws-lambda-go/events package,
// However you could use other event sources (S3, Kinesis etc), or JSON-decoded primitive types such as 'string'.
func (svc *AWSService) Handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

	// stdout and stderr are sent to AWS CloudWatch Logs
	log.Printf("Processing Lambda request %s\n", request.RequestContext.RequestID)

	// If no name is provided in the HTTP request body, throw an error
	if len(request.Body) < 1 {
		return response("", http.StatusBadRequest, ErrNameNotProvided)
	}

	rdn := strconv.Itoa(rand.Intn(svc.KinesisService.shards))

	_, err := svc.KinesisService.client.PutRecord(&kinesis.PutRecordInput{
		Data:         []byte(request.Body),
		StreamName:   aws.String(svc.KinesisService.streamName),
		PartitionKey: aws.String(rdn),
	})
	if err != nil {
		return response("could not put records into kinesis stream", http.StatusInternalServerError, err)
	}

	payload := api.EmailerRequestBody{}
	body := json.RawMessage(request.Body)
	if err := json.Unmarshal(body, &payload); err != nil {
		return response("", http.StatusBadRequest, err)
	}
	if payload.Email == "" {
		return response("", http.StatusBadRequest, ErrBadRequest)
	}
	if err := emailer.Validate(payload.Email); err != nil {
		return response("error validating email", http.StatusBadRequest, err)
	}

	result, err := svc.LambdaService.client.Invoke(&lambdaSvc.InvokeInput{
		FunctionName: aws.String("SMTPHello"),
		Payload:      []byte(payload.Email),
	})
	if err != nil {
		return response("could not invoke lambda function", http.StatusInternalServerError, err)
	}

	return response(string(result.Payload), http.StatusOK, nil)

}

func response(body string, statusCode int, err error) (events.APIGatewayProxyResponse, error) {
	return events.APIGatewayProxyResponse{
		Body:       body,
		StatusCode: statusCode,
	}, err
}
