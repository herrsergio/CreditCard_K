
<%!
    String getCCTerminals()
    {
        String query;

        query = "SELECT terminal_id FROM ss_cat_terminals_ccard";

        return query;
    }

    void checkFailedStatus()
    {
        String lsSqlQuery = "";
	String lsResult   = "";
	String storeid    = "";

	lsSqlQuery = "SELECT store_id FROM ss_cat_store";
	storeid    = moAbcUtils.queryToString(lsSqlQuery);
	storeid    = storeid.trim();

        lsSqlQuery = "SELECT count(*) FROM tmp_ccard WHERE termFailed = 1";
        lsResult = moAbcUtils.queryToString(lsSqlQuery);
	lsResult = lsResult.trim();

	if(!lsResult.equals("0")) {
	    try {
	        Process p = Runtime.getRuntime().exec("/usr/local/tomcat/webapps/ROOT/Scripts/send_failed_ccard_mail.s "+storeid);
	    } catch (IOException e) {
	    }
	}
    }

    void sendMail(float dif, String bdate, String sus_id, String storeid)
    {
        try {
	    Process p = Runtime.getRuntime().exec("/usr/local/tomcat/webapps/ROOT/Scripts/send_ccard_mail.s "+dif+" "+bdate+" "+sus_id+" "+storeid);
	} catch (IOException e) {
	    e.printStackTrace();
	}
    }

    String getBusinessDate()
    {
        String s = "";
	String output = "";

        try {
	    Process p = Runtime.getRuntime().exec("/usr/local/tomcat/webapps/ROOT/Scripts/phpqdate.s");
	    BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));

	    while ((s = stdInput.readLine()) != null) {
	        output = output + s;
	    }

	    

	    
	} catch (IOException e) {
	    e.printStackTrace();
	}
	return output;
    }

    String getCreditCardTotalSUS()
    {

    	String s = "";
	String output = "";

        try {
	    Process p = Runtime.getRuntime().exec("/usr/local/tomcat/webapps/ROOT/Scripts/CreditCard_p014.s 2>/dev/null");

	    BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
	    BufferedReader stdError = new BufferedReader(new InputStreamReader(p.getErrorStream()));

	    while ((s = stdInput.readLine()) != null) {
	    	output = output + s;
	    }


	} catch (IOException e){
	    e.printStackTrace();
	}

	
	return output;
    }

    String getUserValid(String psUser, String psPassword)
    {
        String lsReportId = moAbcUtils.queryToString("SELECT emp_num from pp_employees where emp_num = '" + psUser + "' and sus_pass = '" + psPassword + "'");
        return lsReportId;
    }

    void resetTempTable() {
        String lsSqlQuery = "";
	String lsResult   = "";

        lsSqlQuery += "SELECT count(*) FROM pg_class WHERE relname = 'tmp_ccard'";
        lsResult = moAbcUtils.queryToString(lsSqlQuery);

	if(lsResult.equals("1")) {
	    lsSqlQuery = "";
	    lsSqlQuery += "DROP TABLE tmp_ccard";
	    moAbcUtils.executeSQLCommand(lsSqlQuery);
	    lsSqlQuery = "";
	    lsSqlQuery += "DELETE FROM pg_class WHERE relname = 'tmp_ccard'";
	    moAbcUtils.executeSQLCommand(lsSqlQuery);
	}
    }

    void createTempTable() {
        String lsSqlQuery = "";
	String lsResult   = "";

	resetTempTable();

	lsSqlQuery += "SELECT count(*) FROM pg_class WHERE relname = 'tmp_ccard'";

        lsResult = moAbcUtils.queryToString(lsSqlQuery);

	if(lsResult.equals("0")) {
	    lsSqlQuery = "";

            lsSqlQuery += "CREATE TABLE tmp_ccard ( ";
            lsSqlQuery += "terminal_id integer PRIMARY KEY, ";
	    lsSqlQuery += "monto character(10), ";
	    lsSqlQuery += "fecha character(10), ";
	    lsSqlQuery += "hora  character(10), ";
	    lsSqlQuery += "trans character(10), ";
	    lsSqlQuery += "fechanegocio character(10) ,";
	    lsSqlQuery += "totalSUS character(10) ,";
	    lsSqlQuery += "totalCC character(10), ";
	    lsSqlQuery += "termFailed integer)";

	    moAbcUtils.executeSQLCommand(lsSqlQuery);

	    //System.out.println("**Se crea la tabla temporal tmp_ccard**");
	}
    }

    void SaveAsciiFile(String user_id) {
        String totalSUS = ""; 
        String totalCC  = ""; 
	String lsSqlQuery = "";
	String bdate = "";
	String bdate_ = "";
	String storeid = "";
	String terminal_id = "";
	String terminal_date ="";
	String terminal_hour="";
	String terminal_trans="";
	String terminal_money="";
	String terminal_date_format="";
	String sus_id = "";


	Calendar now = Calendar.getInstance();
	String date_timestamp = now.get(Calendar.DATE)+"-"+ (now.get(Calendar.MONTH) + 1)+ "-"+ now.get(Calendar.YEAR)+ " "+ now.get(Calendar.HOUR_OF_DAY) + ":"+ now.get(Calendar.MINUTE)+ ":"+ now.get(Calendar.SECOND);

	lsSqlQuery = "SELECT count(*) FROM ss_cat_terminals_ccard";
	String num_terminals = moAbcUtils.queryToString(lsSqlQuery);

	lsSqlQuery = "SELECT store_id FROM ss_cat_store";
	storeid    = moAbcUtils.queryToString(lsSqlQuery);
	//System.out.println("SA - storeid: "+storeid);
	
	lsSqlQuery = "SELECT sus_id FROM pp_employees WHERE emp_num='"+user_id+"'";
	sus_id     = moAbcUtils.queryToString(lsSqlQuery).trim();

	bdate = getBusinessDate();
	bdate_= bdate.substring(0,2)+"-"+bdate.substring(2,4)+"-"+bdate.substring(4,6);
	//bdate_= bdate.substring(4,6)+"-"+bdate.substring(2,4)+"-"+bdate.substring(0,2);

	//System.out.println("SA - bdate_: "+bdate_);

	lsSqlQuery = "SELECT totalCC FROM tmp_ccard LIMIT 1";
 	totalCC    = moAbcUtils.queryToString(lsSqlQuery).substring(1);	
	//totalCC    = totalCC.substring(1);

	float ftotalCC  = 0.0f;
	ftotalCC  = Float.valueOf(totalCC).floatValue();
	//System.out.println("SA - totalCC: "+totalCC);

	lsSqlQuery = "SELECT totalSUS FROM tmp_ccard LIMIT 1";
 	totalSUS   = moAbcUtils.queryToString(lsSqlQuery);	
	totalSUS   = totalSUS.substring(1);

	float ftotalSUS  = 0.0f;
	ftotalSUS  = Float.valueOf(totalSUS).floatValue();
	//System.out.println("SA - totalSUS: "+totalSUS);

	float difmontos = 0.0f;
	difmontos = ftotalSUS - ftotalCC;
	difmontos = Math.round(difmontos*100.0f) / 100.0f; 

	if(Math.abs(difmontos) >= 0.5f) {
	    sendMail(difmontos, bdate_, sus_id, storeid);
	}

	//System.out.println("difmontos: "+difmontos);

	String filename = "/usr/fms/op/rpts/creditcard/"+bdate_+".txt";
	try {
	    FileWriter fstream = new FileWriter(filename);
	     BufferedWriter out = new BufferedWriter(fstream);
	     for(int i=0; i < Integer.parseInt(num_terminals.trim()); i++) {
	         terminal_id = Integer.toString(i+1);
	         terminal_date = moAbcUtils.queryToString("SELECT fecha FROM tmp_ccard WHERE terminal_id='"+terminal_id+"'");
		 terminal_date.trim();
		 String tmp[] = terminal_date.split("/"); 
		 terminal_date_format = tmp[2].substring(2,4)+"-"+tmp[1]+"-"+tmp[0]; 
	         terminal_hour = moAbcUtils.queryToString("SELECT hora  FROM tmp_ccard WHERE terminal_id='"+terminal_id+"'");
	         terminal_money= moAbcUtils.queryToString("SELECT monto FROM tmp_ccard WHERE terminal_id='"+terminal_id+"'");
	         terminal_trans= moAbcUtils.queryToString("SELECT trans FROM tmp_ccard WHERE terminal_id='"+terminal_id+"'");
	         out.write(storeid.trim()+"|"+terminal_id.trim()+"|"+bdate_.trim()+"|"+terminal_date_format+"|"+terminal_hour.trim()+"|"+terminal_money.trim()+"|"+ftotalSUS+"|"+ftotalCC+"|"+difmontos+"|"+terminal_trans.trim()+"|"+sus_id+"|"+date_timestamp.trim());
	         out.write("\n");
	     }
	     out.close();

	} catch (Exception e) {
	    System.err.println("Error: " + e.getMessage());
	}

        try {
            String command = "/usr/bin/ph/chkccard_kill_cron.s";
            Runtime rt     = Runtime.getRuntime();
            Process proc   = rt.exec(command);
        }
        catch(Exception e) {
            e.printStackTrace();
        }
	
    } 	

    int countNumberLines(String datafile) {
	int count = 0;
        try {
            File file = new File(datafile);
	    FileReader fr = new FileReader(file);
	    LineNumberReader ln = new LineNumberReader(fr);
	   
	    while (ln.readLine() != null) {
	        count++;
	    }
	   
	    ln.close();
	   
        } catch(IOException e) {
            e.printStackTrace();
        }

        return count;
    }
       

    String[][] readCCFile(String bdate_) {

        String strLine;
            
        String CC         = "";
        String terminal   = "";
        String bdate      = "";
        String input_date = "";
        String input_hour = "";
        String input_trans= "";
        String input_money= "";
        String total_SUS  = "";
        String total_CCard= "";
        String diff       = "";
        String user       = "";
        String timestamp  = "";

	int number_lines = countNumberLines("/usr/fms/op/rpts/creditcard/"+bdate_+".txt");

	String[][] resultset;
	resultset = new String[number_lines][5];

	int i = 0;
        
	try {
        FileInputStream fstream = new FileInputStream("/usr/fms/op/rpts/creditcard/"+bdate_+".txt");
        File            file    = new File("/usr/fms/op/rpts/creditcard/"+bdate_+".txt");
        DataInputStream in      = new DataInputStream(fstream);
        BufferedReader  br      = new BufferedReader(new InputStreamReader(in));

        if (file.exists()) {
            while ((strLine = br.readLine()) != null) {


                StringTokenizer tokenizer = new StringTokenizer(strLine, "|");

                CC         = tokenizer.nextToken();
                terminal   = tokenizer.nextToken();
                bdate      = tokenizer.nextToken();
                input_date = tokenizer.nextToken();
                input_hour = tokenizer.nextToken();
                input_money= tokenizer.nextToken();
                total_SUS  = tokenizer.nextToken();
                total_CCard= tokenizer.nextToken();
                diff       = tokenizer.nextToken();
                input_trans= tokenizer.nextToken();
                user       = tokenizer.nextToken();
                timestamp  = tokenizer.nextToken();

                //System.out.println("Terminal: " + terminal+ " Monto: " + input_money + " Fecha: "+input_date+" Hora: "+input_hour);

		resultset[i][0] = terminal;
		resultset[i][1] = input_money;
		resultset[i][2] = input_date;
		resultset[i][3] = input_hour;
		resultset[i][4] = input_trans;

		i++;



            }


            //System.out.println("Total CCard: "+total_CCard+" Total SUS: "+total_SUS);


        }
        in.close();

	} catch (Exception e) {
	    System.out.println("Error: " + e.getMessage());
	}
	return resultset;

    }


%>
