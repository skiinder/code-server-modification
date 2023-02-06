FROM maven:3.8.7-eclipse-temurin-8-alpine as m2
USER root
COPY pom.xml .
RUN mvn package

FROM codercom/code-server:4.9.1

# 安装常用环境
RUN set -ex && \
    sudo sed -i 's/http:\/\/deb.\(.*\)/https:\/\/deb.\1/g' /etc/apt/sources.list && \
    sudo apt-get update && \
    sudo ln -s /lib /lib64 && \
    sudo apt install -y bash iputils-ping curl git jq libfreetype6 fonts-dejavu fontconfig && \
    sudo rm /bin/sh && \
    sudo ln -sv /bin/bash /bin/sh && \
    sudo rm -rf /var/cache/apt/*

# 安装Java和Maven
RUN curl -L https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u352-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u352b08.tar.gz | sudo tar -zxC /opt --no-same-owner && \
    sudo mv /opt/jdk8u352-b08 /opt/java && \
    curl -L https://dlcdn.apache.org/maven/maven-3/3.8.7/binaries/apache-maven-3.8.7-bin.tar.gz | sudo tar -zxC /opt --no-same-owner && \
    sudo mv /opt/apache-maven-3.8.7 /opt/maven

ENV JAVA_HOME=/opt/java M2_HOME=/opt/maven
ENV PATH=$PATH:$JAVA_HOME/bin:$M2_HOME/bin

# 获取Maven缓存
COPY --from=m2 /root/.m2 ./.m2

# 配置code-server和workspace
RUN code-server --install-extension vscjava.vscode-java-pack && \
    code-server --install-extension sugatoray.vscode-git-extension-pack && \
    mkdir -p /home/coder/.local/share/code-server/User && \
    mkdir -p /home/coder/workspace && \
    mkdir -p /home/coder/.config/code-server && \
    sudo mkdir -p /entrypoint.d

WORKDIR /home/coder/workspace

# 拷贝配置和自定义脚本
COPY settings.json /home/coder/.local/share/code-server/User
COPY config.yaml /home/coder/.config/code-server
COPY before.sh /entrypoint.d
RUN sudo chmod +x /entrypoint.d/before.sh

