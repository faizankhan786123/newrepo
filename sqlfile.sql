TS.mLogger.debug("Sub Process Name : " + Sub_Process_Name);
			// Prepare tag to column map
			String updateDate = tentative_date;
			String wiName = getWorkitemName(iformObj);

			Map<String, String> tagToColumnMap = new HashMap<>();
			tagToColumnMap.put("cARD_CODE", card_code);
			tagToColumnMap.put("wI_NAME", wiName);
			tagToColumnMap.put("dISPUTE_RELATED", "CARD_DISPUTE_TYPE"); // from
																		// NG_TS_EXTTABLE
			tagToColumnMap.put("sUB_PROCESS_NAME", Sub_Process_Name);
			tagToColumnMap.put("uPDATE_DATE", updateDate);
			tagToColumnMap.put("aMOUNT_AED", "CSC_AMT_AED"); // from
																// NG_TS_EXTTABLE

			TS.mLogger.debug("tag To ColumnMap : " + tagToColumnMap);

			// Split dynamic tags
			String[] dynamic_tags = infobip_dynamic_tags.split("~");

			// Prepare tag value map
			Map<String, String> tagValueMap = new HashMap<>();
			tagValueMap.put("sLA_TAT", SLA); // DIRECTLY injecting SLA value
												// here
			TS.mLogger.debug("TAG TO Column : " + tagToColumnMap);

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
