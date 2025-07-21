public static String sendSMS(IFormReference iform, String stage, String data) {
		try{
			CSR_OCC.mLogger.debug("inside sendSMScall txtMessagessss");
			CSR_OCC.mLogger.debug("data----->"+data);
			String[] param = data.split("-");
			//declare all  variable
			String WI_No = (String)iform.getValue("wi_name");
			CSR_OCC.mLogger.debug("WI_No------->" + WI_No);
			String split_WI_No = splitString(WI_No);
			CSR_OCC.mLogger.debug("split_WI_No----------->" + split_WI_No);
			String Card_No = param[0];//(String)iform.getValue("CCI_CrdtCN");
			CSR_OCC.mLogger.debug("Card_No------->" + Card_No);
			String lastDigitCard_No =Card_No.substring(12,16);
			CSR_OCC.mLogger.debug("lastDigitCard_No------->" + lastDigitCard_No);
			String pendingReason = (String)iform.getValue("Pending_Reason");
			CSR_OCC.mLogger.debug("pendingReason------->" + pendingReason);
			String subProcessName = (String)iform.getValue("request_type");
			CSR_OCC.mLogger.debug("subProcessName----------->" + subProcessName);
			String SupplAmount = (String)iform.getValue("oth_ssc_Amount_Text");
			CSR_OCC.mLogger.debug("SupplAmount----------->" + SupplAmount);
			String date = getDate();
			String smsLang = "EN";
			//end
			CSR_OCC.mLogger.debug("inside sendSMScall Card_No :" + Card_No);
			//String path = System.getProperty("user.dir") + File.separatorChar + "folder name" + File.separatorChar + 
			//		"RAKBank_SMS_Temp" + File.separatorChar + "CSR_OCC_"+stage+".html";
			//String txtMessage = readFile(path);
			String Query = "Select * From USR_0_CSR_BT_TemplateMapping where ProcessName = 'CSR_OCC' and TemplateType = '"+stage+"' and SubProcess = '"+subProcessName+"'";
			List<List<String>> Query_data = iform.getDataFromDB(Query);
			CSR_OCC.mLogger.debug("Query_data------->" + Query_data);
			if(Query_data.size()>0) {
			String txtMessage = Query_data.get(0).get(5);
			if (!txtMessage.equalsIgnoreCase("NULL"))
			{
			CSR_OCC.mLogger.debug("txtMessage before replace" + txtMessage);
			txtMessage = txtMessage.replaceAll("#WI_No#", split_WI_No);
			txtMessage = txtMessage.replaceAll("#Card_No#", lastDigitCard_No);
			txtMessage = txtMessage.replaceAll("#CancellationReason#", pendingReason);
			txtMessage = txtMessage.replaceAll("#DD/5MM/YYYY#", date);
			txtMessage = txtMessage.replaceAll("#Sub_Process_Name#", subProcessName);
			txtMessage = txtMessage.replaceAll("#Amount#", SupplAmount);
			CSR_OCC.mLogger.debug("txtMessage after replace" + txtMessage);
			String tableName = "NG_RLOS_SMSQUEUETABLE";
			String ALERT_Name = stage;
			String Alert_Code = "CSR_OCC";
			String Alert_Status = "P";
			String Mobile_No = param[1];//(String)iform.getValue("CCI_MONO");
			CSR_OCC.mLogger.debug("Mobile no--------->" + Mobile_No);
			String Workstep_Name = (String)iform.getActivityName();
			String columnName = "(ALERT_Name, Alert_Code, Alert_Status, Mobile_No, Alert_Text, WI_Name, Workstep_Name, Inserted_Date_time,isViaInfobip)";
			String values = "('" + ALERT_Name + "','" + Alert_Code + "','" + Alert_Status + "','" + Mobile_No + "','" + txtMessage
					+ "','" + WI_No + "','" + Workstep_Name + "', getdate(),'Y' )";
			String SMSInsertQuery = "Insert into "+tableName+" "+columnName+" values "+values ;
			CSR_OCC.mLogger.debug("Query to be inserted in table-----------------: " + SMSInsertQuery);
			int status = iform.saveDataInDB(SMSInsertQuery);
			CSR_OCC.mLogger.debug("SMS Triggred successfuly if value of status is 1-------------STATUS = " + status);
			if(status==1)
			return "true";
			}
			}
		}catch(Exception ex) {
			CSR_OCC.mLogger.debug("Some error in sendSMScall" + ex.toString());
		}
		return "false";
	}
