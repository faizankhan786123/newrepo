package com.newgen.util;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.json.JSONObject;
import com.newgen.wfdesktop.xmlapi.WFCallBroker;
import com.newgen.omni.wf.util.app.NGEjbClient;
import com.newgen.omni.wf.util.excp.NGException;
import com.newgen.omni.jts.cmgr.NGXmlList;
import com.newgen.omni.jts.cmgr.XMLParser;

public class InfoBipCIFSMS implements Runnable {
	private static Logger logger = Logger.getLogger("InfoBipCIFLogger");
	private String cabinetName = SMSAutoService.cabinetName;
	private String jtsIP = SMSAutoService.jtsIP;
	private String jtsPort = SMSAutoService.jtsPort;
	private String username = SMSAutoService.username;
	private String pass = SMSAutoService.password;
	private String baseUrl = SMSAutoService.InfoBIP_ENDPOINTURL;
	private String SessionId = SMSAutoService.sessionID;
	private static final NGEjbClient ngEjbClientConnection = CentralRunner.getConnection();
	private String URL = SMSAutoService.InfoBIP_ENDPOINTURL;

	LoggerManager manager = new LoggerManager();
	GenerateXml objXmlGen = new GenerateXml();
	CentralRunner crObj = new CentralRunner();
	SMSAutoService smsobj = new SMSAutoService();
	public static User userPass = new User();

	private static final int MAX_RETRY = 5; // 🔥 FIX: configurable retry limit

