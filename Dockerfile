FROM codercom/code-server

# Misc
RUN sudo apt-get update && sudo apt-get install --no-install-recommends -y \
    jq \
    gnupg2 \
    curl \
    unzip \
    libarchive-tools \
    wget \
    bash-completion \
    dnsutils \
    netcat \
    telnet \
    postgresql-client \
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

# Liberica JDK
RUN wget -q -O OpenJDK.tar.gz https://download.bell-sw.com/java/17.0.5+8/bellsoft-jdk17.0.5+8-linux-amd64.tar.gz && \
    tar xzf OpenJDK.tar.gz && \
    sudo mv jdk* /opt/ && \
    rm -f OpenJDK.tar.gz && \
    echo "export JAVA_HOME=$(dirname /opt/jdk-*/bin/)" | sudo tee -a /etc/profile.d/00-java.sh > /dev/null && \
    echo 'export JRE_HOME=${JAVA_HOME}' | sudo tee -a /etc/profile.d/00-java.sh > /dev/null && \
    echo 'export PATH=${PATH}:${JAVA_HOME}/bin' | sudo tee -a /etc/profile.d/00-java.sh > /dev/null
USER root
RUN chmod +x /etc/profile.d/00-java.sh
USER coder

# Tanzu
ENV TANZU_VERSION=0.25.0
RUN wget -q https://github.com/vmware-tanzu/tanzu-framework/releases/download/v${TANZU_VERSION}/tanzu-framework-linux-amd64.tar.gz && \
    tar xzvf tanzu-framework-linux-amd64.tar.gz && \
    sudo install cli/core/v${TANZU_VERSION}/tanzu-core-linux_amd64 /usr/local/bin/tanzu && \
    tanzu plugin install --local cli all && \
    rm -fr tanzu-framework* cli

ENV TANZU_APPS_CLI_PLUGIN_VERSION=0.9.0
RUN wget -q https://github.com/vmware-tanzu/apps-cli-plugin/releases/download/v${TANZU_APPS_CLI_PLUGIN_VERSION}/tanzu-apps-plugin-linux-amd64-v${TANZU_APPS_CLI_PLUGIN_VERSION}.tar.gz && \
    mkdir tanzu-apps-plugin && \
    tar xzvf tanzu-apps-plugin-linux-amd64-v${TANZU_APPS_CLI_PLUGIN_VERSION}.tar.gz -C tanzu-apps-plugin && \
    tanzu plugin install apps --local tanzu-apps-plugin --version v${TANZU_APPS_CLI_PLUGIN_VERSION} && \
    rm -fr tanzu-apps-plugin*

# Maven
ENV MAVEN_VERSION=3.8.6
RUN wget -q -O maven.tar.gz http://ftp.riken.jp/net/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar xzf maven.tar.gz && \
    sudo mv apache-maven-* /opt/ && \
    rm -f maven.tar.gz && \
    echo "export MAVEN_HOME=/opt/apache-maven-${MAVEN_VERSION}" | sudo tee -a /etc/profile.d/01-maven.sh > /dev/null && \
    echo 'export PATH=${PATH}:${MAVEN_HOME}/bin' | sudo tee -a /etc/profile.d/01-maven.sh > /dev/null
USER root
RUN chmod +x /etc/profile.d/01-maven.sh
USER coder

# Kubectl
ENV KUBECTL_VERSION 1.23.13
RUN wget -q -O kubectl "https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    sudo install kubectl /usr/local/bin/ && \
    rm -f kubectl*

# HELM
ENV HELM_VERSION 3.10.1
RUN wget -q -O helm.tgz "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" && \
    tar xzf helm.tgz && \
    sudo install linux-amd64/helm /usr/local/bin/ && \
    rm -rf linux-amd64 helm.tgz

# Terraform
ENV TERRAFORM_VERSION 1.3.4
RUN wget -q -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform.zip && \
    sudo install terraform /usr/local/bin/ && \
    rm -f terraform*

# yj
RUN wget -q -O yj https://github.com/sclevine/yj/releases/download/v5.1.0/yj-linux-amd64 && \
    sudo install yj /usr/local/bin/ && \
    rm -f yj*

# ytt
ENV YTT_VERSION 0.43.0
RUN wget -q -O ytt https://github.com/vmware-tanzu/carvel-ytt/releases/download/v${YTT_VERSION}/ytt-linux-amd64 && \
    sudo install ytt /usr/local/bin/ && \
    rm -f ytt*

