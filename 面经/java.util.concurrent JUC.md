### LockSupport

一句话 线程等待唤醒机制 wait/notify 的改良加强版

###### 线程等待唤醒的三种方式(功能越来越强)

1.  synchronized 对 object加锁的 wait和notify 

    wait和notify必须与synchronized联用，而且wait必须在notify之前

2.  lock 加锁 Condition的wait 和signal

    同上wait 和signal必须与lock联用，必须加锁在前，同时wait必须在signal之前

    ```java
        static Lock lock = new ReentrantLock();
        static Condition condition = lock.newCondition();
    	lock.lock()
    	condition.wait();
        condition.signal();
    	lock.unlock()
    ```

3.  LockSupport的 park()和unpark() 阻塞和唤醒  牛逼！

    unpark可以在park之前使用，即唤醒之后执行阻塞无效。

    LockSupport的阻塞状态只有0和1不会累积阻塞，详见下注。

    ```java
    LockSupport.park();//消耗许可证(permit)执行 无许可证则阻塞
    LockSupport.unpark(被阻塞的线程引用);//增加许可证
    ```

​	

[^LockSupport]: 该类与使用它的每个线程关联一个许可证（在[`Semaphore`](https://www.apiref.com/java11-zh/java.base/java/util/concurrent/Semaphore.html)类的意义上）。 如果许可证可用，将立即返回`park` ，并在此过程中消费; 否则*可能会*阻止。 如果尚未提供许可，则致电`unpark`获得许可。 （与Semaphores不同，许可证不会累积。最多只有一个。）

​		

### AQS	AbstractQueuedSynchronizer 抽象队列同步器 重要

-   技术解释：AQS 是用来构建锁或者其它同步器组件的重量级基础框架及整个Juc体系的基石，通过内置的FIFO队列来完成资源获取线程的排队工作，并通过一个int类型变量表示持有锁的状态。

-   AQS = status + CLH(双向链表)队列

-   两个概念：

    ​	锁：面向锁的使用者 (ReetrantLock、CountDownLatch、Samaphore....)

    ​	同步器：面向锁的事先者

    AQS抽象队列同步器统一了锁的实现规范

-   原理：AQs使用一个volatile的int类型的成员变量来表示同步状态，通过内置的FIFO队列来完成资源获取的排队工作将每条要去抢占资源的线程封装成一个Node节点来实现锁的分配，通过CAS完成对State值的修改。

![微信图片_20201129172644](C:\Users\86135\Desktop\github\note\cacheImg\微信图片_20201129172644.png)



### 已ReetrantLock的 lock unlock为切入点学习 AQS

<img src="C:\Users\86135\Desktop\github\note\cacheImg\微信图片_20201129182333.png" alt="微信图片_20201129182333" style="zoom:50%;" />

ReentrantLock内部类Sync继承抽象类AQS，本质是对AQS的封装。

###### 整个ReentrantLock的加锁过程，可以分为三个阶段:

1.  尝试加锁;
2.  加锁失败，线程入队列;
3.  线程入队列后，进入阻塞状态。