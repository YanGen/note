#### **传统五大数据类型(一般用string做k)**

string 

​	对应 Map<String,String>

list

​	对应Map<String,LinkList>，这个list是双向的 Lpush、Rpush可以往两边放

hash

​	对应 Map<String,Map<k,v>>

set

​	对应 Map<String,Set> 无序无重复

zset(sorted set)

​	对应 Map<String,Set> 有序可排序无重复

=============

还有吗？

bitmap

HyperLogLogs

GEO

Stream

![image-20201219230324718](../cacheimg/image-20201219230324718.png)

![image-20201220114412595](../cacheimg/image-20201220114412595.png)

![image-20201220115023622](../cacheimg/image-20201220115023622.png)

![image-20201220114436471](../cacheimg/image-20201220114436471.png)

![image-20201220115553794](../cacheimg/image-20201220115553794.png)

![image-20201220120206290](../cacheimg/image-20201220120206290.png)

##### SpringDataRedis 的StringRedisTemplate

```
StringRedisTemplate.opsForValue().* //操作String字符串类型
StringRedisTemplate.delete(key/collection) //根据key/keys删除3 StringRedisTemplate.opsForList().*  //操作List类型4 StringRedisTemplate.opsForHash().*  //操作Hash类型
StringRedisTemplate.opsForSet().*  //操作set类型
StringRedisTemplate.opsForZSet().*  //操作有序set
```

ps 关于RedisTemplate和StringRedisTemplate的区别

​		当你的redis数据库里面本来存的是字符串数据或者你要存取的数据就是字符串类型数据的时候，那么你就使用StringRedisTemplate即可， 但是如果你的数据是复杂的对象类型，而取出的时候又不想做任何的数据转换，直接从Redis里面取出一个对象，那么使用RedisTemplate是 更好的选择。