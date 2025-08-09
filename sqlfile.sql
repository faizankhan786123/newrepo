-- 1
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMINTRO2',
    Infobip_Dynamic_Tags = 'card_No~wI_No~sLA_TAT',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_MR'
  AND MailSubject = 'We have received your request now!';

-- 2
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BMPCOMP2',
    Infobip_Dynamic_Tags = 'card_No~wI_No',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_MR'
  AND MailSubject = 'We are Done! Your request is now approved.';

-- 3
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPNREJECTRTS2',
    Infobip_Dynamic_Tags = 'card_No~wI_No',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_MR'
  AND MailSubject = '';

-- 4
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMPENDING2',
    Infobip_Dynamic_Tags = 'card_No~wI_No~dDMMYYYY',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_MR'
  AND MailSubject = 'Almost there! Let us finish your request.';

-- 5
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMRJFNDISCARD',
    Infobip_Dynamic_Tags = 'card_No~wI_No',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_MR'
  AND MailSubject = 'Unfortunately, we cannot offer you the requested RAKBANK service at the moment.';

-- 6
UPDATE USR_0_CSR_BT_TemplateMapping
SET Infobip_Alert_ID = 'BPMPENCN',
    Infobip_Dynamic_Tags = 'card_No~wI_No~cancellationReason',
    Infobip_SMS_isActive = 'Y'
WHERE ProcessName = 'DSR_MR'
  AND MailSubject = 'Your RAKBANK request has been cancelled.';
