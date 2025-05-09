CREATE TABLE USR_0_INFOBIP_SMS_QUEUETABLE (
    Infobip_EventID            INT PRIMARY KEY,
    Processname                NVARCHAR(100),
    WI_NAME                    NVARCHAR(100),
    AlertID                    NVARCHAR(100),
    InsertedDateTime           NVARCHAR(50),
    CIF                        NVARCHAR(50),
    Dynamic_Tags               NVARCHAR(400),
    Dynamic_Values             NVARCHAR(400),
    Trigger_Status             CHAR(1),
    Infobip_Response_Code      NVARCHAR(50),
    Infobip_Response_Message   NVARCHAR(1000),
    Infobip_No_Of_Retry        INT
);

CREATE TABLE NG_INFOBIP_JSON_LOGHISTORY (
    infobip_eventID     INT PRIMARY KEY,
    Request_time        DATETIME DEFAULT GETDATE(),
    Response_Time       DATETIME,
    Request_JSON        NVARCHAR(MAX),
    Response_JSON       NVARCHAR(MAX)
);


-- Insert data without specifying Infobip_EventID
INSERT INTO USR_0_INFOBIP_SMS_QUEUETABLE (
    Processname, WI_NAME, AlertID, InsertedDateTime, CIF,
    Dynamic_Tags, Dynamic_Values, Trigger_Status
) 
VALUES (
    'Process1', 'WI-001', 'ALERT1', '2025-05-09 10:00:00', 'CIF001',
    '$Name$', '~#John#', 'P'
);
CREATE TRIGGER trg_infobip_sms_eventid
ON USR_0_INFOBIP_SMS_QUEUETABLE
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NextEventID INT;

    -- Get the next value from the sequence
    SELECT @NextEventID = NEXT VALUE FOR NG_INFOBIP_EVENTID_SEQ;

    -- Insert the data with the generated Infobip_EventID
    INSERT INTO USR_0_INFOBIP_SMS_QUEUETABLE (
        Infobip_EventID, Processname, WI_NAME, AlertID, 
        InsertedDateTime, CIF, Dynamic_Tags, Dynamic_Values, 
        Trigger_Status, Infobip_Response_Code, Infobip_Response_Message, Infobip_No_Of_Retry
    )
    SELECT 
        @NextEventID, Processname, WI_NAME, AlertID, 
        InsertedDateTime, CIF, Dynamic_Tags, Dynamic_Values, 
        Trigger_Status, Infobip_Response_Code, Infobip_Response_Message, Infobip_No_Of_Retry
    FROM inserted;
END;

