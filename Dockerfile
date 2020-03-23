FROM ubuntu:latest as stage1

LABEL maintainer="G. Richard Bellamy <rbellamy@terradatum.com>" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="terradatum/base-github-runner" \
  org.label-schema.description="Base Dockerized GitHub Actions runner." \
  org.label-schema.url="https://github.com/terradatum/github-runner" \
  org.label-schema.vcs-url="https://github.com/terradatum/github-runner" \
  org.label-schema.vendor="Terradatum" \
  org.label-schema.docker.cmd="docker run -it terradatum/base-github-runner:latest /bin/bash"

ARG DEBIAN_FRONTEND=noninteractive
ARG IMAGE_FOLDER=/imagegeneration
ARG http_proxy
ARG https_proxy
ENV http_proxy=${http_proxy:-$http_proxy}
ENV https_proxy=${https_proxy:-$https_proxy}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN mkdir ${IMAGE_FOLDER} \
  && chmod 777 ${IMAGE_FOLDER} \
  && apt-get update \
  && apt-get dist-upgrade -y \
  && echo '* soft nofile 65536 \n* hard nofile 65536' >> /etc/security/limits.conf \
  && echo 'session required pam_limits.so' >> /etc/pam.d/common-session \
  && echo 'session required pam_limits.so' >> /etc/pam.d/common-session-noninteractive \
  && echo 'DefaultLimitNOFILE=65536' >> /etc/systemd/system.conf

FROM stage1 as stage2

ARG DEBIAN_FRONTEND=noninteractive
ARG IMAGE_FOLDER=/imagegeneration
ARG IMAGEDATA_FILE=/imagegeneration/imagedata.json
ARG METADATA_FILE=/imagegeneration/metadatafile
ARG BASE_SCRIPTS_FOLDER=/imagegeneration/base
ARG INSTALLER_SCRIPT_FOLDER=/imagegeneration/installers
ARG HELPER_SCRIPTS=/imagegeneration/helpers
ARG IMAGE_VERSION=dev
ARG IMAGE_OS=ubuntu18
ARG LSB_RELEASE_DIR

WORKDIR /tmp

COPY base "${BASE_SCRIPTS_FOLDER}"
COPY virtual-environments/images/linux/scripts/helpers "${HELPER_SCRIPTS}"

COPY installers/essential.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/${LSB_RELEASE_DIR}/preparemetadata.sh "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}/"
COPY virtual-environments/images/linux/scripts/installers/preimagedata.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/configure-environment.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/${LSB_RELEASE_DIR}/basic.sh "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}/"
COPY virtual-environments/images/linux/scripts/installers/7-zip.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/ansible.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/azure-cli.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/azure-devops-cli.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/aws.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/build-essential.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/git.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/cmake.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/clang.sh "${INSTALLER_SCRIPT_FOLDER}/"

