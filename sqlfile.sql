logger.info("Final Map: " + map);
JSONObject reqBody = new JSONObject(map);
JSONObject finalRequestJSON = new JSONObject();
finalRequestJSON.put("properties", reqBody);

// ✅ Add fallbackDetails object
JSONObject fallbackDetails = new JSONObject();
fallbackDetails.put("mobileNo", Mobile_Number);
fallbackDetails.put("smsMessage", SMS_Content);

finalRequestJSON.put("fallbackDetails", fallbackDetails);

String requestBody = finalRequestJSON.toString();
logger.info("Final JSON Request: " + requestBody);
