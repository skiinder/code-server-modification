const { count } = require('console');
const vscode = require('vscode');
const { renewPodApi, deletePodApi } = require('../api/api');



//续约Pod周期，单位秒
vscode.window.RENEW_POD_INTERVAL = 60;

//倒计时周期，单位秒
vscode.window.COUNTDOWN_INTERVAL = 60;

//倒计时阈值
vscode.window.COUNTDOWN_THRESHOLD = 180;

//检查挂机行为周期，单位秒
vscode.window.CHECK_IDLE_INTERVAL = 2;

//挂机时间阈值
vscode.window.IDLE_THRESHOLD = 1620;

//当前是否挂机
vscode.window.IS_IDLE = false;

//是否续约Pod
vscode.window.shouldRenewPod = true;

//倒计时剩余时间
vscode.window.podLeftSec = vscode.window.COUNTDOWN_THRESHOLD;

//代码末次修改时间
vscode.window.lastChangeTime = parseInt(new Date().getTime() / 1000);



//更新末次修改时间
function updateLastChangeTime() {
    vscode.window.lastChangeTime = parseInt(new Date().getTime() / 1000);

    //若Pod处在存活状态,并且当前是挂机状态,则设置IS_IDLE为活跃状态
    if (vscode.window.shouldRenewPod && vscode.window.IS_IDLE) {
        vscode.window.showInformationMessage("监测到coding, 后台资源将继续为你保留");
        vscode.window.IS_IDLE = false;
        vscode.window.podLeftSec = vscode.window.COUNTDOWN_THRESHOLD;
        checkIdel();
        console.log("重新开始定时检查挂机行为：" + new Date());
    //若Pod已经释放,提示即可
    } else if (!vscode.window.shouldRenewPod) {
        vscode.window.showInformationMessage("后台资源已经释放, 如需继续做题请刷新网页");
    }
}

//定时发送renewPod请求
function renewPod() {
    if (vscode.window.shouldRenewPod) {
        sendRenewPodRequest();
        setTimeout(() => {
            renewPod();
        }, vscode.window.RENEW_POD_INTERVAL * 1000);
    }
}


//定时检查挂机行为
function checkIdel() {
    console.log("定时检查挂机行为:" + new Date());
    //计算挂机时长
    let idleTime = parseInt(new Date().getTime() / 1000) - vscode.window.lastChangeTime;
    
    //若挂机时长超过阈值，并且之前并未处在挂机状态，也就是刚刚监测到挂机行为
    if (idleTime >= vscode.window.IDLE_THRESHOLD && !vscode.window.IS_IDLE) {

        console.log("监测到挂机超过:" + idleTime + "秒,开始倒计时")
        //第一次监测到挂机行为,开始倒计时,并且将IS_IDLE设置为挂机状态,并且不再触发下一次的挂机监测
        vscode.window.IS_IDLE = true;
        countdown();
    } else {
        //未监测到挂机行为,触发下一次的挂机监测
        setTimeout(() => {
            checkIdel();
        }, vscode.window.CHECK_IDLE_INTERVAL * 1000);
    }
}


function countdown() {

    //如果当前状态是挂机状态,并且倒计时时间还有剩余
    if (vscode.window.IS_IDLE && vscode.window.podLeftSec > 0) {
        //显示提示信息
        console.log("监测到挂机行为:" + new Date());
        vscode.window.showInformationMessage("你已经有一段时间没有敲代码了, 如果你继续挂机, 后台资源将在" + vscode.window.podLeftSec + "秒后释放");
        vscode.window.podLeftSec = vscode.window.podLeftSec - vscode.window.COUNTDOWN_INTERVAL;
        //并触发下一次倒计时
        setTimeout(() => { 
            countdown();
        }, vscode.window.COUNTDOWN_INTERVAL * 1000);
    //若当前状态是挂机状态,并且倒计时已经用完
    } else if (vscode.window.IS_IDLE && vscode.window.podLeftSec <= 0) {
        //释放资源,并且不再触发下次的countdown
        console.log("挂机行为超过阈值,释放资源");
        vscode.window.showInformationMessage("后台资源已释放");
        vscode.window.shouldRenewPod = false;
        sendCleanPodRequest();
    //若当前状态恢复为活跃状态,不做任何处理
    } else {
        console.log("玩家已经重新活跃起来,继续保留资源");
    }
}


function sendRenewPodRequest() {
    renewPodApi();
    console.log("发送续约Pod请求" + new Date());
}

function sendCleanPodRequest() {
    deletePodApi();
    console.log("发送清理Pod请求" + new Date());
}

module.exports = { updateLastChangeTime, renewPod, checkIdel };