#### 读写锁可以保证读取的数据都是最新的，注意：只要写锁存在，读锁必须等待，等到写锁释放

读 + 读  无锁

写 + 读  等待写锁释放

写 + 写  阻塞

读 + 写 等待读锁释放

**总结：读共享，写排他，只要有写就有等待，如果经常读会影响系统性能。**

分布式下读写锁demo

```java
//Redisson-读写锁

//改数据加写锁

RReadWriteLock  lock = redisson.getReadWritelLock("rw-lock");
String s = "";
RLock rLock = lock.writeLock();

try{
    // 加锁
    rLock.lock();
    s = uuid;
    // 执行业务代码
    Thread.sleep(30000);
    redisTemplate.opsForValue().set("writeValue",s);
} catch(Exception e) {
    e.printStackTrace();
} finally{
// 解锁
    rLock.unlock();
}

//读数据加读锁

RReadWriteLock  lock = redisson.getReadWritelLock("rw-lock");
String s = "";
RLock rLock = lock.readLock();

try{
// 加锁
    rLock.lock();
    s = uuid;
    // 执行业务代码
    Thread.sleep(30000);
    redisTemplate.opsForValue().set("writeValue",s);
} catch(Exception e) {
    e.printStackTrace();
} finally{
    // 解锁
    rLock.unlock();
}
```

