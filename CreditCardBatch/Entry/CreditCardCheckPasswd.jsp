<jsp:include page = '/Include/ValidateSessionYum.jsp'/>

<%--
##########################################################################################################
# Nombre Archivo  : CreditCardCheckPasswd.jsp
# Compania        : Yum Brands Intl
# Autor           : Sergio Cuellar Valdes
# Objetivo        : Verificar Passwd y guardar archivo
# Fecha Creacion  : 18/Mayo/2009
# Inc/requires    : 
# Observaciones   : 
##########################################################################################################
--%>

<%@ page contentType="text/html" %>
<%@page import="java.util.*" %>
<%@page import="java.io.*" %>
<%@page import="generals.*" %>

<%! 
    AbcUtils moAbcUtils;
    String user   = "";
    String passwd = "";
    String usuValid = "";
    String bdate = "";
    String bdate_ = "";
    String dataSet = "";
%>

<% 
    moAbcUtils = new AbcUtils();
%>

<%@ include file="/Include/CommonLibYum.jsp" %>
<%@ include file="../Proc/CreditCardBatchLibYum.jsp" %>

<%
    HtmlAppHandler moHtmlAppHandler = (HtmlAppHandler)session.getAttribute(request.getRemoteAddr());
    moHtmlAppHandler.setPresentation("VIEWPORT");
    moHtmlAppHandler.initializeHandler();
    moHtmlAppHandler.msReportTitle = getCustomHeader("Cierre Lote de Tarjetas de Cr&eacute;dito", "Preview");
    moHtmlAppHandler.updateHandler();
    moHtmlAppHandler.validateHandler();

    bdate = getBusinessDate();
    //bdate_= bdate.substring(4,6)+"-"+bdate.substring(2,4)+"-"+bdate.substring(0,2);
    bdate_= bdate.substring(0,2)+"-"+bdate.substring(2,4)+"-"+bdate.substring(4,6);

    user    = request.getParameter("cmbUserSus");
    passwd  = request.getParameter("txtPassword");

    //System.out.println("user = "+user);
    //System.out.println("passwd= "+passwd);

    String user_id = getUserValid(user, passwd);

    if(!(user_id.equals(""))) {
         usuValid = "1";
         SaveAsciiFile(user);
	 checkFailedStatus();
	 dataSet = moAbcUtils.getJSArray2D(readCCFile(bdate_));
	 //System.out.println("dataSet = "+dataSet);
    } else {
         usuValid = "0";
    }

    //System.out.println("usuValid= "+usuValid);

%>

<html>
    <head>
        <link rel="stylesheet" type="text/css" href="/CSS/GeneralStandardsYum.css"/>
        <link rel="stylesheet" type="text/css" href="/CSS/DataGridDefaultYum.css"/>

        <script src="/Scripts/AbcUtilsYum.js"></script>
        <script src="/Scripts/StringUtilsYum.js"></script>
        <script src="/Scripts/MiscLibYum.js"></script>
        <script src="/Scripts/DataGridClassYum.js"></script>
        <script src="/Scripts/HtmlUtilsYum.js"></script>
        <script src="/Scripts/StringUtilsYum.js"></script>
    

        <script type="text/javascript">
	var loGrid = new Bs_DataGrid('loGrid');
	var totGrid = new Bs_DataGrid('totGrid');
	var gaDataset = <%= dataSet %>;
	var SUStot = <%= getCreditCardTotalSUS() %>;
	SUStot = SUStot.toFixed(2);
        </script>
	<script src="../Scripts/CreditCardBatchYum.js"></script>

    </head>

    <body bgcolor="white" onLoad="initResultGrid();">

        <% if(usuValid.equals("1")) { %>
        <table align="left" style="width: 384px;" width="90%" border="0">
        <tr class="bsTotals">
            <td>
                <h2>Fecha de Negocio: <%=bdate_%></h2>
            </td>
        <tr>
        <tr class="bsTotals">
            <td>
                <font color="red"><b>*** Cierre exitoso de Lote de Tarjetas de Cr&eacute;dito ***</b></font>
            </td>
        <tr>
        <tr>
            <td style="width: 203px;">
                <input type="button" value="Imprimir" onClick="javascript:window.print()">
            </td>
        </tr>
        <tr>
            <td>
                <div id="resultDataGrid"></div>
            </td>
        </tr>
        <tr>
            <td>
                <div id="resultTotalsGrid"></div>
            </td>
        </tr>
        </table>
        <% } else { %>
        <script type="text/javascript">
            alert("Password incorrecto. Recuerda que es tu password del toma ordenes.");
            history.back();
        </script>
        <% } %>

    <jsp:include page = '/Include/TerminatePageYum.jsp'/>
    </body>
</html>

