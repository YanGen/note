在构造方法中的tableSizeFor的作用，对传入的初始化容量大小进行格式化。

```java
/**
 * Returns a power of two size for the given target capacity.
 * 返回大于输入参数且最近的2的整数次幂的数。比如10，则返回16。
 */
static final int tableSizeFor(int cap) {
    int n = cap - 1;
    n |= n >>> 1;
    n |= n >>> 2;
    n |= n >>> 4;
    n |= n >>> 8;
    n |= n >>> 16;
    return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
}
```





HashMap扩容条件

当哈希表中的条目数超出了加载因子(LoadFactory)与当前容量(capacity)的乘积时，并且要存放的位置已经有元素了（hash碰撞）





### 为啥桶数组的长度是2的N次方？

**好处**

1. 计算更加高效

   ```java
   static final int hash(Object key) {
       int h;
       return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
   }
   ```

   

2. Hash 分布更加均匀

### JDK 1.8改动

- 链表为尾插法