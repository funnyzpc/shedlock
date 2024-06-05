

MERGE INTO SYS_SHEDLOCK_JOB T
USING ( SELECT '' as application,'' as host_ip ,'' as host_name,'' as state,'' as update_time FROM DUAL ) TT
ON (t.application = TT.application AND t.host_ip = TT.host_ip)
WHEN MATCHED THEN
    UPDATE SET T.host_name = TT.host_name ,T.update_time = TT.update_time ,
WHEN NOT MATCHED THEN
    INSERT (application,host_ip ,host_name,state,update_time ) VALUES ( TT.application,TT.host_ip ,TT.host_name,TT.state,TT.update_time )

