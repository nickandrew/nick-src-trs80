C234567890
      PROGRAM TEST
      CALL PRINT ('EXECUTING "DIR A"',17)
      CALL DOSCMD('DIR A',5)
      CALL PRINT ('NOW DATE',8)
      CALL DOSCMD('DATE',4)
      CALL PRINT ('NOW TIME 14:45:00',17)
      CALL DOSCMD('TIME 14:45:00',13)
      CALL DOSCMD('CLOCK',5)
      END
