```python
# 导包
from selenium import webdriver
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
```

```python
    # 启动
    chrome_options = webdriver.ChromeOptions()
    # 更换头部
    chrome_options.add_argument(
        'user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"')
    
    # 远程操控
    # chrome_options.add_experimental_option('debuggerAddress', '127.0.0.1:9222')
	# 添加host
    chrome_options.add_argument(
        'Host="wap.gd.10086.cn"'
    )
    browser = webdriver.Chrome(executable_path="chromedriver.exe", options=chrome_options)
```

```python
#添加cookie
driver.add_cookie({'name':'test_selenium','value':'test_auto'})

#  注意：添加使用cookies的时候，需要先访问url，才能生效,例如
browser.get("https://wap.gd.10086.cn")
browser.add_cookie({
        'name':'validCode',
        'value':"1",
    })
url = 'https://wap.gd.10086.cn/ncc/web/h5/#/offLineCenter?Date=11&isdecrypt=1&recoempltel=627044423671713630776d5268375359464430636c773d3d&city=755&hzhbjr=57574d56446e77757854476246355570513937784d413d3d&substoreid=2f4f3650385368366f31383d&transtype=6&SCENE=4d2f31696a69734649664d3d'
    browser.get(url)
    
```

待更新。。。