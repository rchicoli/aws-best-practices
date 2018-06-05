
BASE_DIR		?= .
CMD_PATH		?= $(BASE_DIR)/cmd
TERRAFORM_PATH 	?= $(BASE_DIR)/terraform
HELLO_PATH		?= $(CMD_PATH)/cmd/hello
PROCESSOR_PATH 	?= $(CMD_PATH)/cmd/processor

.PHONY: all

all: clean build zip

clean:
	find $(CMD_PATH) -mindepth 2 -maxdepth 2 -type f -regextype posix-extended -regex ".+\/main(.zip)?" -exec rm -v '{}' +

build:
	find $(CMD_PATH) -mindepth 1 -maxdepth 1 -not -path "$(CMD_PATH)/validator" |\
		xargs -n1 --max-procs `nproc` -I '{}' go build -a -installsuffix cgo -o '{}'/main '{}'

zip:
	find $(CMD_PATH) -mindepth 2 -maxdepth 2 -type f -name "main" | xargs -n1 --max-procs `nproc` -I '{}' zip --junk-paths '{}'.zip '{}'

create_environment:
	cd $(TERRAFORM_PATH) && terraform apply -auto-approve; cd -

update: create_environment

delete_environment:
	cd $(TERRAFORM_PATH) && terraform destroy; cd -