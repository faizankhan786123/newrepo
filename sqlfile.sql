{
  "properties": {
    "dynamicKey1": "value1",
    "dynamicKey2": "value2"
  },
  "fallbackDetails": {
    "mobileNo": "971586660000",
    "smsMessage": "Fallback SMS message in case of failure."
  }
}



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
	// private static NGEjbClient ngEjbClientConnection;
	private static final NGEjbClient ngEjbClientConnection = CentralRunner.getConnection();

	LoggerManager manager = new LoggerManager();
	GenerateXml objXmlGen = new GenerateXml();
	CentralRunner crObj = new CentralRunner();
	SMSAutoService smsobj = new SMSAutoService();
	public static User userPass = new User();
	/*
	 * static { try { ngEjbClientConnection = NGEjbClient.getSharedInstance();
	 * ngEjbClientConnection.initialize("10.15.12.164", "3333", "JTS"); } catch
	 * (NGException e) { e.printStackTrace(); } }
	 */

	// public InfoBipCIFSMS() {
	// manager.createLogFile();
	// }

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

						String requestBody = finalRequestJSON.toString();
						// Call the POST API
						String requestTime = getCurrentTime();

						if ("".equalsIgnoreCase(Dynamic_Tags) || Dynamic_Tags.length() == 0) {
							requestBody = "{\r\n" + "\"properties\":\r\n" + "{}\r\n" + "}";
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

				}
			} else {
				logger.info("Out of time range....sleeping");
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		logger.info("CIF Thread Ended : ");
		// try {
		// Thread.sleep(SMSAutoService.sleepTimeToWait);
		// } catch (Exception thread) {
		// logger.info("Thread = " + thread);
		// }
	}

	public static String CIFSMSpostAPI(String URL, String requestBody) {
		try {
			// Load SSL certs or custom trust settings
			CentralRunner.loadSSL();

			// Open URL connection
			URL postUrl = new URL(URL);
			HttpURLConnection postConnection = (HttpURLConnection) postUrl.openConnection();
			logger.info("After URL connection:");

			// Set request method and headers
			postConnection.setRequestMethod("POST");
			postConnection.setRequestProperty("Accept", "application/json");
			postConnection.setRequestProperty("Content-Type", "application/json");
			postConnection.setRequestProperty("source", "BPM");
			postConnection.setDoOutput(true);

			// Send request
			logger.info("After JSON Request Construction: " + requestBody);
			try (DataOutputStream outputStream = new DataOutputStream(postConnection.getOutputStream())) {
				outputStream.writeBytes(requestBody);
				outputStream.flush();
			}

			logger.info("After Output Stream flush");

			// Read response
			int postResponseCode = postConnection.getResponseCode();
			logger.info("Response Code: " + postResponseCode);

			StringBuilder postResponse = new StringBuilder();
			try (BufferedReader reader = new BufferedReader(new InputStreamReader(
					postResponseCode >= 400 ? postConnection.getErrorStream() : postConnection.getInputStream()))) {
				logger.info("Inside Response from Input Stream");
				String inputLine;
				while ((inputLine = reader.readLine()) != null) {
					postResponse.append(inputLine);
				}
			}

			// Create response JSON
			// JSONObject jsonResponse = new JSONObject();
			// jsonResponse.put("statusCode", postResponseCode);
			// jsonResponse.put("responseBody", new
			// JSONObject(postResponse.toString()));

			logger.info("Final JSON Response: " + postResponse);
			postConnection.disconnect();

			return postResponseCode + "~" + postResponse.toString();

		} catch (IOException ioEx) {
			logger.error("HTTP Connection Error: " + ioEx.getMessage(), ioEx);
			return "-1~Failure " + ioEx.getMessage(); // indicate connection
														// failure
		} catch (Exception e) {
			logger.error("General Error: " + e.getMessage(), e);
			return "-2~ " + e.getMessage(); // indicate general failure
		}
	}

	// Implement getCurrentTime method
	private String getCurrentTime() {
		// Logic to get the current time in the required format
		return java.time.LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss.SSS"));
	}

}


