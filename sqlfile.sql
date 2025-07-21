public static String sendSMS(IFormReference iform, String stage, String data) {
	try {
		CSR_BT.mLogger.debug("inside sendSMScall txtMessagessss");
		CSR_BT.mLogger.debug("data----->" + data);
		String[] param = data.split("-");
		
		// declare all variables
		String WI_No = (String) iform.getValue("wi_name");
		CSR_BT.mLogger.debug("WI_No------->" + WI_No);
		String split_WI_No = splitString(WI_No);
		CSR_BT.mLogger.debug("split_WI_No----------->" + split_WI_No);
		
		String Card_No = param[0];
		CSR_BT.mLogger.debug("Card_No------->" + Card_No);
		String lastDigitCard_No = Card_No.substring(12, 16);
		CSR_BT.mLogger.debug("lastDigitCard_No------->" + lastDigitCard_No);
		
		String Amount = (String) iform.getValue("BTD_RBC_BTA1");
		CSR_BT.mLogger.debug("Amount------->" + Amount);
		
		String date = getDate();
		String smsLang = "EN";
		
		// Infobip variables
		String AlertID = "";
		String DynamicTags = "";
		String infobipIsActive = "";
		String CIF = "";
		
		// Get CIF from external table
		String QueryExTable = "SELECT CIF FROM RB_CSR_MISC_EXTTABLE WHERE wi_name = '" + WI_No + "'";
		CSR_BT.mLogger.debug("CIF DB Query :" + QueryExTable);
		List<List<String>> QueryExTableList = iform.getDataFromDB(QueryExTable);
		if (QueryExTableList.size() > 0) {
			CIF = QueryExTableList.get(0).get(0);
		}
		CSR_BT.mLogger.debug("Data from DB CIF :" + CIF);

		String Query = "Select * From USR_0_CSR_BT_TemplateMapping where ProcessName = 'CSR_BT' and TemplateType = '" + stage + "'";
		List<List<String>> Query_data = iform.getDataFromDB(Query);
		CSR_BT.mLogger.debug("Query_data------->" + Query_data);

		if (Query_data.size() > 0) {
			String txtMessage = Query_data.get(0).get(5);
			infobipIsActive = Query_data.get(0).get(6);
			AlertID = Query_data.get(0).get(2);
			DynamicTags = Query_data.get(0).get(4);

			if (!txtMessage.equalsIgnoreCase("NULL") && infobipIsActive.equalsIgnoreCase("N")) {
				CSR_BT.mLogger.debug("txtMessage before replace" + txtMessage);
				txtMessage = txtMessage.replaceAll("#WI_No#", split_WI_No);
				txtMessage = txtMessage.replaceAll("#Amount#", Amount);
				txtMessage = txtMessage.replaceAll("#Card_No#", lastDigitCard_No);
				txtMessage = txtMessage.replaceAll("#DD/MM/YYYY#", date);
				if (stage.equalsIgnoreCase("PendingCancel")) {
					String pendingReason = (String) iform.getValue("Pending_Reason");
					CSR_BT.mLogger.debug("pendingReason------->" + pendingReason);
					txtMessage = txtMessage.replaceAll("#CancellationReason#", pendingReason);
				}
				CSR_BT.mLogger.debug("txtMessage after replace" + txtMessage);

				String tableName = "NG_RLOS_SMSQUEUETABLE";
				String ALERT_Name = stage;
				String Alert_Code = "CSR_BT";
				String Alert_Status = "P";
				String Mobile_No = param[1];
				CSR_BT.mLogger.debug("Mobile no--------->" + Mobile_No);
				String Workstep_Name = (String) iform.getActivityName();
				String columnName = "(ALERT_Name, Alert_Code, Alert_Status, Mobile_No, Alert_Text, WI_Name, Workstep_Name, Inserted_Date_time)";
				String values = "('" + ALERT_Name + "','" + Alert_Code + "','" + Alert_Status + "','" + Mobile_No + "','" + txtMessage
						+ "','" + WI_No + "','" + Workstep_Name + "', getdate() )";
				String SMSInsertQuery = "Insert into " + tableName + " " + columnName + " values " + values;
				CSR_BT.mLogger.debug("Query to be inserted in table-----------------: " + SMSInsertQuery);
				int status = iform.saveDataInDB(SMSInsertQuery);
				CSR_BT.mLogger.debug("SMS Triggered successfully if value of status is 1-------------STATUS = " + status);
				if (status == 1)
					return "true";
			} else if (infobipIsActive.equalsIgnoreCase("Y")) {
				String DynamicValues = "";
				String pendingReason = "";
				String[] tags = DynamicTags.split("~");
				CSR_BT.mLogger.debug("Dynamic Tag Arr: " + Arrays.toString(tags));

				if (stage.equalsIgnoreCase("PendingCancel")) {
					pendingReason = (String) iform.getValue("Pending_Reason");
					CSR_BT.mLogger.debug("pendingReason------->" + pendingReason);
				}

				List<String> valueList = new ArrayList<String>();
				for (String tag1 : tags) {
					String pValue = "";
					switch (tag1.trim()) {
						case "card_No":
							pValue = lastDigitCard_No;
							break;
						case "wI_No":
							pValue = split_WI_No;
							break;
						case "dDMMYYYY":
							pValue = date;
							break;
						case "amount":
							pValue = Amount;
							break;
						case "cancellationReason":
							pValue = pendingReason;
							break;
					}
					valueList.add(pValue);
				}
				DynamicValues = String.join("~#~", valueList);
				CSR_BT.mLogger.debug("Final List of Dynamic Values: " + valueList);

				String tableName = "USR_0_INFOBIP_SMS_QUEUETABLE";
				String ALERT_Name = stage;
				String ProcessName = "CSR_BT";
				String Alert_Status = "P";
				String Mobile_No = param[1];
				CSR_BT.mLogger.debug("Mobile no--------->" + Mobile_No);
				String Workstep_Name = (String) iform.getActivityName();
				String columnName = "(Processname,WI_NAME,AlertID,InsertedDateTime,CIF,Dynamic_Tags,Dynamic_Values,Alert_Status)";
				String values = "('" + ProcessName + "','" + WI_No + "','" + AlertID + "',format(getdate(),'yyyy-MM-dd HH:mm:ss.fff'),'" + CIF
						+ "','" + DynamicTags + "','" + DynamicValues + "','" + Alert_Status + "')";
				String SMSInsertQuery = "Insert into " + tableName + " " + columnName + " values " + values;
				CSR_BT.mLogger.debug("Query to be inserted in table-----------------: " + SMSInsertQuery);
				int status = iform.saveDataInDB(SMSInsertQuery);
				CSR_BT.mLogger.debug("SMS Triggered successfully if value of status is 1-------------STATUS = " + status);
				if (status == 1)
					return "true";
			}
		}
	} catch (Exception ex) {
		CSR_BT.mLogger.debug("Some error in sendSMScall" + ex.toString());
		return "false";
	}
	return "false";
}
