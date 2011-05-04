DESCRIPCION:

Parche  edc2011-02 . Sergio Cuellar. 06-Diciembre-10

Reporte para capturar los totales vendidos de las terminales de tarjeta de credito.

Este parche incluye los siguientes cambios:

 * Se crea en eReports el reporte: Ingresos y Gastos-> Venta -> Cierre Lote de Tarjetas de Credito
 * Se crea el reporte dentro del directorio:
   * /usr/local/tomcat/webapps/ROOT/IncomeandExpense/CreditCardBatch

 * Los archivos dentro de este directorio son:
   * Entry/
          CreditCardBatchYum.jsp  CreditCardCheckPasswd.jsp  CreditCardDetailYum.jsp  CreditCardPasswd.jsp
   * Proc/
          CreditCardBatchLibYum.jsp
   * Scripts/
          CreditCardBatchYum.js

 * Además se crean los siguientes scripts: 
   * /usr/local/webapps/ROOT/Scripts/phpqdate.s         <- Para obtener la fecha de negocio
   * /usr/local/webapps/ROOT/Scripts/CreditCard_p014.s  <- Para obtener total del cobrado con Tarjeta de Credito
   * /usr/local/webapps/ROOT/Scripts/send_ccard_mail.s  <- Para enviar correo a Gerente e Ingresos en caso de diferencia en los montos

 * Se crea la tabla ss_cat_terminals_ccard en la base de datos dbeyum para almacenar datos de las terminales de los restaurantes.

 * Se realiza una alarma para que en caso de no haber ingresado su cierre de lote de tarjeta a las 23:45 se active. Los archivos relacionados son:
   * /usr/bin/ph/chk_ccard.pl
   * /usr/bin/ph/beep_terms.pl
   * /usr/bin/ph/chkccard_cron.s
   * /usr/bin/ph/chkccard_kill_cron.s

 * Se coloca dentro de /etc/cron.d los siguientes archivos:
   * chkccard       <- Activa la alarma a las 23:45 en caso de no haber capturado su cierre de lotes. 
   * chkccard_kill  <- Termina la alarma sino la capturaron a las 24:00
