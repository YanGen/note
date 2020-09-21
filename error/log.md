## 记录一些错误

**Redis - OutOfDirectMemoryError**

1. springboot2.0以后默认使用lettuce作为操作redis的客户端，使用netty进行网络通信，吞吐量十分大，同时netty使用直接内存并且限制默认大小，导致堆外内存溢出。
2. netty如果没有指定堆外内存，默认会使用**-Xmx300m**，可以通过**-Dio.netty.maxDirectMemory**进行设置
3. -**Dio.netty.maxDirectMemory**调大堆外内存是没用的(过一段时间还会溢出)，可以升级lettuce客户端，切换使用旧版jedis，使其使用堆内存参与GC。

##### spring cache - SpelEvaluationException: EL1007E: Property or field 'id' cannot be found on

1. @Cacheable key = "#result.id" 当注解用到#result 的时候，需要加上result 不为空的条件判断否则抱错

2. 解决：

   @Cacheable(value = "function",key = "#result.id",condition = "#result != null")

