FROM codercom/code-server

# Misc
RUN sudo apt-get update && sudo apt-get install --no-install-recommends -y \
    jq \
    unzip \
    libarchive-tools \
    wget \
    && sudo rm -rf /var/lib/apt/lists/*

# Visual Studio Code Extentions
ENV VSCODE_USER /home/coder/.local/share/code-server/User
ENV VSCODE_EXTENSIONS /home/coder/.local/share/code-server/extensions

RUN code-server --install-extension redhat.java
RUN code-server --install-extension vscjava.vscode-java-debug
RUN code-server --install-extension vscjava.vscode-java-test
RUN code-server --install-extension vscjava.vscode-maven
RUN code-server --install-extension vscjava.vscode-java-dependency
RUN code-server --install-extension pivotal.vscode-spring-boot
RUN code-server --install-extension vscjava.vscode-spring-initializr
RUN code-server --install-extension vscjava.vscode-spring-boot-dashboard
RUN code-server --install-extension redhat.vscode-yaml
RUN code-server --install-extension adashen.vscode-tomcat
RUN code-server --install-extension dgileadi.java-decompiler
RUN code-server --install-extension gabrielbb.vscode-lombok

# Liberica JDK
RUN wget -q -O OpenJDK.tar.gz https://download.bell-sw.com/java/17.0.1+12/bellsoft-jdk17.0.1+12-linux-amd64.tar.gz && \
    tar xzf OpenJDK.tar.gz && \
    sudo mv jdk* /opt/ && \
    rm -f OpenJDK.tar.gz && \
    echo "export JAVA_HOME=$(dirname /opt/jdk-*/bin/)" | sudo tee -a /home/coder/.bashrc > /dev/null && \
    echo 'export PATH=${PATH}:${JAVA_HOME}/bin' | sudo tee -a /home/coder/.bashrc > /dev/null

# Maven
ENV MAVEN_VERSION=3.8.3
RUN wget -q -O maven.tar.gz http://ftp.riken.jp/net/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar xzf maven.tar.gz && \
    sudo mv apache-maven-* /opt/ && \
    rm -f maven.tar.gz && \
    echo "export MAVEN_HOME=/opt/apache-maven-${MAVEN_VERSION}" | sudo tee -a /home/coder/.bashrc > /dev/null && \
    echo 'export PATH=${PATH}:${MAVEN_HOME}/bin' | sudo tee -a /home/coder/.bashrc > /dev/null

# Kubectl
ENV KUBECTL_VERSION 1.22.0
RUN wget -q -O kubectl "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    sudo install kubectl /usr/local/bin/ && \
    rm -f kubectl*

# HELM
ENV HELM_VERSION 3.7.1
RUN wget -q -O helm.tgz "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" && \
    tar xzf helm.tgz && \
    sudo install linux-amd64/helm /usr/local/bin/ && \
    rm -rf linux-amd64 helm.tgz

# Terraform
ENV TERRAFORM_VERSION 1.0.11
RUN wget -q -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform.zip && \
    sudo install terraform /usr/local/bin/ && \
    rm -f terraform*

# yj
RUN wget -q -O yj https://github.com/sclevine/yj/releases/download/v5.0.0/yj-linux && \
    sudo install yj /usr/local/bin/ && \
    rm -f yj*

# ytt
ENV YTT_VERSION 0.37.0
RUN wget -q -O ytt https://github.com/vmware-tanzu/carvel-ytt/releases/download/v${YTT_VERSION}/ytt-linux-amd64 && \
    sudo install ytt /usr/local/bin/ && \
    rm -f ytt*

# kapp
ENV KAPP_VERSION 0.42.0
RUN wget -q -O kapp https://github.com/vmware-tanzu/carvel-kapp/releases/download/v${KAPP_VERSION}/kapp-linux-amd64 && \
    sudo install kapp /usr/local/bin/ && \
    rm -f kapp*

# kbld
ENV KBLD_VERSION 0.31.0
RUN wget -q -O kbld https://github.com/vmware-tanzu/carvel-kbld/releases/download/v${KBLD_VERSION}/kbld-linux-amd64 && \
    sudo install kbld /usr/local/bin/ && \
    rm -f kbld*

# imgpkg
ENV IMGPKG_VERSION 0.22.0
RUN wget -q -O imgpkg https://github.com/vmware-tanzu/carvel-imgpkg/releases/download/v${IMGPKG_VERSION}/imgpkg-linux-amd64 && \
    sudo install imgpkg /usr/local/bin/ && \
    rm -f imgpkg*

# kwt
ENV KWT_VERSION 0.0.6
RUN wget -q -O kwt https://github.com/vmware-tanzu/carvel-kwt/releases/download/v${KWT_VERSION}/kwt-linux-amd64 && \
    sudo install kwt /usr/local/bin/ && \
    rm -f kwt*

RUN mkdir -p ${VSCODE_USER} && echo "{\"java.home\":\"$(dirname /opt/jdk-*/bin/)\",\"maven.terminal.useJavaHome\":true, \"maven.executable.path\":\"/opt/apache-maven-${MAVEN_VERSION}/bin/mvn\",\"spring-boot.ls.java.home\":\"$(dirname /opt/jdk-*/bin/)\",\"cloudfoundry-manifest.ls.java.home\":\"$(dirname /opt/jdk-*/bin/)\",\"concourse.ls.java.home\":\"$(dirname /opt/jdk-*/bin/)\",\"files.exclude\":{\"**/.classpath\":true,\"**/.project\":true,\"**/.settings\":true,\"**/.factorypath\":true},\"redhat.telemetry.enabled\":false}" | jq . > ${VSCODE_USER}/settings.json
RUN rm -f /home/coder/.wget-hsts