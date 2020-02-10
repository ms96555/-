#!/bin/bash
#sudo echo $(date +%Y%m%d%H%M) >> /opt/project/del_efs_log.log

SHELL_LOG="/opt/project/del_efs_log.log"
#删除mtime=天 mmin=分
SHELL_NAME="$0"
LOCK_FILE="/tmp/${SHELL_NAME}.LOK"
writelog(){
        local LOGINFO=$1
                local AETVAL=$2
        local IS_EXIT=$3
        local IS_UNLOCK=$4
        LDATA=$(date +%F)
        LTIME=$(date +%H-%M-%S)
        if [ $AETVAL -eq 0 ]
        then
                sudo echo "${LDATA} : $LTIME : ${SHELL_NAME} : ${LOGINFO} : Success" >>$SHELL_LOG
                #echo  "${LDATA} : $LTIME : ${SHELL_NAME} : ${LOGINFO} Success"
        else
               sudo echo "${LDATA} : $LTIME : ${SHELL_NAME} : ${LOGINFO} : Fail" >>$SHELL_LOG
               # echo "${LDATA} : $LTIME : ${SHELL_NAME} : ${LOGINFO} Fail"
                if [ $IS_EXIT -eq 1 -a $IS_UNLOCK -eq 1 ]
                then
                    sudo echo "1" > /var/run/del_efs_status.log
                                        shell_unlock
                    exit 5
                elif [ $IS_EXIT -eq 1 -a $IS_UNLOCK -eq 0 ]
                then
                                        sudo echo "1" > /var/run/del_efs_status.log
                                        exit 5
                                fi
        fi

}

shell_lock(){
    touch $LOCK_FILE
}

shell_unlock(){
    rm -rf $LOCK_FILE
}
writelog "$SHELL_NAME Is begin" 0 0 0
if [ -e $LOCK_FILE ];then
        writelog "$SHELL_NAME Is running" 1 1 0
else
        shell_lock
        bet_dir='/efs/bet_dir'
        sudo find $bet_dir \( -name "*.log" -a -mtime +3 \) -o \( -name "*.dat" -a -mtime +3 \) | awk '{print "usleep 100;rm -rf "$1}'|bash
        writelog "del $bet_dir log and dat file " $? 0 0

        lottery_bet_dir='/efs/lottery_bet_dir'
        sudo find $lottery_bet_dir \( -name "*.log" -a -mmin +120 \) -o \( -name "*.dat" -a -mtime +3 \) | awk '{print "usleep 100;rm -rf "$1}'|bash
        writelog "del $lottery_bet_dir dat and log file " $? 0 0

        lottery_bet_dir='/efs/test_env/lottery_bet_dir'
        sudo find $lottery_bet_dir \( -name "*.log" -a -mtime +3 \) -o \( -name "*.dat" -a -mtime +3 \) | awk '{print "usleep 100;rm -rf "$1}'|bash
        writelog "del $lottery_bet_dir log and dat file " $? 0 0

        lottery_bet_dir='/efs/test_env/bet_dir'
        sudo find $lottery_bet_dir \( -name "*.log" -a -mtime +3 \) -o \( -name "*.dat" -a -mtime +3 \) | awk '{print "usleep 100;rm -rf "$1}'|bash
        writelog "del $lottery_bet_dir dat and log file " $? 0 0

        lottery_bet_dir='/efs/live_bet_dir'
        sudo find $lottery_bet_dir -name "*.log" -type f -mtime +1  -delete
        writelog "del $lottery_bet_dir dat file " $? 0 0
        shell_unlock
        echo "0" > /var/run/del_efs_status.log
        writelog "$SHELL_NAME Is finish" 0 1 1
fi