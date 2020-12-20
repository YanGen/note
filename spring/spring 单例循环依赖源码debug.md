也许有些朋友对spring的循环依赖问题并不了解，让我们先一起看看这个例子。

```javascript
@Service
public class AService {

    private BService bService;

    public AService(BService bService) {
        this.bService = bService;
    }

    public void doA() {
        System.out.println("call doA");
    }
}
@Service
public class BService {

    private AService aService;

    public BService(AService aService) {
        this.aService = aService;
    }

    public void doB() {
        System.out.println("call doB");
    }
}
@RequestMapping("/test")
@RestController
public class TestController {

    @Autowired
    private AService aService;

    @RequestMapping("/doSameThing")
    public String doSameThing() {
        aService.doA();
        return "success";
    }
}
@SpringBootApplication
public class Application {

    /**
     * 程序入口
     * @param args 程序输入参数
     */
    public static void main(String[] args) {
        new SpringApplicationBuilder(Application.class).web(WebApplicationType.SERVLET).run(args);
    }
}
```

我们在运行Application类的main方法启动服务时，报了如下异常：

```javascript
Requested bean is currently in creation: Is there an unresolvable circular reference?
```

![image-20201219214944584](../cacheimg/image-20201219214944584.png)

这里提示得很明显，出现了循环依赖。

**什么是循环依赖？**

循环依赖是实例a依赖于实例b，实例b又依赖于实例a。

!![image-20201219215018044](../cacheimg/image-20201219215018044.png)

或者实例a依赖于实例b，实例b依赖于实例c，实例c又依赖于实例a。

![image-20201219215030339](../cacheimg/image-20201219215030339.png)

像这种多个实例之间的相互依赖关系构成一个环形，就是循环依赖。

**为什么会形成循环依赖？**

上面的例子中AService实例化时会调用构造方法 public AService(BService bService)，该构造方法依赖于BService的实例。此时BService还没有实例化，需要调用构造方法public BService(AService aService)才能完成实例化，该构造方法巧合又需要AService的实例作为参数。由于AService和BService都没有提前实例化，在实例化过程中又相互依赖对方的实例作为参数，这样构成了一个死循环，所以最终都无法再实例化了。

**spring要如何解决循环依赖？**

只需要将上面的例子稍微调整一下，不用构造函数注入，直接使用Autowired注入。

```javascript
@Service
public class AService {

    @Autowired
    private BService bService;

    public AService() {
    }

    public void doA() {
        System.out.println("call doA");
    }
}
@Service
public class BService {

    @Autowired
    private AService aService;

    public BService() {
    }

    public void doB() {
        System.out.println("call doB");
    }
}
```

我们看到可以正常启动了，说明循环依赖被自己解决了

![image-20201219215048333](../cacheimg/image-20201219215048333.png)

**spring为什么能循环依赖？**

调用applicationContext.getBean(xx)方法，最终会调到AbstractBeanFactory类的doGetBean方法。由于该方法很长，我把部分不相干的代码省略掉了。

```javascript
protected <T> T doGetBean(final String name, @Nullable final Class<T> requiredType,
@Nullable final Object[] args, boolean typeCheckOnly) throws BeansException { final String beanName = transformedBeanName(name);    Object bean;

    Object sharedInstance = getSingleton(beanName);
    if (sharedInstance != null && args == null) {
       省略........
      bean = getObjectForBeanInstance(sharedInstance, name, beanName, null);
    } else {
       省略........

        if (mbd.isSingleton()) {
          sharedInstance = getSingleton(beanName, () -> {
            try {
              return createBean(beanName, mbd, args);
            }
            catch (BeansException ex) {
              destroySingleton(beanName);
              throw ex;
            }
          });
          bean = getObjectForBeanInstance(sharedInstance, name, beanName, mbd);
        }

        else if (mbd.isPrototype()) {
          // It's a prototype -> create a new instance.
          Object prototypeInstance = null;
          try {
            beforePrototypeCreation(beanName);
            prototypeInstance = createBean(beanName, mbd, args);
          }
          finally {
            afterPrototypeCreation(beanName);
          }
          bean = getObjectForBeanInstance(prototypeInstance, name, beanName, mbd);
        }
        else {
          String scopeName = mbd.getScope();
          final Scope scope = this.scopes.get(scopeName);
          if (scope == null) {
            throw new IllegalStateException("No Scope registered for scope name '" + scopeName + "'");
          }
          try {
            Object scopedInstance = scope.get(beanName, () -> {
              beforePrototypeCreation(beanName);
              try {
                return createBean(beanName, mbd, args);
              }
              finally {
                afterPrototypeCreation(beanName);
              }
            });
            bean = getObjectForBeanInstance(scopedInstance, name, beanName, mbd);
          }
          catch (IllegalStateException ex) {
            throw new BeanCreationException(beanName,
                "Scope '" + scopeName + "' is not active for the current thread; consider " +
                "defining a scoped proxy for this bean if you intend to refer to it from a singleton",
                ex);
          }
        }
      }
      catch (BeansException ex) {
        cleanupAfterBeanCreationFailure(beanName);
        throw ex;
      }
    }
    省略........
    return (T) bean;
  }
```

