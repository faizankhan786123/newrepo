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
