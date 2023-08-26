---
title: Gitlab docs
weight: 100
menu:
  notes:
    name: gitlab-docs
    identifier: notes-gitlab-docs
    parent: notes-docs
    weight: 10
---

{{< note title="gitlab-ci.yml template Golang" >}}

```yaml
stages:
  - lint
  - test
  - build
  - deploy

variables:
  TEMPLATE_DOCKER_REGISTRY: "12345.dkr.ecr.ap-northeast-1.amazonaws.com"
  TEMPLATE_DOCKER_API_PORT: 3333
  TEMPLATE_ETCD_URL: template-stage.etcd.template.com:2379
  TEMPLATE_SERVICE_HOST: template-stage.service.template.com
  TEMPLATE_SERVICE_NAME: template_service
  TEMPLATE_SERVICE_NETWORK: template_network
  TEMPLATE_SERVICE_PORT: 1080
  TEMPLATE_IMAGE_VERSION: template_service-${CI_COMMIT_SHORT_SHA}

before_script:
  - mkdir -p ~/.ssh
  - chmod -R 400 ~/.ssh
  # Add ssh config to skip host verification
  - |
    cat <<EOF>~/.ssh/config
    Host *
      StrictHostKeyChecking no
    EOF
  # Initial and update submodule
  - git submodule update --init --remote

linter:
  stage: lint
  image:
    name: golangci/golangci-lint:latest
    pull_policy: if-not-present
  tags:
    - docker
  script:
    # Create config of golangci-lint
    # https://github.com/golangci/golangci-lint/blob/master/.golangci.reference.yml
    - |
      cat <<EOF>.golangci.yaml
      run:
        timeout: 5m

      linters-settings:
        cyclop:
          max-complexity: 30
          package-average: 10.0

        errcheck:
          check-type-assertions: true

        funlen:
          lines: 200
          statements: 100

        gocognit:
          min-complexity: 50

        gosec:
          excludes:
            - G204 # Subprocess launched with a potential tainted input or cmd arguments # Use os/exec
            - G401 # Use of weak cryptographic primitive # md5, sha1
            - G501 # Blocklisted import crypto/md5: weak cryptographic primitive
            - G505 # Import blocklist: crypto/sha1

        lll:
          line-length: 200

      linters:
        disable-all: true
        enable:
          - errcheck # Errcheck is a program for checking for unchecked errors in go programs. These unchecked errors can be critical bugs in some cases
          - gosimple # Linter for Go source code that specializes in simplifying a code
          - govet # Vet examines Go source code and reports suspicious constructs, such as Printf calls whose arguments do not align with the format string
          - ineffassign # Detects when assignments to existing variables are not used
          - staticcheck # Staticcheck is a go vet on steroids, applying a ton of static analysis checks
          - typecheck # Like the front-end of a Go compiler, parses and type-checks Go code
          - unused # Checks Go code for unused constants, variables, functions and types
          - asasalint # Check for pass []any as any in variadic func(...any)
          - asciicheck # Simple linter to check that your code does not contain non-ASCII identifiers
          - bidichk # Checks for dangerous unicode character sequences
          - bodyclose # checks whether HTTP response body is closed successfully
          - contextcheck # check the function whether use a non-inherited context
          - cyclop # checks function and package cyclomatic complexity
          - dupl # Tool for code clone detection
          - durationcheck # check for two durations multiplied together
          - errname # Checks that sentinel errors are prefixed with the Err and error types are suffixed with the Error.
          - errorlint # errorlint is a linter for that can be used to find code that will cause problems with the error wrapping scheme introduced in Go 1.13.
          - execinquery # execinquery is a linter about query string checker in Query function which reads your Go src files and warning it finds
          - exhaustive # check exhaustiveness of enum switch statements
          - exportloopref # checks for pointers to enclosing loop variables
          - funlen # Tool for detection of long functions
          - gocognit # Computes and checks the cognitive complexity of functions
          - goconst # Finds repeated strings that could be replaced by a constant
          - gocritic # Provides diagnostics that check for bugs, performance and style issues.
          - gocyclo # Computes and checks the cyclomatic complexity of functions
          - godot # Check if comments end in a period
          - goimports # In addition to fixing imports, goimports also formats your code in the same style as gofmt.
          - gomoddirectives # Manage the use of 'replace', 'retract', and 'excludes' directives in go.mod.
          - gomodguard # Allow and block list linter for direct Go module dependencies. This is different from depguard where there are different block types for example version constraints and module recommendations.
          - goprintffuncname # Checks that printf-like functions are named with f at the end
          - gosec # Inspects source code for security problems
          - lll # Reports long lines
          - makezero # Finds slice declarations with non-zero initial length
          - nakedret # Finds naked returns in functions greater than a specified function length
          - nestif # Reports deeply nested if statements
          - nilerr # Finds the code that returns nil even if it checks that the error is not nil.
          - nilnil # Checks that there is no simultaneous return of nil error and an invalid value.
          - noctx # noctx finds sending http request without context.Context
          - nolintlint # Reports ill-formed or insufficient nolint directives
          - nonamedreturns # Reports all named returns
          - nosprintfhostport # Checks for misuse of Sprintf to construct a host with port in a URL.
          - predeclared # find code that shadows one of Go's predeclared identifiers
          - promlinter # Check Prometheus metrics naming via promlint
          - revive # Fast, configurable, extensible, flexible, and beautiful linter for Go. Drop-in replacement of golint.
          - rowserrcheck # checks whether Err of rows is checked successfully
          - sqlclosecheck # Checks that sql.Rows and sql.Stmt are closed.
          - stylecheck # Stylecheck is a replacement for golint
          - tenv # tenv is analyzer that detects using os.Setenv instead of t.Setenv since Go1.17
          - testpackage # linter that makes you use a separate _test package
          - tparallel # tparallel detects inappropriate usage of t.Parallel() method in your Go test codes
          - unconvert # Remove unnecessary type conversions
          - unparam # Reports unused function parameters
          - wastedassign # wastedassign finds wasted assignment statements.
          - whitespace # Tool for detection of leading and trailing whitespace

      issues:
        max-same-issues: 50
      EOF
    - golangci-lint run ./...

tester:
  stage: test
  image:
    name: golang
    pull_policy: if-not-present
  tags:
    - docker
  script:
    - go test -timeout 300s ./...

builder:
  stage: build
  image:
    name: docker:dind
    pull_policy: if-not-present
  tags:
    - dind
  script:
    - docker build -t ${TEMPLATE_DOCKER_REGISTRY}/repository:$TEMPLATE_IMAGE_VERSION .
    # Fetch login password by aws-cli
    - pass="$(docker run --rm -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} amazon/aws-cli ecr get-login-password)"
    # Login to AWS ECR
    - docker login --username AWS --password "${pass}" ${TEMPLATE_DOCKER_REGISTRY}
    - docker push ${TEMPLATE_DOCKER_REGISTRY}/repository:$TEMPLATE_IMAGE_VERSION
  only:
    - main
    - web

deployer:
  stage: deploy
  image:
    name: docker:dind
    pull_policy: if-not-present
  tags:
    - dind
  script:
    - |
      case "${stage}" in
        dev)
          TEMPLATE_SERVICE_HOST=stage-dev.service.template.com
          DOCKER_HOST=${TEMPLATE_SERVICE_HOST}:${TEMPLATE_DOCKER_API_PORT}
          TEMPLATE_ETCD_URL=stage-dev.etcd.template.com:2379
          ;;
        qa)
          TEMPLATE_SERVICE_HOST=stage-qa.service.template.com
          DOCKER_HOST=${TEMPLATE_SERVICE_HOST}:${TEMPLATE_DOCKER_API_PORT}
          TEMPLATE_ETCD_URL=stage-qa.etcd.template.com:2379
          ;;
        *)
          echo 'Please specify ${stage}'
          exit 11
      esac
    - |
      if [[ "${port}" != "" ]];then
        TEMPLATE_SERVICE_PORT="${port}"
      fi
    # Replace variables in docker-compose.yml
    - |
      sed -i \
        -e "s/STAGE/${stage}/g" \
        -e "s/REGISTRY/${TEMPLATE_DOCKER_REGISTRY}/g" \
        -e "s/ETCD-URL/${TEMPLATE_ETCD_URL}/g" \
        -e "s/TEMPLATE_SERVICE_HOST/${TEMPLATE_SERVICE_HOST}/g" \
        -e "s/TEMPLATE_SERVICE_NAME/${TEMPLATE_SERVICE_NAME}/g" \
        -e "s/TEMPLATE_SERVICE_NETWORK/${TEMPLATE_SERVICE_NETWORK}/g" \
        -e "s/TEMPLATE_SERVICE_PORT/${TEMPLATE_SERVICE_PORT}/g" \
        -e "s/TEMPLATE_IMAGE_VERSION/${TEMPLATE_IMAGE_VERSION}/g" \
        docker-compose.yml
    - echo "Deploy to ${DOCKER_HOST}"
    - cat docker-compose.yml
    # Stop CI
    # - exit 0
    # Fetch login password by aws-cli
    - pass="$(docker run --rm -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} amazon/aws-cli ecr get-login-password)"
    # Login to AWS ECR
    - docker login --username AWS --password "${pass}" ${TEMPLATE_DOCKER_REGISTRY}
    - docker-compose down
    - docker-compose up -d --pull always
  only:
    - main
    - web
  when: manual
```