# kapp
ENV KAPP_VERSION 0.53.0
RUN wget -q -O kapp https://github.com/vmware-tanzu/carvel-kapp/releases/download/v${KAPP_VERSION}/kapp-linux-amd64 && \
    sudo install kapp /usr/local/bin/ && \
    rm -f kapp*

# kbld
ENV KBLD_VERSION 0.35.0
RUN wget -q -O kbld https://github.com/vmware-tanzu/carvel-kbld/releases/download/v${KBLD_VERSION}/kbld-linux-amd64 && \
    sudo install kbld /usr/local/bin/ && \
    rm -f kbld*

# imgpkg
ENV IMGPKG_VERSION 0.33.0
RUN wget -q -O imgpkg https://github.com/vmware-tanzu/carvel-imgpkg/releases/download/v${IMGPKG_VERSION}/imgpkg-linux-amd64 && \
    sudo install imgpkg /usr/local/bin/ && \
    rm -f imgpkg*

# kctrl
ENV KCTRL_VERSION 0.42.0
RUN wget -q -O kctrl https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v${KCTRL_VERSION}/kctrl-linux-amd64 && \
    sudo install kctrl /usr/local/bin/ && \
    rm -f kctrl*

# kwt
ENV KWT_VERSION 0.0.6
RUN wget -q -O kwt https://github.com/vmware-tanzu/carvel-kwt/releases/download/v${KWT_VERSION}/kwt-linux-amd64 && \
    sudo install kwt /usr/local/bin/ && \
    rm -f kwt*

# kp
ENV KP_VERSION 0.7.1
RUN wget -q -O kp https://github.com/vmware-tanzu/kpack-cli/releases/download/v${KP_VERSION}/kp-linux-amd64-${KP_VERSION} && \
    sudo install kp /usr/local/bin/ && \
    rm -f kp

# pinniped
ENV PINNIPED_VERSION 0.20.0
RUN wget -q -O pinniped https://get.pinniped.dev/v${PINNIPED_VERSION}/pinniped-cli-linux-amd64 && \
    sudo install pinniped /usr/local/bin/ && \
    rm -f pinniped

# krew
ENV KREW_VERSION 0.4.3
RUN wget -q https://github.com/kubernetes-sigs/krew/releases/download/v${KREW_VERSION}/krew-linux_amd64.tar.gz && \
    tar xzf krew-linux_amd64.tar.gz && \
    ./krew-linux_amd64 install krew && \
    rm -rf krew* && \
    echo "export PATH=\"\${KREW_ROOT:-\$HOME/.krew}/bin:\$PATH\"" | sudo tee -a /home/coder/.bashrc > /dev/null

# Tilt
ENV TILT_VERSION=0.30.11
RUN wget -q -O tilt.tar.gz https://github.com/tilt-dev/tilt/releases/download/v${TILT_VERSION}/tilt.${TILT_VERSION}.linux.x86_64.tar.gz && \
    tar xzf tilt.tar.gz && \
    sudo install tilt /usr/local/bin/ && \
    rm -rf tilt*

# Stern
ENV STERN_VERSION 1.22.0
RUN wget -q https://github.com/stern/stern/releases/download/v${STERN_VERSION}/stern_${STERN_VERSION}_linux_amd64.tar.gz && \
    tar xzf stern_${STERN_VERSION}_linux_amd64.tar.gz && \
    sudo install stern /usr/local/bin/ && \
    rm -rf stern*

# k9s
ENV K9S_VERSION 0.26.7
RUN wget -q https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_x86_64.tar.gz && \
    tar zxf k9s_Linux_x86_64.tar.gz && \
    sudo install k9s /usr/local/bin/ && \
    rm -rf k9s* README.md

# pivnet
ENV PIVNET_VERSION 3.0.1
RUN wget -q -O pivnet https://github.com/pivotal-cf/pivnet-cli/releases/download/v${PIVNET_VERSION}/pivnet-linux-amd64-${PIVNET_VERSION} && \
    sudo install pivnet /usr/local/bin/ && \
    rm -f pivnet*

# Docker
ENV DOCKER_VERSION 20.10.21
RUN wget -q -O docker.tar.gz https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz && \
    tar xzf docker.tar.gz && \
    sudo install docker/docker /usr/local/bin/ && \
    rm -rf docker*

