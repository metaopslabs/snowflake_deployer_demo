BEGIN
  ALTER SESSION SET TIMESTAMP_OUTPUT_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF';
  SELECT CURRENT_TIMESTAMP;
END