我们可以看到，该方法一进来会调用getSingleton方法从缓存获取实例，如果获取不到。会判断作用域是否为：单例，多列 或者 都不是，不同的作用域创建实例的规则不一样。接下来，我们重点看一下getSingleton方法。

```javascript
  public Object getSingleton(String beanName) {
    return getSingleton(beanName, true);
  }
  protected Object getSingleton(String beanName, boolean allowEarlyReference) {
    Object singletonObject = this.singletonObjects.get(beanName);
    if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
      synchronized (this.singletonObjects) {
        singletonObject = this.earlySingletonObjects.get(beanName);
        if (singletonObject == null && allowEarlyReference) {
          ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
          if (singletonFactory != null) {
            singletonObject = singletonFactory.getObject();
            this.earlySingletonObjects.put(beanName, singletonObject);
            this.singletonFactories.remove(beanName);
          }
        }
      }
    }
    return singletonObject;
  }
```

我们发现有三个Map集合：

```javascript
  /** Cache of singleton objects: bean name --> bean instance */
  private final Map<String, Object> singletonObjects = new ConcurrentHashMap<>(256);

  /** Cache of singleton factories: bean name --> ObjectFactory */
  private final Map<String, ObjectFactory<?>> singletonFactories = new HashMap<>(16);

  /** Cache of early singleton objects: bean name --> bean instance */
  private final Map<String, Object> earlySingletonObjects = new HashMap<>(16);
```

singletonObjects对应一级缓存，earlySingletonObjects对应二级缓存，singletonFactories对应三级缓存。

上面getSingleton方法的逻辑是：

1.  先从singletonObjects（一级缓存）中获取实例，如果可以获取到则直接返回singletonObject实例。
2.  如果从singletonObjects（一级缓存）中获取不对实例，再从earlySingletonObjects（二级缓存）中获取实例，如果可以获取到则直接返回singletonObject实例。
3.  如果从earlySingletonObjects（二级缓存）中获取不对实例，则从singletonFactories（三级缓存）中获取singletonFactory，如果获取到则调用getObject方法创建实例，把创建好的实例放到earlySingletonObjects（二级缓存）中，并且从singletonFactories（三级缓存）删除singletonFactory实例，然后返回singletonObject实例。
4.  如果从singletonObjects、earlySingletonObjects和singletonFactories中都获取不到实例，则singletonObject对象为空。

获取实例需要调用applicationContext.getBean("xxx")方法，第一次调用getBean方法，代码走到getSingleton方法时返回的singletonObject对象是空的。然后接着往下执行，默认情况下bean的作用域是单例的，接下来我们重点看看这段代码：

![image-20201219215109094](../cacheimg/image-20201219215109094.png)

createBean方法会调用doCreateBean方法，该方法同样比较长，我们把不相干的代码省略掉。

```javascript
protected Object doCreateBean(final String beanName, final RootBeanDefinition mbd, final @Nullable Object[] args)
      throws BeanCreationException {

    BeanWrapper instanceWrapper = null;
    省略......
    
    if (instanceWrapper == null) {
      instanceWrapper = createBeanInstance(beanName, mbd, args);
    }
    final Object bean = instanceWrapper.getWrappedInstance();
    省略........

    boolean earlySingletonExposure = (mbd.isSingleton() && this.allowCircularReferences &&
        isSingletonCurrentlyInCreation(beanName));
    if (earlySingletonExposure) {
      addSingletonFactory(beanName, () -> getEarlyBeanReference(beanName, mbd, bean));
    }

    Object exposedObject = bean;
    try {
      populateBean(beanName, mbd, instanceWrapper);
      exposedObject = initializeBean(beanName, exposedObject, mbd);
    }
    catch (Throwable ex) {
      省略 .....
    }
    省略 .......
    return exposedObject;
  }
```

