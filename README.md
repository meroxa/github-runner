# NOTE: This entire README needs to be updated - Docker Github Actions Runner

![Deploy - GitHub Actions Runner in Docker][build-badge]
[![Docker Pulls][docker-pulls]][docker-hub]

Originally found at [myoung34/docker-github-actions-runner][myoung34-github-runner] with ideas from [tcardonne/docker-github-runner][tcardonne-github-runner].

## Description

This will run the [new self-hosted github actions runners][self-hosted-runners]. It is built with [packer][packer] and 
builds Docker images and Amazon AMIs. The packer template is derived from the GitHub project and various pieces needed
to make the Docker or AWS images work.

* [Docker Hub][docker-hub]
* [AWS AMI][]

The original project by @myoung34 focuses on a minimal installation of tools. There the guiding principle is to create 
the most basic docker image necessary to run GitHub actions. The advantage to following that principle is that [developers 
can then declare and configure their tools as they see fit][github-runner-lite], and don't have to "fight" the runner to 
get things arranged properly.

The drawback to that model is that every workflow has to include the machinery they need to setup and run their build. 
The guiding principle of the GitHub hosted runners follows a different path, more of an "everything, including the 
kitchen sink" approach, where almost any tool and SDK have already been installed and are ready for use out-of-the-box. 
The majority of the installation scripts used by the GitHub Hosted runners are re-purposed here via a submodule pointing 
to GitHub's [actions/virtual-environments][virtual-environments].

In keeping with the [actions/virtual-environments][virtual-environments] setup, the runner's home directory is `/home/runner`.

_**Docker image size:**_
- _**Compressed: 19G+.**_
- _**Uncompressed: 50G+.**_

## Docker-in-Docker

This Docker image is designed to run Docker-in-Docker as a non-root user, and therefore expects to use a mount `/var/run/docker.sock` 
as that user. That can be an issue if the `docker` group in the container has a different GID than the group in the host. 
To get around that, the container detects the GID of the bind-mounted socket, and if that GID doesn't exist in the container, 
creates a `dockerhost` group and adds that group to the `runner` user.

Because of the nature of Linux user and group membership, and the fact that the `runner` user doesn't START with the `dockerhost`
group membership, you will see a message like this at startup: "`groups: cannot find name for group ID 969`," where `969` is the
GID of the `docker` group on the Docker host. The container will run just fine, with the correct permissions. However, if
you want to get rid of that message, run the container with the `--group-add=$(stat -c 'g%' /var/run/docker.sock)` command.

❗ **In order to run the container on a host that has SELinux installed and enabled, and the Docker daemon has been started 
without disabling it, you MUST start the container with `--security-opt=label=disable`.**

### A note about systemd in Docker

The GitHub-hosted runner is built to run on Azure, and as such is designed around a fully-functioning systemd init system, 
with DBus and UDEV available to help manage IPC and devices. Without these services, some basic functionality isn't available.
For instance, without UDEV, the snapd service has significant issues.

This isn't such a big deal in the AWS AMI image, but for Docker, it's much more challenging. The upstream [docker-systemd][docker-systemd]
is built and available on [Docker hub][docker-systemd-hub].

## Build args

The following build args allow you to control the configuration at build time.

| Name | Description | Default value |
|---|---|---|
| `BUILD_DATE` | The build date of the image. Used to set the `org.label-schema.build-date` image label | `$(date -u +'%Y-%m-%dT%H:%M:%SZ')` |
| `VCS_REF` | The git commit hash of the build. Used to set the `org.label-schema.vcs-ref` image label | `${GITHUB_SHA::8}` |
| `TARGETPLATFORM` | The target platform for the build. One of `linux/amd64`, `linux/arm/v7` or `linux/arm64` | `linux/amd64` |
| `UID` | The UID to use for the user | `1000` |
| `GID` | The GID to use for the user's group | `1000` |
| `USER` | The name of the user to run as | `runner` |
| `GROUP` | The name of runner user's group | `runner` |

## Environment variables

The following environment variables allow you to control the configuration parameters at runtime.

| Name | Description | Default value |
|---|---|---|
| `RUNNER_REPOSITORY_URL` | The runner will be linked to this repository URL | Required |
| `ACCESS_TOKEN` | Personal Access Token with `repo` access | Required if no `RUNNER_TOKEN` |
| `RUNNER_TOKEN` | Personal Access Token provided by GitHub specifically for running Actions | Required if no `ACCESS_TOKEN` |
| `RUNNER_WORK_DIRECTORY` | Runner's work directory | `/home/runner/work` |
| `RUNNER_NAME` | Name of the runner displayed in the GitHub UI | Hostname of the container | |
| `RUNNER_REPLACE_EXISTING` | `true` will replace existing runner with the same name, `false` will use a random name if there is conflict | `"true"` |

