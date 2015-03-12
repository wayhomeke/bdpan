#!/bin/bash
BDPAN_HOME=$(cd $(dirname $BASH_SOURCE) && pwd)
eval $(cat $BDPAN_HOME/user.conf)
FAKE_AGENT='User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.38'
if [[  "X$ppass" == "X" ]]
then
	puser=$1
	ppass=$2
fi

echo TMP dir is set to  ${TMP="/tmp/"}
echo download dir is set to ${DOWNLOAD="/tmp/"}

tt=$(date +%s)

curl -k  -c $BDPAN_HOME/pan.cks "http://pan.baidu.com/" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Connection: keep-alive" -H "Accept-Encoding: deflate" -H "Host: pan.baidu.com" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "$FAKE_AGENT"  >/dev/null 2>&1


curl -k  -c $BDPAN_HOME/pan.cks -b $BDPAN_HOME/pan.cks "https://passport.baidu.com/v2/api/?getapi&tpl=netdisk&apiver=v3&tt=${tt}&class=login&logintype=basicLogin&callback=bd__cbs__rdlhdi" -H "Accept-Encoding: deflate" -H "Host: passport.baidu.com" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "$FAKE_AGENT" -H "Accept: */*" -H "Referer: http://pan.baidu.com/"  -H "Connection: keep-alive" >${TMP}pan.tk 2>/dev/null

eval $(sed -e 's/:/=/g' -e 's/,/\n/g' -e 's/"//g' -e 's/ //g' ${TMP}pan.tk|grep token)

curl -k  -c $BDPAN_HOME/pan.cks -b $BDPAN_HOME/pan.cks  "https://passport.baidu.com/v2/getpublickey?token=${token}&tpl=netdisk&apiver=v3&tt=${tt}&callback=bd__cbs__bytphu" -H "Accept-Encoding: deflate" -H "Host: passport.baidu.com" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "$FAKE_AGENT" -H "Accept: */*" -H "Referer: http://pan.baidu.com/" -H "Connection: keep-alive" >${TMP}rsa.tk 2>/dev/null


eval $(sed -e 's/:/=/g' -e 's/,/\n/g' -e 's/"//g' -e 's/})//g'  ${TMP}rsa.tk|grep key)
echo |awk '{print "'"$pubkey"'"}' >${TMP}pankey.pub 2>/dev/null
passrsa=`perl -MURI::Escape -e 'print URI::Escape::uri_escape($ARGV[0])' "$(echo -ne "$ppass"|openssl rsautl -encrypt -pubin -inkey ${TMP}pankey.pub|base64 --wrap=0)"`


curl -k  -c $BDPAN_HOME/pan.cks -b $BDPAN_HOME/pan.cks  "https://passport.baidu.com/v2/api/?login"  -H "Accept-Encoding: deflate" -H "Host: passport.baidu.com" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "$FAKE_AGENT" -H "Content-Type: application/x-www-form-urlencoded" -H "Cache-Control: max-age=0" -H "Referer: http://pan.baidu.com/" -H "Connection: keep-alive" --data "staticpage=http%3A%2F%2Fpan.baidu.com%2Fres%2Fstatic%2Fthirdparty%2Fpass_v3_jump.html&charset=utf-8&token=${token}&tpl=netdisk&subpro=&apiver=v3&tt=${tt}&codestring=&safeflg=0&u=http%3A%2F%2Fpan.baidu.com%2F&isPhone=&quick_user=0&logintype=basicLogin&logLoginType=pc_loginBasic&idc=&loginmerge=true&username=$puser&password=${passrsa}&verifycode=&mem_pass=on&rsakey=${key}&crypttype=12&ppui_logintime=473523&callback=parent.bd__pcbs__y438yl"  >/${TMP}out.tmp 2>/dev/null

curl -k   -c $BDPAN_HOME/pan.cks -b $BDPAN_HOME/pan.cks   "http://pan.baidu.com/disk/home" -H "Accept-Encoding: deflate" -H "Host: pan.baidu.com" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "$FAKE_AGENT" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Referer: http://pan.baidu.com/"  >${TMP}pan.html  2>/dev/null

curl -k   -c $BDPAN_HOME/pan.cks -b $BDPAN_HOME/pan.cks  "http://pcs.baidu.com/rest/2.0/pcs/file?method=plantcookie&type=ett" -H "Accept-Encoding: deflate" -H "Host: pcs.baidu.com" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "$FAKE_AGENT" -H "Accept: image/webp,*/*;q=0.8" -H "Referer: http://pan.baidu.com/disk/home"  >${TMP}platcookie.out 2>/dev/null

