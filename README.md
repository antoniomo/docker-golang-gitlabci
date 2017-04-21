# Golang for GitlabCI workers

Based on the official [golang-alpine
image](https://github.com/docker-library/golang/tree/master/1.8/alpine).

Adds common tools used for Gitlab CI, with optional arguments so you just
bake-in what you need.

## Sample .gitlab-ci.yml

Assumes that your project uses `make` for linting/testing/building, building
only proceeds if tests pass (but
[gometalinter](https://github.com/alecthomas/gometalinter) warnings are ignored,
they are just informative), manages dependencies with
[glide](https://github.com/Masterminds/glide), and some of the dependencies used
are also on this self-hosted Gitlab.

```
image: antoniomo:docker-golang1.8.1-gitlabci

variables:
  REPO_BASE: gitlab.XYZ.com

stages:
  - linttest
  - build

before_script:
  # SSH stuff to clone our own repositories
  # https://gitlab.com/help/ci/ssh_keys/README.md
  - eval $(ssh-agent -s)
  - echo "${SSH_PRIVATE_KEY}" | ssh-add -
  - mkdir -p ~/.ssh
  - '[[ -f /.dockerenv ]] && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config'
  # End SSH stuff
  #
  # Pulling project dependencies
  - mkdir -p $GOPATH/src/$REPO_BASE/$CI_PROJECT_PATH
  - cp -r $CI_PROJECT_DIR/* $GOPATH/src/$REPO_BASE/$CI_PROJECT_PATH
  - cd $GOPATH/src/$REPO_BASE/$CI_PROJECT_PATH
  - git config --global url."git@$REPO_BASE:".insteadOf "https://$REPO_BASE/"
  - glide install
  # End project dependencies

lint:
  stage: linttest
  script:
    - make lintci
  allow_failure: true

test:
  stage: linttest
  script:
    - make test
  coverage: /(\d+.\d+\%) of statements/

build:
  stage: build
  script:
    - make build
```
