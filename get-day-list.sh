#!/bin/bash

bdate=$1
BDPAN_HOME=$(cd $(dirname $BASH_SOURCE) && pwd)

curl -c pan.cks -b pan.cks "http://pan.baidu.com/wap/home" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "$FAKE_AGENT"  -H "Accept: */*"  >/tmp/waphome.html 2>/dev/null

grep "list-item\|list-content" -A1 /tmp/waphome.html |awk '{if(/[0-9]+-[0-9]+-[0-9]+/){ORS="\n";print}else{ORS="";print}}'|sed 's/.*data-path.*\(data-url[^ ]*\).*\(201[0-9]-[0-9]*-[0-9]*\).*/\1 \2/g'|grep "$bdate"|awk '{print $1}'|sed 's/amp;//g' >/tmp/url.list.$bdate

rm -f /tmp/dlid.list


getlist()
{
	durl=$1
	if echo $durl|grep -q fsid
        then
                echo ${durl}|sed 's/.*=\([0-9]*\)"/\1/' >>/tmp/dlid.list
        else
                eval $(echo  "$durl"|sed 's/data-/data/g')
                curl  -b $BDPAN_HOME/pan.cks "http://pan.baidu.com/wap/${dataurl}" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "$FAKE_AGENT"  -H "Accept: */*"  2>/dev/null|grep "list-item\|list-content" -A1 |awk '{if(/[0-9]+-[0-9]+-[0-9]+/){ORS="\n";print}else{ORS="";print}}'|sed 's/.*data-path.*\(data-url[^ ]*\).*\(201[0-9]-[0-9]*-[0-9]*\).*/\1 \2/g'|grep "$bdate"|awk '{print $1}'|sed 's/amp;//g'| while read nline
		do
			echo "$nline"
			getlist "$nline"
		done
        fi
}

while read line
do 
	getlist "$line"
done < /tmp/url.list.$bdate
