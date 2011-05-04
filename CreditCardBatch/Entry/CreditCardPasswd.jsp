<jsp:include page = '/Include/ValidateSessionYum.jsp'/>

<%--
##########################################################################################################
# Nombre Archivo  : CreditCardPasswd.jsp
# Compania        : Yum Brands Intl
# Autor           : Sergio Cuellar Valdes
# Objetivo        : Capturar usuario SUS y passwd para guardar cambios del cierre de lote
# Fecha Creacion  : 15/Mayo/2009
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
    String bdate  = "";
    String nRows  = "";
    String query  = "";
    String totCC  = "";
    String totSUS = "";
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

    query = "INSERT INTO tmp_ccard(terminal_id, monto, fecha, hora, trans, fechanegocio, totalSUS, totalCC, termFailed) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)";

    nRows  = request.getParameter("numRows");
    totCC  = request.getParameter("totalCC");
    totSUS = request.getParameter("totalSUS");

    bdate = getBusinessDate();

    int failedStatus;

    //System.out.println("nRows = "+nRows);
    //System.out.println("totSUS= "+totSUS);
    //System.out.println("totCC= "+totCC);

    for(int liRowId = 0; liRowId < Integer.parseInt(nRows.trim()); liRowId++) {
        String monto  = request.getParameter("monto|"+liRowId);
        String fecha  = request.getParameter("fecha|"+liRowId);
        String hora   = request.getParameter("hora|"+liRowId);
        String trans  = request.getParameter("trans|"+liRowId);
        String failed = request.getParameter("termfail|"+liRowId);
	if(failed != null) {
	    failedStatus = 1;
	} else {
	    failedStatus = 0;
	}

	int terminal  = liRowId + 1;

	monto  = monto.trim();
	fecha  = fecha.trim();
	hora   = hora.trim();
	trans  = trans.trim();

	//System.out.println(terminal+" "+monto+" "+fecha+" "+hora);

	moAbcUtils.executeSQLCommand(query, new String[]{Integer.toString(terminal), monto, fecha, hora, trans, bdate, totSUS, totCC, Integer.toString(failedStatus)});

    }



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
    
	<script src="../Scripts/CreditCardBatchYum.js"></script>

        <script type="text/javascript">

	function validate() {
	    if(document.frmGrid.cmbUserSus.value == "") {
	        alert("Seleccione un Usuario.");
                return false;
	    }
	    if(document.frmGrid.txtPassword.value == ""){
	        alert("Ingrese el Password.");
		return false;
	    }
	    document.frmGrid.txtPassword.value = document.frmGrid.txtPassword.value.toUpperCase();
	    document.frmGrid.submit();
	}

        </script>
    </head>

    <body bgcolor="white">

        <form name="frmGrid" id="frmGrid" method="post" action="CreditCardCheckPasswd.jsp">

        <table align="left" style="width: 384px;" width="90%" border="0">
	<tr class="bsTotals">
	    <td class="descriptionTabla">
	        Nota: Ingresa tu password del toma ordenes.
            </td>
	</tr>
	<tr class="bsTotals">
	    <td class="descriptionTabla">
	        Usuario SUS: 
	    </td>
	    <td>
	    <select id = 'cmbUserSus' name ='cmbUserSus' size = '1' class ='combos'>
	        <option value="">-- Seleccione --</option>
		<%
		   moAbcUtils.fillComboBox(out,"SELECT emp_num, sus_id FROM pp_employees WHERE sus_id <> 'NULL' AND sus_pass <> 'NULL' AND sus_id <> 'UNKN' AND security_level='01' ORDER BY sus_id");
		%>
	    </select>
	    </td>
	</tr>
	<tr class="bsTotals">
	    <td class="descriptionTabla">
	        Password:
	    </td>
	    <td class="descriptionTabla">
	        <input type='password' name='txtPassword' size='12' maxlength='8'>
	    </td>
	</tr>
        <tr>
            <td style="width: 203px;">
                <input type="button" value="Aceptar" onClick="validate()">
                <input type="button" value="Cancelar" onClick="javascript:history.back();">
            </td>
        </tr>
        </table>
        </form>

    <jsp:include page = '/Include/TerminatePageYum.jsp'/>
    </body>
</html>

