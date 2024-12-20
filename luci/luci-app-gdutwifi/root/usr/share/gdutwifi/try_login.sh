#!/bin/sh

mkdir -p /tmp/gdutwifi

#如果无参数
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 -i <interface> -u <username> -p <password> -l <log_prefix> -s <manully set ip> -w <wlan_ac_ip> -m <monitor api>"
    exit 1
fi

# 解析参数
while getopts "a:i:u:p:s:l:w:m:" opt; do
    case $opt in
        a) AUTH_SERVER="$OPTARG" ;;
        c) COMFIRM_LOGIN="1" ;;
        i) INTERFACE="$OPTARG" ;;
        u) USERNAME="$OPTARG" ;;
        p) PASSWORD="$OPTARG" ;;
        s) WLAN_USER_IP="$OPTARG" ;;
        l) LOG_FILE_PREFIX="$OPTARG" ;;
        w) WLAN_AC_IP="$OPTARG" ;;
        m) MONITOR_API="$OPTARG" ;;
        *) echo "Invalid option"; exit 1 ;;
    esac
done
# AUTH_SERVER USERNAME PASSWORD WLAN_AC_IP is required
if [ -z "$AUTH_SERVER" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$WLAN_AC_IP" ]; then
    echo "Usage: $0 -i <interface> -u <username> -p <password> -l <log_prefix> -s <manully set ip> -w <wlan_ac_ip> -m <monitor api>"
    printf '{"original_response": "Missing required parameters;auth_server:%s username:%s password:%s wlan_ac_ip:%s", "status": 0, "timestamp": "%s", "time": "%s"}' "$AUTH_SERVER" "$USERNAME" "$PASSWORD" "$WLAN_AC_IP" "$(date +%s)" "$(date "+%Y-%m-%d %H:%M:%S")" > /tmp/gdutwifi/"${LOG_FILE_PREFIX}_status"
    exit 1
fi

if [ -z "$WLAN_USER_IP" ];then
    # 获取接口的 L3 设备和 IP 地址
    L3_DEVICE=$(ifstatus "$INTERFACE" |jq -r .l3_device)
    WLAN_USER_IP=$(ip -4 -o addr show dev "$L3_DEVICE" | awk '{print $4}' | cut -d'/' -f1)
    [ -z "$LOG_FILE_PREFIX" ] && LOG_FILE_PREFIX="$INTERFACE"
else
    [ -z "$LOG_FILE_PREFIX" ] && LOG_FILE_PREFIX="$WLAN_USER_IP"
fi
#MONITOR_URL_1 0: online, 1: offline, 2: already online 4: AC Error
MONITOR_URL_1="http://%s:801/eportal/portal/login?user_password=0&wlan_ac_ip=%s&user_account=1&wlan_user_ip=%s"
MONITOR_URL_1=$(printf "$MONITOR_URL_1" "$AUTH_SERVER" "$WLAN_AC_IP" "$WLAN_USER_IP")
#MONITOR_URL_2 0: offline, 1: online
MONITOR_URL_2="http://%s/drcom/chkstatus?callback=dr1002"
MONITOR_URL_2=$(printf "$MONITOR_URL_2" "$AUTH_SERVER")
#LOGIN_URL 0: failed, 1: success
LOGIN_URL="http://%s:801/eportal/portal/login?user_password=%s&wlan_ac_ip=%s&user_account=%s&wlan_user_ip=%s"
LOGIN_URL=$(printf "$LOGIN_URL" "$AUTH_SERVER" "$PASSWORD" "$WLAN_AC_IP" "$USERNAME" "$WLAN_USER_IP" )
#COMFIRM_LOGIN_ULL 1: success
COMFIRM_LOGIN_ULL="http://%s:801/eportal/portal/custom/operator?callback=dr1003&account=%s&r=1&jsVersion=4.1.3&v=7993&lang=en"
COMFIRM_LOGIN_ULL=$(printf "$COMFIRM_LOGIN_ULL" "$AUTH_SERVER" "$USERNAME")
_match_json() {
    #匹配括号中的内容，移除控制字符
    echo "$1" | cut -d'(' -f2 |cut -d')' -f1 | tr -d '\n' | tr -d '\r' | tr -d '\t' | tr -d '\b' | tr -d '\f' | tr -d '\v'
}



# 检查是否在线

# 发送请求并获取返回结果

if [ -n "$L3_DEVICE" ] && [ "$MONITOR_API" -eq 2 ]; then
    RESPONSE=$(curl -s "$MONITOR_URL_2" --interface "$L3_DEVICE" | strings) 
    RESPONSE=$(_match_json "$RESPONSE")
    RES=$(echo "$RESPONSE" | jq -r .result)
    V46IP=$(echo "$RESPONSE" |jq -r .v46ip)
    # 0: offline, 1: online
    if [ "$RES" -eq 0 ]; then
        MSG="IP:$V46IP"
        RET_CODE=1
    else
        MSG="IP:$V46IP"
        RET_CODE=2
    fi
elif [ -n "$L3_DEVICE" ]; then
    RESPONSE=$(curl -s "$MONITOR_URL_1" --interface "$L3_DEVICE")
    RESPONSE=$(_match_json "$RESPONSE")
    RET_CODE=$(echo "$RESPONSE" | jq -r .ret_code) 
    MSG=$(echo "$RESPONSE" | jq -r .msg)
else
    RESPONSE=$(curl -s "$MONITOR_URL_1")
    RESPONSE=$(_match_json "$RESPONSE")
    RET_CODE=$(echo "$RESPONSE" | jq -r .ret_code) 
    MSG=$(echo "$RESPONSE" | jq -r .msg)
fi

# 当前时间戳
TIMESTAMP=$(date +%s)
# 当前时间
TIME=$(date "+%Y-%m-%d %H:%M:%S")

# 处理返回结果
if [ "$RET_CODE" -eq 2 ]; then
    # 已经在线
    STATUS_JSON=$(printf '{"original_response": "%s", "status": %d, "timestamp": "%s", "time": "%s"}' "$MSG" "$RET_CODE" "$TIMESTAMP" "$TIME")
elif [ "$RET_CODE" -eq 4 ];then
    STATUS_JSON=$(printf '{"original_response": "%s", "status": %d, "timestamp": "%s", "time": "%s"}' "$MSG" "$RET_CODE" "$TIMESTAMP" "$TIME")
elif [ "$RET_CODE" -eq 1 ]; then
    
    # 尝试登录
    if [ -n "$L3_DEVICE" ]; then
        [ -n "$COMFIRM_LOGIN" ] && COMFIRM_RESPONSE=$(curl -s "$COMFIRM_LOGIN_ULL" --interface "$L3_DEVICE")
        LOGIN_RESPONSE=$(curl -s "$LOGIN_URL" --interface "$L3_DEVICE")
    else
        [ -n "$COMFIRM_LOGIN" ] && COMFIRM_RESPONSE=$(curl -s "$COMFIRM_LOGIN_ULL")
        LOGIN_RESPONSE=$(curl -s "$LOGIN_URL")
    fi
    [ -n "$COMFIRM_LOGIN" ] &&COMFIRM_RESPONSE=$(_match_json "$COMFIRM_RESPONSE")
    LOGIN_RESPONSE=$(_match_json "$LOGIN_RESPONSE")
    LOGIN_RESULT=$(echo "$LOGIN_RESPONSE" | jq -r .result) #0: failed, 1: success
    LOGIN_MSG=$(echo "$LOGIN_RESPONSE" | jq -r .msg)

    LOGIN_JSON=$(printf '{"original_response": "%s", "status": %d, "timestamp": "%s", "time": "%s"}' "$LOGIN_MSG" "$LOGIN_RESULT" "$TIMESTAMP" "$TIME")
    echo "$LOGIN_JSON" > /tmp/gdutwifi/"${LOG_FILE_PREFIX}_login"
fi

# 写入状态到文件
echo "$STATUS_JSON" > /tmp/gdutwifi/"${LOG_FILE_PREFIX}_status"

exit 0
