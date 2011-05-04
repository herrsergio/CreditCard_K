
<jsp:include page = '/Include/ValidateSessionYum.jsp'/>

<%--
##########################################################################################################
# Nombre Archivo  : CreditCardBatchYum.jsp
# Compania        : Yum Brands Intl
# Autor           : Sergio Cuellar Valdes
# Objetivo        : Cierre de Lote de Tarjetas de Credito
# Fecha Creacion  : 12/Mayo/2009
# Inc/requires    : 
# Modificaciones  :
##########################################################################################################
--%>

<%@ page contentType="text/html"%>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="generals.*" %>
<%@ include file="../Proc/CreditCardBatchLibYum.jsp" %>   
<%@ include file="/Include/CommonLibYum.jsp" %>

<%! 
	AbcUtils moAbcUtils = new AbcUtils();
%>

<%
    HtmlAppHandler moHtmlAppHandler = (HtmlAppHandler)session.getAttribute(request.getRemoteAddr());
    moHtmlAppHandler.msReportTitle = "Cierre Lote de Tarjetas de Cr&eacute;dito";

%>

<html>
    <head>
        <title>Cierre de Lote de Tarjeta de Cr&eamp;dito</title>
        <link rel="stylesheet" type="text/css" href="/CSS/GeneralStandardsYum.css"/>
	<link rel="stylesheet" type="text/css" href="/CSS/TabStandardsYum.css"/>
    	<link rel="stylesheet" type="text/css" href="/CSS/WaitMessageYum.css"/>
	<link rel='stylesheet' href='/CSS/CalendarStandardsYum.css' type='text/css'>
        <div id='popupcalendar' class='text' style='z-index:100006; position:absolute;'></div>

        <script src="/Scripts/AbcUtilsYum.js"></script>
        <script src="/Scripts/ReportUtilsYum.js"></script>
        <script src="/Scripts/Chars.js"></script>
        <script src="/Scripts/StringUtilsYum.js"></script>
        <script src="/Scripts/HtmlUtilsYum.js"></script>
	<script src="/Scripts/CalendarYum.js"></script>

        <script>

        var liRowCount=0;
	var liRowCountRecep=0;
	var gaKeys = new Array('');
	
        function printDetail() {
            executeDetail();
        }

        function adjustPageSettings() {
            adjustContainer(60,165);
        }

        function showHideControls(){
	        showHideControl('divTransferCtrls','hidden');
        }

        function loadFirstTab()
        {
            showHideControls();
			validOption(1);
    	}

        function validOption(psTab)
        {
            switch (psTab){
                    case 1: 	
		                browseDetail('CreditCardDetailYum.jsp','CreditCardBatchYum.jsp','1');
                  	break;

            }

        }
        function validateSearch() {
        	return(true);
        }

        </script>
    </head>
    <body bgcolor="white" OnLoad="loadFirstTab();">
    <jsp:include page = '/Include/GenerateHeaderYum.jsp'>
		<jsp:param name="psStoreName" value="true"/>
    </jsp:include>

    <form id="frmMaster" name="frmMaster" method="post" target="ifrDetail">
    <input type='hidden' name='hidOperation' id='hidOperation' value='S'>

    <table width="99%" align="center" id="tblCapture" border="0" cellpadding="2">
    	<tr valign="top">
        <td width="100%" height="100%">
                <div class>
                    <div class="tabIframeWrapper">
                        <iframe name='ifrDetail' width="100%" height="450"
                                id='ifrDetail' frameBorder='0'></iframe>
                    </div>
                </div>
        </td>
    	</tr>
    </table>
	</form>

    <jsp:include page = '/Include/TerminatePageYum.jsp'/>
</html>

