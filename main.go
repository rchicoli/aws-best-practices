// main.go
package main

import (
	"crypto/tls"
	"database/sql"
	"errors"
	"fmt"
	"log"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/go-sql-driver/mysql"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

var (
	// ErrNameNotProvided is thrown when a name is not provided
	ErrNameNotProvided = errors.New("no name was provided in the HTTP body")
)

// Handler is your Lambda function handler
// It uses Amazon API Gateway request/responses provided by the aws-lambda-go/events package,
// However you could use other event sources (S3, Kinesis etc), or JSON-decoded primitive types such as 'string'.
func Handler(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {

	// stdout and stderr are sent to AWS CloudWatch Logs
	log.Printf("Processing Lambda request %s\n", request.RequestContext.RequestID)

	// If no name is provided in the HTTP request body, throw an error
	if len(request.Body) < 1 {
		return events.APIGatewayProxyResponse{StatusCode: 400}, ErrNameNotProvided
	}

	return events.APIGatewayProxyResponse{
		Body:       "Hello " + request.Body,
		StatusCode: 200,
	}, nil

}

func main() {

	dbEndpoint := "rcwebapper.c3nluwo4j4my.eu-test-1.rds.amazonaws.com:3306"
	// iamArn := "arn:aws:rds:eu-test-1:01234:db:rcwebapper"
	// awsRegion := "eu-central-1c"
	dbUser := "test1234"
	dbPass := "test1234"
	dbName := "rcwebapper"

	// awsCreds := credentials.NewStaticCredentials("", "", "")
	// awsCreds := stscreds.NewCredentials(session.New(&aws.Config{Region: &awsRegion}), iamArn)

	// creating authentication token for the database connection
	// authToken, err := rdsutils.BuildAuthToken(dbEndpoint, awsRegion, dbUser, awsCreds)
	// if err != nil {
	// 	log.Fatal("Unable to build Authentication Token") //todo remove
	// }

	//setting up TLS
	mysql.RegisterTLSConfig("custom", &tls.Config{
		InsecureSkipVerify: true,
	})

	// // Create the MySQL DNS string for the DB connection
	// // user:password@protocol(endpoint)/dbname?<params>
	dnsStr := fmt.Sprintf("%s:%s@tcp(%s)/%s?tls=false", dbUser, dbPass, dbEndpoint, dbName)
	// // log.Println("dns", dnsStr)

	// Use db to perform SQL operations on database
	db, err := sql.Open("mysql", dnsStr)
	if err != nil {
		log.Fatalf("could not connect to db: %v\n", err)
	}

	if err := db.Ping(); err != nil {
		log.Fatalf("could not ping database: %v", err)
	}

	// rows, err := db.Query(`create table Employee (id int NOT NULL AUTO_INCREMENT, Name varchar(255) NOT NULL, PRIMARY KEY (id))`)
	// if err != nil {
	// 	log.Fatalf("could not create table: %v\n", err)
	// }
	rows, err := db.Query(`insert into Employee (Name) values ("Test")`)
	if err != nil {
		log.Fatalf("could not create table: %v\n", err)
	}
	log.Println(rows)

	bucket := "rc-webapper-filestash"

	// Initialize a session in us-west-2 that the SDK will use to load
	// credentials from the shared credentials file ~/.aws/credentials.
	sess, err := session.NewSession(
		&aws.Config{
			Region: aws.String("eu-central-1"),
			// Credentials: awsCreds,
		},
	)
	if err != nil {
		log.Fatalf("wrong session: %v", err)
	}
	log.Printf("new session: %v\n", sess)

	// Create S3 service client
	svc := s3.New(sess)

	// Initial credentials loaded from SDK's default credential chain. Such as
	// the environment, shared credentials (~/.aws/credentials), or EC2 Instance
	// Role. These credentials will be used to to make the STS Assume Role API.
	// sess := session.Must(session.NewSession())

	// // Create the credentials from AssumeRoleProvider to assume the role
	// // referenced by the "myRoleARN" ARN.
	// creds := stscreds.NewCredentials(sess, "")

	// // Create service client value configured for credentials
	// // from assumed role.
	// svc := s3.New(sess, &aws.Config{Credentials: creds})

	log.Printf("new service: %v\n", svc)

	// Get the list of items
	resp, err := svc.ListObjects(&s3.ListObjectsInput{Bucket: aws.String(bucket)})
	if err != nil {
		log.Printf("Unable to list items in bucket %q, %v", bucket, err)
	}

	for _, item := range resp.Contents {
		fmt.Println("Name:         ", *item.Key)
		fmt.Println("Last modified:", *item.LastModified)
		fmt.Println("Size:         ", *item.Size)
		fmt.Println("Storage class:", *item.StorageClass)
		fmt.Println("")
	}

	fmt.Println("Found", len(resp.Contents), "items in bucket", bucket)

	// err = db.Ping()
	// if err != nil {
	// 	log.Fatalf("could not connect to db: %v\n", err)
	// }
	// log.Println("pinged")
	// fmt.Println("db status:", db.)

	lambda.Start(Handler)
}
