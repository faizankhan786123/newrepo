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
			 
			 
