# bdpan
#wayhomeke#gmail.com


require  URI::Escape/nodejs/openssl/aria2


这是一个模拟登陆百度云，按日期下载文件脚本
依赖一个perl模块URI::Escape,和服务器跑js的工具nodejs，密钥加密用的openssl

别人有一个功能写得更好的脚本叫bypy的，在github自己搜
但是是要授权他的应用……简单点说……就是把你的网盘给他……
于是有了这么一个脚本，很简单就是为了我的htpc能自动把网盘文件同步回来。

配置在user.conf,配置用户名和密码还有下载目录，没有了
配置好，登录一下：
sh pan_login.sh
生成某天的下载列表：
sh get-day-list.sh 2015-02-02
把列表下载回来：
for i in $(cat /tmp/dlid.list)
do
  sh download-fsid.sh $i
done
