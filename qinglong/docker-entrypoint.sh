#!/bin/bash

dir_shell=/ql/shell
. $dir_shell/share.sh
. $dir_shell/env.sh

echo -e "======================1. 检测配置文件========================\n"
import_config "$@"
make_dir /etc/nginx/conf.d
make_dir /run/nginx
init_nginx
fix_config

pm2 l &>/dev/null

echo -e "======================2. 安装依赖========================\n"
patch_version

echo -e "======================3. 启动nginx========================\n"
nginx -s reload 2>/dev/null || nginx -c /etc/nginx/nginx.conf
echo -e "nginx启动成功...\n"

echo -e "======================4. 启动pm2服务========================\n"
reload_update
reload_pm2

if [[ $AutoStartBot == true ]]; then
  echo -e "======================5. 启动bot========================\n"
  nohup ql bot >$dir_log/bot.log 2>&1 &
  echo -e "bot后台启动中...\n"
fi

if [[ $EnableExtraShell == true ]]; then
  echo -e "====================6. 执行自定义脚本========================\n"
  nohup ql extra >$dir_log/extra.log 2>&1 &
  echo -e "自定义脚本后台执行中...\n"
fi

echo -e "======================7. 写入rclone配置========================\n"
echo "$RCLONE_CONF" > ~/.config/rclone/rclone.conf

echo -e "############################################################\n"
echo -e "容器启动成功..."
echo -e "############################################################\n"


echo -e "##########8. 写入登陆信息 ############"
echo "{ \"username\": \"$USERNAME\", \"password\": \"$PASSWORD\" }" > /ql/data/config/auth.json

echo -e "##########9. 同步备份信息 ############"
if [ -n "$RCLONE_CONF" ]; then
  echo -e "########## Synchronizing Backup ############"
  
  # Specify the remote folder path in the format remote:path
  REMOTE_FOLDER="huggingface:/qinglong"
  
  # Use rclone ls command to list folder contents, capturing output and errors
  OUTPUT=$(rclone ls "$REMOTE_FOLDER" 2>&1)
  
  # Get the exit status code of the rclone command
  EXIT_CODE=$?
  
  case $EXIT_CODE in
    0) 
      # rclone command executed successfully, check if the folder is empty
      if [ -z "$OUTPUT" ]; then
        echo "Initial installation"
		#rclone sync /ql/data $REMOTE_FOLDER
      else
        mkdir -p /ql/.tmp/data
        rclone sync "$REMOTE_FOLDER" /ql/.tmp/data && real_time=true ql reload data
      fi
      ;;
    1)
      # Handle other errors, check if it was a directory not found error
      if [[ "$OUTPUT" == *"directory not found"* ]]; then
        echo "Error: Folder does not exist"
      else
        echo "Error: $OUTPUT"
      fi
      ;;
    *)
      echo "Error: rclone command failed, exit code: $EXIT_CODE"
      ;;
  esac
else
  echo "No Rclone configuration detected"
fi


tail -f >/dev/null

exec "$@"
