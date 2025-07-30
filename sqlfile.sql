USE [rakcas]
GO
/****** Object:  StoredProcedure [dbo].[NG_TS_MAIL_PROC]    Script Date: 7/30/2025 1:56:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[NG_TS_MAIL_PROC]
@sProcessinstanceid varchar(63),
@tmpParam nvarchar(500)
As
BEGIN

SET NOCOUNT  on

SET XACT_ABORT ON

BEGIN TRY

	SET NOCOUNT ON;
	DECLARE @RetValue nvarchar(512) = ''
	Declare @CabName nvarchar(50);
	DECLARE @ProcessDefID INT = 0;
	DECLARE @ActivityID INT = 0;
	DECLARE @WorkItemID INT = 0;
	DECLARE @WINAME NVARCHAR(100) = '';
	DECLARE @MOB_NO nvarchar(20)= '';
	DECLARE @MAIL_TEMPLATE nvarchar(max)= '';
	DECLARE @SMS_TEMPLATE nvarchar(1000)= '';
	DECLARE @Infobip_SMS_isActive NVARCHAR(200)='';
	DECLARE @MAIL_PLACEHOLDER nvarchar(200)= '';
	DECLARE @MAIL_TO NVARCHAR(255) = ''
	DECLARE @MAIL_FROM NVARCHAR(255) = ''
	DECLARE @MAIL_SUBJECT NVARCHAR(255) = ''
	DECLARE @Constant_Name nvarchar(200) = ''
	DECLARE @Constant_Value nvarchar(200) = ''
	declare @activityname NVARCHAR(200)=''
	declare @entryDATETIME datetime
	
	
	SELECT @ProcessDefID=ProcessDefId FROM PROCESSDEFTABLE WITH(NOLOCK) WHERE ProcessName = 'TS'
	
	DECLARE doc_cursor1 CURSOR FOR
	SELECT ConstantName, ConstantValue FROM CONSTANTDEFTABLE with(nolock) WHERE ProcessDefId = @ProcessDefID

	OPEN doc_cursor1  
	FETCH NEXT FROM doc_cursor1 INTO @Constant_Name,@Constant_Value
	WHILE @@FETCH_STATUS = 0  
	BEGIN			
		if(@Constant_Name = 'CONST_CabinetName')
		BEGIN
			set @CabName = @Constant_Value
			print 'CabName'+@CabName
		END
		
	   FETCH NEXT FROM doc_cursor1 INTO @Constant_Name,@Constant_Value
	END 
		
	CLOSE doc_cursor1  
	DEALLOCATE doc_cursor1

	------------------------
	if @tmpParam = 'Document_Attach_Hold'
	BEGIN  
      print 'ProcessInstanceID'+@sProcessinstanceid
			
			SELECT @WorkItemID=WorkItemId, @ActivityID=ActivityId FROM WFINSTRUMENTTABLE WITH(NOLOCK) WHERE ProcessInstanceID=@sProcessinstanceid 
			
			Select @WINAME=WI_NAME ,@entryDATETIME = ENTRYAT, @MAIL_TO = EMAIL_ID,@MOB_NO = MOBILE_NO  from NG_TS_EXTTABLE WITH(NOLOCK) WHERE WI_NAME=@sProcessinstanceid
			
			print 'ProcessInstanceID'+@WINAME+@MOB_NO
			Select @MAIL_FROM = FROM_MAILID,@MAIL_SUBJECT = MAIL_SUBJECT,@MAIL_TEMPLATE = REPLACE((REPLACE(MAIL_TEMPLATE,'$WI_NAME$',''+@WINAME+'')),'$UPDATE_DATE$',@entryDATETIME+5),@SMS_TEMPLATE = REPLACE(SMS_TEMPLATE,'$WI_NAME$',''+@WINAME+''),@MAIL_PLACEHOLDER = MAIL_PLACEHOLDER
			,@Infobip_SMS_isActive = Infobip_SMS_isActive from NG_TS_TEMPLATE_MAPPING_MASTER WITH(NOLOCK) where SERVICE_NAME = 'Card Dispute' and TEMPLATE_ID = '40' and ISACTIVE = 'Y'
			
			
			---@MAIL_TEMPLATE = REPLACE(MAIL_TEMPLATE,'$WI_NAME$',''+@WINAME+'')
			--@MAIL_TEMPLATE = REPLACE(MAIL_TEMPLATE,'$UPDATE_DATE$',''+@entryDATETIME+'+5')
			--@SMS_TEMPLATE = REPLACE(SMS_TEMPLATE,'$WI_NAME$',''+@WINAME+'')
			
			print 'MAil'+@MAIL_FROM
				IF(@MAIL_TO <> '' AND @MAIL_TO is not null AND @MAIL_TEMPLATE <> '' AND @MAIL_TEMPLATE is not null)
				begin
					
					set @MAIL_TO='test11@rakbanktst.ae' --used for testing
					
					INSERT INTO WFMAILQUEUETABLE(mailFrom,mailTo,mailCC,mailBCC,mailSubject,mailMessage,mailContentType,attachmentISINDEX,attachmentNames,attachmentExts,mailPriority,mailStatus,statusComments,lockedBy,successTime,LastLockTime,insertedBy,mailActionType,insertedTime,processDefId,processInstanceId,workitemId,activityId,noOfTrials,zipFlag,zipName,maxZipSize,alternateMessage) values(''+@MAIL_FROM+'',''+@MAIL_TO+'',NULL,NULL,''+@MAIL_SUBJECT+'',''+@MAIL_TEMPLATE+'','text/html;charset=UTF-8',NULL,NULL,NULL,1,'N',NULL,NULL,NULL,NULL,'CUSTOM','TRIGGER',getdate(),@ProcessDefID,@sProcessinstanceid,@WorkItemID,@ActivityID,0,NULL,NULL,NULL,NULL)	
					
				END
				IF(@MOB_NO <> '' AND @MOB_NO is not null AND @SMS_TEMPLATE <> '' AND @SMS_TEMPLATE is not null)
				begin
					
					print 'SMS'
					INSERT INTO NG_RLOS_SMSQUEUETABLE(Alert_Name,Alert_Code,ALert_Status,Mobile_No,Alert_Text,WI_NAME,Workstep_Name,inserted_Date_time) values('TS_Testing','TS Subject Testing','P',''+@MOB_NO+'',''+@SMS_TEMPLATE+'',''+@WINAME+'','Discard-Document_Attach_Hold',GETDATE())	
					
				END
		Set @RetValue='Success'
	END 

	END	TRY
	BEGIN CATCH

		SELECT ERROR_MESSAGE()

		IF @@TRANCOUNT>0
			ROLLBACK

		 
	END CATCH
END
--exec NG_TS_MAIL_PROC 'TS-0000000593-Process', 'Document_Attach_Hold'


"INSERT INTO NG_RLOS_SMSQUEUETABLE "
							+ "(Alert_Name, Alert_Code, ALert_Status, Mobile_No, Alert_Text, WI_Name, Workstep_Name, inserted_Date_time) "
							+ "VALUES ('TS SMS', 'TS', 'P', '" + SMS_MOBNO + "', '" + sms_template + "', '"
							+ getWorkitemName(iformObj) + "', '" + iformObj.getActivityName() + "', GETDATE())";

