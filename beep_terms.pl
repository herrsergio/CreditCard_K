#!/usr/bin/perl  -w
#
##           beep_terms.pl
##  Mon May 25 10:03:08 2009
##  Copyright  2009  Sergio Cuellar
##  <sergio.cuellar@yum.com>
#
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU Library General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA

@ttys=`grep "^D[0-9]:4:respawn:/usr/fms/etc/sysuif" /etc/inittab | awk '{print \$4}' | tr -d "<"`;
chomp(@ttys);

while(1) {
    foreach $tty(@ttys) {
        system("echo -e \"\a\" > $tty");
    }
    system("echo -e \"\a\" > /dev/tty11");
    sleep(2);
}

