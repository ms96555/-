#!/bin/bash
#api 启动脚本
image_api="dk-img.n-b-e-t.com:7777/api"
image_back_admin="dk-img.n-b-e-t.com:7777/back_admin"
image_cld_admin="dk-img.n-b-e-t.com:7777/cld_admin"
image_settlement="dk-img.n-b-e-t.com:7777/settlement"
image_data="dk-img.n-b-e-t.com:7777/data_process"
image_pay_platform_admin="dk-img.n-b-e-t.com:7777/pay_platform_admin"
image_pay_site_api="dk-img.n-b-e-t.com:7777/pay_site_api"
image_pay_platform_api="dk-img.n-b-e-t.com:7777/pay_platform_api"
SHELL_DIR="/script/logs"
SHELL_LOG="${SHELL_DIR}/$0.log"
SHELL_NAME="$0"
mkdir -p $SHELL_DIR
. /etc/init.d/functions
writelog(){
        local LOGINFO=$1
                local AETVAL=$2
        local IS_EXIT=$3
        LDATA=$(date +%F)
        LTIME=$(date +%H-%M-%S)
        if [ $AETVAL -eq 0 ]
        then
                echo "${LDATA} : $LTIME : ${SHELL_NAME} : ${LOGINFO} : Success" >>$SHELL_LOG
                action  "${LDATA} : $LTIME : ${SHELL_NAME} : ${LOGINFO} " /bin/true
        else
                echo "${LDATA} : $LTIME : ${SHELL_NAME} : ${LOGINFO} : Fail" >>$SHELL_LOG
                action "${LDATA} : $LTIME : ${SHELL_NAME} : ${LOGINFO} "  /bin/false
                if [ $IS_EXIT -eq 1 ]
                then
                        exit 5
                fi
        fi

}
function run_docker () {
local image_name="$1"
local docker_name="$2"
local docker_port="$3"
local docker=`sudo docker search ${image_name} |awk '{if (NR>1) {print $1}}' |awk -F: '{print $3}' |sort -r`
local version=`echo "$docker" |sed -n 1p`
local local=`sudo docker images |grep ${image_name} |awk '{print $2}' |sort -r`
case $image_name in
        $image_api)
                docker_run="sudo docker run --restart=always -itd -p ${docker_port}:8080 --name ${docker_name} \
                        -v /opt/logs/${docker_name}/Logs:/app/Logs  \
                        -v /opt/logs/${docker_name}/logs:/app/logs  \
                        -v /opt/project/code/config/${docker_name}.config:/app/NP.API.dll.config \
                        ${image_name}:$version"
        ;;
        $image_back_admin)
                docker_run="sudo docker run --restart=always -itd -p ${docker_port}:8080 --name ${docker_name} \
                        -v /opt/logs/${docker_name}/Logs:/app/Logs  \
                        -v /opt/logs/${docker_name}/logs:/app/logs  \
                        -v /opt/project/code/config/${docker_name}.config:/app/NP.Web.dll.config \
                        ${image_name}:$version"
        ;;
        $image_cld_admin)
                docker_run="sudo docker run --restart=always -itd -p ${docker_port}:8080 --name ${docker_name} \
                        -v /opt/logs/${docker_name}/Logs:/app/Logs  \
                        -v /opt/logs/${docker_name}/logs:/app/logs  \
                        -v /opt/project/code/${docker_name}/Configs:/app/Configs  \
                        -v /opt/project/code/config/${docker_name}.config:/app/NP.Platform.dll.config \
                        ${image_name}:$version"
        ;;
        $image_settlement)
                if [ -z $docker_port ]
                then
                        docker_run="sudo docker run --restart=always -itd --name ${docker_name} \
                                -v /opt/logs/${docker_name}/Logs:/app/Logs  \
                                -v /opt/logs/${docker_name}/logs:/app/logs  \
                                -v /efs/lottery_bet_dir:/share/csv \
                                -v /opt/project/code/config/${docker_name}.config:/app/NP.Settlement.dll.config \
                                ${image_name}:$version"
                else
                        docker_run="sudo docker run --restart=always -itd -p ${docker_port}:8080 --name ${docker_name} \
                                -v /opt/logs/${docker_name}/Logs:/app/Logs  \
                                -v /opt/logs/${docker_name}/logs:/app/logs  \
                                -v /efs/lottery_bet_dir:/share/csv \
                                -v /opt/project/code/config/${docker_name}.config:/app/NP.Settlement.dll.config \
                                ${image_name}:$version"
                fi
        ;;
        $image_data)
                docker_run="sudo docker run --restart=always -itd -p ${docker_port}:8080 --name ${docker_name} \
                        -v /opt/logs/${docker_name}/Logs:/app/Logs  \
                        -v /opt/logs/${docker_name}/logs:/app/logs  \
                        -v /efs/bet_dir:/share/csv \
                        -v /opt/project/code/config/${docker_name}.config:/app/NP.DataProces.dll.config \
                        ${image_name}:$version"
        ;;
        $image_pay_platform_admin)
                docker_run="sudo docker run --restart=always -itd -p ${docker_port}:8080 --name ${docker_name} \
                        -v /opt/logs/${docker_name}/Logs:/app/Logs  \
                        -v /opt/logs/${docker_name}/logs:/app/logs  \
                        -v /opt/project/code/${docker_name}/Configs:/app/Configs  \
                        -v /opt/project/code/config/${docker_name}.config:/app/NP.Pay.Platform.dll.config \
                        ${image_name}:$version"
        ;;
        $image_pay_site_api)
                docker_run="sudo docker run --restart=always -itd -p ${docker_port}:8080 --name ${docker_name} \
                        -v /opt/logs/${docker_name}/Logs:/app/Logs  \
                        -v /opt/logs/${docker_name}/logs:/app/logs  \
                        -v /opt/project/code/config/${docker_name}.config:/app/NP.Pay.Redirect.dll.config \
                        ${image_name}:$version"
        ;;
        $image_pay_platform_api)
                docker_run="sudo docker run --restart=always -itd -p ${docker_port}:8080 --name ${docker_name} \
                        -v /opt/logs/${docker_name}/Logs:/app/Logs  \
                        -v /opt/logs/${docker_name}/logs:/app/logs  \
                        -v /opt/project/code/${docker_name}/Configs:/app/Configs  \
                        -v /opt/project/code/config/${docker_name}.config:/app/NP.Pay.API.dll.config \
                        ${image_name}:$version"
        ;;
        *)
                exit 5