	@Override
	public void run() {
		try {
			logger.info("CIF Thread Started : ");
			manager.createLogFile();
			String startTime = SMSAutoService.TimeToRun2;
			String endTime = SMSAutoService.TimeToRun3;

			username = userPass.getUsername();
			pass = userPass.getPassword();

			logger.info("Username for WM Connect ----->" + username);
			logger.info("Pass for WM Connect ----->" + pass);
			logger.info("Session ID before : " + SMSAutoService.sessionID);
			SessionId = smsobj.getSessionID();
			logger.info("Session ID after: " + SessionId);
			LocalTime start = LocalTime.parse(startTime);
			LocalTime end = LocalTime.parse(endTime);

			LocalTime now = LocalTime.now();
			boolean inRange = false;
			if (start.isBefore(end)) {
				inRange = !now.isBefore(start) && now.isBefore(end);
			}

			logger.info("startTime = " + start);
			logger.info("endTime = " + end);
			logger.info("nowTime = " + now);
			if (inRange) {

				String wmConnectIPXML = objXmlGen.getConnectInputXML(cabinetName, username, pass);
				logger.info("Input XML WM Connect ----->" + wmConnectIPXML);
				String wmConnectOPXML = ngEjbClientConnection.makeCall(wmConnectIPXML);

				logger.info("Output XML WM Connect ----->" + wmConnectOPXML);
				XMLParser xmlParserConnect = new XMLParser(wmConnectOPXML);
				SessionId = xmlParserConnect.getValueOf("SessionId");
				logger.info("Session ID: " + SessionId);

				if (SessionId == null || SessionId.trim().isEmpty()) {
					logger.info("Session ID not found exiting...... ");
					return;
				}

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
					NGXmlList objWorkList = xmlParserData.createList("Records", "Record");

					List<Map<String, String>> dataList = new ArrayList<>();

					for (; objWorkList.hasMoreElements(true); objWorkList.skip(true)) {
						Map<String, String> dataMap = new HashMap<>();
						dataMap.put("Infobip_EventID", objWorkList.getVal("Infobip_EventID"));
						dataMap.put("Processname", objWorkList.getVal("Processname"));
						dataMap.put("WI_NAME", objWorkList.getVal("WI_NAME"));
						dataMap.put("AlertID", objWorkList.getVal("AlertID"));
						dataMap.put("CIF", objWorkList.getVal("CIF"));
						dataMap.put("Dynamic_Tags", objWorkList.getVal("Dynamic_Tags"));
						dataMap.put("Dynamic_Values", objWorkList.getVal("Dynamic_Values"));
						dataMap.put("Alert_Status", objWorkList.getVal("Alert_Status"));
						dataMap.put("Infobip_No_Of_Retry", objWorkList.getVal("Infobip_No_Of_Retry"));
						dataMap.put("MobileNumber", objWorkList.getVal("MobileNumber"));
						dataMap.put("SMS_Content", objWorkList.getVal("SMS_Content"));

						if ("".equals(dataMap.get("Infobip_No_Of_Retry")) || dataMap.get("Infobip_No_Of_Retry") == null) {
							dataMap.put("Infobip_No_Of_Retry", "0");
						}
						if (Integer.parseInt(dataMap.get("Infobip_No_Of_Retry")) < MAX_RETRY) {
							dataList.add(dataMap);
						}
					}

					for (Map<String, String> data : dataList) {
						String Infobip_EventID = data.get("Infobip_EventID");
						String AlertID = data.get("AlertID");
						String CIF_ID = data.get("CIF");
						String Dynamic_Tags = data.get("Dynamic_Tags");
						String Dynamic_Values = data.get("Dynamic_Values");
						String Infobip_No_Of_Retry = data.get("Infobip_No_Of_Retry");
						String Mobile_Number = data.get("MobileNumber");
						String SMS_Content = data.get("SMS_Content");

						String dynamicURL = baseUrl + "/peopleevents/2/persons/" + CIF_ID + "." + CIF_ID
								+ "/definitions/" + AlertID + "/events";

						String[] tags = Dynamic_Tags != null ? Dynamic_Tags.split("~") : new String[0];
						String[] values = Dynamic_Values != null ? Dynamic_Values.split("~#~") : new String[0];

						Map<String, String> map = new HashMap<>();
						int minLength = Math.min(tags.length, values.length);
						for (int i = 0; i < minLength; i++) {
							map.put(tags[i], values[i]);
						}

						JSONObject finalRequestJSON = new JSONObject();
						finalRequestJSON.put("properties", new JSONObject(map));

						JSONObject fallbackDetails = new JSONObject();
						fallbackDetails.put("mobileNo", Mobile_Number);
						fallbackDetails.put("smsMessage", SMS_Content);
						finalRequestJSON.put("fallbackDetails", fallbackDetails);

						String requestBody = finalRequestJSON.toString();
						String requestTime = getCurrentTime();

						if (Dynamic_Tags == null || Dynamic_Tags.trim().isEmpty()) {
							requestBody = "{\n" + "\"properties\": {},\n" + "\"fallbackDetails\": {\n"
									+ "   \"mobileNo\": \"" + Mobile_Number + "\",\n" + "   \"smsMessage\": \"" + SMS_Content
									+ "\"\n" + "}\n" + "}";
						}

						// 🔥 FIX: Safe CIF null check
						if (CIF_ID == null || CIF_ID.trim().isEmpty()) {
							logger.info("Inside Non-CIF flow");
							String requestBodynonCif = "{\n" + "  \"messages\": [\n" + "    {\n"
									+ "      \"from\": \"RAKBANK\",\n" + "      \"destinations\": [\n" + "        {\n"
									+ "          \"to\": \"{{MOBILE}}\"\n" + "        }\n" + "      ],\n"
									+ "      \"text\": \"{{MESSAGE}}\"\n" + "    }\n" + "  ]\n" + "}";
							String finalJsonforNonCif = requestBodynonCif.replace("{{MOBILE}}", Mobile_Number)
									.replace("{{MESSAGE}}", SMS_Content);

							String output = NonCIFSMSPostApi(URL, finalJsonforNonCif);
							String[] postAPIResponse = output.split("~");
							int responseCode = Integer.parseInt(postAPIResponse[0]);
							String responseJson = postAPIResponse[1];
							String responseTime = getCurrentTime();

							crObj.pushDataIntoDB(cabinetName, SessionId, "NG_INFOBIP_JSON_LOGHISTORY", Infobip_EventID,
									requestTime, responseTime, finalJsonforNonCif, responseJson, logger);

							// 🔥 FIX: handle 500 separately
							if (responseCode == 500) {
								logger.error("500 error - No retry. EventID: " + Infobip_EventID);
								crObj.updateUSRTable(cabinetName, SessionId, responseCode, responseJson,
										Infobip_No_Of_Retry, Infobip_EventID, "USR_0_INFOBIP_SMS_QUEUETABLE", logger);
							} else if (responseCode == 200) {
								logger.info("SMS API executed successfully: " + Infobip_EventID);
								crObj.updateUSRTable(cabinetName, SessionId, responseCode, responseJson,
										Infobip_No_Of_Retry, Infobip_EventID, "USR_0_INFOBIP_SMS_QUEUETABLE", logger);
							} else {
								logger.error("SMS API Failed for eventID: " + Infobip_EventID);
								crObj.updateUSRTable(cabinetName, SessionId, responseCode, responseJson,
										Infobip_No_Of_Retry, Infobip_EventID, "USR_0_INFOBIP_SMS_QUEUETABLE", logger);
							}
						} else {
							String output = CIFSMSpostAPI(dynamicURL, requestBody);
							String[] postAPIResponse = output.split("~");
							int responseCode = Integer.parseInt(postAPIResponse[0]);
							String responseJson = postAPIResponse[1];
							String responseTime = getCurrentTime();

							crObj.pushDataIntoDB(cabinetName, SessionId, "NG_INFOBIP_JSON_LOGHISTORY", Infobip_EventID,
									requestTime, responseTime, requestBody, responseJson, logger);

							// 🔥 FIX: handle 500 separately
							if (responseCode == 500) {
								logger.error("500 error - No retry. CIF_ID: " + CIF_ID + ", AlertID: " + AlertID);
								crObj.updateUSRTable(cabinetName, SessionId, responseCode, responseJson,
										Infobip_No_Of_Retry, Infobip_EventID, "USR_0_INFOBIP_SMS_QUEUETABLE", logger);
							} else if (responseCode == 200) {
								logger.info("SMS sent successfully for CIF_ID: " + CIF_ID + ", AlertID: " + AlertID);
								crObj.updateUSRTable(cabinetName, SessionId, responseCode, responseJson,
										Infobip_No_Of_Retry, Infobip_EventID, "USR_0_INFOBIP_SMS_QUEUETABLE", logger);
							} else {
								logger.error("SMS failed for CIF_ID: " + CIF_ID + ", AlertID: " + AlertID
										+ ". Response code: " + responseCode);
								crObj.updateUSRTable(cabinetName, SessionId, responseCode, responseJson,
										Infobip_No_Of_Retry, Infobip_EventID, "USR_0_INFOBIP_SMS_QUEUETABLE", logger);
							}
						}
					}
				}
			} else {
				logger.info("Out of time range....sleeping");
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		logger.info("CIF Thread Ended : ");
	}

	public static String CIFSMSpostAPI(String URL, String requestBody) {
		try {
			CentralRunner.loadSSL();
			URL postUrl = new URL(URL);
			HttpURLConnection postConnection = (HttpURLConnection) postUrl.openConnection();
			postConnection.setRequestMethod("POST");
			postConnection.setRequestProperty("Accept", "application/json");
			postConnection.setRequestProperty("Content-Type", "application/json");
			postConnection.setRequestProperty("source", "BPM");
			postConnection.setDoOutput(true);

			try (DataOutputStream outputStream = new DataOutputStream(postConnection.getOutputStream())) {
				outputStream.writeBytes(requestBody);
				outputStream.flush();
			}

			int postResponseCode = postConnection.getResponseCode();
			StringBuilder postResponse = new StringBuilder();
			try (BufferedReader reader = new BufferedReader(new InputStreamReader(
					postResponseCode >= 400 ? postConnection.getErrorStream() : postConnection.getInputStream()))) {
				String inputLine;
				while ((inputLine = reader.readLine()) != null) {
					postResponse.append(inputLine);
				}
			}
			postConnection.disconnect();
			return postResponseCode + "~" + postResponse.toString();

		} catch (IOException ioEx) {
			logger.error("HTTP Connection Error: " + ioEx.getMessage(), ioEx);
			return "-1~Failure " + ioEx.getMessage();
		} catch (Exception e) {
			logger.error("General Error: " + e.getMessage(), e);
			return "-2~ " + e.getMessage();
		}
	}

	private String getCurrentTime() {
		return java.time.LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss.SSS"));
	}

	public static String NonCIFSMSPostApi(String URL, String requestBody) {
		String dynamicURL = URL + "/sms/2/text/advanced";
		try {
			CentralRunner.loadSSL();
			URL postUrl = new URL(dynamicURL);
			HttpURLConnection postConnection = (HttpURLConnection) postUrl.openConnection();
			postConnection.setRequestMethod("POST");
			postConnection.setRequestProperty("Accept", "application/json");
			postConnection.setRequestProperty("Content-Type", "application/json");
			postConnection.setRequestProperty("source", "BPM");
			postConnection.setDoOutput(true);

			try (DataOutputStream outputStream = new DataOutputStream(postConnection.getOutputStream())) {
				outputStream.writeBytes(requestBody);
				outputStream.flush();
			}

			int postResponseCode = postConnection.getResponseCode();
			StringBuilder postResponse = new StringBuilder();
			try (BufferedReader reader = new BufferedReader(new InputStreamReader(
					postResponseCode >= 400 ? postConnection.getErrorStream() : postConnection.getInputStream()))) {
				String inputLine;
				while ((inputLine = reader.readLine()) != null) {
					postResponse.append(inputLine);
				}
			}
			postConnection.disconnect();
			return postResponseCode + "~" + postResponse.toString();

		} catch (IOException ioEx) {
			logger.error("HTTP Connection Error: " + ioEx.getMessage(), ioEx);
			return "-1~Failure: " + ioEx.getMessage();
		} catch (Exception e) {
			logger.error("Error: " + e.getMessage());
			return "Exception Occured in: " + e.getMessage();
		}
	}
}
