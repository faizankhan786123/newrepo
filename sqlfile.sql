String dynamic_tags[] = infobip_dynamic_tags.split("~");

			Map<String, String> tagToColumnMap = new HashMap<>();
			tagToColumnMap.put("sLA_TAT", "SLA_TAT");
			tagToColumnMap.put("cARD_CODE", "CARD_CODE");
			tagToColumnMap.put("wI_NAME", "WI_Name");
			tagToColumnMap.put("dISPUTE_RELATED", "DISPUTE_RELATED");
			tagToColumnMap.put("sUB_PROCESS_NAME", "SUB_PROCESS");

			List<String> selectedColumns = new ArrayList<>();
			List<String> matchedTags = new ArrayList<>();

			for (String tag : dynamic_tags) {
				if (tagToColumnMap.containsKey(tag)) {
					selectedColumns.add(tagToColumnMap.get(tag));
					matchedTags.add(tag);

				}

			}

			Map<String, String> tagValueMap = new HashMap();
			
			if(!selectedColumns.isEmpty()) {
				String ColumnList=String.join(",", selectedColumns);
				String wiName = getWorkitemName(iformObj);
				 String sql = "SELECT " + columnList + " FROM NG_TS_EXTTABLE WITH(NOLOCK) WHERE WI_NAME = '" + wiName + "'";
				 
				 List queryResult  = iformObj.getDataFromDB(sql);
				 
				 if (!queryResult.isEmpty()) {
			            List<String> row = (List<String>) queryResult.get(0);
			            for (int i = 0; i < matchedTags.size(); i++) {
			                tagValueMap.put(matchedTags.get(i), row.get(i));
			            }
			        }
			}
			 String DynamicValues = "";
			 
			 List<String> dynamicValuesList = new ArrayList<>();
		        for (String tag : dynamicTags) {
		            if (tagValueMap.containsKey(tag)) {
		                dynamicValuesList.add(tagValueMap.get(tag));
		            }
		        }
		        DynamicValues = String.join("~#~", dynamicValuesList);
		        CPMS.mLogger.debug("Dynamic Values: " + DynamicValues);
		    }






String qry = "select top 1 a.SERVICE_NAME,ISNULL(ISNULL(b.CSC_REQUEST_TYPE,b.RP_REQUEST_TYPE),'') as SUB_PROCESS,a.FROM_MAILID,"
					+ "a.MAIL_SUBJECT,a.MAIL_TEMPLATE,a.SMS_TEMPLATE,a.SMS_PLACEHOLDER,a.MAIL_PLACEHOLDER,"
					+ "ISNULL(COALESCE(RIGHT(b.HEADER_CARD_NO,4),RIGHT(b.HEADER_CIF,4)),'') as CARD_CODE,"
					+ "b.CUSTOMER_NAME,b.MOBILE_NO,b.EMAIL_ID,b.REJECT_REASON,b.CIF_ID,a.infobip_alert_id,a.infobip_dynamic_tags,b.OTHER_REJ_REASON,ISNULL(b.AD_AMT_DISPUTE,'') as AMT_IN_DISPUTE from NG_TS_TEMPLATE_MAPPING_MASTER a,NG_TS_EXTTABLE b WITH(NOLOCK) "
					+ "WHERE a.SERVICE_NAME=b.SERVICE_TYPE and a.STAGE='" + Stage + "' " + "and a.SUB_PROCESS_NAME='"
					+ Sub_Process_Name + "' " + "and b.WI_NAME='" + getWorkitemName(iformObj) + "' and a.ISACTIVE='Y'";




// faizan khan start
				CIF_ID = arr1.get(13);
				infobip_Alert_id = arr1.get(14);
				infobip_dynamic_tags = arr1.get(15);
				// faizan khan end

				OtherRejectReason = arr1.get(16);
				AMT_Dispute = arr1.get(17);
