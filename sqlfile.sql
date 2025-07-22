public static String sendSMS(IFormReference iform, String stage, String data) {
		try {
			CSR_OCC.mLogger.debug("inside sendSMScall txtMessagessss");
			CSR_OCC.mLogger.debug("data----->" + data);
			String[] param = data.split("-");

			// Declare all variables
			String WI_No = (String) iform.getValue("wi_name");
			CSR_OCC.mLogger.debug("WI_No------->" + WI_No);
			String split_WI_No = splitString(WI_No);
			CSR_OCC.mLogger.debug("split_WI_No----------->" + split_WI_No);

			String Card_No = param[0];
			CSR_OCC.mLogger.debug("Card_No------->" + Card_No);
			String lastDigitCard_No = Card_No.substring(12, 16);
			CSR_OCC.mLogger.debug("lastDigitCard_No------->" + lastDigitCard_No);

			String pendingReason = (String) iform.getValue("Pending_Reason");
			CSR_OCC.mLogger.debug("pendingReason------->" + pendingReason);

			String subProcessName = (String) iform.getValue("request_type");
			CSR_OCC.mLogger.debug("subProcessName----------->" + subProcessName);

			String SupplAmount = (String) iform.getValue("oth_ssc_Amount_Text");
			CSR_OCC.mLogger.debug("SupplAmount----------->" + SupplAmount);

			String date = getDate();
			String smsLang = "EN";

			// Infobip variables
			String AlertID = "";
			String DynamicTags = "";
			String infobipIsActive = "";
			String CIF = "";

			// Get CIF from external table
			String QueryExTable = "SELECT CIF FROM RB_CSR_OCC_EXTTABLE WHERE wi_name = '" + WI_No + "'";
			CSR_OCC.mLogger.debug("CIF DB Query :" + QueryExTable);
			List<List<String>> QueryExTableList = iform.getDataFromDB(QueryExTable);
			if (QueryExTableList.size() > 0) {
				CIF = QueryExTableList.get(0).get(0);
			}
			CSR_OCC.mLogger.debug("Data from DB CIF :" + CIF);

			String Query = "SELECT * FROM USR_0_CSR_BT_TemplateMapping WHERE ProcessName = 'CSR_OCC' AND TemplateType = '" + stage + "' AND SubProcess = '" + subProcessName + "'";
			List<List<String>> Query_data = iform.getDataFromDB(Query);
			CSR_OCC.mLogger.debug("Query_data------->" + Query_data);

			if (Query_data.size() > 0) {
				String txtMessage = Query_data.get(0).get(5);
				infobipIsActive = Query_data.get(0).get(10);
				AlertID = Query_data.get(0).get(8);
				DynamicTags = Query_data.get(0).get(9);
				

				CSR_OCC.mLogger.debug("infobip is Active " + infobipIsActive);
				CSR_OCC.mLogger.debug("infobip Alert ID " + AlertID);
				CSR_OCC.mLogger.debug("infobip Dynamic Tags " + DynamicTags);

				if (!txtMessage.equalsIgnoreCase("NULL") && infobipIsActive.equalsIgnoreCase("N")) {
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
					String Mobile_No = param[1];
					CSR_OCC.mLogger.debug("Mobile no--------->" + Mobile_No);
					String Workstep_Name = (String) iform.getActivityName();

					String columnName = "(ALERT_Name, Alert_Code, Alert_Status, Mobile_No, Alert_Text, WI_Name, Workstep_Name, Inserted_Date_time)";
					String values = "('" + ALERT_Name + "','" + Alert_Code + "','" + Alert_Status + "','" + Mobile_No + "','" + txtMessage + "','" + WI_No + "','" + Workstep_Name + "', getdate() )";
					String SMSInsertQuery = "INSERT INTO " + tableName + " " + columnName + " VALUES " + values;

					CSR_OCC.mLogger.debug("Query to be inserted in table-----------------: " + SMSInsertQuery);
					int status = iform.saveDataInDB(SMSInsertQuery);
					CSR_OCC.mLogger.debug("SMS Triggered successfully if value of status is 1-------------STATUS = " + status);
					if (status == 1) return "true";
				} else if (infobipIsActive.equalsIgnoreCase("Y")) {
					String DynamicValues = "";
					String[] tags = DynamicTags.split("~");
					CSR_OCC.mLogger.debug("Dynamic Tag Arr: " + Arrays.toString(tags));

					List<String> valueList = new ArrayList<>();
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
								pValue = SupplAmount;
								break;
							case "cancellationReason":
								pValue = pendingReason;
								break;
						}
						valueList.add(pValue);
					}

					DynamicValues = String.join("~#~", valueList);
					CSR_OCC.mLogger.debug("Final List of Dynamic Values: " + valueList);

					String tableName = "USR_0_INFOBIP_SMS_QUEUETABLE";
					String ALERT_Name = stage;
					String ProcessName = "CSR_OCC";
					String Alert_Status = "P";
					String Mobile_No = param[1];
					CSR_OCC.mLogger.debug("Mobile no--------->" + Mobile_No);
					String Workstep_Name = (String) iform.getActivityName();

					String columnName = "(Processname,WI_NAME,AlertID,InsertedDateTime,CIF,Dynamic_Tags,Dynamic_Values,Alert_Status)";
					String values = "('" + ProcessName + "','" + WI_No + "','" + AlertID + "',format(getdate(),'yyyy-MM-dd HH:mm:ss.fff'),'" + CIF + "','" + DynamicTags + "','" + DynamicValues + "','" + Alert_Status + "')";
					String SMSInsertQuery = "INSERT INTO " + tableName + " " + columnName + " VALUES " + values;

					CSR_OCC.mLogger.debug("Query to be inserted in table-----------------: " + SMSInsertQuery);
					int status = iform.saveDataInDB(SMSInsertQuery);
					CSR_OCC.mLogger.debug("SMS Triggered successfully if value of status is 1-------------STATUS = " + status);
					if (status == 1) return "true";
				}
			}
		} catch (Exception ex) {
			CSR_OCC.mLogger.debug("Some error in sendSMScall" + ex.toString());
			return "false";
		}
		return "false";
	}
