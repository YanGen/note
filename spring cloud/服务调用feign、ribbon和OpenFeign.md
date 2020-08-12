## **ribbon**

目前，在Spring cloud 中服务之间通过restful方式调用有两种方式 

- restTemplate+Ribbon 
- feign

相同点:

　　：ribbon和feign都是实现软负载均衡调用

不同点:

**ribbon**：

是一个基于 HTTP 和 TCP 客户端的负载均衡器 

它可以在客户端配置 ribbonServerList（服务端列表），然后默认以轮询请求以策略实现均衡负载，他是使用可以用restTemplate+Ribbon 使用

**feign:**

Spring Cloud Netflix 的微服务都是以 HTTP 接口的形式暴露的，所以可以用 Apache 的 HttpClient ，而 Feign 是一个使用起来更加方便的 HTTP 客戶端，使用起来就像是调用自身工程的方法，而感觉不到是调用远程方法

**选择**
选择feign
默认集成了ribbon
写起来更加思路清晰和方便
采用注解方式进行配置，配置熔断等方式方便

## Feign

Feign是Springcloud组件中的一个轻量级Restful的HTTP服务客户端，Feign内置了Ribbon，是在ribbon上的一次升级。用来做客户端负载均衡，去调用服务注册中心的服务。Feign的使用方式是：使用Feign的注解定义接口，调用这个接口，就可以调用服务注册中心的服务

```maven
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-feign</artifactId>
</dependency>
```

spring-cloud的服务调用是基于http调用，dubbo是基于RPC调用。使用feign就能实现微服务间的方法调用。其实本质上相当于前端调用http接口,只不过这里用java代码实现，但也因此, 使用feign就可以与其他语言进行http通信了， 就是需要多一步写接口的流程。

spring-cloud的服务调用一般有两种，第一种是ribbon+restTemplate，第二种是feign 

下面记录feign 使用中遇到的坑
1.	@RequestMapping(value = "/user/{id}", method = RequestMethod.GET) 
	@GetMapping("/user/{id}")

	这两个注解的效果是等价的，但是在Feign使用中，只能用上面的那种方式，不能直接用@GetMapping，下面我们将前面的那个示例中，改成@GetMapping注解看下效果，我们发现，修改注解后重新启动服务的时候，抛了如下异常：
	Caused by: java.lang.IllegalStateException: Method findById not annotated with HTTP method type (ex. GET, POST) 
	异常的意思是，我们没有指定HTTP的方法
	
2.	@GetMapping("/template/{id}") 
	public User findById(@PathVariable Long id) { 
	return client.findById(id); 
	}

	这里，findById方法的参数中，我们直接使用了

	@PathVariable Long id

	启动服务，我们发现，又抛异常了，异常信息如下：

	Caused by: java.lang.IllegalStateException: PathVariable annotation was empty on param 0. 

	大概的意思是PathVariable注解的第一个参数不能为空，我们改成如下的方式：

	@RequestMapping(value = "/user/{id}", method = RequestMethod.GET) 
	User findById(@PathVariable("id") Long id);

3.	当接口上配了 FeignClient 和 RequestMapping 两个注解

	@FeignClient(value = "MICROSERVICECLOUD-GOODS-PROVIDER-8004",fallbackFactory=GoodsClientServiceFallbackFactory.class)
	@RequestMapping("/goods")
	public interface GoodsClientService extends BaseServiceApi<Goods> {

	}

	报
	This application has no explicit mapping for /error, so you are seeing this as a fallback.

	改
	@FeignClient(value = "MICROSERVICECLOUD-GOODS-PROVIDER-8004",path = "/goods",fallbackFactory=GoodsClientServiceFallbackFactory.class)
	public interface GoodsClientService extends BaseServiceApi<Goods> {

	}



## OpenFeign 用这个

Feign和OpenFeign两者都是在注册中心获取服务信息，通过协议进行请求转发。

OpenFeign是springcloud在Feign的基础上支持了SpringMVC的注解，如@RequestMapping等等。OpenFeign的@FeignClient可以解析SpringMVC的@RequestMapping注解下的接口，并通过动态代理的方式产生实现类，实现类中做负载均衡并调用其他服务。

```maven
 <dependency>
     <groupId>org.springframework.cloud</groupId>
     <artifactId>spring-cloud-starter-openfeign</artifactId>
 </dependency>
```

### OpenFeign简单使用

##### remote提供端

```Java
@EnableFeignClients
```

```java
@RequestMapping(value = "/goods/get",method = RequestMethod.GET)
public ResultBean get(){
    return ResultBean.succeed("商品信息");
}
```

##### local使用端

```java
@EnableFeignClients
```

```java
// 做成service
@Component
@FeignClient(name = "remote")
public interface RemoteService {
    @RequestMapping("/goods/get")
    public ResultBean get();
}
```

```java
// 调用
private final RemoteService remoteService;

public TestOpenFeignController(RemoteService remoteService) {
    this.remoteService = remoteService;
}

@RequestMapping("/getGoods")
public ResultBean getGoods(){
    return remoteService.get();
}
```

## 	Feign负载均衡

本质是ribbon负载均衡.

```java
/**
 * 负载均衡
 * @return
 */
@Bean
@LoadBalanced
public RestTemplate restTemplate() {
    return new RestTemplate();
}
```

加上以上配置就可以对注册中心同名服务进行负载均衡，另外可以指定其他或自定义的负载均衡策略。

介绍一下 Ribbon的几个比较常用的负载均衡实现

| 策略类                    | 命名             | 说明                                                         |
| ------------------------- | ---------------- | ------------------------------------------------------------ |
| RandomRule                | 随机策略         | 随机选择 Server                                              |
| RoundRobinRule            | 轮训策略         | 按顺序循环选择 Server                                        |
| RetryRule                 | 重试策略         | 在一个配置时问段内当选择 Server 不成功，则一直尝试选择一个可用的 Server |
| BestAvailableRule         | 最低并发策略     | 逐个考察 Server，如果 Server 断路器打开，则忽略，再选择其中并发连接最低的 Server |
| AvailabilityFilteringRule | 可用过滤策略     | 过滤掉一直连接失败并被标记为 `circuit tripped` 的 Server，过滤掉那些高并发连接的 Server（active connections 超过配置的网值） |
| ResponseTimeWeightedRule  | 响应时间加权策略 | 根据 Server 的响应时间分配权重。响应时间越长，权重越低，被选择到的概率就越低；响应时间越短，权重越高，被选择到的概率就越高。这个策略很贴切，综合了各种因素，如：网络、磁盘、IO等，这些因素直接影响着响应时间 |
| ZoneAvoidanceRule         | 区域权衡策略     | 综合判断 Server 所在区域的性能和 Server 的可用性轮询选择 Server，并且判定一个 AWS Zone 的运行性能是否可用，剔除不可用的 Zone 中的所有 Server |