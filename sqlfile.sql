USE [rakcas]
GO
/****** Object:  StoredProcedure [dbo].[NG_TS_DOC_REMINDER_MAIL_PROC]    Script Date: 7/30/2025 2:20:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[NG_TS_DOC_REMINDER_MAIL_PROC]
As
BEGIN
	SET NOCOUNT ON;
	Declare @processinstanceid nvarchar(63)
	Declare @CabName nvarchar(50);
	DECLARE @ProcessDefID INT = 0;
	DECLARE @ActivityID INT = 0;
	DECLARE @WorkItemID INT = 0;
	DECLARE @WINAME NVARCHAR(100) = '';
	DECLARE @MOB_NO nvarchar(20)= '';
	DECLARE @MAIL_TEMPLATE nvarchar(max)= '';
	DECLARE @SMS_TEMPLATE nvarchar(1000)= '';
	DECLARE @MAIL_PLACEHOLDER nvarchar(200)= '';
	DECLARE @MAIL_TO NVARCHAR(255) = ''
	DECLARE @MAIL_FROM NVARCHAR(255) = ''
	DECLARE @MAIL_SUBJECT NVARCHAR(255) = ''
	DECLARE @Constant_Name nvarchar(200) = ''
	DECLARE @Constant_Value nvarchar(200) = ''
	declare @activityname NVARCHAR(200)=''
	declare @entryDATETIME datetime
	declare @Dispute_Ref_No nvarchar(400) = '';
	declare @AMT_IN_AED nvarchar(400) = '';
	declare @MERCHANT_NAME nvarchar(400)= '';
	declare @CARD_CRN_NO nvarchar(16) = '';
	declare @condition nvarchar(100) = '';
	DECLARE @Infobip_SMS_isActive nvarchar(200) = '';
	
	
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

	-------------------------

	DECLARE rem_cursor CURSOR FOR 
	SELECT processinstanceid from queueview with(nolock) where activityname='Document_Attach_Hold' 

	OPEN rem_cursor  
	FETCH NEXT FROM rem_cursor INTO @processinstanceid  

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
      print 'ProcessInstanceID'+@ProcessInstanceID
			
			SELECT @WorkItemID=WorkItemId, @ActivityID=ActivityId FROM WFINSTRUMENTTABLE WITH(NOLOCK) WHERE ProcessInstanceID=@ProcessInstanceID AND ActivityName = 'Document_Attach_Hold' 
			
			Select @WINAME=WI_NAME ,@entryDATETIME = ENTRYAT, @MAIL_TO = EMAIL_ID,@MOB_NO = MOBILE_NO from NG_TS_EXTTABLE WITH(NOLOCK) WHERE WI_NAME=@ProcessInstanceID
			
			
			
			print 'ProcessInstanceID'+@WINAME+@MOB_NO
			Select @MAIL_FROM = FROM_MAILID,@MAIL_SUBJECT = MAIL_SUBJECT,@MAIL_TEMPLATE = REPLACE((REPLACE(MAIL_TEMPLATE,'$WI_NAME$',''+@WINAME+'')),'$UPDATE_DATE$',@entryDATETIME+5),@SMS_TEMPLATE = REPLACE(SMS_TEMPLATE,'$WI_NAME$',''+@WINAME+''),@MAIL_PLACEHOLDER = MAIL_PLACEHOLDER,
			@Infobip_SMS_isActive = Infobip_SMS_isActive from NG_TS_TEMPLATE_MAPPING_MASTER WITH(NOLOCK) where SERVICE_NAME = 'Card Dispute' and TEMPLATE_ID = '39' and ISACTIVE = 'Y' 
			
			
			---@MAIL_TEMPLATE = REPLACE(MAIL_TEMPLATE,'$WI_NAME$',''+@WINAME+'')
			--@MAIL_TEMPLATE = REPLACE(MAIL_TEMPLATE,'$UPDATE_DATE$',''+@entryDATETIME+'+5')
			--@SMS_TEMPLATE = REPLACE(SMS_TEMPLATE,'$WI_NAME$',''+@WINAME+'')
			
			print 'MAil'+@MAIL_FROM
				IF(@MAIL_TO <> '' AND @MAIL_TO is not null AND @MAIL_TEMPLATE <> '' AND @MAIL_TEMPLATE is not null)
				begin
					
					--if(DATEDIFF(day,@entryDATETIME,GETDATE())=2 OR )
					if(dbo.CPMSDateDiffExcludingWeekends(@entryDATETIME,GETDATE())=1 OR dbo.CPMSDateDiffExcludingWeekends(@entryDATETIME,GETDATE())=2)
					begin
						print 'MAil'
						--INSERT WFMAILQUEUETABLE COLUMNS
						-- 'RAKBANKquickapply@rakbank.ae' - this fromMailId has to be used in Production
						set @MAIL_TO='test11@rakbanktst.ae' --used for testing
						
						INSERT INTO WFMAILQUEUETABLE(mailFrom,mailTo,mailCC,mailBCC,mailSubject,mailMessage,mailContentType,attachmentISINDEX,attachmentNames,attachmentExts,mailPriority,mailStatus,statusComments,lockedBy,successTime,LastLockTime,insertedBy,mailActionType,insertedTime,processDefId,processInstanceId,workitemId,activityId,noOfTrials,zipFlag,zipName,maxZipSize,alternateMessage) values(''+@MAIL_FROM+'',''+@MAIL_TO+'',NULL,NULL,''+@MAIL_SUBJECT+'',''+@MAIL_TEMPLATE+'','text/html;charset=UTF-8',NULL,NULL,NULL,1,'N',NULL,NULL,NULL,NULL,'CUSTOM','TRIGGER',getdate(),@ProcessDefID,@ProcessInstanceID,@WorkItemID,@ActivityID,0,NULL,NULL,NULL,NULL)	
					end
				END
				IF(@MOB_NO <> '' AND @MOB_NO is not null AND @SMS_TEMPLATE <> '' AND @SMS_TEMPLATE is not null)
				begin
					if(dbo.CPMSDateDiffExcludingWeekends(@entryDATETIME,GETDATE())=2 OR dbo.CPMSDateDiffExcludingWeekends(@entryDATETIME,GETDATE())=1)
					print 'SMS'
                  IF (@Infobip_SMS_isActive = 'N')
                  BEGIN
	                  INSERT INTO NG_RLOS_SMSQUEUETABLE(Alert_Name, Alert_Code, ALert_Status, Mobile_No, Alert_Text, WI_NAME, Workstep_Name, inserted_Date_time)
	                   VALUES('TS_Testing','TS Subject Testing','P',''+@MOB_NO+'',''+@SMS_TEMPLATE+'',''+@WINAME+'','Document_Attach_Hold',GETDATE())
                           END
                  ELSE IF (@Infobip_SMS_isActive = 'Y')
                 BEGIN
	                   INSERT INTO USR_0_INFOBIP_SMS_QUEUETABLE(Processname, WI_NAME, AlertID, InsertedDateTime, CIF, Dynamic_Tags, Dynamic_Values, Alert_Status)
	                    VALUES('TS', @WINAME, 'infobip_Alert_id', FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss.fff'), 'CIF_ID', 'infobip_dynamic_tags', 'DynamicValues', 'P')
                        END

				END
		FETCH NEXT FROM rem_cursor INTO @processinstanceid 
	END 

	CLOSE rem_cursor  
	DEALLOCATE rem_cursor
	
	DECLARE rem_cursor1 CURSOR FOR 
	SELECT WI_NAME FROM NG_TS_EXTTABLE WITH(NOLOCK) WHERE CURRENT_WS NOT IN ('Closed','Discard','Initiation','Archival') AND SERVICE_TYPE='Card Dispute'

	OPEN rem_cursor1  
	FETCH NEXT FROM rem_cursor1 INTO @WINAME  

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
      print 'ProcessInstanceID'+@WINAME
			
			SELECT @WorkItemID= WorkItemId, @ActivityID=ActivityId, @activityname=ActivityName FROM WFINSTRUMENTTABLE WITH(NOLOCK) WHERE ProcessInstanceID=@WINAME
			
			
			
			
			Select @WINAME=WI_NAME , @CARD_CRN_NO =SUBSTRING(HEADER_CARD_NO,13,16), @entryDATETIME = CREATED_AT, @MAIL_TO = EMAIL_ID,@MOB_NO = MOBILE_NO  from NG_TS_EXTTABLE WITH(NOLOCK) WHERE WI_NAME=@WINAME
			
			
			 print '@activityname'+@activityname
	if((@activityname ='Final_Credit' OR @activityname ='TC_Update'))
	BEGIN
	 print 'inside if con @activityname'+@activityname
	
			Select  @Dispute_Ref_No = stuff (( select ', ' + REF_NO from NG_TS_TRANS_DISPUTE_GRID_DTLS e2 where e1.WI_NAME = e2.WI_NAME
			and e2.DECISION !='Decline' for XML path ('')),1,2,'')  from NG_TS_TRANS_DISPUTE_GRID_DTLS e1 WHERE e1.WI_NAME=@WINAME group by WI_NAME
			
			print 'inside if con  @Dispute_Ref_No'+ @Dispute_Ref_No
			
			Select @AMT_IN_AED = stuff (( select ', ' + AMT_IN_AED from NG_TS_TRANS_DISPUTE_GRID_DTLS e2 where e1.WI_NAME = e2.WI_NAME 
			and e2.DECISION !='Decline' for XML path ('')),1,2, '')   from NG_TS_TRANS_DISPUTE_GRID_DTLS e1 WHERE e1.WI_NAME=@WINAME group by WI_NAME
			
			print 'inside if con   @AMT_IN_AED '+  @AMT_IN_AED
			 
			Select @MERCHANT_NAME = stuff (( select ', ' + MERCHANT_NAME from NG_TS_TRANS_DISPUTE_GRID_DTLS e2 where e1.WI_NAME = e2.WI_NAME 
			and e2.DECISION !='Decline' for XML path ('')),1,2, '')  from NG_TS_TRANS_DISPUTE_GRID_DTLS e1 WHERE e1.WI_NAME=@WINAME group by WI_NAME
			
			print 'inside if con   @MERCHANT_NAME'+  @MERCHANT_NAME
	
	END
	else 	
	BEGIN
	 print 'inside else con @activityname'+@activityname
			Select  @Dispute_Ref_No = stuff (( select ', ' + REF_NO from NG_TS_TRANS_DISPUTE_GRID_DTLS e2 where e1.WI_NAME = e2.WI_NAME
			for XML path ('')),1,2,'')  from NG_TS_TRANS_DISPUTE_GRID_DTLS e1 WHERE WI_NAME=@WINAME group by WI_NAME
			
			Select @AMT_IN_AED = stuff (( select ', ' + AMT_IN_AED from NG_TS_TRANS_DISPUTE_GRID_DTLS e2 where e1.WI_NAME = e2.WI_NAME for XML path ('')),1,2, '')   from NG_TS_TRANS_DISPUTE_GRID_DTLS e1 WHERE WI_NAME=@WINAME group by WI_NAME
			 
			Select @MERCHANT_NAME = stuff (( select ', ' + MERCHANT_NAME from NG_TS_TRANS_DISPUTE_GRID_DTLS e2 where e1.WI_NAME = e2.WI_NAME for XML path ('')),1,2, '')  from NG_TS_TRANS_DISPUTE_GRID_DTLS e1 WHERE WI_NAME=@WINAME group by WI_NAME
	END
			
			
			
			
			print 'ProcessInstanceID'+@WINAME+@MOB_NO
			Select @MAIL_FROM = FROM_MAILID,@MAIL_SUBJECT = MAIL_SUBJECT,@MAIL_TEMPLATE =REPLACE(REPLACE(REPLACE(REPLACE((REPLACE(MAIL_TEMPLATE,'$WI_NAME$',''+@WINAME+'')),'$MERCHANT_NAME$',@MERCHANT_NAME),'$CARD_CODE$',@CARD_CRN_NO),'$DISPUTE_REF_NO$',@Dispute_Ref_No),'$AMOUNT_AED$',@AMT_IN_AED), @SMS_TEMPLATE =  REPLACE(REPLACE((REPLACE(SMS_TEMPLATE,'$WI_NAME$',''+@WINAME+'')),'$CARD_CODE$',@CARD_CRN_NO),'$AMOUNT_AED$',@AMT_IN_AED),@MAIL_PLACEHOLDER = MAIL_PLACEHOLDER from NG_TS_TEMPLATE_MAPPING_MASTER WITH(NOLOCK) where SERVICE_NAME = 'Card Dispute' and TEMPLATE_ID = '54' and ISACTIVE = 'Y'
			
			print 'MAil'+@MAIL_FROM
				IF(@MAIL_TO <> '' AND @MAIL_TO is not null AND @MAIL_TEMPLATE <> '' AND @MAIL_TEMPLATE is not null)
				begin
					print 'inside mail Begin date25'
					if(DATEDIFF(day,@entryDATETIME,GETDATE()) = 1)
					begin
						print 'MAil-25'
						--INSERT WFMAILQUEUETABLE COLUMNS
						set @MAIL_TO='test11@rakbanktst.ae' --used for testing
						INSERT INTO WFMAILQUEUETABLE(mailFrom,mailTo,mailCC,mailBCC,mailSubject,mailMessage,mailContentType,attachmentISINDEX,attachmentNames,attachmentExts,mailPriority,mailStatus,statusComments,lockedBy,successTime,LastLockTime,insertedBy,mailActionType,insertedTime,processDefId,processInstanceId,workitemId,activityId,noOfTrials,zipFlag,zipName,maxZipSize,alternateMessage) values(''+@MAIL_FROM+'',''+@MAIL_TO+'',NULL,NULL,''+@MAIL_SUBJECT+'',''+@MAIL_TEMPLATE+'','text/html;charset=UTF-8',NULL,NULL,NULL,1,'N',NULL,NULL,NULL,NULL,'CUSTOM','TRIGGER',getdate(),@ProcessDefID,@WINAME,@WorkItemID,@ActivityID,0,NULL,NULL,NULL,NULL)	
						
					end
				END
				IF(@MOB_NO <> '' AND @MOB_NO is not null AND @SMS_TEMPLATE <> '' AND @SMS_TEMPLATE is not null)
				begin
				print 'inside sms date25'
					if(DATEDIFF(day,@entryDATETIME,GETDATE()) = 4)
					
					begin
						print 'SMS-25'
						INSERT INTO NG_RLOS_SMSQUEUETABLE(Alert_Name,Alert_Code,ALert_Status,Mobile_No,Alert_Text,WI_NAME,Workstep_Name,inserted_Date_time) values('TS_Testing','TS Subject Testing','P',''+@MOB_NO+'',''+@SMS_TEMPLATE+'',''+@WINAME+'','Card Dispute',GETDATE())	
					end
				END
		FETCH NEXT FROM rem_cursor1 INTO @WINAME 
	END 

	CLOSE rem_cursor1  
	DEALLOCATE rem_cursor1
END	
--exec NG_TS_DOC_REMINDER_MAIL_PROC



 
