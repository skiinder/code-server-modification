# code-server启动配置
cat <<"EOF" >/home/coder/.config/code-server/config.yaml
bind-addr: 127.0.0.1:8080
auth: none
cert: false
EOF

# vs-code配置
mkdir -p /home/coder/.local/share/code-server/User
cat <<EOF >/home/coder/.local/share/code-server/User/settings.json
{
  "security.workspace.trust.enabled": false
}
EOF

mkdir -p /home/coder/.local/share/code-server/Machine
cat <<EOF >/home/coder/.local/share/code-server/Machine/settings.json
{
  "java.jdt.ls.java.home": "/opt/java",
  "java.compile.nullAnalysis.mode": "automatic",
  "maven.terminal.useJavaHome": true,
  "maven.executable.path": "/opt/maven/bin/mvn",
  "java.server.launchMode": "Standard",
  "oj-config.project.token": "${PROJECT_TOKEN}",
  "oj-config.project.id": ${PROJECT_ID},
  "oj-config.project.url": "${PROJECT_URL}",
  "workbench.startupEditor": "readme"
}
EOF

# 拉取代码
PROJECT_DIR="$(basename "${PROJECT_URL}" .git)"
if [ "${PROJECT_URL}" ] && [ ! -d "${PROJECT_DIR}" ]; then
  git clone "${PROJECT_URL}"
fi
rm -rf "${PROJECT_DIR}/.git"

# 配置运行设置
mkdir "${PROJECT_DIR}/.vscode"
cat <<EOF >"${PROJECT_DIR}/.vscode/launch.json"
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
find "${PROJECT_DIR}" -iname readme.md -print0 | xargs -0 rm -rf
cat <<'EOF' >"${PROJECT_DIR}/README.txt"
这是一个线上IDE，使用上需要注意以下几点：
    1. 由于线上资源有限，IDE不允许挂机，如果检测到挂机时长超过30分钟，服务器资源会自动释放。挂机检测以是否敲击代码为准;
    2. 退出该IDE后，你的代码会在后台保留4小时。如果你在4小时内重新打开同一题目，可以继续之前的工作。
    3. IDE环境为vscode，不是IDEA，使用上稍有区别。
EOF