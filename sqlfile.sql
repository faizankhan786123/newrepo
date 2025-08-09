-- 1
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = NULL,
    Infobip_Dynamic_Tags = NULL,
    Infobip_SMS_isActive = 'N'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'TRANSACTION DISPUTE';

-- 2
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = NULL,
    Infobip_Dynamic_Tags = NULL,
    Infobip_SMS_isActive = 'N'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'Unfortunately, we cannot offer you the requested RAKBANK service at the moment.';

-- 3
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMINTRO31',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name~sLA_TAT',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'We have received your request now!';

-- 4
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMCOMP31',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'We are Done! Your request is now approved.';

-- 5
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMREJRTS31',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = '';

-- 6
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMREJFINDIS31',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'Unfortunately, we cannot offer you the requested RAKBANK service at the moment.';

-- 7
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMINTRO32',
    Infobip_Dynamic_Tags = 'card_No~wI_No',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'We have received your request now!';

-- 8
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMCOMP32',
    Infobip_Dynamic_Tags = 'card_No~wI_No~amount',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'We are Done! Your request is now approved.';

-- 9
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMPEN32',
    Infobip_Dynamic_Tags = 'card_No~wI_No~dDMMYYYY',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'Almost there! Let us finish your request.';

-- 10
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMINTRO33',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name~sLA_TAT',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'We have received your request now!';

-- 11
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMCOMP33',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name~sLA_TAT',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'We are Done! Your request is now approved.';

-- 12
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMREJRTS31',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = '';

-- 13
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMREJFINDIS31',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'Unfortunately, we cannot offer you the requested RAKBANK service at the moment.';

-- 14
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMPEN34',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name~dDMMYYYY',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'Almost there! Let us finish your request.';

-- 15
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMINTRO34',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'We have received your request now!';

-- 16
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMCOMP34',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'We are Done! Your request is now approved.';

-- 17
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMREJRTS34',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = '';

-- 18
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMREJFINDIS31',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'Unfortunately, we cannot offer you the requested RAKBANK service at the moment.';

-- 19
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMPEN33',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name~dDMMYYYY',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'Almost there! Let us finish your request.';

-- 20
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMINTRO34',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'We have received your request now!';

-- 21
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMCOMP34',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'We are Done! Your request is now approved.';

-- 22
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMPEN33',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name~dDMMYYYY',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = '';

-- 23
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMREJFINDIS31',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sub_Process_Name',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_ODC'
  AND MailSubject = 'Unfortunately, we cannot offer you the requested RAKBANK service at the moment.';
