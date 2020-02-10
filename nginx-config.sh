#!/bin/bash
CONFIG_DIR=/opt/lnmp/nginx/conf/vhost
CONFIG_ORG_DIR=/opt/lnmp/nginx/conf/vhost-org
TMP_DIR=/opt/lnmp/nginx/conf/vhost-tmp
INDEX_DIR=/opt/project/code

backup(){
        if [ ! -e $TMP_DIR ]
        then
                sudo cp -R -f $CONFIG_DIR $TMP_DIR
        fi

        CONFIG_NAMES=`find $TMP_DIR -name *.conf`
        echo $CONFIG_NAMES
        for CONFIG_NAME in $CONFIG_NAMES
        do
                SITE_NAME=`echo $CONFIG_NAME|awk -F '/' '{if (NF==8) {print $(NF-1)}}'`
                if [ -n $SITE_NAME ]
                then
                        INDEX_FILE=$INDEX_DIR/$SITE_NAME/index
                        cat $CONFIG_NAME | egrep "^server|^[ \t]*listen|^[ \t]*server_name" >/tmp/nginx_tmp.conf
                        echo -e "\r\n\tlocation /{\r\n\t\t\troot\t$INDEX_FILE;\r\n\t\t\tindex\tindex.htm;\r\n\t\t}\r\n}" >>/tmp/nginx_tmp.conf
                        sudo cat /tmp/nginx_tmp.conf > $CONFIG_NAME
                fi

        done
}

maintain(){
        if [ ! -e $TMP_DIR ]
        then
                echo "nginx config is no backup please run $0 backup!" 
                exit 1
        fi
        if [ ! -e $CONFIG_ORG_DIR ]
        then
                sudo mv $CONFIG_DIR $CONFIG_ORG_DIR
                if [ $? -eq 0 ]
                then
                        sudo mv $TMP_DIR $CONFIG_DIR && sudo /opt/lnmp/nginx/sbin/nginx -s reload && echo "The server nginx config to maintain mode OK"
                else
                        echo "nginx config back original fial"
                        exit 2
                fi
        else
                echo "nginx org config is exist,please confirm"
                exit 1
        fi

}

rollback(){
        if [ ! -e $CONFIG_ORG_DIR ]
        then
                echo "nginx config is no maintain please run $0 maintain!"  
                exit 1
        fi
        if [ ! -e $TMP_DIR ]
        then
                sudo mv $CONFIG_DIR $TMP_DIR && sudo mv $CONFIG_ORG_DIR $CONFIG_DIR && sudo /opt/lnmp/nginx/sbin/nginx -s reload && echo "The server nginx config rollback OK"
        else
                sudo rm -rf $TMP_DIR && sudo mv $CONFIG_DIR $TMP_DIR && sudo mv $CONFIG_ORG_DIR $CONFIG_DIR && sudo /opt/lnmp/nginx/sbin/nginx -s reload && echo "The server nginx config rollback OK"
        fi
        sudo chown -R centos.centos $CONFIG_DIR

}

case $1 in
        backup)
                backup
        ;;
        maintain)
                maintain
        ;;
        rollback)
                rollback
        ;;
        *)
                echo "usage: $0 [backup|maintain|rollback]"
                exit 1
        ;;
esac
