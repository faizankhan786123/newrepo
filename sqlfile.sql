public static String sendSMS(IFormReference iform, String stage, String data) {
	try {
		CSR_CCC.mLogger.debug("Inside sendSMS call. Data: " + data);
		String[] param = data.split("-");
		if (param.length < 2) {
			CSR_CCC.mLogger.debug("Invalid input data.");
			return "false";
		}

		// Extract WI and other parameters
		String WI_No = (String) iform.getValue("wi_name");
		String split_WI_No = splitString(WI_No);
		String Card_No = param[0];
		String lastDigitCard_No = Card_No.substring(12, 16);
		String Amount = (String) iform.getValue("CHQ_AMOUNT1");
		String date = getDate();
		String smsLang = "EN";

		// Get CIF from external table
		String CIF = "";
		String QueryExTable = "SELECT CIF FROM RB_CSR_MISC_EXTTABLE WHERE wi_name = '" + WI_No + "'";
		List<List<String>> exTableList = iform.getDataFromDB(QueryExTable);
		if (!exTableList.isEmpty()) {
			CIF = exTableList.get(0).get(0);
		}
		CSR_CCC.mLogger.debug("CIF: " + CIF);

		// Fetch template data
		String templateQuery = "Select * From USR_0_CSR_BT_TemplateMapping where ProcessName = 'CSR_CCC' and TemplateType = '" + stage + "'";
		List<List<String>> templateData = iform.getDataFromDB(templateQuery);

		if (!templateData.isEmpty()) {
			String txtMessage = templateData.get(0).get(5);
			String infobipIsActive = templateData.get(0).get(6);
			String AlertID = templateData.get(0).get(2);
			String DynamicTags = templateData.get(0).get(4);
			String Mobile_No = param[1];
			String Workstep_Name = (String) iform.getActivityName();

			if (!"NULL".equalsIgnoreCase(txtMessage) && "N".equalsIgnoreCase(infobipIsActive)) {
				// Replace placeholders
				txtMessage = txtMessage
						.replaceAll("#WI_No#", split_WI_No)
						.replaceAll("#Amount#", Amount)
						.replaceAll("#Card_No#", lastDigitCard_No)
						.replaceAll("#DD/MM/YYYY#", date);

				// Insert into legacy SMS queue table
				String insertQuery = "INSERT INTO NG_RLOS_SMSQUEUETABLE (ALERT_Name, Alert_Code, Alert_Status, Mobile_No, Alert_Text, WI_Name, Workstep_Name, Inserted_Date_time) " +
						"VALUES ('" + stage + "','CSR_CCC','P','" + Mobile_No + "','" + txtMessage + "','" + WI_No + "','" + Workstep_Name + "', getdate())";

				CSR_CCC.mLogger.debug("Insert Query: " + insertQuery);
				int status = iform.saveDataInDB(insertQuery);
				return (status == 1) ? "true" : "false";

			} else if ("Y".equalsIgnoreCase(infobipIsActive)) {
				// Dynamic Value creation
				List<String> valueList = new ArrayList<>();
				for (String tag : DynamicTags.split("~")) {
					switch (tag.trim()) {
						case "card_No": valueList.add(lastDigitCard_No); break;
						case "wI_No": valueList.add(split_WI_No); break;
						case "dDMMYYYY": valueList.add(date); break;
						case "amount": valueList.add(Amount); break;
						default: valueList.add(""); break;
					}
				}
				String DynamicValues = String.join("~#~", valueList);

				// Insert into InfoBip queue
				String insertQuery = "INSERT INTO USR_0_INFOBIP_SMS_QUEUETABLE " +
						"(Processname, WI_NAME, AlertID, InsertedDateTime, CIF, Dynamic_Tags, Dynamic_Values, Alert_Status) " +
						"VALUES ('CSR_CCC','" + WI_No + "','" + AlertID + "', format(getdate(),'yyyy-MM-dd HH:mm:ss.fff'),'" +
						CIF + "','" + DynamicTags + "','" + DynamicValues + "','P')";

				CSR_CCC.mLogger.debug("Insert Query: " + insertQuery);
				int status = iform.saveDataInDB(insertQuery);
				return (status == 1) ? "true" : "false";
			}
		}
	} catch (Exception ex) {
		CSR_CCC.mLogger.debug("Error in sendSMS: " + ex.toString());
	}
	return "false";
}
