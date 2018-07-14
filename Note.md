
```
cat terraform.tfstate | jq -r '.modules[0].resources."aws_db_instance.rcwebapper".primary.attributes.endpoint'
```

https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa

```
# Configure Terragrunt to use DynamoDB for locking
lock = {
  backend = "dynamodb"
  config {
    state_file_id = "(YOUR_APP_NAME)"
  }
}

# Configure Terragrunt to automatically store tfstate files in S3
remote_state = {
  backend = "s3"
  config {
    encrypt = "true"
    bucket = "(YOUR_BUCKET_NAME)"
    key = "terraform.tfstate"
    region = "(YOUR_BUCKET_REGION)"
  }
}
```