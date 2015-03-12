#!/bin/bash

fsid=$1
BDPAN_HOME=$(cd $(dirname $BASH_SOURCE) && pwd)
FAKE_AGENT='User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.38'
##load config
eval $(cat $BDPAN_HOME/user.conf)

echo TMP dir is set to  ${TMP="/tmp/"}
echo download dir is set to ${DOWNLOAD="/tmp/"}


cd $BDPAN_HOME;
curl -k -c $BDPAN_HOME/pan.cks -b $BDPAN_HOME/pan.cks "http://pan.baidu.com/wap/view?fsid=${fsid}" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "$FAKE_AGENT"  -H "Accept: */*"  >$TMP/a.html 2>/dev/null

if ! grep -q "$puser" $TMP/a.html
then
	sh pan_login.sh
        curl -k -c pan.cks -b pan.cks "http://pan.baidu.com/wap/view?fsid=${fsid}" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "$FAKE_AGENT"  -H "Accept: */*"  >$TMP/a.html
fi 

curl -k  -c pan.cks -b pan.cks  "http://pcs.baidu.com/rest/2.0/pcs/file?method=plantcookie&type=ett" -H "Accept-Encoding: deflate" -H "Host: pcs.baidu.com" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "$FAKE_AGENT" -H "Accept: image/webp,*/*;q=0.8" -H "Referer: http://pan.baidu.com/disk/home"  >$TMP/platcookie.out 2>/dev/null

eval "$(cat $TMP/a.html |grep sign3| sed  's/.*sign1=\("[^"]*"\);.*sign3=\("[^"]*"\);.*/r=\1;\nj=\2;\n/')"
sign3="$(perl -MURI::Escape -e 'print URI::Escape::uri_escape($ARGV[0])' $(bash $BDPAN_HOME/sign.sh "$j" "$r"|base64 --wrap=0))"


tt=$(cat $TMP/a.html |grep timest |sed 's/;/\n/g'|grep viewsingle_param.time|awk -F'"' '{print $2}')

curl -k "http://pan.baidu.com/api/download"  -b $BDPAN_HOME/pan.cks -H "Origin: http://pan.baidu.com"  -H "Host: pan.baidu.com" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "$FAKE_AGENT" -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: */*" -H "Referer: http://pan.baidu.com/wap/view?fsid=${fsid}" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive" --data "sign=$sign3&timestamp=$tt&fidlist="%"5B"%"22${fsid}"%"22"%"5D&type=dlink" >$TMP/dlink.html 2>/dev/null

eval "$(cat $TMP/dlink.html |sed -e 's/,/\n/g' -e 's/":/"=/g' -e 's/}]}//g' -e 's/"dlink"/dlink/g'|grep http)"
dlk=$(echo |awk '{print "'"$dlink"'"}' 2>/dev/null)

curl -k "http://pcs.baidu.com/rest/2.0/pcs/file?method=plantcookie&type=ett" -c $BDPAN_HOME/pan.cks  -b $BDPAN_HOME/pan.cks    -H "Host: pcs.baidu.com" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "$FAKE_AGENT" -H "Accept: image/webp,*/*;q=0.8" -H "Referer: http://pan.baidu.com/wap/view?fsid=$fsid"  -H "Connection: keep-alive" -H "Cache-Control: max-age=0" 

cd $DOWNLOAD
curl -k -I -b $BDPAN_HOME/pan.cks -H 'User-Agent: netdisk;5.1.0.6;PC;PC-Windows;6.1.7601;WindowsBaiduYunGuanJia' "$dlk" >$TMP/head.log 2>/dev/null
tdlk=$(cat $TMP/head.log|awk '/Location/{print $2}')

if [[ "X$tdlk" == "X" ]]
then
    tdlk=$dlk
fi

eval $(echo "$tdlk"|sed 's/&/\n/g'|grep fin|sed -e 's/=/="/' -e 's/$/"/')

if echo "$fin"|grep   -q torrent
then
	echo Torrent file skiped...
fi

aria2c -c --file-allocation=none --header="User-Agent: netdisk;5.1.0.6;PC;PC-Windows;6.1.7601;WindowsBaiduYunGuanJia" --load-cookies=$BDPAN_HOME/pan.cks -x5 -s5 "$tdlk"  -o "${DOWNLOAD}/$fin"
