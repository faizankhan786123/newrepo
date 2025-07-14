 if (!"".equalsIgnoreCase(SMS_MOBNO) &&
				 !"".equalsIgnoreCase(sms_template)) {
				 SMSquery = "Insert into NG_RLOS_SMSQUEUETABLE"
				+ (Alert_Name,Alert_Code,ALert_Status,Mobile_No,Alert_Text,WI_Name,Workstep_Name,inserted_Date_time)
				 values ('TS SMS','TS','P','"
				 + SMS_MOBNO + "','" + sms_template + "', '" +
				 getWorkitemName(iformObj) + "','"
				 + iformObj.getActivityName() + "', getdate())";
				 int saveDataInDB1 = iformObj.saveDataInDB(SMSquery);
				 TS.mLogger.debug("Query:" + SMSquery + saveDataInDB1);
				 }
