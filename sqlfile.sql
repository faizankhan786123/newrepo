strQuery1 = "SELECT top 10 " + select_column + " FROM " + TableName + " with (nolock) WHERE " + ColNames
					+ " = '" + ReadCode + "'";
					
					
					
select top 10 ALERT_INDEX, Alert_name, Alert_code, Mobile_no, Alert_text, Alert_Status,wi_Name from NG_RLOS_SMSQUEUETABLE with (nolock) where ALERT_STATUS ='p';

				mLogger.info("Complete ArrayList Values: " + ArrLstTableValues.toString());


CREATE TABLE NG_INFOBIP_AUDIT_LOG (
    WORKITEM_NO     VARCHAR(100),
    INPUT_XML       TEXT,
    OUTPUT_XML      TEXT,
    RESPONSE_CODE   VARCHAR(50),
    INSERTED_ON     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

UPDATE NG_INFOBIP_AUDIT_LOG
SET RESPONSE_CODE = '500'
WHERE WORKITEM_NO = 'W12345';

CREATE SEQUENCE NG_INFOBIP_EVENTID_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;




CREATE TABLE USR_0_INFOBIP_SMS_QUEUETABLE (
    Infobip_EventID            NUMBER PRIMARY KEY,
    Processname                NVARCHAR(100),
    WI_NAME                    NVARCHAR(100),
    AlertID                    NVARCHAR(100),
    InsertedDateTime           NVARCHAR(50),
    CIF                        NVARCHAR(50),
    Dynamic_Tags               NVARCHAR(400), -- $ or ~ separated
    Dynamic_Values             NVARCHAR(400), -- ~#$~ separated
    Trigger_Status             CHAR(1),        -- P, D, F
    Infobip_Response_Code      NVARCHAR(50),
    Infobip_Response_Message   NVARCHAR(1000),
    Infobip_No_Of_Retry        NUMBER
);


CREATE TABLE NG_INFOBIP_JSON_LOGHISTORY (
    infobip_eventID     NUMBER PRIMARY KEY,
    Request_time        TIMESTAMP DEFAULT SYSTIMESTAMP,
    Response_Time       TIMESTAMP,
    Request_JSON        CLOB,
    Response_JSON       CLOB
);
