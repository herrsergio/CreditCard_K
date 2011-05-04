# Instalador de Parches EDC's patch edc2011-02
###############################################################################
#                                                                             #
#   @(#)%M% %R%.%L% %E% %D%                                                   #
#                                                                             #
#   COMPANIA        :  Premium                                                #
#   PROGRAMA        :  %M%                                                    #
#   DESCRIPCION        :                                                      #
#                                                                             #
#                                                                             #
#    FUNCIONES                                                                #
#        f_nombre()    Una linea comentario                                   #
#        r_nombre()    Una linea comentario                                   #
#                                                                             #
#   TABLAS                                                                    #
#        nombre        Una linea comentario                                   #
#                                                                             #
#                                                                             #
#    HISTORIA                                                                 #
#       CREACION            :  10/12/03                                       #
#           AUTOR            :  Sergio Cuellar Valdes                         #
#        ULTIMA VERSION %R%.%L%        :  %E%                                 #
#            AUTOR            : xxxxxxxxxxx                                   #
#            DESC. CAMBIO    : xxxxxxxxxxx                                    #
#                                                                             #
###############################################################################
#
set -x
exec 2>/tmp/edc11-02.log

EDC=edc2011-02

#
# Ambiente
USAGE="USAGE: $0 [-h] "
DESC=" Este programa sirve para instalar el $EDC"
PATCHDIR=/usr/bin/ph/patch
BASEDIR=${BASEDIR:=$PATCHDIR/$EDC/}
PATCHCTL=$PATCHDIR/edc.ctl
WRKDIR=$BASEDIR
LOGFILE=$PATCHDIR/$EDC/edc11-02.log

#
# Argumentos

#
# Validacion  de Argumentos y Ayuda estanda
if [ "$1" = "-h" ]
then
    echo $USAGE
    echo $DESC
    exit 0
fi 

#
# Funciones

# ENCABEZADO FUNCION
###############################################################################
#  f_nombre()                                                                 #
#                                                                             #
#  DESCRIPCION:                                                               #
#                                                                             #
#  ENTRADAS:                                                                  #
#                                                                             #
#  SALIDAS:                                                                   #
#                                                                             #
###############################################################################
#

TOMCAT_HOME=/usr/local/tomcat
WEBAPPS=$TOMCAT_HOME/webapps
CCARD=$WEBAPPS/ROOT/IncomeAndExpense/CreditCardBatch
IE=$WEBAPPS/ROOT/IncomeAndExpense
MARCA=`/usr/bin/ph/getmarca.s`
VERSION=`cat /usr/fms/op/cfg/Release`
UNIT=`/usr/fms/op/bin/phtbpr -u unit 2>/dev/null | grep UNIT01 | cut -d"|" -f4 | cut -c4-6`

# Script dentro del parche
set -e

cd $WRKDIR

NUM_TERMS=`grep $UNIT cc_termccard.txt | cut -d\| -f2`

if [ ! -n "$NUM_TERMS" ]; then
    NUM_TERMS=3
fi

phzap echo "$EDC" > $LOGFILE

phzap echo "1. Se detiene el servidor Tomcat ... " >> $LOGFILE
#phzap $TOMCAT_HOME/bin/shutdown.sh
phzap /etc/init.d/tomcat stop
phzap sleep 3    