该方法的主要流程是：

1.  创建bean实例
2.  判断作用域是否为单例，允许循环依赖，并且当前bean正在创建，还没有创建完成。如果都满足条件，则调用addSingletonFactory将bean实例放入缓存中。
3.  调用populateBean方法进行依赖注入
4.  调用initializeBean方法完成对象初始化和AOP增强

我们关注的重点可以先放到addSingletonFactory方法上。

```javascript
  protected void addSingletonFactory(String beanName, ObjectFactory<?> singletonFactory) {
    Assert.notNull(singletonFactory, "Singleton factory must not be null");
    synchronized (this.singletonObjects) {
      if (!this.singletonObjects.containsKey(beanName)) {
        this.singletonFactories.put(beanName, singletonFactory);
        this.earlySingletonObjects.remove(beanName);
        this.registeredSingletons.add(beanName);
      }
    }
  }
```

该方法的逻辑是判断如果singletonObjects（一级缓存）中找不到实例，则将singletonFactory实例放到singletonFactories（三级缓存）中，并且移除earlySingletonObjects（二级缓存）中的实例。

createBean方法执行完之后，会调用外层的getSingleton方法

![image-20201219215122717](../cacheimg/image-20201219215122717.png)

我们重点看看这个getSingleton方法

```javascript
public Object getSingleton(String beanName, ObjectFactory<?> singletonFactory) {
    Assert.notNull(beanName, "Bean name must not be null");
    synchronized (this.singletonObjects) {
      Object singletonObject = this.singletonObjects.get(beanName);
      if (singletonObject == null) {
        if (this.singletonsCurrentlyInDestruction) {
          throw new BeanCreationNotAllowedException(beanName,
              "Singleton bean creation not allowed while singletons of this factory are in destruction " +
              "(Do not request a bean from a BeanFactory in a destroy method implementation!)");
        }
        beforeSingletonCreation(beanName);
        boolean newSingleton = false;
        boolean recordSuppressedExceptions = (this.suppressedExceptions == null);
        if (recordSuppressedExceptions) {
          this.suppressedExceptions = new LinkedHashSet<>();
        }
        try {
          singletonObject = singletonFactory.getObject();
          newSingleton = true;
        }
        catch (IllegalStateException ex) {

          singletonObject = this.singletonObjects.get(beanName);
          if (singletonObject == null) {
            throw ex;
          }
        }
        catch (BeanCreationException ex) {
          if (recordSuppressedExceptions) {
            for (Exception suppressedException : this.suppressedExceptions) {
              ex.addRelatedCause(suppressedException);
            }
          }
          throw ex;
        }
        finally {
          if (recordSuppressedExceptions) {
            this.suppressedExceptions = null;
          }
          afterSingletonCreation(beanName);
        }
        if (newSingleton) {
          addSingleton(beanName, singletonObject);
        }
      }
      return singletonObject;
    }
  }
```

该方法逻辑很简单，就是先从singletonObjects（一级缓存）中获取实例，如果获取不到，则调用singletonFactory.getObject()方法创建一个实例，然后调用addSingleton方法放入singletonObjects缓存中。

```javascript
  protected void addSingleton(String beanName, Object singletonObject) {
    synchronized (this.singletonObjects) {
      this.singletonObjects.put(beanName, singletonObject);
      this.singletonFactories.remove(beanName);
      this.earlySingletonObjects.remove(beanName);
      this.registeredSingletons.add(beanName);
    }
  }
```

该方法会将实例放入singletonObjects（一级缓存），并且删除singletonFactories（二级缓存），这样以后再调用getBean时，都能从singletonObjects（一级缓存）中获取到实例了。

说了这么多，再回到示例中的场景。

![image-20201219215153726](../cacheimg/image-20201219215153726.png)