package main

import (
	"bytes"
	"flag"
	"io/ioutil"
	"log"
	"net/http"
	"time"

	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/signer/v4"
)

func main() {

	url := flag.String("url", "", "API endpoint")
	payload := flag.String("payload", ``, "JSON request body")
	apiKey := flag.String("x-api-key", "", "API key")
	region := flag.String("region", "", "AWS region")

	p := bytes.NewReader([]byte(*payload))

	req, err := http.NewRequest("POST", *url, p)
	if err != nil {
		log.Fatal(err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("x-api-key", *apiKey)
	req.Header.Add("Cache-Control", "no-cache")

	cred := credentials.NewEnvCredentials()
	signer := v4.NewSigner(cred)

	if _, err := signer.Sign(req, p, "execute-api", *region, time.Now()); err != nil {
		log.Fatalf("failed to sign a HTTP request: %v", err)
	}

	client := new(http.Client)
	resp, err := client.Do(req)
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatal(err)
	}
	log.Println(string(body))

}
