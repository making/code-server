FROM codercom/code-server

# Misc
RUN sudo apt-get update && sudo apt-get install --no-install-recommends -y \
    jq \
    unzip \
    bsdtar \
    wget \
    && sudo rm -rf /var/lib/apt/lists/*

# Visual Studio Code Extentions
ENV VSCODE_USER /home/coder/.local/share/code-server/User
ENV VSCODE_EXTENSIONS /home/coder/.local/share/code-server/extensions

RUN code-server --install-extension redhat.java@0.80.0
RUN code-server --install-extension vscjava.vscode-java-debug@0.35.0
RUN code-server --install-extension vscjava.vscode-java-test@0.31.1
RUN code-server --install-extension vscjava.vscode-maven@0.32.2
RUN code-server --install-extension vscjava.vscode-java-dependency@0.18.6
RUN code-server --install-extension pivotal.vscode-spring-boot@1.17.0
RUN code-server --install-extension vscjava.vscode-spring-initializr@0.7.0
RUN code-server --install-extension vscjava.vscode-spring-boot-dashboard@0.1.8
RUN code-server --install-extension redhat.vscode-yaml@0.22.0
RUN code-server --install-extension pivotal.vscode-manifest-yaml@1.17.0
RUN code-server --install-extension pivotal.vscode-concourse@1.17.0
RUN code-server --install-extension adashen.vscode-tomcat@0.11.2
RUN code-server --install-extension dgileadi.java-decompiler@0.0.2
RUN code-server --install-extension gabrielbb.vscode-lombok@1.0.0

# AdoptOpenJDK
RUN wget -q -O OpenJDK.tar.gz https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.12%2B7/OpenJDK11U-jdk_x64_linux_hotspot_11.0.12_7.tar.gz && \
    tar xzf OpenJDK.tar.gz && \
    sudo mv jdk-* /opt/ && \
    rm -f OpenJDK.tar.gz && \
    echo "export JAVA_HOME=$(dirname /opt/jdk-*/bin/)" | sudo tee -a /home/coder/.bashrc > /dev/null && \
    echo 'export PATH=${PATH}:${JAVA_HOME}/bin' | sudo tee -a /home/coder/.bashrc > /dev/null

# Maven
ENV MAVEN_VERSION=3.8.1
RUN wget -q -O maven.tar.gz http://ftp.riken.jp/net/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar xzf maven.tar.gz && \
    sudo mv apache-maven-* /opt/ && \
    rm -f maven.tar.gz && \
    echo "export MAVEN_HOME=/opt/apache-maven-${MAVEN_VERSION}" | sudo tee -a /home/coder/.bashrc > /dev/null && \
    echo 'export PATH=${PATH}:${MAVEN_HOME}/bin' | sudo tee -a /home/coder/.bashrc > /dev/null

# CF CLI
ENV CF_CLI_VERSION 7.2.0
RUN wget -q -O cf.tgz "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=${CF_CLI_VERSION}&source=github-rel" && \
    tar xzf cf.tgz && \
    sudo install cf /usr/local/bin/ && \
    rm -f cf* LICENSE NOTICE

# BOSH
ENV BOSH_VERSION 6.4.4
RUN wget -q -O bosh https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_VERSION}/bosh-cli-${BOSH_VERSION}-linux-amd64 && \
    sudo install bosh /usr/local/bin/ && \
    rm -f bosh*

# OM
ENV OM_VERSION 7.3.1
RUN wget -q -O om https://github.com/pivotal-cf/om/releases/download/${OM_VERSION}/om-linux-${OM_VERSION} && \
    sudo install om /usr/local/bin/ && \
    rm -f om*

# Kubectl
ENV KUBECTL_VERSION 1.22.0
RUN wget -q -O kubectl "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    sudo install kubectl /usr/local/bin/ && \
    rm -f kubectl*

# HELM
ENV HELM_VERSION 3.6.3
RUN wget -q -O helm.tgz "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" && \
    tar xzf helm.tgz && \
    sudo install linux-amd64/helm /usr/local/bin/ && \
    rm -rf linux-amd64 helm.tgz

# Terraform
ENV TERRAFORM_VERSION 1.0.4
RUN wget -q -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform.zip && \
    sudo install terraform /usr/local/bin/ && \
    rm -f terraform*

# Fly
ENV FLY_VERSION 7.4.0
RUN wget -q -O fly.tgz https://github.com/concourse/concourse/releases/download/v${FLY_VERSION}/fly-${FLY_VERSION}-linux-amd64.tgz && \
    tar xzf fly.tgz && \
    sudo install fly /usr/local/bin/ && \
    rm -f fly*

# CredHub
ENV CREDHUB_VERSION 2.9.0
RUN wget -q -O credhub.tgz https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_VERSION}/credhub-linux-${CREDHUB_VERSION}.tgz && \
    tar xzf credhub.tgz && \
    sudo install credhub /usr/local/bin/ && \
    rm -f credhub*

# yj
RUN wget -q -O yj https://github.com/sclevine/yj/releases/download/v5.0.0/yj-linux && \
    sudo install yj /usr/local/bin/ && \
    rm -f yj*

# ytt
ENV YTT_VERSION 0.35.1
RUN wget -q -O ytt https://github.com/vmware-tanzu/carvel-ytt/releases/download/v${YTT_VERSION}/ytt-linux-amd64 && \
    sudo install ytt /usr/local/bin/ && \
    rm -f ytt*

# kapp
ENV KAPP_VERSION 0.37.0
RUN wget -q -O kapp https://github.com/vmware-tanzu/carvel-kapp/releases/download/v${KAPP_VERSION}/kapp-linux-amd64 && \
    sudo install kapp /usr/local/bin/ && \
    rm -f kapp*

# kbld
ENV KBLD_VERSION 0.30.0
RUN wget -q -O kbld https://github.com/vmware-tanzu/carvel-kbld/releases/download/v${KBLD_VERSION}/kbld-linux-amd64 && \
    sudo install kbld /usr/local/bin/ && \
    rm -f kbld*

# imgpkg
ENV IMGPKG_VERSION 0.17.0
RUN wget -q -O imgpkg https://github.com/vmware-tanzu/carvel-imgpkg/releases/download/v${IMGPKG_VERSION}/imgpkg-linux-amd64 && \
    sudo install imgpkg /usr/local/bin/ && \
    rm -f imgpkg*

RUN mkdir -p ${VSCODE_USER} && echo "{\"java.home\":\"$(dirname /opt/jdk-*/bin/)\",\"maven.terminal.useJavaHome\":true, \"maven.executable.path\":\"/opt/apache-maven-${MAVEN_VERSION}/bin/mvn\",\"spring-boot.ls.java.home\":\"$(dirname /opt/jdk-*/bin/)\",\"cloudfoundry-manifest.ls.java.home\":\"$(dirname /opt/jdk-*/bin/)\",\"concourse.ls.java.home\":\"$(dirname /opt/jdk-*/bin/)\",\"files.exclude\":{\"**/.classpath\":true,\"**/.project\":true,\"**/.settings\":true,\"**/.factorypath\":true}}" | jq . > ${VSCODE_USER}/settings.json