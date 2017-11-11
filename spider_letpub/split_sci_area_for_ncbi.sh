#!/bin/bash
a=(2 5 7 10 15 20 30)
let last_index=${#a[@]}-1   
## last_index=6
for ((i=0; i<=$last_index; i++));
do
begin=${a[${i}]}
end=${a[${i}+1]}
## less than IF2
if [ $i -eq 0 ];then
	awk -F"\t" '$4 < begin' begin=$begin  sci_journal.txt\
	|cut -f1|awk '{print $1 "[ISSN]"}'|perl -ane 'chomp ;print "$_ " '|perl -lane 'print join" OR ",@F '\
	> IF_${a[${i}]}.ncbi.filterformat
fi

if [ $i -lt $last_index ];then
	awk -F"\t" '$4 >= begin && $4< end' begin=$begin end=$end sci_journal.txt\
	|cut -f1|awk '{print $1 "[ISSN]"}'|perl -ane 'chomp ;print "$_ " '|perl -lane 'print join" OR ",@F '\
	> IF${a[${i}]}_${a[${i}+1]}.filterformat
fi

##more than IF30
if [ $i -eq $last_index ];then
	awk -F"\t" '$4 >= begin ' begin=$begin sci_journal.txt\
	|cut -f1|awk '{print $1 "[ISSN]"}'|perl -ane 'chomp ;print "$_ " '|perl -lane 'print join" OR ",@F ' \
	> IF${a[${i}]}_.filterformat
fi

done
