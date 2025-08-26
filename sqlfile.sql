package com.newgen.util;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.apache.log4j.Logger;

import org.json.JSONObject;

import com.newgen.omni.jts.cmgr.NGXmlList;
import com.newgen.omni.jts.cmgr.XMLParser;
import com.newgen.omni.wf.util.app.NGEjbClient;

public class InfoBipNonCIFSMS implements Runnable {
	public static  Logger mLogger = Logger.getLogger("InfoBipNonCIFLogger");
//	private static NGEjbClient ngEjbClientConnection;
	private static final NGEjbClient ngEjbClientConnection = CentralRunner.getConnection();

	private String URL = SMSAutoService.InfoBIP_ENDPOINTURL;
	private String SessionId = "";
	private String username = SMSAutoService.username;
	private String pass = SMSAutoService.password;
	private String cabinetName = SMSAutoService.cabinetName;
	GenerateXml objXmlGen = new GenerateXml();
	LoggerManager manager = new LoggerManager();
	CentralRunner crObj = new CentralRunner();
	public static User userPass = new User();

	/*
	 * static {
	 * 
	 * try { ngEjbClientConnection = NGEjbClient.getSharedInstance();
	 * ngEjbClientConnection.initialize("10.15.12.164", "3333", "JTS"); } catch
	 * (Exception e) { e.printStackTrace(); } }
	 */

//	public InfoBipNonCIFSMS() {
//		manager.createLogFile();
//	}

