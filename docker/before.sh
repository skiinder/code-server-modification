# code-server启动配置
cat <<"EOF" >/home/coder/.config/code-server/config.yaml
bind-addr: 127.0.0.1:8080
auth: none
cert: false
EOF

# vs-code配置
cat <<EOF >/home/coder/.local/share/code-server/User/settings.json
{
  "java.home": "/opt/java",
  "maven.terminal.useJavaHome": true,
  "maven.executable.path": "/opt/maven/bin/mvn",
  "java.server.launchMode": "Standard",
  "oj-config.project.token": "${PROJECT_TOKEN}",
  "oj-config.project.id": ${PROJECT_ID},
  "oj-config.project.url": "${PROJECT_URL}",
  "oj-config.oj.countdown.idel.threshold": 4
}
EOF

# 拉取代码
if [ "${PROJECT_URL}" ] && [ ! -d "$(basename "${PROJECT_URL}" .git)" ]; then
  git clone "${PROJECT_URL}"
fi
