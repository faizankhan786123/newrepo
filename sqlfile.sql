IF(@MOB_NO <> '' AND @MOB_NO is not null AND @SMS_TEMPLATE <> '' AND @SMS_TEMPLATE is not null)
				begin
				print 'inside sms date25'
				  SELECT @CIF_ID = CIF_ID ,@HEADER_CARD_NO = HEADER_CARD_NO
                     FROM NG_TS_EXTTABLE WITH(NOLOCK) 
                     WHERE WI_NAME = @WINAME;

					 set @DynamicValues = @HEADER_CARD_NO
					
					print 'CIF ID IS = '+ @CIF_ID 
					print 'Card Number  = '+ @HEADER_CARD_NO

					if(DATEDIFF(day,@entryDATETIME,GETDATE()) = 1)
					print(DATEDIFF(day,@entryDATETIME,GETDATE()))
					begin
						print 'SMS-25'
						IF (@Infobip_SMS_isActive = 'N')
                  BEGIN
	                  INSERT INTO NG_RLOS_SMSQUEUETABLE(Alert_Name,Alert_Code,ALert_Status,Mobile_No,Alert_Text,WI_NAME,Workstep_Name,inserted_Date_time) values('TS_Testing','TS Subject Testing','P',''+@MOB_NO+'',''+@SMS_TEMPLATE+'',''+@WINAME+'','Card Dispute',GETDATE())	
                           END
                  ELSE IF (@Infobip_SMS_isActive = 'Y')
				  print('faizan khan')
                 BEGIN
	                   INSERT INTO USR_0_INFOBIP_SMS_QUEUETABLE(Processname, WI_NAME, AlertID, InsertedDateTime, CIF, Dynamic_Tags, Dynamic_Values, Alert_Status)
	                    VALUES('TS', ''+@WINAME+'', ''+@infobip_Alert_id+'', FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss.fff'), ''+@CIF_ID+'', 
						''+@Infobip_Dynamic_Tags+'', ''+@DynamicValues+'', 'P')
                        END
					end
				END
