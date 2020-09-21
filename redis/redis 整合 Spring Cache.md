#### 整合spring cache简化缓存开发

SpringCache本身是一个缓存体系的抽象实现，并没有具体的缓存能力，要使用SpringCache还需要配合具体的缓存实现来完成。

```java
<dependency>
 <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-cache</artifactId>
</dependency>
```

#### 指定使用redis

```java
spring.cache.type = redis
```

SpringCache可以整合各种存储单元，其中包括redis

当应用配置的是redis，那么不指定也能自动识别应用配置的redis

主启动类 @EnableCaching

##### 几个注解

```
@Cacheable：触发将数据保存到缓存
@CacheEvict：触发将数据从缓存删除的操作
@CachePut：不影响方法执行更新缓存
@Caching：组合以上多个操作
@CacheConfig：在类级别共享缓存的相同配置
```

##### 不足

## Spring-Cache的不足

**原理：**

> `CacheManager`（`RedisCacheManager`） --创建--> `Cache`（`RedisCache`）--> `Cache`负责缓存的读写操作

**不足：**

（1）、**读模式**

- `缓存穿透`：查询一个null数据。`解决：缓存空数据`，添加配置 `spring.cache.redis.cache-null-values=true`
- `缓存击穿`：大量并发进来同时查询一个正好过期的数据。`解决：加锁`。但是Spring-Cache默认put时是不加锁的，所以没有办法解决这个问题。但是可以设置 `sync = true` `@Cacheable(value = xxx, key = xxx, sync = true)`，在查缓存的时候调用使用了同步的get方法`org.springframework.data.redis.cache.RedisCache#get(java.lang.Object, java.util.concurrent.Callable)` 获取到获取到空数据时在put中放一份空的数据。
- `缓存雪崩`：大量的key同时过期。`解决：加随机时间`。加上过期时间：`spring.cache.redis.time-to-live=3600000`

（2）、**写模式（缓存与数据库一致）**

- 1）`读写加锁`：使用读多写少场景
- 2）`引入Canal：感知到MySQL的更新就去更新缓存
- 3）`读多写多`：直接去数据库查询
- 4）不在乎暂时的脏数据则不考虑一致性

**总结：**

- `常规数据`（读多写少、即时性、一致性要求不高的数据）：完全可以使用Spring-Cache；写模式：只要缓存设置了过期时间就足够了
- `特殊数据`：特殊设计