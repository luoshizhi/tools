#!/bin/bash

if [ $# != 2 ]
then
    echo "    use for root in cluster"
    echo "    Usage:"
    echo "          $0 NewUser Group"
    exit 2
fi

WHO=`whoami`

if [ $WHO != "root" ]
then
    echo " Only root have permission to add user "
    echo " Please use root to run this script! "
    exit 2
fi

HOST=`hostname`
if [ $HOST != "cluster.hpc.org" ]
then
    echo "WARNING: Hostname is not cluster"
    echo " please \"ssh cluster\""
    exit 2
fi


NewUser=$1
Group=$2
echo "...run log..."

###########################################

#create group if not exists
grep "^$Group" /etc/group >& /dev/null
if [ $? -ne 0 ]  
then  
echo "groupadd $Group"
    groupadd $Group
fi  


###########################################
#create user if not exists  
id $NewUser >& /dev/null
if [ $? -eq 0 ]
then
    echo "$NewUser has already exists"
    echo "Please change the new user name!"
    exit 2
fi


echo "useradd $NewUser -g $Group "
useradd $NewUser -g $Group



echo "passwd $NewUser"
echo "123.brd" | passwd --stdin $NewUser



echo "rock sync user"
ROCKS=`rocks sync users`


perdir="/share/nas1/"
echo "mkdir $perdir/$NewUser"
mkdir $perdir/$NewUser
chown -R $NewUser $perdir/$NewUser
chgrp -R $Group $perdir/$NewUser

echo "ln -s $perdir/$NewUser /home/$NewUser/workdir"
ln -s $perdir/$NewUser  /home/$NewUser/workdir

chown -R $NewUser  /home/$NewUser/workdir
chgrp -R $Group  /home/$NewUser/workdir

echo " chage -d 0 $NewUser"
chage -d 0 $NewUser
echo "...Add User $NewUser Done..."
