TS.mLogger.debug("Sub Process Name : " + Sub_Process_Name);

// Prepare tag to column map
String updateDate = tentative_date;
String wiName = getWorkitemName(iformObj);

Map<String, String> tagToColumnMap = new HashMap<>();
tagToColumnMap.put("cARD_CODE", card_code);
tagToColumnMap.put("wI_NAME", wiName);
tagToColumnMap.put("dISPUTE_RELATED", "CARD_DISPUTE_TYPE"); // from NG_TS_EXTTABLE
tagToColumnMap.put("sUB_PROCESS_NAME", Sub_Process_Name);
tagToColumnMap.put("uPDATE_DATE", updateDate);
tagToColumnMap.put("aMOUNT_AED", "AMT_IN_AED"); // from NG_TS_TRANS_DISPUTE_GRID_DTLS

TS.mLogger.debug("tag To ColumnMap : " + tagToColumnMap);

// Split dynamic tags
String[] dynamic_tags = infobip_dynamic_tags.split("~");

// Prepare tag value map
Map<String, String> tagValueMap = new HashMap<>();
tagValueMap.put("sLA_TAT", SLA); // DIRECTLY injecting SLA value
TS.mLogger.debug("TAG TO Column : " + tagToColumnMap);

// Separate columns for each table
Set<String> extColsFromEXTTABLE = new HashSet<>();
Set<String> extColsFromDISPUTE = new HashSet<>();

for (String tag : dynamic_tags) {
    String column = tagToColumnMap.get(tag);
    if (column == null) continue;

    if ("CARD_DISPUTE_TYPE".equals(column)) {
        extColsFromEXTTABLE.add(column);
    } else if ("AMT_IN_AED".equals(column)) {
        extColsFromDISPUTE.add(column);
    }
}

// Fetch from NG_TS_EXTTABLE
if (!extColsFromEXTTABLE.isEmpty()) {
    String colStr = String.join(",", extColsFromEXTTABLE);
    String sql = "SELECT " + colStr + " FROM NG_TS_EXTTABLE WITH(NOLOCK) WHERE WI_NAME = '" + wiName + "'";
    List extResult = iformObj.getDataFromDB(sql);
    if (!extResult.isEmpty()) {
        List<String> row = (List<String>) extResult.get(0);
        int i = 0;
        for (String col : extColsFromEXTTABLE) {
            tagValueMap.put(getTagByValue(tagToColumnMap, col), row.get(i++));
        }
    }
}

// Fetch from NG_TS_TRANS_DISPUTE_GRID_DTLS
if (!extColsFromDISPUTE.isEmpty()) {
    String colStr = String.join(",", extColsFromDISPUTE);
    String sql = "SELECT " + colStr + " FROM NG_TS_TRANS_DISPUTE_GRID_DTLS WITH(NOLOCK) WHERE WI_NAME = '" + wiName + "'";
    List extResult = iformObj.getDataFromDB(sql);
    if (!extResult.isEmpty()) {
        List<String> row = (List<String>) extResult.get(0);
        int i = 0;
        for (String col : extColsFromDISPUTE) {
            tagValueMap.put(getTagByValue(tagToColumnMap, col), row.get(i++));
        }
    }
}
