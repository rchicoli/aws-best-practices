provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.profile}"
}

# provider "aws" {
#   access_key = "${var.access_key}"
#   secret_key = "${var.secret_key}"
#   region     = "${var.region}"
# }

