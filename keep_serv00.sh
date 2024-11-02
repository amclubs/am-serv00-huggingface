#!/bin/bash

# 定义颜色代码
green="\033[32m"
yellow="\033[33m"
red="\033[31m"
purple() { echo -e "\033[35m$1\033[0m"; }
re="\033[0m"

# 打印欢迎信息
echo ""
purple "=== serv00 | AM科技 一键保活脚本 ===\n"
echo -e "${green}脚本地址：${re}${yellow}https://github.com/amclubs/am-serv00-huggingface${re}\n"
echo -e "${green}个人博客：${re}${yellow}https://am.809098.xyz${re}\n"
echo -e "${green}TG反馈群组：${re}${yellow}https://t.me/AM_CLUBS${re}\n"
purple "=== 转载请著名出处 AM科技，请勿滥用 ===\n"

base_url="https://raw.githubusercontent.com/amclubs"

# 配置服务器，格式为：["IP/域名,用户名,密码"]="s5(socket5标识符),端口1;vmess(服务标识符),端口2,Argo隧道域名,Argo隧道token或json;nezha-dashboard(服务标识符),端口3"
declare -A servers=(
	["s8.serv00.com,username1,password1"]="s5,10000"
	["s8.serv00.com,username2,password2"]="s5,20000"
    ["s11.serv00.com,username3,password3"]="s5,30000;vmess,40000,vmess.abc.xyz,GN0TldJNU9URXhOV05qWm1NMiJ9"	
)

# 最大检测失败次数
max_fail=3

# 获取脚本 URL
get_script_url() {
    case $1 in
        s5) echo "${base_url}/am-serv00-socks5/main/am_restart_s5.sh" ;;
        vmess) echo "${base_url}/am-serv00-vmess/main/am_restart_vmess.sh" ;;
        nezha-dashboard) echo "${base_url}/am-serv00-nezha/main/am_restart_dashboard.sh" ;;
        #nezha-agent) echo "${base_url}/am-serv00-nezha/main/am_restart_agent.sh" ;;	
	x-ui) echo "${base_url}/am-serv00-x-ui/main/am_restart_x_ui.sh" ;;
        *) echo "${base_url}/am-serv00-socks5/main/am_restart_s5.sh" ;;
    esac
}

# 检查端口是否打开
check_port() {
    nc -zv "$1" "$2" >/dev/null 2>&1
}

# 检查 Argo 隧道是否在线
check_argo() {
    local http_code
	#http_code=$(curl -v -o /dev/null -s -w "%{http_code}" "https://$1")
    http_code=$(curl -o /dev/null -s -w "%{http_code}" "https://$1")

    echo "HTTP Code: $http_code"
    # 如果返回状态码为404，则视为在线
    if [ "$http_code" -eq 404 ]; then
        return 0  # 视为在线
    else
        return 1  # 视为不在线
    fi
}


# 远程执行脚本
execute_remote_script() {
    local script_url token=""
    script_url=$(get_script_url "$4")

    # 如果服务类型是 vmess，设置 token
    if [[ "$4" == "vmess" ]]; then
        token="${5}"  # 传递 token
    fi

    echo "通过 SSH 连接 $2@$1 并执行下载脚本 bash <(curl -Ls $script_url) $token ..."
    sshpass -p "$3" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -tt "$2@$1" "bash <(curl -Ls $script_url) $token"
}

# 打印状态信息
print_status() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${re}"
}

# 遍历每个服务器和服务
for server_info in "${!servers[@]}"; do
    IFS=',' read -r server username password <<< "$server_info"
    IFS=';' read -ra services <<< "${servers[$server_info]}"

    for service_info in "${services[@]}"; do
        IFS=',' read -ra ports <<< "$service_info"
        
        if [[ ${#ports[@]} -eq 4 ]]; then
            # vmess 服务
            service=${ports[0]}
            port=${ports[1]}
            argo_domain=${ports[2]}
            token=${ports[3]}
        else
            # s5 服务
            service=${ports[0]}
            port=${ports[1]}
            token=""
        fi

        print_status "$re" "检测服务器: $server 用户名: $username 端口: $port 服务: $service ..."

        fail_count=0
        for attempt in {1..3}; do
            if check_port "$server" "$port"; then
                print_status "$green" "端口 $port 在 $server 正常"
                break
            else
                fail_count=$((fail_count + 1))
                print_status "$red" "第 $attempt 次检测失败，端口 $port 不通"
                sleep 5
            fi
        done

		# 在遍历服务的循环中
		if [[ "$service" == "vmess" ]]; then
		    argo_fail_count=0
		    print_status "$re" "开始检测 Argo 隧道..."
		    for argo_attempt in {1..3}; do
				echo "Argo 隧道域名: $argo_domain"
		        if check_argo "$argo_domain"; then
		            print_status "$green" "Argo 隧道在线"
		            break  # 成功检测，退出循环
		        else
		            argo_fail_count=$((argo_fail_count + 1))
		            print_status "$red" "第 $argo_attempt 次检测 Argo 隧道失败"
		            sleep 5
		        fi
		    done

		    # 检查 Argo 隧道的失败次数是否达到了最大值
		    if [[ $argo_fail_count -eq $max_fail ]]; then
		        print_status "$red" "Argo 隧道状态: 连续 $max_fail 次检测失败"
		    fi
		fi

        # 如果端口检测或 Argo 隧道连续失败，执行远程操作
        if [[ $fail_count -eq $max_fail ]] || [[ "$service" == "vmess" && $argo_fail_count -eq $max_fail ]]; then
            print_status "$red" "服务器状态: $server 用户名: $username 端口: $port 服务: $service 连续 $max_fail 次检测失败，执行远程操作..."
            execute_remote_script "$server" "$username" "$password" "$service" "$token"
            print_status "$green" "执行远程操作完毕"
        else
            print_status "$re" "服务器状态: $server 用户名: $username 端口: $port 服务: $service 检测成功"
        fi

        echo "----------------------------"
    done
done

print_status "$re" "所有服务器检测完毕"
