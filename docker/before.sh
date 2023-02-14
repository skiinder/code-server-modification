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
  "security.workspace.trust.enabled": false,
  "workbench.startupEditor": "readme"
}
EOF

# 拉取代码
PROJECT_DIR="$(basename "${PROJECT_URL}" .git)"
if [ "${PROJECT_URL}" ] && [ ! -d "${PROJECT_DIR}" ]; then
  git clone "${PROJECT_URL}"
fi

# 配置运行设置
mkdir .vscode
cat <<EOF >.vscode/launch.json
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "java",
            "name": "Launch Current File",
            "request": "launch",
            "mainClass": "\${file}",
            "vmArgs": "-Xmx512m"
        },
        {
            "type": "java",
            "name": "Launch Runner",
            "request": "launch",
            "mainClass": "com.atguigu.Runner",
            "projectName": "${PROJECT_DIR}",
            "vmArgs": "-Xmx512m"
        }
    ]
}
EOF
