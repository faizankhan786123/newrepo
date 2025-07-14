if (!"".equalsIgnoreCase(SMS_MOBNO) && !"".equalsIgnoreCase(sms_template)) {
    String SMSquery = "INSERT INTO NG_RLOS_SMSQUEUETABLE " +
        "(Alert_Name, Alert_Code, ALert_Status, Mobile_No, Alert_Text, WI_Name, Workstep_Name, inserted_Date_time) " +
        "VALUES ('TS SMS', 'TS', 'P', '" + SMS_MOBNO + "', '" + sms_template + "', '" +
        getWorkitemName(iformObj) + "', '" + iformObj.getActivityName() + "', GETDATE())";

    int saveDataInDB1 = iformObj.saveDataInDB(SMSquery);
    TS.mLogger.debug("Query: " + SMSquery + " | Result: " + saveDataInDB1);
}
