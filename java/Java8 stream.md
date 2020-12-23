## Stream API常用方法：

注：数据量越大，stream的优势越明显，数据量小，for循环性能最好。

1. 对集合操作简单，使用fori即可。
2. 如果不是很在意性能，且对集合操作较为复杂，建议适用stream。
3. 数据量大，考虑使用多线程时，且数据之间没有内在联系，推荐stream。

| Stream操作分类 |                                                         |                                                              |
| -------------- | ------------------------------------------------------- | ------------------------------------------------------------ |
| 中间操作       | 无状态                                                  | unordered() filter() map() mapToInt() mapToLong() mapToDouble() flatMap() flatMapToInt() flatMapToLong() flatMapToDouble() peek() |
| 有状态         | distinct() sorted() boxed() limit() skip()              |                                                              |
| 结束操作       | 非短路操作                                              | forEach() forEachOrdered() toArray() reduce() collect() max() min() count() |
| 短路操作       | anyMatch() allMatch() noneMatch() findFirst() findAny() |                                                              |

　　

  无状态：指元素的处理不受之前元素的影响；

  有状态：指该操作只有拿到所有元素之后才能继续下去。

  非短路操作：指必须处理所有元素才能得到最终结果；

  短路操作：指遇到某些符合条件的元素就可以得到最终结果，如 A || B，只要A为true，则无需判断B的结果。

### **常用中间件**

   filter：过滤流，过滤流中的元素，返回一个符合条件的Stream

   map：转换流，将一种类型的流转换为另外一种流。（mapToInt、mapToLong、mapToDouble 返回int、long、double基本类型对应的Stream）

   flatMap：简单的说，就是一个或多个流合并成一个新流。（flatMapToInt、flatMapToLong、flatMapToDouble 返回对应的IntStream、LongStream、DoubleStream流。）

   distinct：返回去重的Stream。

   sorted：返回一个排序的Stream。

   peek：主要用来查看流中元素的数据状态。

   limit：返回前n个元素数据组成的Stream。属于短路操作

   skip：返回第n个元素后面数据组成的Stream。 

　  boxed: 将LongStream、IntStream、DoubleStream转换成对应类型的Stream<T>

### **结束操作**

 forEach: 循环操作Stream中数据。

 toArray: 返回流中元素对应的数组对象。

 reduce: 聚合操作，用来做统计。

 collect: 聚合操作，封装目标数据。

 min、max、count: 聚合操作，最小值，最大值，总数量。

 anyMatch: 短路操作，有一个符合条件返回true。

 allMatch: 所有数据都符合条件返回true。

 noneMatch: 所有数据都不符合条件返回true。

 findFirst: 短路操作，获取第一个元素。

 findAny: 短路操作，获取任一元素。

 forEachOrdered: 暗元素顺序执行循环操作。

 

## 举例说明

```java
@Data
public class Person {
    
    private Integer  id;
    
    private String name;
    
    private String sex;
    
    private Integer age;
    
}
```

map中间件例子

```java
public class TestMap {

    public static void main(String[] args) {
        List<Person> persionList = new ArrayList<Person>();
        persionList.add(new Person(1,"小陈","男",38));
        persionList.add(new Person(2,"小小","女",2));
        persionList.add(new Person(3,"小李","男",65));
        persionList.add(new Person(4,"小王","女",20));
        persionList.add(new Person(5,"小童","男",38));
        persionList.add(new Person(6,"小刘","男",65));

        //1、只取出该集合中所有姓名组成一个新集合
        List<String> nameList=persionList.stream().map(Person::getName).collect(Collectors.toList());
        System.out.println(nameList.toString());

       
        //2、只取出该集合中所有id组成一个新集合
        List<Integer> idList=persionList.stream().mapToInt(Person::getId).boxed().collect(Collectors.toList());
        System.out.println(idList.toString());

        //3、list转map，key值为id，value为Person对象
        Map<Integer, Person> personmap = persionList.stream().collect(Collectors.toMap(Person::getId, person -> person));
        System.out.println(personmap.toString());

        //4、list转map，key值为id，value为name
        Map<Integer, String> namemap = persionList.stream().collect(Collectors.toMap(Person::getId, Person::getName));
        System.out.println(namemap.toString());

        //5、进行map集合存放，key为age值 value为Person对象 它会把相同age的对象放到一个集合中
        Map<Integer, List<Person>> ageMap = persionList.stream().collect(Collectors.groupingBy(Person::getAge));
        System.out.println(ageMap.toString());

        //6、获取最小年龄
        Integer ageMin = persionList.stream().mapToInt(Person::getAge).min().getAsInt();
        System.out.println("最小年龄为: "+ageMin);

        //7、获取最大年龄
        Integer ageMax = persionList.stream().mapToInt(Person::getAge).max().getAsInt();
        System.out.println("最大年龄为: "+ageMax);

        //8、集合年龄属性求和
        Integer ageAmount = persionList.stream().mapToInt(Person::getAge).sum();
        System.out.println("年龄总和为: "+ageAmount);
        
    }
}
```

