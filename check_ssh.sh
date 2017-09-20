#!/bin/bash
:>ssh_yes.txt
qhost|awk  -F" " '{print $1"\t"$3"\t"$5}'|sed "1,4d">.ip.txt
while read line; do
	detail=(${line})	
	echo -n "checking ${detail[0]}... "
	ssh -n -o NumberOfPasswordPrompts=0 ${detail[0]} "ls" > /dev/null 2>&1
	if [ $? = 0 ]; then
		echo $line >> ssh_yes.txt
		echo -e "\033[46;31m SUCCESS \033[0m"
	else
		echo -e -n "\033[31m FAILED \033[0m\r"	
	fi
done < .ip.txt
rm .ip.txt
