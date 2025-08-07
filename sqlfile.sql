 -- Get last 4 digits of the card number
    SET @DynamicValues = RIGHT(@HEADER_CARD_NO, 4)

    PRINT 'CIF ID IS = ' + @CIF_ID 
    PRINT 'Card Number  = ' + @HEADER_CARD_NO
    PRINT 'Last 4 Digits (DynamicValues) = ' + @DynamicValues
