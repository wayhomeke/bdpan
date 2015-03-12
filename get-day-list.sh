#!/bin/bash

bdate=$1
BDPAN_HOME=$(cd $(dirname $BASH_SOURCE) && pwd)
eval $(cat $BDPAN_HOME/user.conf)
FAKE_AGENT='User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.38'

echo TMP dir is set to  ${TMP="/tmp/"}
echo download dir is set to ${DOWNLOAD="/tmp/"}


curl -k -c pan.cks -b pan.cks "http://pan.baidu.com/wap/home" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "$FAKE_AGENT"  -H "Accept: */*"  >${TMP}/waphome.html 2>/dev/null

grep "list-item\|list-content" -A1 ${TMP}/waphome.html |awk '{if(/[0-9]+-[0-9]+-[0-9]+/){ORS="\n";print}else{ORS="";print}}'|sed 's/.*data-path.*\(data-url[^ ]*\).*\(201[0-9]-[0-9]*-[0-9]*\).*/\1 \2/g'|grep "$bdate"|awk '{print $1}'|sed 's/amp;//g' >${TMP}/url.list.$bdate

rm -f ${TMP}/dlid.list


getlist()
{
	durl=$1
	if echo $durl|grep -q fsid
        then
                echo ${durl}|sed 's/.*=\([0-9]*\)"/\1/' >>${TMP}/dlid.list
        else
                eval $(echo  "$durl"|sed 's/data-/data/g')
                curl -k  -b $BDPAN_HOME/pan.cks "http://pan.baidu.com/wap/${dataurl}" -H "Accept-Language: zh-CN,zh;q=0.8,en;q=0.6" -H "$FAKE_AGENT"  -H "Accept: */*"  2>/dev/null|grep "list-item\|list-content" -A1 |awk '{if(/[0-9]+-[0-9]+-[0-9]+/){ORS="\n";print}else{ORS="";print}}'|sed 's/.*data-path.*\(data-url[^ ]*\).*\(201[0-9]-[0-9]*-[0-9]*\).*/\1 \2/g'|grep "$bdate"|awk '{print $1}'|sed 's/amp;//g'| while read nline
		do
			echo "$nline"
			getlist "$nline"
		done
        fi
}

while read line
do 
	getlist "$line"
done < ${TMP}/url.list.$bdate
