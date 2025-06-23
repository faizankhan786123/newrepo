sLA_TAT~cARD_CODE~wI_NAME~dISPUTE_RELATED
dISPUTE_RELATED~cARD_CODE~sUB_PROCESS_NAME~wI_NAME
dISPUTE_RELATED~cARD_CODE~sUB_PROCESS_NAME~wI_NAME
cARD_CODE~wI_NAME
cARD_CODE~wI_NAME
cARD_CODE~wI_NAME
cARD_CODE~wI_NAME



if (AlertID.equalsIgnoreCase("BPMFOLLOWUP") || AlertID.equalsIgnoreCase("BPMCLSNOT")) {

					DynamicValues = getWorkitemName(iformObj);
					CPMS.mLogger.debug("Dynamic Values for only 2 Alter id " + DynamicValues);
				} else {

					DynamicValues = MobileNumber + "~#~" + CustomerName + "~#~" + getWorkitemName(iformObj);
					CPMS.mLogger.debug("Dynamic Values :" + MobileNumber + CustomerName + getWorkitemName(iformObj));

				} 
