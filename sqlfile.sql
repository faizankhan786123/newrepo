String qry = "select top 1 a.SERVICE_NAME,ISNULL(ISNULL(b.CSC_REQUEST_TYPE,b.RP_REQUEST_TYPE),'') as SUB_PROCESS,a.FROM_MAILID,"
					+ "a.MAIL_SUBJECT,a.MAIL_TEMPLATE,a.SMS_TEMPLATE,a.SMS_PLACEHOLDER,a.MAIL_PLACEHOLDER,"
					+ "ISNULL(COALESCE(RIGHT(b.HEADER_CARD_NO,4),RIGHT(b.HEADER_CIF,4)),'') as CARD_CODE,"
					+ "b.CUSTOMER_NAME,b.MOBILE_NO,b.EMAIL_ID,b.REJECT_REASON,b.CIF_ID,a.infobip_alert_id,a.infobip_dynamic_tags,b.OTHER_REJ_REASON,ISNULL(b.AD_AMT_DISPUTE,'') as AMT_IN_DISPUTE from NG_TS_TEMPLATE_MAPPING_MASTER a,NG_TS_EXTTABLE b WITH(NOLOCK) "
					+ "WHERE a.SERVICE_NAME=b.SERVICE_TYPE and a.STAGE='" + Stage + "' " + "and a.SUB_PROCESS_NAME='"
					+ Sub_Process_Name + "' " + "and b.WI_NAME='" + getWorkitemName(iformObj) + "' and a.ISACTIVE='Y'";
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
				// faizan khan start
				CIF_ID = arr1.get(13);
				infobip_Alert_id = arr1.get(14);
				infobip_dynamic_tags = arr1.get(15);
				// faizan khan end

				OtherRejectReason = arr1.get(16);
				AMT_Dispute = arr1.get(17);

				if (!"".equalsIgnoreCase(customer_name) && customer_name != null) {
					CustFirstName = customer_name.split(" ")[0];
				}
			}

			String dynamic_tags[] = infobip_dynamic_tags.split("~");
			TS.mLogger.debug("Dynamic Tags : " + dynamic_tags);
			
			String updateDate="24-12-1999";

			Map<String, String> tagToColumnMap = new HashMap<>();
			tagToColumnMap.put("sLA_TAT", "SLA");  // for sla we have to use join query  SELECT SLA FROM NG_TS_SERVICE_REQUEST_MASTER
			tagToColumnMap.put("cARD_CODE", "CARD_CODE"); //header card number
			tagToColumnMap.put("wI_NAME", "WI_Name");  
			tagToColumnMap.put("dISPUTE_RELATED", "DISPUTE_RELATED");//card dispute typoe
			tagToColumnMap.put("sUB_PROCESS_NAME", "SUB_PROCESS_NAME"); // NG_TS_TEMPLATE_MAPPING_MASTER  from this master table 
			tagToColumnMap.put("uPDATE_DATE", updateDate);
			tagToColumnMap.put("aMOUNT_AED", "SUB_PROCESS"); //CSC_AMT_AED
			

			TS.mLogger.debug("Tag to Column : " + tagToColumnMap);

			List<String> selectedColumns = new ArrayList<>();
			List<String> matchedTags = new ArrayList<>();

			for (String tag : dynamic_tags) {
				if (tagToColumnMap.containsKey(tag)) {
					selectedColumns.add(tagToColumnMap.get(tag));
					matchedTags.add(tag);

				}

			}
			Map<String, String> tagValueMap = new HashMap();
			if (!selectedColumns.isEmpty()) {
				String ColumnList = String.join(",", selectedColumns);
				String wiName = getWorkitemName(iformObj);
				String sql = "SELECT " + ColumnList + " FROM NG_TS_EXTTABLE WITH(NOLOCK) WHERE WI_NAME = '" + wiName
						+ "'";

				List queryResult = iformObj.getDataFromDB(sql);

				TS.mLogger.debug("Result : " + queryResult);

				if (!queryResult.isEmpty()) {
					List<String> row = (List<String>) queryResult.get(0);
					for (int i = 0; i < matchedTags.size(); i++) {
						tagValueMap.put(matchedTags.get(i), row.get(i));
					}
				}
			}
			TS.mLogger.debug("Tag value : " + tagValueMap);

			String DynamicValues = "";

			List<String> dynamicValuesList = new ArrayList<>();
			for (String tag : dynamic_tags) {
				if (tagValueMap.containsKey(tag)) {
					dynamicValuesList.add(tagValueMap.get(tag));
				}
			}
			DynamicValues = String.join("~#~", dynamicValuesList);
			TS.mLogger.debug("Dynamic Values: " + DynamicValues);
