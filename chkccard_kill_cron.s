#!/bin/bash
#           chkccard_kill_cron.s.sh
#  Tue May 26 12:30:15 2009
#  Copyright  2009  Sergio Cuellar
#  <sergio.cuellar@yum.com>

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA

. /usr/bin/ph/sysshell.new SUS >/dev/null 2>&1

CHK_CCARD="/usr/bin/ph/chk_ccard.pl"
BEEPS="/usr/bin/ph/beep_terms.pl"

PHPQDATE=`unset SRVR; perl -e '\`. /usr/bin/ph/sysshell.new SUS >/dev/null\`; $phpqdate=\`/usr/fms/op/bin/phpqdate 2>/dev/null\`; chomp($phpqdate); $phpqdate_ = substr($phpqdate, 0, 2)."-".substr($phpqdate, 2, 2)."-".substr($phpqdate, 4, 5); print $phpqdate_;'`

TIME=`perl -e '($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime(); $year = 1900 + $yearOffset; $month += 1; $theTime = "$dayOfMonth-$month-$year $hour:$minute:$second"; print $theTime;'`

PID_CHK_CCARD=`ps -eo pid,args | grep $CHK_CCARD | grep -v grep | awk '{print $1}'`
PID_BEEPS=`ps -eo pid,args | grep $BEEPS | grep -v grep | awk '{print $1}'`

if [ "$PID_CHK_CCARD" != "" ]; then
    echo "ALARMA_FIN|$TIME" >> /usr/fms/op/rpts/creditcard/${PHPQDATE}.alarm 
    kill -9 $PID_CHK_CCARD
    pkill Xdialog
fi
    
if [ "$PID_BEEPS" != "" ]; then
    kill -9 $PID_BEEPS
fi
