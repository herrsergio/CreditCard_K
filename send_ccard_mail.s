#!/bin/bash

#           send_ccard_mail.s.s
#  Tue May 26 09:43:18 2009
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

PATH=$PATH:/usr/bin/ph:/usr/fms/op/bin
export PATH

# Script para mandar correos
JMAIL="/usr/bin/ph/jmail.s"

# Script para mandar sms
SMS_SEND="/usr/bin/ph/sop/sendSMS.sh"

# Sender del correo
SENDER="mx"`/usr/bin/ph/unit.s`"r"

WGET="/usr/bin/wget"

URL="http://poleo.yum.com.mx/sisdevel/ccard_mails"

DIF=$1
BDATE=$2
SUS_ID=$3
STORE_ID=$4

MAILS_FILE="${STORE_ID}.txt"
SMS_FILE="${STORE_ID}.sms"

if [ -s /tmp/ccard_mails.txt ]; then
    /bin/rm -f /tmp/ccard_mails.txt
fi

if [ -s /tmp/ccard_sms.txt ]; then
    /bin/rm -f /tmp/ccard_sms.txt
fi

$WGET --quiet --output-document=/tmp/ccard_mails.txt $URL/$MAILS_FILE
$WGET --quiet --output-document=/tmp/ccard_sms.txt   $URL/$SMS_FILE

DESTS="`/bin/cat /tmp/ccard_mails.txt`"
SMS="`/bin/cat /tmp/ccard_sms.txt`"

MSG="Existe una diferencia en el CC ${STORE_ID} por ${DIF} en sus cierre de lote de tarjetas de credito realizado por ${SUS_ID} en la fecha de negocio ${BDATE}."

MSG_SMS="Dif en el CC ${STORE_ID} de ${DIF} en su cierre de lote de TC,realizado por ${SUS_ID} con fecha neg ${BDATE}"

SUBJ="Diferencia en Cierre de Lote de Tarjetas de Credito en CC ${STORE_ID} ${BDATE}"

$JMAIL "${SENDER}" "${DESTS}" "${SUBJ}" "${MSG}"
$SMS_SEND "${SMS}" "${MSG_SMS}"