### GitHub Runner Environment

Example runtime environment:
```shell script
ACCESS_TOKEN=SOMEACCESSTOKENHERE
AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
ANDROID_HOME=/usr/local/lib/android/sdk
ANDROID_SDK_ROOT=/usr/local/lib/android/sdk
ANT_HOME=/usr/share/ant
AZURE_EXTENSION_DIR=/opt/az/azcliextensions
BASH=/bin/bash
BASHOPTS=cmdhist:complete_fullquote:extquote:force_fignore:hostcomplete:interactive_comments:progcomp:promptvars:sourcepath
BASH_ALIASES=()
BASH_ARGC=()
BASH_ARGV=()
BASH_CMDS=()
BASH_LINENO=([0]="0")
BASH_SOURCE=([0]="/home/runner/work/_temp/c81a8b82-bc01-4725-8443-1d03ae1e8308.sh")
BASH_VERSINFO=([0]="4" [1]="4" [2]="20" [3]="1" [4]="release" [5]="x86_64-pc-linux-gnu")
BASH_VERSION='4.4.20(1)-release'
BOOST_ROOT_1_69_0=/usr/local/share/boost/1.69.0
BOOST_ROOT_1_72_0=/usr/local/share/boost/1.72.0
CHROMEWEBDRIVER=/usr/local/share/chrome_driver
CHROME_BIN=/usr/bin/google-chrome
CI=true
CONDA=/usr/share/miniconda
DEBIAN_FRONTEND=noninteractive
DIRSTACK=()
DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
EUID=1000
GECKOWEBDRIVER=/usr/local/share/gecko_driver
GITHUB_ACTION=run1
GITHUB_ACTIONS=true
GITHUB_ACTOR=rbellamy
GITHUB_BASE_REF=
GITHUB_EVENT_NAME=repository_dispatch
GITHUB_EVENT_PATH=/home/runner/work/_temp/_github_workflow/event.json
GITHUB_HEAD_REF=
GITHUB_JOB=test-self-hosted
GITHUB_REF=refs/heads/master
GITHUB_REPOSITORY=terradatum/test-workflows
GITHUB_REPOSITORY_OWNER=terradatum
GITHUB_RUN_ID=87759165
GITHUB_RUN_NUMBER=4
GITHUB_SHA=74d8e792549145ab96cd707d9fb9ddf5bc2fc917
GITHUB_WORKFLOW=.github/workflows/test-self-hosted.yml
GITHUB_WORKSPACE=/home/runner/work/test-workflows/test-workflows
GRADLE_HOME=/usr/share/gradle
GROUPS=()
HHVM_DISABLE_NUMA=true
HOME=/home/runner
HOSTNAME=81b1ff544971
HOSTTYPE=x86_64
IFS=$' \t\n'
ImageOS=ubuntu18
ImageVersion=dev
JAVA_HOME=/usr/lib/jvm/adoptopenjdk-11-hotspot-amd64
JAVA_HOME_11=/usr/lib/jvm/adoptopenjdk-11-hotspot-amd64
JAVA_HOME_12=/usr/lib/jvm/adoptopenjdk-12-hotspot-amd64
JAVA_HOME_13=/usr/lib/jvm/adoptopenjdk-13-hotspot-amd64
JAVA_HOME_8=/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64
JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
LEIN_HOME=/usr/local/lib/lein
LEIN_JAR=/usr/local/lib/lein/self-installs/leiningen-2.9.3-standalone.jar
M2_HOME=/usr/share/apache-maven-3.6.3
MACHTYPE=x86_64-pc-linux-gnu
OPTERR=1
OPTIND=1
OSTYPE=linux-gnu
PATH=/usr/share/rust/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/runner/.dotnet/tools:/home/runner/.config/composer/vendor/bin
PPID=72
PS4='+ '
PWD=/home/runner/work/test-workflows/test-workflows
RUNNER_HOME=/home/runner
RUNNER_NAME=linux-test-workflows
RUNNER_OS=Linux
RUNNER_REPLACE_EXISTING=true
RUNNER_REPOSITORY_URL=https://github.com/terradatum/test-workflows
RUNNER_TEMP=/home/runner/work/_temp
RUNNER_TOKEN=SOMERUNNERTOKENHERE
RUNNER_TOOL_CACHE=/opt/hostedtoolcache
RUNNER_TRACKING_ID=github_8f2a9954-f948-49aa-995b-a287e72cddc9
RUNNER_WORKSPACE=/home/runner/work/test-workflows
RUNNER_WORK_DIRECTORY=/home/runner/work
SELENIUM_JAR_PATH=/usr/share/java/selenium-server-standalone.jar
SHELL=/bin/bash
SHELLOPTS=braceexpand:errexit:hashall:interactive-comments
SHLVL=2
SUPERVISOR_ENABLED=1
SUPERVISOR_GROUP_NAME=runner
SUPERVISOR_PROCESS_NAME=runner
TERM=dumb
UID=1000
VCPKG_INSTALLATION_ROOT=/usr/local/share/vcpkg
```