#Se borra el cache de Tomcat 
if [ -d $TOMCAT_HOME/work/Catalina/localhost/_/org/apache/jsp ]; then
    phzap echo "2. Se borra el cache de Tomcat .........." >> $LOGFILE
    phzap rm -rf $TOMCAT_HOME/work/Catalina/localhost/_/org/apache/jsp/*
fi

if [ -d $CCARD ]; then
    phzap /bin/rm -rf $CCARD
fi

if [ ! -d $CCARD ]; then
    phzap echo "3. Desempacando:        $CCARD.........." >> $LOGFILE
    phzap echo "                        $CCARD/Entry.........." >> $LOGFILE
    phzap echo "                        $CCARD/Proc .........." >> $LOGFILE
    phzap echo "                        $CCARD/Scripts .........." >> $LOGFILE
    phzap tar xvjf CreditCardBatch.tar.bz2 -C $IE 
fi

phzap echo "7. Respaldando archivo s_cat_menu_option_XX.sql ........." >> $LOGFILE
if [ $MARCA == "K" ]; then
    if [ ! -f $WEBAPPS/ROOT/SQL/ss_cat_menu_option_kfc.sql.edc1102 ];then
        phzap cp $WEBAPPS/ROOT/SQL/ss_cat_menu_option_kfc.sql $WEBAPPS/ROOT/SQL/ss_cat_menu_option_kfc.sql.edc1102
    fi
fi
if [ $MARCA == "P" ]; then
    if [ ! -f $WEBAPPS/ROOT/SQL/ss_cat_menu_option_ph.sql.edc1102 ];then
        phzap cp $WEBAPPS/ROOT/SQL/ss_cat_menu_option_ph.sql $WEBAPPS/ROOT/SQL/ss_cat_menu_option_ph.sql.edc1102
    fi
fi

phzap echo "8. Copiando nueva version de ss_cat_menu_option_XX.sql .........." >> $LOGFILE
if [ $MARCA == "K" ]; then
    phzap cp ss_cat_menu_option_kfc.sql $WEBAPPS/ROOT/SQL/
fi

if [ $MARCA == "P" ]; then
    phzap cp ss_cat_menu_option_ph.sql $WEBAPPS/ROOT/SQL/
fi

phzap echo "9. Cargando ss_cat_menu_option_XX.sql en PostgreSQL .........." >> $LOGFILE
if [ $MARCA == "K" ]; then
    if [ -e $WEBAPPS/ROOT/SQL/ss_cat_menu_option_kfc.sql ]; then 
        phzap psql -U postgres dbeyum < $WEBAPPS/ROOT/SQL/ss_cat_menu_option_kfc.sql
    fi
fi
if [ $MARCA == "P" ]; then
    if [ -e $WEBAPPS/ROOT/SQL/ss_cat_menu_option_ph.sql ]; then 
        phzap psql -U postgres dbeyum < $WEBAPPS/ROOT/SQL/ss_cat_menu_option_ph.sql
    fi
fi


phzap echo "10. Copiando phpqdate.s a $WEBAPPS/ROOT/Scripts.........." >> $LOGFILE
phzap cp phpqdate.s  $WEBAPPS/ROOT/Scripts
phzap chmod +x $WEBAPPS/ROOT/Scripts/phpqdate.s

phzap echo "11. Copiando CreditCard_p014.s a $WEBAPPS/ROOT/Scripts.........." >> $LOGFILE
phzap cp CreditCard_p014.s  $WEBAPPS/ROOT/Scripts
phzap chmod +x $WEBAPPS/ROOT/Scripts/CreditCard_p014.s

phzap echo "12. Copiando send_ccard_mail.s a $WEBAPPS/ROOT/Scripts.........." >> $LOGFILE
phzap cp send_ccard_mail.s  $WEBAPPS/ROOT/Scripts
phzap cp send_failed_ccard_mail.s  $WEBAPPS/ROOT/Scripts
phzap chmod +x $WEBAPPS/ROOT/Scripts/send_ccard_mail.s
phzap chmod +x $WEBAPPS/ROOT/Scripts/send_failed_ccard_mail.s

phzap echo "13. Estableciendo permisos en Tomcat .........." >> $LOGFILE
phzap chown -R root.root $IE
phzap chmod -R 755 $IE

phzap echo "14. Se inicia el servidor Tomcat .........." >> $LOGFILE
#phzap $TOMCAT_HOME/bin/startup.sh
phzap /etc/init.d/tomcat start

phzap echo "15. Creando tabla ss_cat_terminals_ccard y haciendo alter a pp_employees  .........." >> $LOGFILE
cp ccard_sql_commands.sql.${NUM_TERMS}term /tmp/ccard_sql_commands.sql
psql -U postgres dbeyum < /tmp/ccard_sql_commands.sql
rm /tmp/ccard_sql_commands.sql

phzap echo "16. Copiando beep_terms.pl  .........." >> $LOGFILE
phzap cp beep_terms.pl /usr/bin/ph
phzap chmod 755 /usr/bin/ph/beep_terms.pl
phzap chown admin.sus /usr/bin/ph/beep_terms.pl

phzap echo "17. Copiando chk_ccard.pl  .........." >> $LOGFILE
phzap cp chk_ccard.pl /usr/bin/ph
phzap chmod 755 /usr/bin/ph/chk_ccard.pl
phzap chown admin.sus /usr/bin/ph/chk_ccard.pl

phzap echo "18 Copiando chkccard_cron.s  .........." >> $LOGFILE
phzap cp chkccard_cron.s /usr/bin/ph
phzap chmod 755 /usr/bin/ph/chkccard_cron.s
phzap chown admin.sus /usr/bin/ph/chkccard_cron.s

phzap echo "19. Copiando chkccard_kill_cron.s  .........." >> $LOGFILE
phzap cp chkccard_kill_cron.s /usr/bin/ph
phzap chmod 755 /usr/bin/ph/chkccard_kill_cron.s
phzap chown admin.sus /usr/bin/ph/chkccard_kill_cron.s

phzap echo "20. Estableciendo cron de chkccard  .........." >> $LOGFILE
phzap cp chkccard.cron /etc/cron.d/chkccard
phzap chown root.root /etc/cron.d/chkccard
phzap chmod 644 /etc/cron.d/chkccard

phzap echo "21. Estableciendo cron de chkccard_kill .........." >> $LOGFILE
phzap cp chkccard_kill.cron /etc/cron.d/chkccard_kill
phzap chown root.root /etc/cron.d/chkccard_kill
phzap chmod 644 /etc/cron.d/chkccard_kill

phzap echo "22. Crear directorio /usr/fms/op/rpts/creditcard .........." >> $LOGFILE
if [ ! -d /usr/fms/op/rpts/creditcard ]; then
    phzap mkdir /usr/fms/op/rpts/creditcard
    phzap chown -R admin.sus /usr/fms/op/rpts/creditcard
fi

phzap echo "23. Copiando nueva version de val_err.s" >> $LOGFILE

if [ ! -f /usr/bin/ph/val_err.s.edc1102]; then
    phzap /bin/cp /usr/bin/ph/val_err.s  /usr/bin/ph/val_err.s.edc1102
fi

phzap /bin/cp val_err.s.KFC /usr/bin/ph/val_err.s
phzap chmod +x /usr/bin/ph/val_err.s
phzap chown admin.sus /usr/bin/ph/val_err.s

# Terminacion
phzap echo "Ok, instalacion completa........" >> $LOGFILE
exit 0
