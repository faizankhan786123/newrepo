	public static String sendSMS(IFormReference iform, String stage, String data) {
		try{
			CSR_CCC.mLogger.debug("inside sendSMScall txtMessagessss");
			String[] param = data.split("-");
			//declare all  variable
			String WI_No = (String)iform.getValue("wi_name");
			String split_WI_No = splitString(WI_No);
			CSR_CCC.mLogger.debug("split_WI_No----------->" + split_WI_No);
			String Amount = (String)iform.getValue("CHQ_AMOUNT1");
			String Card_No = param[0];//(String)iform.getValue("CCI_CrdtCN");
			String lastDigitCard_No = Card_No.substring(12,16);
			String date = getDate();
			String smsLang = "EN";
			//end
			CSR_CCC.mLogger.debug("inside sendSMScall Card_No :" + Card_No);
			//String path = System.getProperty("user.dir") + File.separatorChar + "folder name" + File.separatorChar + 
			//		"RAKBank_SMS_Temp" + File.separatorChar + "CSR_CCC_"+stage+".html";
			//String txtMessage = readFile(path);
			String Query = "Select * From USR_0_CSR_BT_TemplateMapping where ProcessName = 'CSR_CCC' and TemplateType = '"+stage+"'";
			List<List<String>> Query_data = iform.getDataFromDB(Query);
			CSR_CCC.mLogger.debug("Query_data--------->" + Query_data);
			String txtMessage = Query_data.get(0).get(5);
			CSR_CCC.mLogger.debug("txtMessage before replace" + txtMessage);
			txtMessage = txtMessage.replaceAll("#WI_No#", split_WI_No);
			txtMessage = txtMessage.replaceAll("#Amount#", Amount);
			txtMessage = txtMessage.replaceAll("#Card_No#", lastDigitCard_No);
			txtMessage = txtMessage.replaceAll("#DD/MM/YYYY#", date);
			CSR_CCC.mLogger.debug("txtMessage after replace" + txtMessage);
			String tableName = "NG_RLOS_SMSQUEUETABLE";
			String ALERT_Name = stage;
			String Alert_Code = "CSR_CCC";
			String Alert_Status = "P";
			String Mobile_No = param[1];//(String)iform.getValue("CCI_MONO");
			CSR_CCC.mLogger.debug("Mobile_No" + Mobile_No);
			String Workstep_Name = (String)iform.getActivityName();
			String columnName = "(ALERT_Name, Alert_Code, Alert_Status, Mobile_No, Alert_Text, WI_Name, Workstep_Name, Inserted_Date_time,isViaInfobip)";
			String values = "('" + ALERT_Name + "','" + Alert_Code + "','" + Alert_Status + "','" + Mobile_No + "','" + txtMessage
					+ "','" + WI_No + "','" + Workstep_Name + "', getdate(),'Y' )";
			String SMSInsertQuery = "Insert into "+tableName+" "+columnName+" values "+values ;
			CSR_CCC.mLogger.debug("Query to be inserted in table-----------------: " + SMSInsertQuery);
			int status = iform.saveDataInDB(SMSInsertQuery);
			CSR_CCC.mLogger.debug("SMS Triggred successfuly if value of status is 1--------STATUS = " + status);
			if(status==1)
			return "true";
		}catch(Exception ex) {
			CSR_CCC.mLogger.debug("Some error in sendSMScall" + ex.toString());
			return "false";
		}
		return "false";
	}