###  filter相关

```java
public class TestFilter {

    public static void main(String[] args) {
        List<Person> persionList = new ArrayList<Person>();
        persionList.add(new Person(1, "张三", "男", 8));
        persionList.add(new Person(2, "小小", "女", 2));
        persionList.add(new Person(3, "李四", "男", 25));
        persionList.add(new Person(4, "王五", "女", 8));
        persionList.add(new Person(5, "赵六", "女", 25));
        persionList.add(new Person(6, "大大", "男", 65));

        //1、查找年龄大于20岁的人数
        long  age=persionList.stream().filter(p->p.getAge()>20).count();
        System.out.println(age);

        //2、查找年龄大于20岁，性别为男的人数
       List<Person>  ageList=persionList.stream().filter(p->p.getAge()>20).filter(p->"男".equals(p.getSex())).collect(Collectors.toList());
        System.out.println(ageList.size());

    }
```

### sorted相关

```java
//数组相关public class TestSort {

    String[] arr1 = {"abc","a","bc","abcd"};

    /**
     * 按照字符长度排序
     */
    @Test
    public void testSorted1_(){
        Arrays.stream(arr1).sorted(Comparator.comparing(String::length)).forEach(System.out::println);
        //输出：a、bc、abc、abcd
    }

    /**
     * 倒序
     * reversed(),java8泛型推导的问题，所以如果comparing里面是非方法引用的lambda表达式就没办法直接使用reversed()
     * Comparator.reverseOrder():也是用于翻转顺序，用于比较对象（Stream里面的类型必须是可比较的）
     * Comparator. naturalOrder()：返回一个自然排序比较器，用于比较对象（Stream里面的类型必须是可比较的）
     */
    @Test
    public void testSorted2_(){
        Arrays.stream(arr1).sorted(Comparator.comparing(String::length).reversed()).forEach(System.out::println);
        //输出：abcd、abc、bc、a
        Arrays.stream(arr1).sorted(Comparator.reverseOrder()).forEach(System.out::println);
        //输出：bc、abcd、abc、a
        Arrays.stream(arr1).sorted(Comparator.naturalOrder()).forEach(System.out::println);
        //输出：a、abc、abcd、bc
    }

    /**
     * 先按照首字母排序
     * 之后按照String的长度排序
     */
    @Test
    public void testSorted3_(){
        Arrays.stream(arr1).sorted(Comparator.comparing(this::com1).thenComparing(String::length)).forEach(System.out::println);
    }
    //输出：a、abc、abcd、bc
    public char com1(String x){
        return x.charAt(0);
    }
}
```

### 集合相关

```java
public class TestSort {

    public static void main(String[] args) {
        List<Person> persionList = new ArrayList<Person>();
        persionList.add(new Person(1, "张三", "男", 8));
        persionList.add(new Person(2, "小小", "女", 2));
        persionList.add(new Person(3, "李四", "男", 25));
        persionList.add(new Person(4, "王五", "女", 8));
        persionList.add(new Person(5, "赵六", "女", 25));
        persionList.add(new Person(6, "大大", "男", 65));

        //1、找到年龄最小的岁数
        Collections.sort(persionList, (x, y) -> x.getAge().compareTo(y.getAge()));
        Integer age = persionList.get(0).getAge();
        System.out.println("年龄最小的有:" + age);
        //输出：年龄最小的有:2

        //2、找到年龄最小的姓名
        String name = persionList.stream()
                .sorted(Comparator.comparingInt(x -> x.getAge()))
                .findFirst()
                .get().getName();
        System.out.println("年龄最小的姓名:" + name);
        //输出：年龄最小的姓名:小小
    }
}
```