## Runner auto-update behavior

The GitHub runner (the binary) will update itself when receiving a job, if a new release is available. In order to allow
the runner to exit and restart by itself, the binary is started as a systemd service. This also takes care of zombie reaping 
since systemd is running as PID 1.

## Platforms

This has been tested and verified on:

 * x86_64

## Examples

Manual:

```shell script
docker run -d --restart always \
  --group-add=$(stat -c '%g' /var/run/docker.sock) \
  --security-opt=label=disable \
  --cap-add=SYS_ADMIN \
  --device=/dev/fuse \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -v github-runner:/home/runner \
  -e RUNNER_REPOSITORY_URL="https://github.com/terradatum/repo" \
  -e RUNNER_NAME="foo-runner" \
  -e RUNNER_TOKEN="footoken" \
  --name=github-runner \
  terradatum/github-runner:latest
```

Or as a shell function (as root):

*Note: the "lite" functions use the self-hosted runner from [myoung34/docker-github-actions-runner](https://github.com/myoung34/docker-github-actions-runner).

```shell script
function github-runner {
    org=$(dirname $1)
    repo=$(basename $1)
    name=github-runner-${repo}
    tag=${3:-bionic}
    docker rm -f $name
    docker run -d --restart=always \
        --group-add=$(stat -c '%g' /var/run/docker.sock) \
        --security-opt=label=disable \
        --cap-add=SYS_ADMIN \
        --device=/dev/fuse \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
        -v github-runner:/home/runner \
        -e RUNNER_REPOSITORY_URL="https://github.com/${org}/${repo}" \
        -e RUNNER_TOKEN="$2" \
        -e RUNNER_NAME="linux-${repo}" \
        --name=$name \
        ${org}/github-runner:${tag}
}

function github-runner-pat {
    org=$(dirname $1)
    repo=$(basename $1)
    name=github-runner-${repo}
    tag=${3:-bionic}
    docker rm -f $name
    docker run -d --restart=always \
        --group-add=$(stat -c '%g' /var/run/docker.sock) \
        --security-opt=label=disable \
        --cap-add=SYS_ADMIN \
        --device=/dev/fuse \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
        -v github-runner:/home/runner \
        -e ACCESS_TOKEN="$2" \
        -e RUNNER_REPOSITORY_URL="https://github.com/${org}/${repo}" \
        -e RUNNER_NAME="linux-${repo}" \
        --name=$name \
        ${org}/github-runner:${tag}
}

function github-runner-lite {
    org=$(dirname $1)
    repo=$(basename $1)
    name=github-runner-${repo}
    tag=${3:-bionic}
    docker rm -f $name
    docker run -d --restart=always \
        --security-opt=label=disable \
        -e REPO_URL="https://github.com/${org}/${repo}" \
        -e RUNNER_TOKEN="$2" \
        -e RUNNER_NAME="linux-${repo}" \
        -e RUNNER_WORKDIR="/tmp/github-runner-${repo}" \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /tmp/github-runner-${repo}:/tmp/github-runner-${repo} \
        --name=$name myoung34/github-runner:${tag}
}

function github-runner-lite-pat {
    org=$(dirname $1)
    repo=$(basename $1)
    name=github-runner-${repo}
    tag=${3:-bionic}
    docker rm -f $name
    docker run -d --restart=always \
        --security-opt=label=disable \
        -e ACCESS_TOKEN="$2" \
        -e REPO_URL="https://github.com/${org}/${repo}" \
        -e RUNNER_NAME="linux-${repo}" \
        -e RUNNER_WORKDIR="/tmp/github-runner-${repo}" \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /tmp/github-runner-${repo}:/tmp/github-runner-${repo} \
        --name=$name myoung34/github-runner:${tag}
}

function refresh-all {
    CONTAINERS=$(docker ps -a -q --filter "name=github-runner" --format="{{.Names}}")
    for c in ${CONTAINERS[@]:-}; do
        [[ "$c" == *"github"* ]] && docker stop "${c}"
        [[ "$c" == *"github"* ]] && docker rm "${c}"
    done
    docker rmi terradatum/github-runner:latest
    for c in ${CONTAINERS[@]}; do
        [[ "$c" == *"github"* ]] && github-runner-pat "${c/github-runner-/terradatum\/}" $1
    done
}

github-runner your-account/your-repo       AARGHTHISISYOURGHACTIONSTOKEN
github-runner your-account/some-other-repo ARGHANOTHERGITHUBACTIONSTOKEN ubuntu-xenial

# Or to refresh all the current runners
refresh-all AARGHTHISISYOURGITHUBPERSONALACCESSTOKEN
```

Nomad:

```hocon
job "github_runner" {
  datacenters = ["home"]
  type = "system"

  task "runner" {
    driver = "docker"

    env {
      RUNNER_REPOSITORY_URL = "https://github.com/your-account/your-repo"
      RUNNER_TOKEN   = "footoken"
    }

    config {
      privileged = false
      image = "terradatum/github-runner:latest"
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock",
        "github-runner:/home/runner",
      ]
    }
  }
}
```

Kubernetes:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: actions-runner
  namespace: runners
spec:
  replicas: 1
  selector:
    matchLabels:
      app: actions-runner
  template:
    metadata:
      labels:
        app: actions-runner
    spec:
      volumes:
      - name: dockersock
        hostPath:
          path: /var/run/docker.sock
      - name: runnerhome
        hostPath:
          path: /home/runner
      containers:
      - name: runner
        image: terradatum/github-runner:latest
        env:
        - name: RUNNER_TOKEN
          value: footoken
        - name: RUNNER_REPOSITORY_URL
          value: https://github.com/your-account/your-repo
        - name: RUNNER_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        volumeMounts:
        - name: dockersock
          mountPath: /var/run/docker.sock
        - name: runnerhome
          mountPath: /home/runner
```

## Usage From GH Actions Workflow

```yaml
name: Package

on:
  release:
    types: [created]

jobs:
  build:
    runs-on: self-hosted
    steps:
    - uses: actions/checkout@v1
    - name: build packages
      run: make all

```

## Automatically Acquiring a Runner Token 

A runner token can be automatically acquired at runtime if `ACCESS_TOKEN` (a GitHub personal access token) is a supplied. 
This uses the [GitHub Actions API](https://developer.github.com/v3/actions/self_hosted_runners/#create-a-registration-token). e.g.:

```shell script
docker run -d --restart always --name github-runner \
  --group-add $(stat -c '%g' /var/run/docker.sock) \
  -e ACCESS_TOKEN="footoken" \
  -e RUNNER_REPOSITORY_URL="https://github.com/terradatum/repo" \
  -e RUNNER_NAME="foo-runner" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v github-runner:/home/runner \
  terradatum/github-runner:latest
```

[build-badge]: https://github.com/terradatum/github-runner/workflows/GitHub%20Actions%20Runner%20in%20Docker%20-%20Latest/badge.svg
[docker-pulls]: https://img.shields.io/docker/pulls/terradatum/github-runner
[docker-hub]: https://hub.docker.com/r/terradatum/github-runner
[aws-ami]: 
[myoung34-github-runner]: https://github.com/myoung34/docker-github-actions-runner
[tcardonne-github-runner]: https://github.com/tcardonne/docker-github-runner
[self-hosted-runners]: https://help.github.com/en/actions/automating-your-workflow-with-github-actions/hosting-your-own-runners
[packer]: https://www.packer.io/docs/from-1.5
[github-runner-lite]: https://github.com/myoung34/docker-github-actions-runner/pull/6#issuecomment-584785114
[virtual-environments]: https://github.com/actions/virtual-environments
[docker-systemd]: https://github.com/terradatum/docker-systemd
[docker-systemd-hub]: https://hub.docker.com/r/terradatum/docker-systemd
[runner-labels]: https://github.com/actions/runner/blob/a5f06b3ec2c138a4a3a03b674e87fa262e1f766f/docs/adrs/0397-runner-registration-labels.md