# SCDF Shell
ENV SCDF_VERSION 2.9.6
RUN wget -q https://repo.spring.io/release/org/springframework/cloud/spring-cloud-dataflow-shell/${SCDF_VERSION}/spring-cloud-dataflow-shell-${SCDF_VERSION}.jar && \
    sudo mv spring-cloud-dataflow-shell-${SCDF_VERSION}.jar /opt/

# WebSocat
ENV WEBSOCAT_VERSION=1.11.0
RUN wget -q -O websocat https://github.com/vi/websocat/releases/download/v${WEBSOCAT_VERSION}/websocat.x86_64-unknown-linux-musl && \
    sudo install websocat /usr/local/bin/ && \
    rm -f websocat*

# MongoDB
ENV MONGODB_VERSION=5.0.13
RUN wget -q https://repo.mongodb.org/apt/ubuntu/dists/focal/mongodb-org/5.0/multiverse/binary-amd64/mongodb-org-shell_${MONGODB_VERSION}_amd64.deb && \
    sudo dpkg -i mongodb-org-shell_${MONGODB_VERSION}_amd64.deb && \
    rm -f mongodb-org-shell_${MONGODB_VERSION}_amd64.deb

# AWS
RUN curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    rm -rf aws*

# AZURE
RUN wget -q -O az.deb https://packages.microsoft.com/repos/azure-cli/pool/main/a/azure-cli/azure-cli_2.42.0-1~focal_all.deb && \
    sudo dpkg -i az.deb && \
    rm -f az.deb

# gcloud
RUN wget -q -O google-cloud-cli.deb https://packages.cloud.google.com/apt/pool/google-cloud-cli_408.0.1-0_all_c2612580339572c4c5fdb31365a2a8e7760a450ff86cd7c3068510fa662230ae.deb && \
    sudo dpkg -i google-cloud-cli.deb && \
    rm -f google-cloud-cli.deb

RUN /home/coder/.krew/bin/kubectl-krew install tree && \
    /home/coder/.krew/bin/kubectl-krew install neat

RUN wget -q https://github.com/jonmosco/kube-ps1/raw/master/kube-ps1.sh && \
    sudo mv kube-ps1.sh /opt/

RUN kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null && \
    helm completion bash | sudo tee /etc/bash_completion.d/helm > /dev/null && \
    tanzu completion bash | sudo tee /etc/bash_completion.d/tanzu > /dev/null && \
    kp completion bash | sudo tee /etc/bash_completion.d/kp > /dev/null && \
    ytt completion bash | sudo tee /etc/bash_completion.d/ytt > /dev/null && \
    kapp completion bash | grep -v Succeeded | sudo tee /etc/bash_completion.d/kapp > /dev/null && \
    imgpkg completion bash | grep -v Succeeded | sudo tee /etc/bash_completion.d/imgpkg > /dev/null && \
    kctrl completion bash | grep -v Succeeded | sudo tee /etc/bash_completion.d/kctrl > /dev/null && \
    stern --completion bash | sudo tee /etc/bash_completion.d/stern > /dev/null && \
    tilt completion bash | sudo tee /etc/bash_completion.d/tilt > /dev/null && \
    pinniped completion bash | sudo tee /etc/bash_completion.d/pinniped > /dev/null

RUN rm -f LICENSE README.md

RUN mkdir /home/coder/.bin && \
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" | sudo tee -a /home/coder/.bashrc > /dev/null

COPY install-from-tanzunet.sh /home/coder/

RUN mkdir -p ${VSCODE_USER} && echo "{\"java.home\":\"$(dirname /opt/jdk-*/bin/)\",\"maven.terminal.useJavaHome\":true, \"maven.executable.path\":\"/opt/apache-maven-${MAVEN_VERSION}/bin/mvn\",\"spring-boot.ls.java.home\":\"$(dirname /opt/jdk-*/bin/)\",\"files.exclude\":{\"**/.classpath\":true,\"**/.project\":true,\"**/.settings\":true,\"**/.factorypath\":true},\"redhat.telemetry.enabled\":false,\"java.server.launchMode\": \"Standard\"}" | jq . > ${VSCODE_USER}/settings.json
RUN echo 'for f in /etc/profile.d/*.sh;do source $f;done' | sudo tee -a /home/coder/.bashrc > /dev/null
RUN rm -f /home/coder/.wget-hsts
