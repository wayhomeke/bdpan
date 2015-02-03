#!/bin/bash

fsid=$1

curl -c pan.cks -b pan.cks "http://pan.baidu.com/wap/view?fsid=${fsid}" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36"  -H "Accept: */*"  >/tmp/a.html 2>/dev/null

if ! grep -q wayhomeke /tmp/a.html
then
	sh pan_login.sh
        curl -c pan.cks -b pan.cks "http://pan.baidu.com/wap/view?fsid=${fsid}" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36"  -H "Accept: */*"  >/tmp/a.html
fi 

curl  -c pan.cks -b pan.cks  "http://pcs.baidu.com/rest/2.0/pcs/file?method=plantcookie&type=ett" -H "Accept-Encoding: deflate" -H "Host: pcs.baidu.com" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36" -H "Accept: image/webp,*/*;q=0.8" -H "Referer: http://pan.baidu.com/disk/home"  >/tmp/platcookie.out 2>/dev/null

cat /tmp/a.html |grep sign3| sed  's/.*sign1=\("[^"]*"\);.*sign3=\("[^"]*"\);.*/r=\1;\nj=\2;\n/' >getsign2.js
tt=$(cat /tmp/a.html |grep timest |sed 's/;/\n/g'|grep viewsingle_param.time|awk -F'"' '{print $2}')
echo $(date +%s)
cat sign2.js >>getsign2.js

sign3=`perl -MURI::Escape -e 'print URI::Escape::uri_escape($ARGV[0])' "$(/home/wayhome/download/node-v0.10.35-linux-x64/bin/node getsign2.js)"`

#sign3="$(/home/wayhome/download/node-v0.10.35-linux-x64/bin/node getsign2.js)"

#curl -c pan.cks -b pan.cks "http://pan.baidu.com/api/download" -H "Origin: http://pan.baidu.com" -H "Accept-Encoding: deflate" -H "Host: pan.baidu.com" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: */*" -H "Referer: http://pan.baidu.com/wap/view?fsid=${fsid}"  --data "sign=$sign3&timestamp=$tt&fidlist=[\"$fsid\"]&type=dlink" >/tmp/dlink.html 2>/dev/null

curl "http://pan.baidu.com/api/download"  -b $BDPAN_HOME/pan.cks -H "Origin: http://pan.baidu.com" -H "Accept-Encoding: gzip,deflate,sdch" -H "Host: pan.baidu.com" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36" -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: */*" -H "Referer: http://pan.baidu.com/wap/view?fsid=103315380517772" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive" --data "sign=$sign3&timestamp=$tt&fidlist="%"5B"%"22${fsid}"%"22"%"5D&type=dlink" --compressed >/tmp/dlink.html 2>/dev/null

eval "$(cat /tmp/dlink.html |sed -e 's/,/\n/g' -e 's/":/"=/g' -e 's/}]}//g' -e 's/"dlink"/dlink/g'|grep http)"
dlk=$(echo |awk '{print "'"$dlink"'"}' 2>/dev/null)

curl "http://pcs.baidu.com/rest/2.0/pcs/file?method=plantcookie&type=ett" -c $BDPAN_HOME/pan.cks  -b $BDPAN_HOME/pan.cks   -H "Accept-Encoding: gzip,deflate,sdch" -H "Host: pcs.baidu.com" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36" -H "Accept: image/webp,*/*;q=0.8" -H "Referer: http://pan.baidu.com/wap/view?fsid=$fsid"  -H "Connection: keep-alive" -H "Cache-Control: max-age=0" --compressed

dld=/media/d/mov
cd $dld
curl -I -b $BDPAN_HOME/pan.cks -H 'User-Agent: netdisk;5.1.0.6;PC;PC-Windows;6.1.7601;WindowsBaiduYunGuanJia' "$dlk" >/tmp/head.log 2>/dev/null
tdlk=$(cat /tmp/head.log|awk '/Location/{print $2}')
if [[ "X$tdlk" == "X" ]]
then
    tdlk=$dlk
fi
echo "$tdlk"
#curl -I -b $BDPAN_HOME/pan.cks -H 'User-Agent: netdisk;5.1.0.6;PC;PC-Windows;6.1.7601;WindowsBaiduYunGuanJia' "$tdlk"
#aria2c -c --file-allocation=none --header="User-Agent: netdisk;5.1.0.6;PC;PC-Windows;6.1.7601;WindowsBaiduYunGuanJia" --load-cookies=$BDPAN_HOME/pan.cks -x5 -s5 "$tdlk"
