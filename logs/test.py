import time
timestamp = 1577670720
format='%Y-%m-%d %H:%M:%S'
timeTuple = time.localtime(timestamp)  # 把时间戳转换成时间元祖
result = time.strftime(format, timeTuple)

print(all([True,True,1]))

print(result)