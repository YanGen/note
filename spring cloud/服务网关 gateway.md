## 概念

Route 路由，网关基本单元

1. ID

   定义这个路由单元的唯一标识，无实际意义，一般用此路由转发(或代理)的目标服务的服务名称命名。

2. uri

   代理前置路径

3. predicates 谓词、断言

   路由转发的判断条件，通过`PredicateDefinition`类进行接收配置。目前SpringCloud Gateway支持多种方式， 常见如：Path、Query、Method、Header、开放时间等，符合断言则进行代理。

   <img src="https://img2018.cnblogs.com/blog/1450135/201910/1450135-20191022114243645-371057197.png" alt="img" style="zoom:50%;" />

4. filters

   过滤器是路由转发请求时所经过的过滤逻辑，可用于修改请求、响应内容。

##### 可以通过Java进行规则配置，也可以通过yaml进行配置，目前来看更推荐yaml

```yaml
# 举个栗子
spring:
  main:
    allow-bean-definition-overriding: true
  application:
    name: gateway
  cloud:
    gateway:
      #路由
      routes:
        #demo 完整转发路径 = uri + predicates = http://localhost:18003/demo/hello/**
        - id: demo #请求 http://localhost:18003/demo/*会转发到demo服务
          uri: lb://demo #在服务注册中心找服务名为 demo的服务
          predicates:
            - Path= /hello/** #设置路由断言,代理servicerId为demo的hello路径
          filters:
            - StripPrefix=1
      discovery:
        locator:
          enabled: true #表明Gateway开启动态路由 可以服务名命名uri lb://微服务名
          lower-case-service-id: true #将请求路径上的服务名配置为小写
```

## predicates

```yaml
# 匹配路径转发
- Path=/xxx/**.html
# 某一个时间点之前允许路由转发
- Before=2019-05-01T00:00:00+08:00[Asia/Shanghai]
# 某一个时间点之后允许路由转发
- After=2019-04-29T00:00:00+08:00[Asia/Shanghai]
# 某一时间段
- Between=2019-04-29T00:00:00+08:00[Asia/Shanghai], 2019-05-01T00:00:00+08:00[Asia/Shanghai]
# 携带对应Cookie才能过
# 测试 curl http://localhost:9090 --cookie "hengboy=yuqiyu"
- Cookie=hengboy, yuqiyu
# header + 正则 如果X-Request-Id的值为数字，那么就可以转发
- Header=X-Request-Id, \d+
# 只允许**.yuqiyu.com域名进行访问，那么配置如下所示
- Host=**.yuqiyu.com
- Method=POST
# 请求中存在xxx参数
- Query=xxx
# 请求中存在xxx参数且值为zzz
- Query=xxx,zzz
# 限制允许访问接口的客户端IP地址，配置后只对指定IP地址的客户端进行请求转发，配置如下所示 24则是子网掩码
- RemoteAddr=192.168.1.56/24
# 相同的Predicate也可以配置多个，请求的转发是必须满足所有的Predicate后才可以进行路由转发，组合使用示例如下所示
spring:
  cloud:
    gateway:
      routes:
        - id: blog
          uri: http://blog.yuqiyu.com
          predicates:
            - Query=author, hengboy
            - Query=yuqiyu
            - Method=GET
            - Cookie=hengboy, yuqiyu
            - Header=X-Request-Id, \d+
            - RemoteAddr=192.168.1.56/24
```

