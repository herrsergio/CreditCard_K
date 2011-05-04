#!/bin/bash

#           send_failed_ccard_mail.s
#  Wed Feb 23 17:24 2010
#  Copyright  2010  Sergio Cuellar
#  <sergio.cuellar@prb.com.mx>

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

# Sender del correo
SENDER="mx"`/usr/bin/ph/unit.s`"r"

WGET="/usr/bin/wget"

URL="http://poleo.yum.com.mx/sisdevel/ccard_mails"

STORE_ID=$1

MAILS_FILE="afiliacion_mails.dat"
AFILIACION_FILE="afiliacion_nums.dat"

if [ -s /tmp/$MAILS_FILE ]; then
    /bin/rm -f /tmp/$MAILS_FILE
fi

if [ -s /tmp/$AFILIACION_FILE ]; then
    /bin/rm -f /tmp/$AFILIACION_FILE
fi

$WGET --quiet --output-document=/tmp/$MAILS_FILE $URL/$MAILS_FILE
$WGET --quiet --output-document=/tmp/$AFILIACION_FILE $URL/$AFILIACION_FILE

DESTS="`/bin/cat /tmp/$MAILS_FILE`"

AF=`grep "\<${STORE_ID}\>" /tmp/$AFILIACION_FILE | cut -d\| -f2`

FECHA=`date +%d/%m/%y`

MSG=`psql -U postgres -d dbeyum -c "SELECT terminal_id as terminal, monto, fecha, hora FROM tmp_ccard WHERE termFailed = 1" | grep -v row`

SUBJ="Cierre de Lote Fallido Afiliacion ${AF} Fecha ${FECHA}"

$JMAIL "${SENDER}" "${DESTS}" "${SUBJ}" "${MSG}"

