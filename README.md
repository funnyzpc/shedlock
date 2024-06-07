
## shedlock (分布式任务锁)

 本工程主要是对 **shedlock(4.47.0)** 的二开，源头是: [https://github.com/lukas-krecan/ShedLock](https://github.com/lukas-krecan/ShedLock)

&nbsp;&nbsp;这里再次感谢 [ukas-krecan](https://github.com/lukas-krecan) 等大佬的倾情开源，没有他们也就没有此项目的存在🌹

&nbsp;&nbsp;此工程是在原版的shedlock(4.47.0)上做的修改，实现了分布式锁：主要增加了对任务锁及任务实例的控制，同时扩充了部分字段便于从后台控制任务的执行以及暂停
  
&nbsp;&nbsp;另外，本`shedlock`仅仅对 `Oracle`、`Mysql`、`PostgreSQL` 这三个厂商的数据库做了兼容开发，其他暂不考虑～ 

### 使用说明
#### 1、根据项目锁使用的数据库导入对应的SQL脚本

+ [MySQL](documentation%2Ftable_mysql.sql) table_mysql.sql
+ [PostgreSQL](documentation%2Ftable_postgresql.sql) table_postgresql.sql
+ [Oracle](documentation%2Ftable_oracle.sql) table_oracle.sql

#### 2、配置Bean(spring)
```agsl
import net.javacrumbs.shedlock.core.ClockProvider;
import net.javacrumbs.shedlock.core.LockProvider;
import net.javacrumbs.shedlock.provider.jdbctemplate.JdbcTemplateLockProvider;
import net.javacrumbs.shedlock.spring.annotation.EnableSchedulerLock;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;

import javax.sql.DataSource;


/**
* 定时任务锁配置
* @className    ShedlockConfiguration
* @author       shadow
* @date         2024/7/3 13:14
* @version      1.0
*/
@Configuration
@EnableSchedulerLock(defaultLockAtMostFor = "PT10M",defaultLockAtLeastFor="PT2M")
public class ShedlockConfiguration {
    /**
    * 定义定时任务worker数
     */
    private static final int PROCESSOR = Runtime.getRuntime().availableProcessors();

    /**
     * 配置锁
     * @param dataSource
     * @return
     */
    @Bean
    public LockProvider lockProvider(DataSource dataSource) {
        return new JdbcTemplateLockProvider(
                JdbcTemplateLockProvider.Configuration.builder()
                        .withTableName("SYS_SHEDLOCK_JOB") // 定义任务锁表
                        .withTableAppName("SYS_SHEDLOCK_APP") // 定义实例锁表(如果不使用可不用导入)
                        .withJdbcTemplate(new JdbcTemplate(dataSource))
                        .usingDbTime() // DB 时间为UTC时区会有时差,虽然如此但也十分建议如此
//                        .withTimeZone(TimeZone.getTimeZone(DateUtil.zoneId))
                        .build()
        );
    }

    /**
     * 设置执行线程数
     *
     * @return
     */
    @Bean
    public ThreadPoolTaskScheduler threadPoolTaskScheduler() {
        ThreadPoolTaskScheduler scheduler = new ThreadPoolTaskScheduler();
        scheduler.setPoolSize(PROCESSOR*2);
        scheduler.setThreadNamePrefix("SHEDLOCK-");
        scheduler.initialize();
        return scheduler;
    }

}

```
 
#### 3、使用说明
+ 1、目前仅对 `MySQL`、`PostgreSQL`、`Oracle` 做支持（当前版本已测试通过），其他数据库需自行开发，目前对 `PostgreSQL` 做一等支持，所以`PostgreSQL`的问题会做优先处理
其他bug请提issue🌹

+ 2、如需要配置到后台以控制任务启停，请 使用`SYS_SHEDLOCK_JOB::state` (仅0或1)字段进行控制任务启停，使用 `SYS_SHEDLOCK_APP::state` (仅0或1)字段进行控制实例启停，实例关闭后，实例下所有任务不可执行

+ 3、如需直接使用构建包，请至 [Releases](https://github.com/funnyzpc/shedlock/releases) 中下载，请广泛测试后再应用于生产

