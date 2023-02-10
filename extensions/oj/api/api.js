const axios = require('axios')
const vscode = require('vscode');


//项目的gitee地址
let projectURL = vscode.workspace.getConfiguration().get("oj-config.project.url");

//题目ID
let questinoId = vscode.workspace.getConfiguration().get("oj-config.project.id");


//用户Token
let userToken = vscode.workspace.getConfiguration().get("oj-config.project.token");


// 创建instance
const request = axios.create({
    baseURL: "http://practice.atguigu.cn",
    timeout: 20000
})



// 指定请求拦截器
request.interceptors.request.use(config => {


    // 配置token到header
    let token = userToken;
    if (token) {
        config.headers['token'] = token;
    }

    return config // 必须返回config
})

export function renewPodApi() {
    return request({
        url: "/codeserver/renew",
        method:"get",
        params:{
            "questionId":questinoId
        }
    });
}


export function deletePodApi() {
    return request({
        url: "/codeserver/delete",
        method:"get",
    });
}
