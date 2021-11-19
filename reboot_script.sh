#!/bin/bash
TIME1=$(date +"%Y-%m-%d %H:%M")
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
TICK="[✓]"
CROSS="[✗]"
LOG="/home/user/log/$TIMESTAMP_reboot.log"
EMAIL="/home/user/email/email.txt"
HDD_UUID="62BAA268BAA23905"
#######################################################

touch "$LOG"

echo "The server has just been booted on:" | tee -a "$LOG"
echo $TIME1 | tee -a "$LOG"
echo "" | tee -a "$LOG"

#
# Restart some programmes and services to make sure they are running.
#

service nginx restart
sleep 1

service sslh restart
sleep 1

# Restart pihole
pihole disable
pihole enable

echo -e "\n\n" | tee -a "$LOG"

#Automatic security update with import of non-critical packages apt-get update
#apt-get -yt $(lsb_release -cs)-security dist-upgrade apt-get --trivial-only dist-upgrade
#apt-get autoclean

# mount hdd manually
mount UUID=$HDD_UUID -t ntfs /media/hdd/
if [ $? -ne 0 ]
then
        echo "ERROR when mounting the 6Tb hard drive @/media/hdd/!" | tee -a "$LOG"
fi

# Check that the hard disk has been mounted
if mount | grep /media/hdd
then
        echo "  $TICK HDD 6Tb is mounted!" | tee -a "$LOG"
else
        echo "  $CROSS HDD 6Tb is not mounted!" | tee -a "$LOG"
fi
echo -e "\n\n" | tee -a "$LOG"

# print pihole status
pihole status | tee -a "$LOG"
echo  "" | tee -a "$LOG"

echo "Updates for Pihole available?" | tee -a "$LOG"
/home/user/scripts/check_Pihole_Updates.sh | tee -a "$LOG"
echo "" | tee -a "$LOG"

# Speedtest
echo "Speedtest:" | tee -a "$LOG"
speedtest --simple | tee -a "$LOG"
if [ $? -ne 0 ]
then
        echo "ERROR: Speedtest!" | tee -a "$LOG"
fi

echo "" | tee -a "$LOG"
echo "---| EOF |---" | tee -a "$LOG"

#
# Send EMail ######
#
txt="$(cat $EMAIL)"
txt+="\n\n"
txt+="$(cat $LOG)"

echo -e "$txt" | /usr/bin/msmtp -t usern@mail.com
if [ $? -ne 0 ]
then
        echo "ERROR: MSMTP!" | tee -a "$LOG"
fi

exit 0
#####################################################
