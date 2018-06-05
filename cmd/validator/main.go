package main

import (
	"context"
	"encoding/json"
	"errors"
	"log"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"

	"github.com/rchicoli/aws-best-practices/api"
	"github.com/rchicoli/aws-best-practices/pkg/emailer"
)

var (

	// ErrNameNotProvided is thrown when a name is not provided
	ErrNameNotProvided = errors.New("no name was provided in the HTTP body")

	// ErrBadRequest ...
	ErrBadRequest = errors.New(http.StatusText(http.StatusBadRequest))
)

// Handler is your Lambda function handler
// It uses Amazon API Gateway request/responses provided by the aws-lambda-go/events package,
// However you could use other event sources (S3, Kinesis etc), or JSON-decoded primitive types such as 'string'.
func Handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

	// stdout and stderr are sent to AWS CloudWatch Logs
	log.Printf("Processing Lambda request %s\n", request.RequestContext.RequestID)

	// If no name is provided in the HTTP request body, throw an error
	if len(request.Body) < 1 {
		return response("", http.StatusBadRequest, ErrNameNotProvided)
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
	// fmt.Printf("email valid: %s\n", colphonetics.Code(email))

	return response("OK", http.StatusOK, nil)

}

func response(body string, statusCode int, err error) (events.APIGatewayProxyResponse, error) {
	return events.APIGatewayProxyResponse{
		Body:       body,
		StatusCode: statusCode,
	}, err
}

func main() { lambda.Start(Handler) }
