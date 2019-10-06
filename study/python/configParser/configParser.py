import configparser


import configparser #引入模块

config = configparser.ConfigParser()    #类中一个方法 #实例化一个对象

config["DEFAULT"] = {'ServerAliveInterval': '45',
                      'Compression': 'yes',
                     'CompressionLevel': '9',
                       'ForwardX11':'yes'
                     }	#类似于操作字典的形式

config['bitbucket.org'] = {'User':'Atlan'} #类似于操作字典的形式

config['topsecret.server.com'] = {'Host Port':'50022','ForwardX11':'no'}

with open('example.ini', 'w') as configfile:

   config.write(configfile)	


config.read('example.ini')  #读文件

config.add_section('yuan')  #添加section



config.remove_section('bitbucket.org') #删除section
config.remove_option('topsecret.server.com',"forwardx11") #删除一个配置想


config.set('topsecret.server.com','k1','11111')
config.set('yuan','k2','22222')
with open('new2.ini','w') as f:
     config.write(f)