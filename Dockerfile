FROM codercom/code-server

# Misc
RUN sudo apt-get update && sudo apt-get install --no-install-recommends -y \
    jq \
    unzip \
    bsdtar \
    && sudo rm -rf /var/lib/apt/lists/*

# AdoptOpenJDK
RUN wget -q -O OpenJDK.tar.gz https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.6%2B10/OpenJDK11U-jdk_x64_linux_hotspot_11.0.6_10.tar.gz && \
    tar xzf OpenJDK.tar.gz && \
    sudo mv jdk-* /opt/ && \
    rm -f OpenJDK.tar.gz && \
    echo "export JAVA_HOME=$(dirname /opt/jdk-*/bin/)" | sudo tee -a /home/coder/.bashrc > /dev/null && \
    echo 'export PATH=${PATH}:${JAVA_HOME}/bin' | sudo tee -a /home/coder/.bashrc > /dev/null

# Maven
ENV MAVEN_VERSION=3.6.3
RUN wget -q -O maven.tar.gz http://ftp.riken.jp/net/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar xzf maven.tar.gz && \
    sudo mv apache-maven-* /opt/ && \
    rm -f maven.tar.gz && \
    echo "export MAVEN_HOME=/opt/apache-maven-${MAVEN_VERSION}" | sudo tee -a /home/coder/.bashrc > /dev/null && \
    echo 'export PATH=${PATH}:${MAVEN_HOME}/bin' | sudo tee -a /home/coder/.bashrc > /dev/null

# Visual Studio Code Extentions
ENV VSCODE_USER /home/coder/.local/share/code-server/User
ENV VSCODE_EXTENSIONS /home/coder/.local/share/code-server/extensions

RUN mkdir -p ${VSCODE_EXTENSIONS}/java \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/redhat/vsextensions/java/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/java extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/java-debugger \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/vscjava/vsextensions/vscode-java-debug/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/java-debugger extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/java-test \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/vscjava/vsextensions/vscode-java-test/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/java-test extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/maven \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/vscjava/vsextensions/vscode-maven/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/maven extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/spring-boot \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/pivotal/vsextensions/vscode-spring-boot/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/spring-boot extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/spring-initializr \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/vscjava/vsextensions/vscode-spring-initializr/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/spring-initializr extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/spring-boot-dashboard \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/vscjava/vsextensions/vscode-spring-boot-dashboard/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/spring-boot-dashboard extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/manifest-yaml \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/pivotal/vsextensions/vscode-manifest-yaml/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/manifest-yaml extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/concourse \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/pivotal/vsextensions/vscode-concourse/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/concourse extension

RUN mkdir -p ${VSCODE_EXTENSIONS}/yaml \
    && curl -JLs https://marketplace.visualstudio.com/_apis/public/gallery/publishers/redhat/vsextensions/vscode-yaml/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/yaml extension

# CF CLI
ENV CF_CLI_VERSION 6.49.0
RUN wget -q -O cf.tgz "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=${CF_CLI_VERSION}&source=github-rel" && \
    tar xzf cf.tgz && \
    sudo install cf /usr/local/bin/ && \
    rm -f cf* LICENSE NOTICE

ENV CF7_CLI_VERSION 7.0.0-beta.29
RUN wget -q -O cf.tgz "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=${CF7_CLI_VERSION}&source=github-rel" && \
    tar xzf cf.tgz && \
    sudo install cf7 /usr/local/bin/ && \
    rm -f cf* LICENSE NOTICE

# BOSH
ENV BOSH_VERSION 6.2.1
RUN wget -q -O bosh https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_VERSION}/bosh-cli-${BOSH_VERSION}-linux-amd64 && \
    sudo install bosh /usr/local/bin/ && \
    rm -f bosh*

# OM
ENV OM_VERSION 4.4.2
RUN wget -q -O om https://github.com/pivotal-cf/om/releases/download/${OM_VERSION}/om-linux-${OM_VERSION} && \
    sudo install om /usr/local/bin/ && \
    rm -f om*

# Kubectl
ENV KUBECTL_VERSION 1.15.9
RUN wget -q -O kubectl "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    sudo install kubectl /usr/local/bin/

# Terraform
ENV TERRAFORM_VERSION 0.11.14
RUN wget -q -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform.zip && \
    sudo install terraform /usr/local/bin/ && \
    rm -f terraform*

# Fly
ENV FLY_VERSION 5.5.7
RUN wget -q -O fly.tgz https://github.com/concourse/concourse/releases/download/v${FLY_VERSION}/fly-${FLY_VERSION}-linux-amd64.tgz && \
    tar xzf fly.tgz && \
    sudo install fly /usr/local/bin/ && \
    rm -f fly*

# CredHub
ENV CREDHUB_VERSION 2.6.2
RUN wget -q -O credhub.tgz https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_VERSION}/credhub-linux-${CREDHUB_VERSION}.tgz && \
    tar xzf credhub.tgz && \
    sudo install credhub /usr/local/bin/ && \
    rm -f credhub*

# yj
RUN wget -q -O yj https://github.com/sclevine/yj/releases/download/v4.0.0/yj-linux && \
    sudo install yj /usr/local/bin/ && \
    rm -f yj*

# ytt
ENV YTT_VERSION 0.25.0
RUN wget -q -O ytt https://github.com/k14s/ytt/releases/download/v${YTT_VERSION}/ytt-linux-amd64 && \
    sudo install ytt /usr/local/bin/ && \
    rm -f ytt*

# kapp
ENV KAPP_VERSION 0.19.0
RUN wget -q -O kapp https://github.com/k14s/kapp/releases/download/v${KAPP_VERSION}/kapp-linux-amd64 && \
    sudo install kapp /usr/local/bin/ && \
    rm -f kapp*

# kbld
ENV KBLD_VERSION 0.13.0
RUN wget -q -O kbld https://github.com/k14s/kbld/releases/download/v${KBLD_VERSION}/kbld-linux-amd64 && \
    sudo install kbld /usr/local/bin/ && \
    rm -f kbld*

RUN mkdir -p ${VSCODE_USER} && echo "{\"java.home\":\"$(dirname /opt/jdk-*/bin/)\",\"maven.terminal.useJavaHome\":true, \"maven.executable.path\":\"/opt/apache-maven-${MAVEN_VERSION}/bin/mvn\",\"spring-boot.ls.java.home\":\"$(dirname /opt/jdk-*/bin/)\",\"cloudfoundry-manifest.ls.java.home\":\"$(dirname /opt/jdk-*/bin/)\",\"concourse.ls.java.home\":\"$(dirname /opt/jdk-*/bin/)\",\"files.exclude\":{\"**/.classpath\":true,\"**/.project\":true,\"**/.settings\":true,\"**/.factorypath\":true}}" | jq . > ${VSCODE_USER}/settings.json
RUN chmod +x /home/coder/.local/share/code-server/extensions/maven/resources/maven-wrapper/mvnw