#!/bin/bash
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin


ESPACO=`df -h /media/STR | awk '{print $5}' | grep -v Use | sort -nr | awk -F % '{print $1}' | head -n1`

# Verifica espaco em disco
case $ESPACO in
        9[1-9])
	ls -ltrxp /media/STR/MOVIES | head -n 5 | tr "\n" "\0" | xargs -0 rm -rf;
        find /media/STR/CLIPS -ctime +90 -exec rm -rf {} \;
        find /media/STR/TVSHOWS -ctime +180 -exec rm -rf {} \;
esac

