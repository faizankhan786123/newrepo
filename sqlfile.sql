try {
	String qry = "select top 1 a.SERVICE_NAME,ISNULL(ISNULL(b.CSC_REQUEST_TYPE,b.RP_REQUEST_TYPE),'') as SUB_PROCESS,"
			+ "a.FROM_MAILID,a.MAIL_SUBJECT,a.MAIL_TEMPLATE,a.SMS_TEMPLATE,a.SMS_PLACEHOLDER,a.MAIL_PLACEHOLDER,"
			+ "ISNULL(COALESCE(RIGHT(b.HEADER_CARD_NO,4),RIGHT(b.HEADER_CIF,4)),'') as CARD_CODE,"
			+ "b.CUSTOMER_NAME,b.MOBILE_NO,b.EMAIL_ID,b.REJECT_REASON,b.CIF_ID,a.infobip_alert_id,"
			+ "a.infobip_dynamic_tags,b.OTHER_REJ_REASON,ISNULL(b.AD_AMT_DISPUTE,'') as AMT_IN_DISPUTE "
			+ "from NG_TS_TEMPLATE_MAPPING_MASTER a,NG_TS_EXTTABLE b WITH(NOLOCK) "
			+ "WHERE a.SERVICE_NAME=b.SERVICE_TYPE and a.STAGE='" + Stage + "' "
			+ "and a.SUB_PROCESS_NAME='" + Sub_Process_Name + "' "
			+ "and b.WI_NAME='" + getWorkitemName(iformObj) + "' and a.ISACTIVE='Y'";

	List Templates = iformObj.getDataFromDB(qry);
	for (int i = 0; i < Templates.size(); i++) {
		List<String> arr1 = (List) Templates.get(i);
		service_name = arr1.get(0);
		sub_process_name = arr1.get(1);
		from_mailid = arr1.get(2);
		mail_subject = arr1.get(3);
		mail_template = arr1.get(4);
		sms_template = arr1.get(5);
		sms_placeholder = arr1.get(6);
		mail_placeholder = arr1.get(7);
		card_code = arr1.get(8);
		customer_name = arr1.get(9);
		SMS_MOBNO = arr1.get(10);
		MailID = arr1.get(11);
		RejectReason = arr1.get(12);
		CIF_ID = arr1.get(13);
		infobip_Alert_id = arr1.get(14);
		infobip_dynamic_tags = arr1.get(15);
		OtherRejectReason = arr1.get(16);
		AMT_Dispute = arr1.get(17);

		if (!"".equalsIgnoreCase(customer_name) && customer_name != null) {
			CustFirstName = customer_name.split(" ")[0];
		}
	}

	// Prepare tag to column map
	String updateDate = "24-12-1999";
	String wiName = getWorkitemName(iformObj);

	Map<String, String> tagToColumnMap = new HashMap<>();
	tagToColumnMap.put("cARD_CODE", card_code);
	tagToColumnMap.put("wI_NAME", wiName);
	tagToColumnMap.put("dISPUTE_RELATED", "CARD_DISPUTE_TYPE"); // from NG_TS_EXTTABLE
	tagToColumnMap.put("sUB_PROCESS_NAME", Sub_Process_Name);
	tagToColumnMap.put("uPDATE_DATE", updateDate);
	tagToColumnMap.put("aMOUNT_AED", "CSC_AMT_AED"); // from NG_TS_EXTTABLE

	TS.mLogger.debug("tag To ColumnMap : " + tagToColumnMap);

	// Split dynamic tags
	String[] dynamic_tags = infobip_dynamic_tags.split("~");

	// Prepare tag value map
	Map<String, String> tagValueMap = new HashMap<>();
	tagValueMap.put("sLA_TAT", SLA); // DIRECTLY injecting SLA value here

	// Determine extra columns needed from NG_TS_EXTTABLE
	Set<String> extColsToFetch = new HashSet<>();
	for (String tag : dynamic_tags) {
		String column = tagToColumnMap.get(tag);
		if ("CARD_DISPUTE_TYPE".equals(column) || "CSC_AMT_AED".equals(column)) {
			extColsToFetch.add(column);
		}
	}

	// Fetch data for additional required columns from NG_TS_EXTTABLE
	if (!extColsToFetch.isEmpty()) {
		String colStr = String.join(",", extColsToFetch);
		String sql = "SELECT " + colStr + " FROM NG_TS_EXTTABLE WITH(NOLOCK) WHERE WI_NAME = '" + wiName + "'";
		List extResult = iformObj.getDataFromDB(sql);
		if (!extResult.isEmpty()) {
			List<String> row = (List<String>) extResult.get(0);
			int i = 0;
			for (String col : extColsToFetch) {
				tagValueMap.put(getTagByValue(tagToColumnMap, col), row.get(i++));
			}
		}
	}

	// Fill in remaining tag values
	for (String tag : dynamic_tags) {
		if (!tagValueMap.containsKey(tag)) {
			String val = tagToColumnMap.get(tag);
			if (val != null) {
				tagValueMap.put(tag, val);
			}
		}
	}

	// Build final dynamic value string
	List<String> dynamicValuesList = new ArrayList<>();
	for (String tag : dynamic_tags) {
		String value = tagValueMap.getOrDefault(tag, "");
		dynamicValuesList.add(value);
	}

	String DynamicValues;
	if ("BPMFOLLOWUP".equalsIgnoreCase(infobip_Alert_id) || "BPMCLSNOT".equalsIgnoreCase(infobip_Alert_id)) {
		DynamicValues = wiName;
	} else {
		DynamicValues = String.join("~#~", dynamicValuesList);
	}

	TS.mLogger.debug("Final Dynamic Values: " + DynamicValues);
} catch (Exception e) {
	TS.mLogger.error("Error generating dynamic tag values", e);
}
