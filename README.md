# Requirements

- `Docker`: Write and build a simple docker container able to make calls to vault server and parses the following
values: AWS_KEY, AWS_PASS, SAT_ID, ENCR_KEY. Values are located in Vault KV secrete engine with path: local/esdata.
We should be able to run the container with arguments from shell and returned result to be requested
value. We should be able to get all values at once or values one by one.

- `GitLab CI/CD pipeline`: Use this container in the Gitlab CI pipeline with pipeline stages: Build docker image -> Push docker image to GitLab Docker Registry-> Get credentials values from Vault -> Passing credential values to another stage.

Note: Send credential to another stage in the same ci pipeline is done via GitLab artifacts. Explanation: The environment variables created during jobs are lost when the job finished, so I would recommend saving our variables to files that can be collected by the GitLab Runner via the artifacts .gitlab-ci.yml attribute. The artifacts from all jobs will then be available to the job(s) in our next stage(s).

## Prepare on-prem infrastructure 

## Install/setup/configure GitLab & HashiCorp Vault.

### Gitlab server install via ansible 

```
$ cd gitlab-ansible
$ ansible-playbook -i ./inventory.ini gitlab.yml
```

### gitlab-runner setup (docker-based)

```
# curl -LJO "https://gitlab-runner-downloads.s3.amazonaws.com/latest/deb/gitlab-runner_amd64.deb"
# dpkg -i gitlab-runner_amd64.deb
# cp gitlab-runner/config.toml /etc/gitlab-runner/config.toml 
# systemctl restart gitlab-runner  
```   

### Install/Setup Vault server & Unseal Vault & Create secrets.
```
### Install/Setup Vault server
# curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
# apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com focal main"
# apt-get update && apt-get install vault
# systemctl start vault
$ vault operator init
Unseal Key 1: b8P+huX0Vg8pEJeyJl+oeDPyhpy6QfhXsvMx6rPFHKaT
Unseal Key 2: fYAydRBmZIFO4V/QXe4YBZ6ow3L2MqK6tbB+SGBBA1Px
Unseal Key 3: QggzBeKmJJAU7vignPA9emKFppD7Sov8VWUc8g7kytr3
Unseal Key 4: SRTc/JCxVZ9M9jYwTOrAHhbM6ehHtpQ9WU8/rITfemXI
Unseal Key 5: B24sVrIpnaea2FJEB4NISisNtTYUYoi1S5MFJpmL5W0W

Initial Root Token: hvs.mSX4zcy6M7suKKnnSguIg5j6

### Unseal Vault
$ vault operator unseal
$ vault operator unseal
$ vault operator unseal
$ vault login

### Create secrets
$ vault secrets enable -path=local kv
Success! Enabled the kv secrets engine at: local/
$ vault write local/esdata AWS_KEY="AKIAIOSFODNN7EXAMPLE" AWS_PASS="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" SAT_ID="22" ENCR_KEY="qwerty123"
Success! Data written to: local/esdata
$ vault secrets list -detailed
```

## Manual create Docker image and test it 

```
### Build & Test docker container
$ docker build -t vault-get .
$ docker run --rm  --name=dev-vault vault-get -c "/get.sh AWS_KEY"
AKIAIOSFODNN7EXAMPLE
$ docker run --rm  --name=dev-vault vault-get -c "/get.sh AWS_PASS"
wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
$ docker run --rm  --name=dev-vault vault-get -c "/get.sh ENCR_KEY"
qwerty123d
$ docker run --rm  --name=dev-vault vault-get -c "/get.sh SAT_ID"
22
$ docker run --rm  --name=dev-vault vault-get -c "/get.sh ALL"
AKIAIOSFODNN7EXAMPLE
wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
qwerty123
22
```

## Create Gitlab project and push vault-demo-gitlab-repo folder to GitLab a new repo

### Setup Gitlab CI/CD pipeline variables and create [.gitlab-ci.yml](./vault-demo-gitlab-repo/.gitlab-ci.yml) file.

### Screenshots: 

GitLab repo:

<img src="./screenshots/gitlab-vault-demo-repo.png?raw=true" width="900">

GitLab CI/CD pipilene variables (VAULT_ADDR=https://192.168.1.99:8200 & VAULT_TOKEN=hvs.mSX4zcy6M7suKKnnSguIg5j6):

<img src="./screenshots/gitlab-vault-demo-pipeline-variables.png?raw=true" width="900">

GitLab CI/CD pipilene passed:

<img src="./screenshots/gitlab-vault-demo-pipeline.png?raw=true" width="900">

GitLab CI/CD pipeline stage: build docker image:

<img src="./screenshots/gitlab-vault-demo-pipeline-build.png?raw=true" width="900">

GitLab CI/CD pipeline stage: push docker image to GitLab registry:

<img src="./screenshots/gitlab-vault-demo-pipeline-push.png?raw=true" width="900">

GitLab CI/CD pipeline stage: get Vault secrets:

<img src="./screenshots/gitlab-vault-demo-pipeline-get-credentials.png?raw=true" width="900">

GitLab CI/CD pipeline stage: passing credential to another stage:

<img src="./screenshots/gitlab-vault-demo-pipeline-pass-credentials-to-ononter-stage.png?raw=true" width="900">









