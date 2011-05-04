#!/usr/bin/perl 
#
##           chk_ccard.pl
##  Fri May 22 08:53:08 2009
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
#
#
use lib "/usr/bin/ph/databases/posdb/lib";
use posdb;

`. /usr/bin/ph/sysshell.new SUS >/dev/null`;

$phpqdate=`unset SRVR; /usr/fms/op/bin/phpqdate 2>/dev/null`;

$sql_getempls = "SELECT emp_num, sus_id FROM pp_employees WHERE sus_id <> 'NULL' AND sus_pass <> 'NULL' AND sus_id <> 'UNKN' AND security_level='01' ORDER BY sus_id";
$sql_user_passwd = "SELECT emp_num FROM pp_employees WHERE sus_id=? AND sus_pass=?";

$data = $dbh->prepare($sql_getempls);
$data->execute();

$list = "";

while(@empls = $data->fetchrow()) {
    ($emp_num, $sus_id) = @empls;
    #print "$emp_num, $sus_id\n";
    $list = $list." \"$sus_id\" \"\"";
}


`rm -f /tmp/option.txt 2>/dev/null`;

$xdialog_alert = "\/usr\/bin\/Xdialog  --screen-center --beep --no-close --no-cancel --stdout --title \"***ATENCION***\" --ok-label \"Apagar Alarma\" --msgbox \"No ha capturado su cierre de lote de tarjeta de credito \" 15 50";
$xdialog_users_list = "\/usr\/bin\/Xdialog --screen-center --beep --no-close --no-cancel --title \"Ingresa Usuario y Password\" --menu \"Selecciona tu usuario de SUS: \" 24 51 6 $list 2\> \/tmp\/option.txt";
$xdialog_passwd_box = "\/usr\/bin\/Xdialog --stdout --beep --no-close --no-cancel --title \"Ingrese su Password\" --password --inputbox \"Password de toma ordenes:\" 15 50";
$xdialog_wrong_passwd = "\/usr\/bin\/Xdialog --screen-center --beep --no-close --no-buttons --title \"Password incorrecto\" --infobox \"EL PASSWORD ES INCORRECTO.\nRecuerda que es el password del toma ordenes\" 13 45 2000";
$xdialog_thanks = "\/usr\/bin\/Xdialog --screen-center --beep --no-close --no-buttons --title \"Gracias\" --infobox \"Ahora cierre su lote de tarjetas de credito en eReports\" 13 50 2000";


chomp($phpqdate);

#$phpqdate_ = substr($phpqdate, 4, 5)."-".substr($phpqdate, 2, 2)."-".substr($phpqdate, 0, 2);
$phpqdate_ = substr($phpqdate, 0, 2)."-".substr($phpqdate, 2, 2)."-".substr($phpqdate, 4, 5);


if (! -e "/usr/fms/op/rpts/creditcard/$phpqdate_.txt") {

    open(SCRIPT, '>/tmp/script.sh');


$send_sms=<<EOT;
#!/bin/bash
unit=`hostname`
store_id=\${unit:2:3}
/usr/bin/wget --quiet --output-document=/tmp/ccard_sms.txt http://poleo.yum.com.mx/sisdevel/ccard_mails/\${store_id}.sms
SMS=\"`/bin/cat /tmp/ccard_sms.txt`\"
MSG=\"Favor de realizar su cierre de lotes de TC. CC \${store_id}\"
/usr/bin/ph/sop/sendSMS.sh \"\${SMS}\" \"\${MSG}\"
EOT

    print SCRIPT "$send_sms";
    close(SCRIPT);

    system("chmod +x /tmp/script.sh");
    system("/tmp/script.sh");

    unlink("/tmp/script.sh");
    unlink("/tmp/ccard_sms.txt");

    open(SCRIPT, '>/tmp/script.sh');

$send_mail=<<EOT;
#!/bin/bash
JMAIL=\"/usr/bin/ph/jmail.s\"
SENDER=\"mx\"`/usr/bin/ph/unit\.s`\"r\"
unit=`hostname`
store_id=\${unit:2:3}
/usr/bin/wget --quiet --output-document=/tmp/ccard_mails.txt http://poleo.yum.com.mx/sisdevel/ccard_mails/\${store_id}.txt
DESTS=\"`/bin/cat /tmp/ccard_mails.txt`\"
MSG=\"Alarma de Cierre de Lotes Activada a las `date +%T`\"
SUBJ=\"Alarma Cierre de Lotes Activada\"
\$JMAIL \"\${SENDER}\" \"\${DESTS}\" \"\${SUBJ}\" \"\${MSG}\"
EOT

    print SCRIPT "$send_mail";
    close(SCRIPT);

    system("chmod +x /tmp/script.sh");
    system("/tmp/script.sh");

    unlink("/tmp/script.sh");
    unlink("/tmp/ccard_mails.txt");
    
 
    system("/usr/bin/ph/beep_terms.pl &");
    $alarm_pid = `ps -def | grep /usr/bin/ph/beep_terms.pl | grep -v grep | awk '{print \$2}'`;
    chomp($alarm_pid);
    #print "alarm_pid = $alarm_pid\n";

    ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    $year = 1900 + $yearOffset;
    $month += 1;
    $theTime = "$dayOfMonth-$month-$year $hour:$minute:$second";

    $alarm_file = "/usr/fms/op/rpts/creditcard/$phpqdate_.alarm";
    open (MYFILE, ">> $alarm_file")|| die("Cannot Open File");
    print MYFILE "ALARMA_ACTIVADA|$theTime\n";

    `$xdialog_alert`;
    while($? != 0 ) {
        `$xdialog_alert`;
    }
    if($? == 0) {
        `$xdialog_users_list`;
	$retval=$?;
	$user=`cat /tmp/option.txt`;
        `rm -f /tmp/option.txt 2>/dev/null`;
	while($retval != 0) {
            `xdialog_users_list`;
            $retval=$?;
            $user=`cat /tmp/option.txt`;
            `rm -f /tmp/option.txt 2>/dev/null`;
	}
        #print "Usuario: $user\n";

	$passwd_typed = `$xdialog_passwd_box`;

	#print "Passwd: $passwd_typed\n";
	
        $data2 = $dbh->prepare($sql_user_passwd);
	chomp($user);
	chomp($passwd_typed);
        $data2->execute($user, $passwd_typed);

	while($data2->fetchrow() eq "") {
	    `$xdialog_wrong_passwd`;
	    $passwd_typed = `$xdialog_passwd_box`;
	    $data2 = $dbh->prepare($sql_user_passwd);
	    chomp($passwd_typed);
	    $data2->execute($user, $passwd_typed);
	}

	
	($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
	$year = 1900 + $yearOffset;
	$month += 1;
	$theTime = "$dayOfMonth-$month-$year $hour:$minute:$second";
	
	print MYFILE "$user|$theTime\n";
	close(MYFILE);

	system("kill -9 $alarm_pid");

	`$xdialog_thanks`;

	system("/usr/local/firefox/firefox http://localhost:8080 &");
	
    }

}
