
-- 定时任务应用配置
DROP TABLE IF EXISTS SYS_SHEDLOCK_APP;
CREATE TABLE SYS_SHEDLOCK_APP (
  APPLICATION VARCHAR(64) NOT NULL COMMENT '当前实例应用',
  HOST_IP VARCHAR(32) not null COMMENT '当前实例应用所属IP',
  HOST_NAME varchar(100) COMMENT '创建机器',
  STATE CHAR(1) NOT NULL DEFAULT 1 COMMENT '状态 0.关闭 1.开启',
  UPDATE_TIME TIMESTAMP(3) NOT NULL COMMENT '创建及更新时间',
  PRIMARY KEY (APPLICATION,HOST_IP)
) ENGINE=INNODB DEFAULT CHARSET=UTF8MB4 COMMENT='集群分佈式鎖-应用配置';

-- 定时任务锁(new)
DROP TABLE IF EXISTS SYS_SHEDLOCK_JOB;
CREATE TABLE SYS_SHEDLOCK_JOB (
  APPLICATION VARCHAR(64) NOT NULL COMMENT '当前实例应用',
  NAME varchar(64) not null COMMENT '任務名稱',
  HOST_IP varchar(32) not null COMMENT '当前实例应用所属IP',
  LOCKED_AT timestamp(6) NOT NULL COMMENT '任務開始鎖定',
  LOCK_UNTIL timestamp(6) NOT NULL COMMENT '任務鎖定至',
  LOCKED_BY varchar(100) NOT NULL COMMENT '任務執行人',
  STATE CHAR(1) NOT NULL DEFAULT 1 COMMENT '0.close关闭 1.open开启(默认) 具体是否关闭取决于lock_until',
  LABEL varchar(100) COMMENT '任務標識',
  UPDATE_TIME TIMESTAMP(3) NOT NULL COMMENT '创建及更新时间',
  PRIMARY KEY (APPLICATION, NAME)
) ENGINE=INNODB DEFAULT CHARSET=UTF8MB4 COMMENT='集群分佈式鎖-任务配置';

/*
update sys_shedlock_job set host_ip='10.156.122.215',locked_at =now(),lock_until = now()+ interval 10 minute,locked_by ='SCD202212140004'
where application ='MEE_QUARTZ' and name='testTask1' and state ='1'
and '1' = ( select state from SYS_SHEDLOCK_APP where application ='MEE_QUARTZ' and host_ip ='10.156.122.215'  )
*/



