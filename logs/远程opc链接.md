### win10 下远程opc访问配置

###### 1.首先确保本机账号密码与远程opcserver主机账号密码相同

client 开启一个与opcserver账户名相同的账户并设置与远程opc server主机相同的账号密码，安装 opc remote ，必须提前使账户具有权限的管理员(如Administrator)下安装且 ，如果否则安装失败，安装后会自动生成一个win账户，不用管。

##### 2.配置DCOM

​	打开电脑组件服务->计算机->我的电脑->属性

​	在默认属性中开启![DCOM](D:\project\java\note\logs\DCOM.png)

​	![DCOM1](D:\project\java\note\logs\DCOM1.png)

​	在COM安全中 对访问权限 和 启动和激活权限 进行编辑限制 对应账户(像前面提到的同名账户 Administrator、Everyone)的权限全部开启

![DCOM2](D:\project\java\note\logs\DCOM2.png)

##### 3.安装opc 核心包

![DCOM3](D:\project\java\note\logs\DCOM3.png)

##### 4.结束

​	附资源

链接：https://pan.baidu.com/s/1fdzcr0ttZmCHpCMj9wUL4g 
提取码：10ln