	public static String sendSMS(IFormReference iform, String stage, String data) {
		try{
			CSR_MR.mLogger.debug("inside sendSMScall txtMessagessss");
			CSR_MR.mLogger.debug("data----->"+data);
			String[] param = data.split("-");
			//declare all  variable
			String SLA_TAT = "0";

			String WI_No = (String)iform.getValue("wi_name");
			CSR_MR.mLogger.debug("WI_No------->" + WI_No);
			String split_WI_No = splitString(WI_No);
			CSR_MR.mLogger.debug("split_WI_No----------->" + split_WI_No);
			String Card_No = param[0];//(String)iform.getValue("CCI_CrdtCN");
			CSR_MR.mLogger.debug("Card_No------->" + Card_No);
			String lastDigitCard_No =Card_No.substring(12,16);
			CSR_MR.mLogger.debug("lastDigitCard_No------->" + lastDigitCard_No);
			String pendingReason = (String)iform.getValue("Pending_Reason");
			CSR_MR.mLogger.debug("pendingReason------->" + pendingReason);
			String subProcessName = (String)iform.getValue("CCI_REQUESTTYPE");
			CSR_MR.mLogger.debug("subProcessName----------->" + subProcessName);
			String subProcess = convertToCamelCase(subProcessName);
			CSR_MR.mLogger.debug("subProcessName----------->" + subProcessName);
			String CUR_Amount = (String)iform.getValue("Curr_Amount");
			CSR_MR.mLogger.debug("CUR_Amount----------->" + CUR_Amount);
			String MerchantName = (String)iform.getValue("Merchant_Name");
			CSR_MR.mLogger.debug("MerchantName----------->" + MerchantName);
			String SchoolName = (String)iform.getValue("SchoolName");
			CSR_MR.mLogger.debug("SchoolName----------->" + SchoolName);
			String OS_Amount =  (String)iform.getValue("Cards_Outstanding");
			CSR_MR.mLogger.debug("OS_Amount----------->" + OS_Amount);
			String date = getDate();
			String smsLang = "EN";
			//end
			CSR_MR.mLogger.debug("inside sendSMScall Card_No :" + Card_No);
			//String path = System.getProperty("user.dir") + File.separatorChar + "folder name" + File.separatorChar + 
			//		"RAKBank_SMS_Temp" + File.separatorChar + "CSR_MR_"+stage+".html";
			//String txtMessage = readFile(path);
			String Query = "Select * From USR_0_CSR_BT_TemplateMapping where ProcessName = 'CSR_MR' and TemplateType = '"+stage+"' and SubProcess = '"+subProcessName+"'";
			List<List<String>> Query_data = iform.getDataFromDB(Query);
			CSR_MR.mLogger.debug("Query_data------->" + Query_data);
			if(Query_data.size()>0) {
			String txtMessage = Query_data.get(0).get(5);
			CSR_MR.mLogger.debug("txtMessage before replace" + txtMessage);
			if(!txtMessage.equalsIgnoreCase("NULL"))
			{
			txtMessage = txtMessage.replaceAll("#WI_No#", split_WI_No);
			txtMessage = txtMessage.replaceAll("#Card_No#", lastDigitCard_No);
			txtMessage = txtMessage.replaceAll("#CancellationReason#", pendingReason);
			txtMessage = txtMessage.replaceAll("#Sub_Process_Name#", subProcess);
			txtMessage = txtMessage.replaceAll("#SLA_TAT#", SLA_TAT);
			txtMessage = txtMessage.replaceAll("#DD/MM/YYYY#", date);
			txtMessage = txtMessage.replaceAll("#CUR_Amount#", CUR_Amount);
			txtMessage = txtMessage.replaceAll("#Merchant_Name#", MerchantName);
			txtMessage = txtMessage.replaceAll("#School_Name#", SchoolName);
			txtMessage = txtMessage.replaceAll("#OS_Amount#", OS_Amount);
			CSR_MR.mLogger.debug("txtMessage after replace" + txtMessage);
			String tableName = "NG_RLOS_SMSQUEUETABLE";
			String ALERT_Name = stage;
			String Alert_Code = "CSR_MR";
			String Alert_Status = "P";
			String Mobile_No = param[1];//(String)iform.getValue("CCI_MONO");
			CSR_MR.mLogger.debug("Mobile no--------->" + Mobile_No);
			String Workstep_Name = (String)iform.getActivityName();
			String columnName = "(ALERT_Name, Alert_Code, Alert_Status, Mobile_No, Alert_Text, WI_Name, Workstep_Name, Inserted_Date_time,isViaInfobip)";
			String values = "('" + ALERT_Name + "','" + Alert_Code + "','" + Alert_Status + "','" + Mobile_No + "','" + txtMessage
					+ "','" + WI_No + "','" + Workstep_Name + "', getdate(),'Y' )";
			String SMSInsertQuery = "Insert into "+tableName+" "+columnName+" values "+values ;
			CSR_MR.mLogger.debug("Query to be inserted in table-----------------: " + SMSInsertQuery);
			int status = iform.saveDataInDB(SMSInsertQuery);
			CSR_MR.mLogger.debug("SMS Triggred successfuly if value of status is 1-------------STATUS = " + status);
			if(status==1)
			return "true";
			}
		}
		}catch(Exception ex) {
			CSR_MR.mLogger.debug("Some error in sendSMScall" + ex.toString());
		}
		return "false";
	}