	@Override
	public void run() {

		try {
			manager.createLogFile();
			mLogger.debug("Non CIF Thread Started");
			username = userPass.getUsername();
			pass = userPass.getPassword();
			
			mLogger.info("Username for WM Connect ----->" + username);
			mLogger.info("Pass for WM Connect ----->" + pass);
			String wmConnectIPXML = objXmlGen.getConnectInputXML(cabinetName, username, pass);
			mLogger.debug("Input XML WM Connect ----->" + wmConnectIPXML);

			String wmConnectOPXML = ngEjbClientConnection.makeCall(wmConnectIPXML);

			mLogger.debug("Output XML WM Connect ----->" + wmConnectOPXML);
			XMLParser xmlParserConnect = new XMLParser(wmConnectOPXML);
			SessionId = xmlParserConnect.getValueOf("SessionId");
			mLogger.info("Session ID: " + SessionId);

			String strQuery1 = "select top 10  Mobile_No,Alert_Text,Infobip_EventID,Infobip_No_of_Retry from "
					+ "NG_RLOS_SMSQUEUETABLE with (NOLOCK) where Alert_Status='P' and isViaInfobip='Y'";
			String fetchIInputXML = objXmlGen.APSelectWithColumnNames(cabinetName, strQuery1);
			mLogger.debug("Input XML RLOS SMS Queue Table----->" + fetchIInputXML);

			String fetchIOutputXML = ngEjbClientConnection.makeCall(fetchIInputXML);
			mLogger.debug("Output XML RLOS SMS Queue Table----->" + fetchIOutputXML);

			XMLParser xmlParserData = new XMLParser(fetchIOutputXML);

			int employerDetails_totalRetreived = Integer.parseInt(xmlParserData.getValueOf("TotalRetrieved"));

			if (xmlParserData.getValueOf("MainCode").equalsIgnoreCase("0") && employerDetails_totalRetreived > 0) {


			}

			if (xmlParserData.getValueOf("MainCode").equalsIgnoreCase("0") && employerDetails_totalRetreived > 0) {
				String xmlParserData_val = xmlParserData.getNextValueOf("Record");
				mLogger.info("employerDetails_totalRetreived : " + xmlParserData_val);
				xmlParserData_val = xmlParserData_val.replaceAll("[ ]+>", ">").replaceAll("<[ ]+", "<");
				// replace the spcl char above.
				NGXmlList objWorkList = xmlParserData.createList("Records", "Record");

				// Store the data to process later outside the loop
				List<Map<String, String>> dataList = new ArrayList<>();

				for (; objWorkList.hasMoreElements(true); objWorkList.skip(true)) {
					String Mobile_No = objWorkList.getVal("Mobile_No");
					String Alert_Text = objWorkList.getVal("Alert_Text");
					String Infobip_EventID = objWorkList.getVal("Infobip_EventID");
					String Infobip_No_of_Retry = objWorkList.getVal("Infobip_No_of_Retry");

					mLogger.debug("Values fetched from DB: " + Mobile_No + "\n" + Alert_Text + "\n" + Infobip_EventID
							+ "\n" + Infobip_No_of_Retry);

					if ("".equals(Infobip_No_of_Retry) || Infobip_No_of_Retry == null) {
						Infobip_No_of_Retry = "0";
						mLogger.debug("No of Retry: " + Infobip_No_of_Retry);
					}

					mLogger.debug("No of Retry: " + Infobip_No_of_Retry);
					if (Integer.parseInt(Infobip_No_of_Retry) < 5) {
						// Store data for later processing
						Map<String, String> dataMap = new HashMap<>();
						dataMap.put("Mobile_No", Mobile_No);
						dataMap.put("Alert_Text", Alert_Text);
						dataMap.put("Infobip_EventID", Infobip_EventID);
						dataMap.put("Infobip_No_of_Retry", Infobip_No_of_Retry);
						dataList.add(dataMap);
					}
				}

				// After collecting data, process each entry
				for (Map<String, String> data : dataList) {
					String Mobile_No = data.get("Mobile_No");
					String Alert_Text = data.get("Alert_Text");
					String Infobip_EventID = data.get("Infobip_EventID");
					String Infobip_No_of_Retry = data.get("Infobip_No_of_Retry");

					String requestBody = "{\n" + "  \"messages\": [\n" + "    {\n" + "      \"from\": \"RAKBANK\",\n"
							+ "      \"destinations\": [\n" + "        {\n" + "          \"to\": \"{{MOBILE}}\"\n"
							+ "        }\n" + "      ],\n" + "      \"text\": \"{{MESSAGE}}\"\n" + "    }\n" + "  ]\n"
							+ "}";

					String finalJson = requestBody.replace("{{MOBILE}}", Mobile_No).replace("{{MESSAGE}}", Alert_Text);

					mLogger.debug("Final Request Body: " + finalJson);

					// Call the POST API
					String requestTime = getCurrentTime();
					String output = NonCIFSMSPostApi(finalJson);
					String[] postAPIResponse = output.split("~");
					int responseCode = Integer.parseInt(postAPIResponse[0]);

					// Capture the request and response time
					String responseTime = getCurrentTime();
					String responseJson = postAPIResponse[1];
					mLogger.debug("Response JSON: " + responseJson);

					crObj.pushDataIntoDB(cabinetName, SessionId, "NG_INFOBIP_JSON_LOGHISTORY", Infobip_EventID, requestTime, responseTime, finalJson, responseJson, mLogger);

					if (responseCode == 200) {
						mLogger.debug("SMS API executed successfully: " + Infobip_EventID);
						// status = D, No of tries +1, response message
						crObj.updateUSRTable(cabinetName, SessionId, responseCode, responseJson,
								Infobip_No_of_Retry, Infobip_EventID, "NG_RLOS_SMSQUEUETABLE", mLogger);

					} else {
						mLogger.error("SMS API Failed for eventID: " + Infobip_EventID);
						crObj.updateUSRTable(cabinetName, SessionId, responseCode, responseJson,
								Infobip_No_of_Retry, Infobip_EventID, "NG_RLOS_SMSQUEUETABLE", mLogger);
					}
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		mLogger.debug("End of Non-CIF Thread");
	}

	public String NonCIFSMSPostApi(String requestBody) {
		String dynamicURL = URL + "/sms/2/text/advanced";
		try {
			// POST Request
			CentralRunner.loadSSL();
			URL postUrl = new URL(dynamicURL);
			HttpURLConnection postConnection = (HttpURLConnection) postUrl.openConnection();
			mLogger.debug("After NON-CIFSMS  URL connection:");

			// Set request method and headers
			postConnection.setRequestMethod("POST");
			postConnection.setRequestProperty("Accept", "application/json");
			postConnection.setRequestProperty("Content-Type", "application/json");
			postConnection.setRequestProperty("source", "BPM");
			postConnection.setDoOutput(true);

			mLogger.debug("After JSON Request Construction: " + requestBody);

			try (DataOutputStream outputStream = new DataOutputStream(postConnection.getOutputStream())) {
				outputStream.writeBytes(requestBody);
				outputStream.flush();
			}

			mLogger.debug("After Output Stream flush");

			int postResponseCode = postConnection.getResponseCode();
			mLogger.debug("Response Code: " + postResponseCode);

			StringBuilder postResponse = new StringBuilder();
			try (BufferedReader reader = new BufferedReader(new InputStreamReader(
					postResponseCode >= 400 ? postConnection.getErrorStream() : postConnection.getInputStream()))) {
				mLogger.debug("Inside Response from Input Stream");
				String inputLine;
				while ((inputLine = reader.readLine()) != null) {
					postResponse.append(inputLine);
				}
			}


			mLogger.debug("Final JSON Response: " + postResponse);

			// Close connections
			postConnection.disconnect();
			return postResponseCode + "~" + postResponse.toString();

		} catch (IOException ioEx) {
			mLogger.error("HTTP Connection Error: " + ioEx.getMessage(), ioEx);
			return "-1~Failure"; // indicate connection failure
		} catch (Exception e) {
			mLogger.error("Error: " + e.getMessage());
			e.printStackTrace();
			return "Exception Occured in: " + e.getMessage();
		}

	}

	private String getCurrentTime() {
		// Logic to get the current time in the required format
		return java.time.LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss.SSS"));
	}

	public void updateUSRTable(int responseCode, String responseJson, String Infobip_No_Of_Retry,
			String Infobip_EventID) {
		try {

			if (cabinetName == null || SessionId == null) {
				mLogger.error("Cabinet name or session ID is null.");
				mLogger.error("cabinet Name is : " + cabinetName);
				mLogger.error("Session ID is  : " + SessionId);
				return;
			}

			// extract response message from JSON
			String responseMessage = "";
			int retryCount = 0;

			try {
				mLogger.debug("Parsing response JSON...");
				JSONObject json = new JSONObject(responseJson);
				responseMessage = json.optString("message", "");
				mLogger.debug("Extracted message from JSON: " + responseMessage);

				retryCount = Integer.parseInt(Infobip_No_Of_Retry);
			} catch (Exception e) {
				mLogger.error("Error parsing Response JSON: " + e.getMessage());
			}

			retryCount++;

			String Trigger_Status = responseCode == 200 ? "D" : "P";
			String tableName = "NG_RLOS_SMS_QUEUETABLE";
			String ColumnNames = "Infobip_Response_Code,Trigger_Status,Infobip_Response_Message,Infobip_No_Of_Retry";
			String values = "'" + responseCode + "', '" + Trigger_Status + "', '" + responseMessage.replace("'", "''")
					+ "', '" + retryCount + "'";

			String whereClause = "Infobip_EventID = '" + Infobip_EventID + "'";
			mLogger.debug("Info Bip Event ID is  : " + Infobip_EventID);

			mLogger.debug("Preparing update with:");
			mLogger.debug("Table Name: " + tableName);
			mLogger.debug("Column Names: " + ColumnNames);
			mLogger.debug("Values: " + values);
			mLogger.debug("Where Clause: " + whereClause);

			try {
				mLogger.debug("Generating XML for update...");
				String updateXml = GenerateXml.apUpdateInput(tableName, ColumnNames, values, whereClause, cabinetName,
						SessionId);
				if (updateXml == null) {
					mLogger.debug("Generated update XML is null.");
					return;
				}

				mLogger.debug("Update XML: " + updateXml);

				mLogger.debug("Calling ngEjbClientConnection.makeCall...");
				String updateResponse = ngEjbClientConnection.makeCall(updateXml);
				if (updateResponse == null) {
					mLogger.error("Update Response is Null");
				} else {
					mLogger.error("Update Response is: " + updateResponse);
				}

			} catch (Exception e) {
				mLogger.error("Exception while updating table: " + e.getMessage());
				e.printStackTrace();
			}

		} catch (Exception e) {
			mLogger.error("Unexpected exception in updateUSRTable: " + e.getMessage());
		}
	}

}
