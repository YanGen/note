## 注解

```java
@SentinelResource(value="testA",
            blockHandler="handleException",blockHandlerClass= SentinelBlockHandler.class,
            fallback = "fallBackHandler",fallbackClass = SentinelFallbackHandler.class,
            exceptionsToIgnore = {
                RuntimeException.class,
            }
    )
```

blockHandler管sentinel层面的请求违规(违反流控配置等...)
fallback 管Java runtime 层面的请求异常，注解SentinelResource可以理解成try块包含了原方法，fallback管理原方法异常后处理方法。
exceptionsToIgnore 忽略指定类型错误，会直接跳过处理这类错误。

## 流控:

​	概念：
​		resource 资源名称 ：接口的请求路径
​		grade 阈值类型：QPS、线程数
​		strategy : 流控制模式, 直接，关联、 链路
​		controlBehavior : 流控效果 
​			快速失败 ：当QPS超过了指定的阈值时，请求会立即拒绝，拒绝的方式是抛出FlowException。
​			Warm Up （预热/冷启动方式）：当系统长期的处于低水平的情况下，流量突然增加时，直接吧系统拉升到高水位可能瞬间把系统压垮。通过“冷启动”，让请求的流量缓慢增加，在一定时间内增加到阈值的上限，给冷系统一个预热的时间。避免令系统被压垮。
​			匀速排队：类似队列。

## 降级:

​	平均响应时间RT
​		平均响应时间(RT)是先计算前5次的请求的平均处理时间，如果超过了预定的阈值时间(count)，那么在接下来的时间范围/窗口(timeWindow)后直接进行服务降级，抛出DegradeException.过了时间窗口后重新计算RT.

异常比例
		超过异常比例则触发降级，时间窗口时间内访问均抛DegradeException.
异常数
		超过异常数则触发降级，时间窗口时间内访问均抛DegradeException.
TW time window 时间窗口 
		从第一次抛出DegradeException 等待时间，过了时间窗口后重新等待触发.

## 热点:

针对对应索引位参数设定限流
限流模式
​	QPS限流
参数索引
​	处理方法的第几位参数，索引位从0开始
阈值
窗口时长

参数例外项 对特定类型特定值进行针对限流，参数索引引用以上配置
	参数类型
	参数值
	阈值

## 系统保护规则 (SystemRule)

针对整个系统的重要属性：
Load（仅对 Linux/Unix-like 机器生效）：当系统 load1 超过阈值，且系统当前的并发线程数超过系统容量时才会触发系统保护。系统容量由系统的 maxQps * minRt 计算得出。设定参考值一般是 CPU cores * 2.5。

CPU使用率：当系统 CPU 使用率超过阈值即触发系统保护（取值范围 0.0-1.0）。

RT：当单台机器上所有入口流量的平均 RT 达到阈值即触发系统保护，单位是毫秒。

线程数：当单台机器上所有入口流量的并发线程数达到阈值即触发系统保护。

入口 QPS：当单台机器上所有入口流量的 QPS 达到阈值即触发系统保护。

