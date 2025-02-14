# [am-serv00-huggingface](https://github.com/amclubs/am-serv00-huggingface)
通过huggingface部署青龙面板,实现serv00、socks5、vmess节点等在serv00里部署的程序保活

#
▶️ **新人[YouTube](https://youtube.com/@am_clubs?sub_confirmation=1)** 需要您的支持，请务必帮我**点赞**、**关注**、**打开小铃铛**，***十分感谢！！！*** ✅
</br>🎁请 **follow** 我的[GitHub](https://github.com/amclubs)、给我所有项目一个 **Star** 星星（拜托了）！你的支持是我不断前进的动力！ 💖
</br>✅**解锁更多技能** [加入TG群【am_clubs】](https://t.me/am_clubs)、[YouTube频道【@am_clubs】](https://youtube.com/@am_clubs?sub_confirmation=1)、[【博客(国内)】](https://amclubss.com)、[【博客(国际)】](https://amclubs.blogspot.com) 
</br>✅点击观看教程[CLoudflare免费节点](https://www.youtube.com/playlist?list=PLGVQi7TjHKXbrY0Pk8gm3T7m8MZ-InquF) | [VPS搭建节点](https://www.youtube.com/playlist?list=PLGVQi7TjHKXaVlrHP9Du61CaEThYCQaiY) | [获取免费域名](https://www.youtube.com/playlist?list=PLGVQi7TjHKXZGODTvB8DEervrmHANQ1AR) | [免费VPN](https://www.youtube.com/playlist?list=PLGVQi7TjHKXY7V2JF-ShRSVwGANlZULdk) | [IPTV源](https://www.youtube.com/playlist?list=PLGVQi7TjHKXbkozDYVsDRJhbnNaEOC76w) | [Mac和Win工具](https://www.youtube.com/playlist?list=PLGVQi7TjHKXYBWu65yP8E08HxAu9LbCWm) | [AI分享](https://www.youtube.com/playlist?list=PLGVQi7TjHKXaodkM-mS-2Nwggwc5wRjqY)

 - [点击观看视频教程 ](https://youtu.be/J4lcIwBowmM)

## 一、需要准备的前提资料
### 1、注册**Serv00**账号，建议使用**Gmail**邮箱
- 注册地址：https://serv00.com
<a href="https://youtu.be/NET1FTlfDTs">[点击观看视频教程]</a>

### 2、**SSH**连接工具(可选)
- 加入TG群[AM科技｜分享交流群](https://t.me/AM_CLUBS)发送关键字: ssh

### 3、注册**huggingface**账号
- 注册地址：https://huggingface.co

### 4、注册**onedrive**账号
- 注册地址：[点击进入onedrive官网](https://onedrive.live.com/login) 
<a href="https://youtu.be/ZyGpSRYAr4Q">[点击观看视频教程]</a>

## 二、安装青龙面板

- 1、登录**huggingface**

- 2、创建**space** 名称如: **qinglong**

- 3、修改**README.md**文件,增加端口变量**app_port**
```
app_port: 5700
```

- 4、在 **settings** 下 **Variables and secrets** 点 **New secret** 增加相关变量
**注意：环境变量是secrets类型,千万不要选错**

`①` **USERNAME**变量
```
admin
```
`②` **PASSWORD**变量(自己要设置密码度强一点的)
```
123456
```
`③` **RCLONE_CONF**变量 [**点击视频教程获取**](https://youtu.be/ZyGpSRYAr4Q)
根据上面视频教程获取
```shell
cat ~/.config/rclone/rclone.conf
```
(win系统用不了上面命令,可以使用下面的命令,查看文件路径,然后打开文件)
```shell
./rclone config file
```
根据上面命令获取填自己的,下面只是返回信息格式的例子
```
[huggingface]
type = onedrive
token = {"access_token":"xxx","token_type":"Bearer","refresh_token":"xxx","expiry":"xxx"}
drive_id = xxx
drive_type = personal
```

- 5、上传部署文件 **docker-entrypoint.sh** 、**Dockerfile** 、**npmrc** 、**package.json** 、**pnpm-lock.yaml**
</br><a href="https://raw.amclubss.us.kg/qinglong/docker-entrypoint.sh">[点击下载docker-entrypoint.sh]</a>
</br><a href="https://raw.amclubss.us.kg/qinglong/Dockerfile">[点击下载Dockerfile]</a>
</br><a href="https://raw.amclubss.us.kg/qinglong/npmrc">[点击下载npmrc]</a>
</br><a href="https://raw.amclubss.us.kg/qinglong/package.json">[点击下载package.json]</a>
</br><a href="https://raw.amclubss.us.kg/qinglong/pnpm-lock.yaml">[点击下载pnpm-lock.yaml]</a>
</br>项目地址：https://github.com/amclubs/am-serv00-huggingface

- 6、部署完成后，点击 **settings** 下 **Embed this Space** 找到 **Direct URL** 就是访问地址,如下面
```
https://用户名-space名.hf.space
```


## 三、青龙保活命令设置
- 1、登录青龙面板后,在 定时任务 -> 创建任务
`①`名称自己定义,如: 
```
 serv00保活
```
`②` 创建命令脚本 点击 **脚本管理** -> 右上角点击 **+** 号 创建脚本 -> 选择本地文件 -> 然后上传下载好的**keep_serv00.sh**文件 -> 点 **确认** -> 点 **保存**
<a href="https://raw.amclubss.us.kg/keep_serv00.sh">[点击下载 keep_serv00.sh]</a>
`③` 命令/脚本
```shell
bash keep_serv00.sh
```
`④` 定时规则(这里第1小时检测一次,可以根据自己情况调整)
```shell
0 0 */1 * *
```

- 2、增加手工备份青龙部署文件 **(huggingface有时重启或重置就会重新部署,所以通过备份,重启脚本自动同步数据回来)**
`①`名称自己定义 ,如: 
```
rclone-onedrive
```
`②` 命令/脚本
```shell
rclone sync /ql/data huggingface:/qinglong
```
`③` 定时规则
```shell
0 0 1 * * *
```

- 3、增加cloudflare部署uptime监控服务检查huggingface应用 [**点击视频教程**](https://youtu.be/X03S2HxnniM)

</br>[**点击观看免费部署socks5视频教程**](https://youtu.be/Bw82BH_ecC4)
</br>[**点击观看免费部署vmess节点视频教程**](https://youtu.be/6UZXHfc3zEU)
</br>[**点击观看所有免费节点部署相关视频教程**](https://www.youtube.com/playlist?list=PLGVQi7TjHKXbrY0Pk8gm3T7m8MZ-InquF)


# 
<center>
<details><summary><strong> [点击展开] 赞赏支持 ~🧧</strong></summary>
*我非常感谢您的赞赏和支持，它们将极大地激励我继续创新，持续产生有价值的工作。*

- **USDT-TRC20:** `TWTxUyay6QJN3K4fs4kvJTT8Zfa2mWTwDD`
- **TRX-TRC20:** `TWTxUyay6QJN3K4fs4kvJTT8Zfa2mWTwDD`

<div align="center"> 
  <img src="https://github.com/user-attachments/assets/e6cdc42a-6374-4722-b833-601738f72196" width="200"></br> 
  TRC10/TRC20扫码支付 
</div> 
</details>
</center>

 #
 免责声明:
 - 1、该项目设计和开发仅供学习、研究和安全测试目的。请于下载后 24 小时内删除, 不得用作任何商业用途, 文字、数据及图片均有所属版权, 如转载须注明来源。
 - 2、使用本程序必循遵守部署服务器所在地区的法律、所在国家和用户所在国家的法律法规。对任何人或团体使用该项目时产生的任何后果由使用者承担。
 - 3、作者不对使用该项目可能引起的任何直接或间接损害负责。作者保留随时更新免责声明的权利，且不另行通知。
 
 
 
