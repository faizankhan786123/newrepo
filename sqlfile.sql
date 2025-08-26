String strQuery1 = "select top 10 * from USR_0_INFOBIP_SMS_QUEUETABLE  with (NOLOCK) where Alert_Status='P'";
				String fetchIInputXML = objXmlGen.APSelectWithColumnNames(cabinetName, strQuery1);
				logger.info("Input XML Infobip SMS Queue Table----->" + fetchIInputXML);

				String fetchIOutputXML = ngEjbClientConnection.makeCall(fetchIInputXML);
				logger.info("Output XML Infobip SMS Queue Table----->" + fetchIOutputXML);

				XMLParser xmlParserData = new XMLParser(fetchIOutputXML);

				int employerDetails_totalRetreived = Integer.parseInt(xmlParserData.getValueOf("TotalRetrieved"));

				if (xmlParserData.getValueOf("MainCode").equalsIgnoreCase("0") && employerDetails_totalRetreived > 0) {
					String xmlParserData_val = xmlParserData.getNextValueOf("Record");
					logger.info("employerDetails_totalRetreived : " + xmlParserData_val);
					xmlParserData_val = xmlParserData_val.replaceAll("[ ]+>", ">").replaceAll("<[ ]+", "<");
					// replace the spcl char above.
					NGXmlList objWorkList = xmlParserData.createList("Records", "Record");

					// Store the data to process later outside the loop
					List<Map<String, String>> dataList = new ArrayList<>();

					for (; objWorkList.hasMoreElements(true); objWorkList.skip(true)) {
						String Infobip_EventID = objWorkList.getVal("Infobip_EventID");
						String Processname = objWorkList.getVal("Processname");
						String WI_NAME = objWorkList.getVal("WI_NAME");
						String AlertID = objWorkList.getVal("AlertID");
						String CIF = objWorkList.getVal("CIF");
						String Dynamic_Tags = objWorkList.getVal("Dynamic_Tags");
						String Dynamic_Values = objWorkList.getVal("Dynamic_Values");
						String Trigger_Status = objWorkList.getVal("Alert_Status");
						String Infobip_No_Of_Retry = objWorkList.getVal("Infobip_No_Of_Retry");
						String MobileNumber = objWorkList.getVal("MobileNumber");
						String SMS_Content = objWorkList.getVal("SMS_Content");

						logger.info("Values fetched from DB: " + Infobip_EventID + "\n" + Processname + "\n" + WI_NAME
								+ "\n" + AlertID + "\n" + CIF + "\n" + Dynamic_Tags + "\n" + Dynamic_Values + "\n"
								+ Trigger_Status + "\n" + Infobip_No_Of_Retry + "\n" + MobileNumber + "\n"
								+ SMS_Content);

						if ("".equals(Infobip_No_Of_Retry) || Infobip_No_Of_Retry == null) {
							Infobip_No_Of_Retry = "0";
						}
						if (Integer.parseInt(Infobip_No_Of_Retry) < 5) {
							// Store data for later processing
							Map<String, String> dataMap = new HashMap<>();
							dataMap.put("Infobip_EventID", Infobip_EventID);
							dataMap.put("Processname", Processname);
							dataMap.put("WI_NAME", WI_NAME);
							dataMap.put("AlertID", AlertID);
							dataMap.put("CIF", CIF);
							dataMap.put("Dynamic_Tags", Dynamic_Tags);
							dataMap.put("Dynamic_Values", Dynamic_Values);
							dataMap.put("Alert_Status", Trigger_Status);
							dataMap.put("Infobip_No_Of_Retry", Infobip_No_Of_Retry);
							// change by faizan khan 22-8-2025 start
							dataMap.put("MobileNumber", MobileNumber);
							dataMap.put("SMS_Content", SMS_Content);

							// change by faizan khan 22-8-2025 start

							dataList.add(dataMap);
						}
					}

					for (Map<String, String> data : dataList) {
						String Infobip_EventID = data.get("Infobip_EventID");
						String AlertID = data.get("AlertID");
						String CIF = data.get("CIF");
						String Dynamic_Tags = data.get("Dynamic_Tags");
						String Dynamic_Values = data.get("Dynamic_Values");
						String Infobip_No_Of_Retry = data.get("Infobip_No_Of_Retry");
						String Mobile_Number = data.get("MobileNumber");
						String SMS_Content = data.get("SMS_Content");

						String dynamicURL = baseUrl + "/peopleevents/2/persons/" + CIF + "." + CIF + "/definitions/"
								+ AlertID + "/events";

						String[] tags = Dynamic_Tags.split("~");
						String[] values = Dynamic_Values.split("~#~");

						logger.info("Tags Array: " + Arrays.toString(tags));
						logger.info("Values Array: " + Arrays.toString(values));

						Map<String, String> map = new HashMap<>();
						try {
							for (int i = 0; i < tags.length; i++) {
								map.put(tags[i], values[i]);
							}
						} catch (Exception e) {
							logger.error("Exception while iterating tags: " + CentralRunner.customException(e));
						}

						logger.info("Final Map: " + map);
						JSONObject reqBody = new JSONObject(map);
						JSONObject finalRequestJSON = new JSONObject();
						finalRequestJSON.put("properties", reqBody);

						//  Add fallbackDetails object
						JSONObject fallbackDetails = new JSONObject();
						fallbackDetails.put("mobileNo", Mobile_Number);
						fallbackDetails.put("smsMessage", SMS_Content);

						finalRequestJSON.put("fallbackDetails", fallbackDetails);

						String requestBody = finalRequestJSON.toString();
						logger.info("Final JSON Request: " + requestBody);

//						String requestBody = finalRequestJSON.toString();
						// Call the POST API
						String requestTime = getCurrentTime();

						if ("".equalsIgnoreCase(Dynamic_Tags) || Dynamic_Tags.length() == 0) {
//							requestBody = "{\r\n" + "\"properties\":\r\n" + "{}\r\n" + "}";
							
							requestBody = "{\r\n" +
						            "\"properties\": {},\r\n" +
						            "\"fallbackDetails\": {\r\n" +
						            "   \"mobileNo\": \"" + Mobile_Number + "\",\r\n" +
						            "   \"smsMessage\": \"" + SMS_Content + "\"\r\n" +
						            "}\r\n" +
						            "}";
						}
						
						

						logger.info("Final Request JSON:\n" + requestBody);
						logger.info("Final Request URL:\n" + dynamicURL);
						String output = CIFSMSpostAPI(dynamicURL, requestBody);
						String[] postAPIResponse = output.split("~");
						int responseCode = Integer.parseInt(postAPIResponse[0]);
						String responseJson = postAPIResponse[1];

						// Capture the request and response time
						String responseTime = getCurrentTime();
						// String requestJson = finalRequestJSON.toString();

						crObj.pushDataIntoDB(cabinetName, SessionId, "NG_INFOBIP_JSON_LOGHISTORY", Infobip_EventID,
								requestTime, responseTime, requestBody, responseJson, logger);

						if (responseCode == 200) {
							logger.info("SMS sent successfully for CIF: " + CIF + ", AlertID: " + AlertID);
							// status = D, No of tries +1, response message
							crObj.updateUSRTable(cabinetName, SessionId, responseCode, responseJson,
									Infobip_No_Of_Retry, Infobip_EventID, "USR_0_INFOBIP_SMS_QUEUETABLE", logger);

						} else {

							logger.error("SMS failed for CIF: " + CIF + ", AlertID: " + AlertID + ". Response code: "
									+ responseCode);
							crObj.updateUSRTable(cabinetName, SessionId, responseCode, responseJson,
									Infobip_No_Of_Retry, Infobip_EventID, "USR_0_INFOBIP_SMS_QUEUETABLE", logger);
							// status = P, No of tries +1, response message
						}
					}