{{< /note >}}

{{< note title="gitlab-runner" >}}

```toml
check_interval = 0
concurrent = 3
shutdown_timeout = 0

[session_server]
session_timeout = 300

[[runners]]
executor = "docker"
id = 1
name = "runner-docker"
token = "RTalJ5ZWxSU2VrWmlXbv"
token_expires_at = 0001-01-01T00:00:00Z
token_obtained_at = 2023-01-31T11:20:18Z
url = "http://gitlab.com/"
[runners.docker]
allowed_pull_policies = ["always", "if-not-present"]
disable_cache = false
disable_entrypoint_overwrite = false
image = "golang"
oom_kill_disable = false
privileged = false
pull_policy = ["if-not-present"]
shm_size = 0
tls_verify = false
volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]

[[runners]]
executor = "docker"
id = 2
name = "runner-dind"
token = "RTalJ5ZWxSU2VrWmlXbv"
token_expires_at = 0001-01-01T00:00:00Z
token_obtained_at = 2023-01-31T11:21:01Z
url = "http://gitlab.com/"
[runners.cache]
MaxUploadedArchiveSize = 0
[runners.docker]
allowed_pull_policies = ["always", "if-not-present"]
disable_cache = false
disable_entrypoint_overwrite = false
image = "docker:dind"
oom_kill_disable = false
privileged = true
pull_policy = ["if-not-present"]
shm_size = 0
tls_verify = false
volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
```

{{< /note >}}