esac
if [ -n "$local" ];then
        for i in $local
        do
                if [ "$i"  == "$version" ];then
                        if sudo docker ps -a | grep ${docker_name}; then
                           sudo docker rm -f ${docker_name}
                           writelog "rm docker ${docker_name}" $? 1
                        fi
                        $docker_run
                        writelog "run docker ${docker_name}" $? 1
                        break
                else
                        sudo docker pull ${image_name}:$version
                        writelog "pull ${image_name}:$version" $? 1
                        if sudo docker ps -a | grep ${docker_name}; then
                           sudo docker rm -f ${docker_name}
                           writelog "rm docker ${docker_name}" $? 1
                        fi
                        $docker_run
                        writelog "run docker ${docker_name}" $? 1
                        break
                fi
        done
else
        sudo docker pull ${image_name}:$version
        writelog "pull ${image_name}:$version" $? 1
        sudo $docker_run
        writelog "run docker ${docker_name}" $? 1
fi
}


#判断函数
case $1 in
api)
run_docker $image_api $2 $3
;;
settlement2)
run_docker $image_settlement $2 $3
;;
settlement1)
run_docker $image_settlement $2
;;
cld_admin)
run_docker $image_cld_admin $2 $3
;;
back_admin)
run_docker $image_back_admin $2 $3
;;
data)
run_docker $image_data $2
;;
pay_platform_admin)
run_docker $image_pay_platform_admin $2 $3
;;
pay_site_api)
run_docker $image_pay_site_api $2 $3
;;
pay_platform_api)
run_docker $image_pay_platform_api $2 $3
;;
*)
exit 0
;;
esac