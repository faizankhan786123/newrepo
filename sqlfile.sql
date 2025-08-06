public static String sendSMS(IFormReference iform, String stage, String data) {
	try {
		CSR_MR.mLogger.debug("inside sendSMScall txtMessagessss");
		CSR_MR.mLogger.debug("data----->" + data);
		String[] param = data.split("-");
		String SLA_TAT = "0";

		String WI_No = (String) iform.getValue("wi_name");
		String split_WI_No = splitString(WI_No);
		String Card_No = param[0];
		String lastDigitCard_No = Card_No.substring(12, 16);
		String pendingReason = (String) iform.getValue("Pending_Reason");
		String subProcessName = (String) iform.getValue("CCI_REQUESTTYPE");
		String subProcess = convertToCamelCase(subProcessName);
		String CUR_Amount = (String) iform.getValue("Curr_Amount");
		String MerchantName = (String) iform.getValue("Merchant_Name");
		String SchoolName = (String) iform.getValue("SchoolName");
		String OS_Amount = (String) iform.getValue("Cards_Outstanding");
		String date = getDate();
		String smsLang = "EN";

		String Query = "Select * From USR_0_CSR_BT_TemplateMapping where ProcessName = 'CSR_MR' and TemplateType = '" + stage + "' and SubProcess = '" + subProcessName + "'";
		List<List<String>> Query_data = iform.getDataFromDB(Query);
		CSR_MR.mLogger.debug("Query_data------->" + Query_data);

		if (Query_data.size() > 0) {
			String txtMessage = Query_data.get(0).get(5);
			String DynamicTags = Query_data.get(0).get(6); // assuming this column contains tag list like card_No~wI_No~...
			String AlertID = Query_data.get(0).get(3);     // assuming AlertID is in column index 3
			String CIF = Query_data.get(0).get(4);         // assuming CIF is in column index 4

			CSR_MR.mLogger.debug("txtMessage before replace: " + txtMessage);
			CSR_MR.mLogger.debug("DynamicTags: " + DynamicTags);

			String[] tags = DynamicTags.split("~");
			List<String> valueList = new ArrayList<>();

			for (String tag : tags) {
				String pValue = "";
				switch (tag.trim().toLowerCase()) {
					case "card_no":
						pValue = lastDigitCard_No;
						break;
					case "wi_no":
						pValue = split_WI_No;
						break;
					case "sub_process_name":
						pValue = subProcess;
						break;
					case "ddmmyyyy":
						pValue = date;
						break;
					case "cur_amount":
						pValue = CUR_Amount;
						break;
					case "merchant_name":
						pValue = MerchantName;
						break;
					case "school_name":
						pValue = SchoolName;
						break;
					case "sla_tat":
						pValue = SLA_TAT;
						break;
					case "os_amount":
						pValue = OS_Amount;
						break;
					case "cancellationreason":
						pValue = pendingReason;
						break;
					default:
						pValue = ""; // fallback
						break;
				}
				valueList.add(pValue);
			}

			String DynamicValues = String.join("~#~", valueList);
			CSR_MR.mLogger.debug("DynamicValues: " + DynamicValues);

			String tableName = "USR_0_INFOBIP_SMS_QUEUETABLE";
			String ALERT_Name = stage;
			String ProcessName = "CSR_MR";
			String Alert_Status = "P";
			String Mobile_No = param[1];
			String Workstep_Name = (String) iform.getActivityName();

			String columnName = "(Processname,WI_NAME,AlertID,InsertedDateTime,CIF,Dynamic_Tags,Dynamic_Values,Alert_Status)";
			String values = "('" + ProcessName + "','" + WI_No + "','" + AlertID + "',format(getdate(),'yyyy-MM-dd HH:mm:ss.fff'),'" + CIF
					+ "','" + DynamicTags + "','" + DynamicValues + "','" + Alert_Status + "')";

			String SMSInsertQuery = "Insert into " + tableName + " " + columnName + " values " + values;
			CSR_MR.mLogger.debug("Query to be inserted in table: " + SMSInsertQuery);

			int status = iform.saveDataInDB(SMSInsertQuery);
			CSR_MR.mLogger.debug("SMS Triggered successfully if value of status is 1--------STATUS = " + status);
			if (status == 1)
				return "true";
		}
	} catch (Exception ex) {
		CSR_MR.mLogger.debug("Some error in sendSMScall: " + ex.toString());
	}
	return "false";
}
