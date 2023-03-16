FROM maven:3.8.7-eclipse-temurin-8-alpine as m2
USER root
COPY mapreduce.xml pom.xml
RUN mvn clean package
COPY spark.xml pom.xml
RUN mvn clean package
COPY flink.xml pom.xml
RUN mvn clean package
RUN chown -R 1000:1000 /root/.m2

FROM codercom/code-server:4.10.1

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
RUN set -ex && \
    curl -L https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u352-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u352b08.tar.gz | sudo tar -zxC /opt --no-same-owner && \
    sudo mv /opt/jdk8u352-b08 /opt/java && \
    curl -L https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz | sudo tar -zxC /opt --no-same-owner && \
    sudo mv /opt/apache-maven-3.6.3 /opt/maven && \
    sudo bash -c 'echo "export JAVA_HOME=/opt/java" >> /etc/environment' && \
    sudo bash -c 'echo "export M2_HOME=/opt/maven" >> /etc/environment' && \
    sudo bash -c 'echo "export PATH=\$PATH:/opt/java/bin:/opt/maven/bin" >> /etc/environment' && \
    sudo sed -i '/<mirrors>/a<mirror><id>nexus-aliyun</id><mirrorOf>central</mirrorOf><name>Nexus aliyun</name><url>http://maven.aliyun.com/nexus/content/groups/public</url></mirror>' /opt/maven/conf/settings.xml

ENV JAVA_HOME=/opt/java M2_HOME=/opt/maven

# 获取Maven缓存
COPY --from=m2 --chown=coder:coder /root/.m2 ./.m2
COPY extensions ./extensions

# 配置code-server和workspace
RUN set -ex && \
    find extensions -name *.vsix | xargs -rn1 code-server --install-extension && \
    sudo rm -rf extensions && \
    mkdir -p /home/coder/.local/share/code-server/User && \
    mkdir -p /home/coder/workspace && \
    mkdir -p /home/coder/.config/code-server && \
    sudo mkdir -p /entrypoint.d && \
    sudo sed -i '/coder/d' /etc/sudoers.d/nopasswd

# 拷贝配置和自定义脚本
COPY --chmod=755 --chown=coder:coder before.sh /entrypoint.d
WORKDIR /home/coder/workspace
