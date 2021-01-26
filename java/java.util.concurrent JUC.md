### CAS

 	CAS硬件级别保证原子性，如何实现？过程？
	1.预设 内存值、预期值、新值 三个值
	2.进行 预期值和内存值 是否相等的判断
	3.若相等则修改内存值为新值
	4.若不相等则更新 预期值和新值 
	5.重复以上操作直到修改成功 结束



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

![微信图片_20201129172644](..\cacheImg\微信图片_20201129172644.png)



### 以ReentrantLock的 lock unlock为切入点学习 AQS

<img src="..\cacheImg\微信图片_20201129182333.png" alt="微信图片_20201129182333" style="zoom:50%;" />

ReentrantLock内部类Sync继承抽象类AQS，本质是对AQS抽象层的实现(落地)，而Sync的两个子类 NonfairSync和FairSync分别实现公平非公平锁。

###### 整个ReentrantLock的非公平锁抢占过程，可以分为三个阶段:

1.  尝试加锁，成功加锁的线程执行;
2.  加锁失败，线程自旋的CAS进去入队列(Node链表)，无头节点时必须在第一轮自旋先初始化一个哨兵节点(head指向);
3.  封装着线程的节点CAS响应修改pre、next(入队)后，进入阻塞状态等待占锁线程唤醒(LockSupport的park、unpark)；
4.  抢占锁线程执行完成后，设置整体状态为可抢占(锁)并唤醒队列中哨兵后方节点线程；
5.  将Node中线程提出执行(Node的线程引用置为null)，并删除与哨兵Node的前后指针指向，让哨兵Node的next形成新的哨兵节点，旧哨兵节点等待GC(此时已经不可达)；

###### AQS需要的一些标志属性(关键点)

<img src="..\cacheImg\微信图片_20201201213256.png" alt="微信图片_20201201213256" style="zoom: 33%;" /><img src="..\cacheImg\微信图片_20201201213600.png" alt="微信图片_20201201213600" style="zoom:50%;" /><img src="..\cacheImg\微信图片_20201201213256.png" alt="微信图片_20201201213256" style="zoom: 33%;" /><img src="..\cacheImg\微信图片_20201201213600.png" alt="微信图片_20201201213600" style="zoom:50%;" />

1.  Node节点链表，Node封装如上。
2.  链表的头尾前后指针。
3.  exclusiveOwnerThread(在运行线程 由AQS继承自父类)、state(AQS 当前锁占用状态)、waitStatus(每个Node) 三个状态

