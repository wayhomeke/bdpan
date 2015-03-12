#!/bin/bash
s()
{
	j=$1
	r=$2
        v="$(echo -ne "$j"|wc -m)"
        for((q=0; q<256; q++))
        do 
            jsub=${j:$(($q%$v)):1}
            a[$q]=$((0$(echo -ne "$jsub"|hexdump -b|awk '/0000000/{printf $2}')))
            p[$q]=$q
        done
        u=0
        for((q=0;q<256;q++))
        do
            u=$(((u + p[q] + a[q]) % 256))
            t=${p[$q]}
            p[$q]=${p[$u]}
            p[$u]=$t
        done
        i=0
        u=0
        rlength="$(echo -ne "$r"|wc -m)"
        for((q=0;q<rlength;q++))
        do
            i=$(((i + 1) % 256))
            u=$(((u + p[i]) % 256))
            t=${p[$i]};
            p[$i]=${p[$u]};
            p[$u]=$t;
            k=${p[$((((p[i] + p[u]) % 256)))]};
            rsub=${r:$q:1}
            qhex=$((0$(echo -ne "$rsub"|hexdump -b|awk '/0000000/{printf $2}')))
            cc="$(printf "%x" "$((qhex ^ k))")"
            o="$o""\x$cc"
        done
        echo -ne "$o"
    }

s $1 $2
