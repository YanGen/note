#### 基于redis Java implement的redisTemplate

。。。

##### redisson已实现的分布式锁

依赖

```xml
        <dependency>
            <groupId>org.redisson</groupId>
            <artifactId>redisson</artifactId>
            <version>3.10.6</version>
        </dependency>
```

集成

```java
   /**
     * 创建RedissonClient(这里以单机redis为例子)
     *
     * @return
     */
    @Bean(destroyMethod = "shutdown")
    public static RedissonClient singletonRedisson() {
        Config config = new Config();
        // 可以将配置参数放到配置文件中
        config.useSingleServer().setAddress("redis://127.0.0.1:6379");
        return Redisson.create(config);
    }
```

使用

```java
@Service
public class XxxService {
     /**
     * 从Spring中引用
     */
    @Autowired
    private RedissonClient redisson;

     /**
     * 需要获取分布式锁的业务方法
     */
    public void redisson() {
        RLock rLock = redisson.getLock("lockName");
        // 如果获取锁成功
        if (rLock.tryLock()) {
            try {
                System.out.println("获取锁成功,执行业务逻辑");
            } finally {
                // 解锁
                rLock.unlock();
                System.out.println("解锁成功");
            }
        }
    }
}
```