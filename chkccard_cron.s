#!/bin/bash
#           chkccard_cron.s.sh
#  Fri May 22 12:10:23 2009
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

PID=`ps -eo pid,args | grep $CHK_CCARD | grep -v grep | awk '{print $1}'`

function isFranq () {
    NUM=`hostname|sed 's/S\([0-9][0-9][0-9][0-9]\)01/\1/'`
    if [ "${NUM}" -ge "1000" ] && [ "${NUM}" -lt "2000" ]; then
        echo "1"
    else
        echo "0"
    fi
}

if [ "$PID" = "" ]; then
    res=$(isFranq)
    if [ "$res" -eq "0" ]; then
        /usr/bin/ph/chk_ccard.pl 2>/dev/null 
    fi
else
    exit 1
fi
    
