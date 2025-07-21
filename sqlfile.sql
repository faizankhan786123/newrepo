public static String sendSMS(IFormReference iform, String stage, String data) {
	try {
		CSR_CCC.mLogger.debug("inside sendSMScall txtMessagessss");
		CSR_CCC.mLogger.debug("data----->" + data);
		String[] param = data.split("-");

		// declare all variables
		String WI_No = (String) iform.getValue("wi_name");
		CSR_CCC.mLogger.debug("WI_No------->" + WI_No);
		String split_WI_No = splitString(WI_No);
		CSR_CCC.mLogger.debug("split_WI_No----------->" + split_WI_No);

		String Card_No = param[0];
		CSR_CCC.mLogger.debug("Card_No------->" + Card_No);
		String lastDigitCard_No = Card_No.substring(12, 16);
		CSR_CCC.mLogger.debug("lastDigitCard_No------->" + lastDigitCard_No);

		String Amount = (String) iform.getValue("CHQ_AMOUNT1");
		CSR_CCC.mLogger.debug("Amount------->" + Amount);

		String date = getDate();
		String smsLang = "EN";

		// Infobip variables
		String AlertID = "";
		String DynamicTags = "";
		String infobipIsActive = "";
		String CIF = "";

		// Get CIF from external table
		String QueryExTable = "SELECT CIF FROM RB_CSR_MISC_EXTTABLE WHERE wi_name = '" + WI_No + "'";
		CSR_CCC.mLogger.debug("CIF DB Query :" + QueryExTable);
		List<List<String>> QueryExTableList = iform.getDataFromDB(QueryExTable);
		if (QueryExTableList.size() > 0) {
			CIF = QueryExTableList.get(0).get(0);
		}
		CSR_CCC.mLogger.debug("Data from DB CIF :" + CIF);

		String Query = "Select * From USR_0_CSR_BT_TemplateMapping where ProcessName = 'CSR_CCC' and TemplateType = '" + stage + "'";
		List<List<String>> Query_data = iform.getDataFromDB(Query);
		CSR_CCC.mLogger.debug("Query_data--------->" + Query_data);

		if (Query_data.size() > 0) {
			String txtMessage = Query_data.get(0).get(5);
			infobipIsActive = Query_data.get(0).get(6);
			AlertID = Query_data.get(0).get(2);
			DynamicTags = Query_data.get(0).get(4);

			if (!txtMessage.equalsIgnoreCase("NULL") && infobipIsActive.equalsIgnoreCase("N")) {
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
				String Mobile_No = param[1];
				CSR_CCC.mLogger.debug("Mobile_No--------->" + Mobile_No);
				String Workstep_Name = (String) iform.getActivityName();
				String columnName = "(ALERT_Name, Alert_Code, Alert_Status, Mobile_No, Alert_Text, WI_Name, Workstep_Name, Inserted_Date_time)";
				String values = "('" + ALERT_Name + "','" + Alert_Code + "','" + Alert_Status + "','" + Mobile_No + "','" + txtMessage
						+ "','" + WI_No + "','" + Workstep_Name + "', getdate() )";
				String SMSInsertQuery = "Insert into " + tableName + " " + columnName + " values " + values;
				CSR_CCC.mLogger.debug("Query to be inserted in table-----------------: " + SMSInsertQuery);
				int status = iform.saveDataInDB(SMSInsertQuery);
				CSR_CCC.mLogger.debug("SMS Triggered successfully if value of status is 1--------STATUS = " + status);
				if (status == 1)
					return "true";
			} else if (infobipIsActive.equalsIgnoreCase("Y")) {
				String DynamicValues = "";
				String[] tags = DynamicTags.split("~");
				CSR_CCC.mLogger.debug("Dynamic Tag Arr: " + Arrays.toString(tags));

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
					}
					valueList.add(pValue);
				}
				DynamicValues = String.join("~#~", valueList);
				CSR_CCC.mLogger.debug("Final List of Dynamic Values: " + valueList);

				String tableName = "USR_0_INFOBIP_SMS_QUEUETABLE";
				String ALERT_Name = stage;
				String ProcessName = "CSR_CCC";
				String Alert_Status = "P";
				String Mobile_No = param[1];
				CSR_CCC.mLogger.debug("Mobile no--------->" + Mobile_No);
				String Workstep_Name = (String) iform.getActivityName();
				String columnName = "(Processname,WI_NAME,AlertID,InsertedDateTime,CIF,Dynamic_Tags,Dynamic_Values,Alert_Status)";
				String values = "('" + ProcessName + "','" + WI_No + "','" + AlertID + "',format(getdate(),'yyyy-MM-dd HH:mm:ss.fff'),'" + CIF
						+ "','" + DynamicTags + "','" + DynamicValues + "','" + Alert_Status + "')";
				String SMSInsertQuery = "Insert into " + tableName + " " + columnName + " values " + values;
				CSR_CCC.mLogger.debug("Query to be inserted in table-----------------: " + SMSInsertQuery);
				int status = iform.saveDataInDB(SMSInsertQuery);
				CSR_CCC.mLogger.debug("SMS Triggered successfully if value of status is 1--------STATUS = " + status);
				if (status == 1)
					return "true";
			}
		}
	} catch (Exception ex) {
		CSR_CCC.mLogger.debug("Some error in sendSMScall" + ex.toString());
		return "false";
	}
	return "false";
}
