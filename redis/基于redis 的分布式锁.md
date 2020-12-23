### 基于redis Java implement的redisTemplate

```java
public void stock(){
    // 保证加锁解锁是同一线程
    String uuid = UUID.randomUUID().toString();
    boolean lock = redisTemplate.opsForValue.setIfAbsent("lock",uuid,180,TimeUnit.SECONDS);
    if(lock){
        try{
            // 执行业务...
        }finally{
            // Lua脚本 - 2个参数 key和value 保证判断和删除是原子操作
           String script = "if redis.call('get',KEYS[1]) == ARGV[1] then return redis.call('del',KEYS[1]) else return 0 end";
           Long result = redisTemplate.execute(new DefaultRedisScript<Long>(script,Long.class),Arrays.asList("lock"),uuid);
       }else{
            // 拿不到锁执行逻辑
        }
}
```

**ps:上面的代码解决了** 

- 基于redis setNX(不存在则设置) 命令，一对键值为锁,不存在则设置代替枪锁
- 原子加锁和设置过期时间
- 唯一的标志id确保加锁解锁是同一线程
- lua脚本保证在解锁时判断同一线程和删除锁的

**存在问题**

- 锁续期问题，如果业务执行时间过长，锁自动消除但以持有的未解锁所以仍有一定概率产生同步问题，上面的代码只能将过期时间加长或者启动协助进程来判断持有线程是否解锁，未解锁则对锁过期时间定期续命。而Redisson已经相应(看门狗)实现了分布式锁的续期问题。
- 不可重入，和synchronized一样。而Redisson有可重复锁。

### redisson已实现的分布式锁

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
        Long userId = 1111L;
        RLock rLock = redisson.getLock("lockName");
        // 如果获取锁成功
        if (rLock.tryLock()) {
            try {
                System.out.println("获取锁成功,执行业务逻辑");
            } finally {
                // 解锁 注意这里要判断
                rLock.unlock();
                System.out.println("解锁成功");
            }
        }
    }
}
```

原理：

![img](D:\project\java\note\cacheImg\20190328230407942.jpg)