RUN chmod -R 777 "${BASE_SCRIPTS_FOLDER}"/*.sh \
  && chmod -R 777 "${HELPER_SCRIPTS}"/*.sh \
  && chmod -R 777 "${INSTALLER_SCRIPT_FOLDER}"/*.sh \
  && chmod -R 777 "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}"/*.sh \
  && "${INSTALLER_SCRIPT_FOLDER}/essential.sh" \
  && find "${IMAGE_FOLDER}" -type f -exec dos2unix "{}" \;

RUN "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}/preparemetadata.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/preimagedata.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/configure-environment.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}/basic.sh"
RUN "${BASE_SCRIPTS_FOLDER}/repos.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/7-zip.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/ansible.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/azure-cli.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/azure-devops-cli.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/aws.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/build-essential.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/cmake.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/git.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/clang.sh"

FROM stage2 as stage3

ARG DEBIAN_FRONTEND=noninteractive
ARG IMAGE_FOLDER=/imagegeneration
ARG METADATA_FILE=/imagegeneration/metadatafile
ARG BASE_SCRIPTS_FOLDER=/imagegeneration/base
ARG INSTALLER_SCRIPT_FOLDER=/imagegeneration/installers
ARG HELPER_SCRIPTS=/imagegeneration/helpers
ARG LSB_RELEASE_DIR

COPY virtual-environments/images/linux/scripts/installers/docker-compose.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/docker-ce.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/dotnetcore-sdk.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/erlang.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/firefox.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/gcc.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/gfortran.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/go.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/azcopy.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/google-chrome.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/google-cloud-sdk.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/haskell.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/heroku.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/hhvm.sh "${INSTALLER_SCRIPT_FOLDER}/"

RUN chmod -R 777 "${BASE_SCRIPTS_FOLDER}"/*.sh \
  && chmod -R 777 "${HELPER_SCRIPTS}"/*.sh \
  && chmod -R 777 "${INSTALLER_SCRIPT_FOLDER}"/*.sh \
  && chmod -R 777 "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}"/*.sh \
  && find "${IMAGE_FOLDER}" -type f -exec dos2unix "{}" \;

RUN "${INSTALLER_SCRIPT_FOLDER}/docker-compose.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/docker-ce.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/dotnetcore-sdk.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/erlang.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/firefox.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/gcc.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/gfortran.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/go.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/azcopy.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/google-chrome.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/google-cloud-sdk.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/haskell.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/heroku.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/hhvm.sh"

FROM stage3 as stage4

ARG DEBIAN_FRONTEND=noninteractive
ARG IMAGE_FOLDER=/imagegeneration
ARG METADATA_FILE=/imagegeneration/metadatafile
ARG BASE_SCRIPTS_FOLDER=/imagegeneration/base
ARG INSTALLER_SCRIPT_FOLDER=/imagegeneration/installers
ARG HELPER_SCRIPTS=/imagegeneration/helpers
ARG LSB_RELEASE_DIR

COPY virtual-environments/images/linux/scripts/installers/image-magick.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/java-tools.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/kind.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/${LSB_RELEASE_DIR}/kubernetes-tools.sh "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}/"
COPY virtual-environments/images/linux/scripts/installers/leiningen.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/${LSB_RELEASE_DIR}/mercurial.sh "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}/"
COPY virtual-environments/images/linux/scripts/installers/miniconda.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/mono.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/mysql.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/nodejs.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/bazel.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/phantomjs.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/${LSB_RELEASE_DIR}/php.sh "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}/"

RUN chmod -R 777 "${BASE_SCRIPTS_FOLDER}"/*.sh \
  && chmod -R 777 "${HELPER_SCRIPTS}"/*.sh \
  && chmod -R 777 "${INSTALLER_SCRIPT_FOLDER}"/*.sh \
  && chmod -R 777 "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}"/*.sh \
  && find "${IMAGE_FOLDER}" -type f -exec dos2unix "{}" \;

RUN "${INSTALLER_SCRIPT_FOLDER}/image-magick.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/java-tools.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/kind.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}/kubernetes-tools.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/leiningen.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}/mercurial.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/miniconda.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/mono.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/mysql.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/nodejs.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/bazel.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/phantomjs.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}/php.sh"

FROM stage4 as stage5

ARG DEBIAN_FRONTEND=noninteractive
ARG IMAGE_FOLDER=/imagegeneration
ARG METADATA_FILE=/imagegeneration/metadatafile
ARG BASE_SCRIPTS_FOLDER=/imagegeneration/base
ARG INSTALLER_SCRIPT_FOLDER=/imagegeneration/installers
ARG HELPER_SCRIPTS=/imagegeneration/helpers
ARG LSB_RELEASE_DIR

COPY virtual-environments/images/linux/scripts/installers/pollinate.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/postgresql.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/powershellcore.sh ${INSTALLER_SCRIPT_FOLDER}
COPY virtual-environments/images/linux/scripts/installers/ruby.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/rust.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/julia.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/sbt.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/selenium.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/sphinx.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/subversion.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/terraform.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/packer.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/vcpkg.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/zeit-now.sh "${INSTALLER_SCRIPT_FOLDER}/"

RUN chmod -R 777 "${BASE_SCRIPTS_FOLDER}"/*.sh \
  && chmod -R 777 "${HELPER_SCRIPTS}"/*.sh \
  && chmod -R 777 "${INSTALLER_SCRIPT_FOLDER}"/*.sh \
  && chmod -R 777 "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}"/*.sh \
  && find "${IMAGE_FOLDER}" -type f -exec dos2unix "{}" \;

RUN "${INSTALLER_SCRIPT_FOLDER}/pollinate.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/postgresql.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/powershellcore.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/ruby.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/rust.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/julia.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/sbt.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/selenium.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/sphinx.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/subversion.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/terraform.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/packer.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/vcpkg.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/zeit-now.sh"

FROM stage5 as stage6

ARG DEBIAN_FRONTEND=noninteractive
ARG IMAGE_FOLDER=/imagegeneration
ARG METADATA_FILE=/imagegeneration/metadatafile
ARG BASE_SCRIPTS_FOLDER=/imagegeneration/base
ARG INSTALLER_SCRIPT_FOLDER=/imagegeneration/installers
ARG HELPER_SCRIPTS=/imagegeneration/helpers
ARG LSB_RELEASE_DIR
ARG GITHUB_FEED_TOKEN

COPY virtual-environments/images/linux/toolcache-${LSB_RELEASE_DIR}.json "${INSTALLER_SCRIPT_FOLDER}/toolcache.json"

COPY virtual-environments/images/linux/scripts/installers/updatepath.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/dpkg-config.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/${LSB_RELEASE_DIR}/android.sh "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}/"
COPY installers/azpowershell.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY installers/awspowershell.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/hosted-tool-cache.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/python.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/test-toolcache.sh "${INSTALLER_SCRIPT_FOLDER}/"
COPY virtual-environments/images/linux/scripts/installers/boost.sh "${INSTALLER_SCRIPT_FOLDER}/"

RUN chmod -R 777 "${BASE_SCRIPTS_FOLDER}"/*.sh \
  && chmod -R 777 "${HELPER_SCRIPTS}"/*.sh \
  && chmod -R 777 "${INSTALLER_SCRIPT_FOLDER}"/*.sh \
  && chmod -R 777 "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}"/*.sh \
  && find "${IMAGE_FOLDER}" -type f -exec dos2unix "{}" \;

RUN "${INSTALLER_SCRIPT_FOLDER}/updatepath.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/dpkg-config.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/${LSB_RELEASE_DIR}/android.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/azpowershell.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/awspowershell.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/hosted-tool-cache.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/python.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/test-toolcache.sh"
RUN "${INSTALLER_SCRIPT_FOLDER}/boost.sh"

RUN apt-get autoremove -y \
  && apt-get clean -y \
  && rm -fr "${HELPER_SCRIPTS}}" \
  && rm -fr "${INSTALLER_SCRIPT_FOLDER}" \
  && chmod 755 "${IMAGE_FOLDER}"

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF