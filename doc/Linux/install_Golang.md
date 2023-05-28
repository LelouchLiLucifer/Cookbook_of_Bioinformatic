**Debian系系统安装最新版Golang**<br>
使用apt install也能装golang，但大多数源都是旧版本，会出现很多问题，所以建议从官方下载<br>
最新版可以从官网获取到https://golang.google.cn/dl/<br>
从Featured downloads中挑一下操作系统对应的即可,不要去下载Source，那是源码<br>
```
wget https://golang.google.cn/dl/go1.19.1.linux-amd64.tar.gz
tar -xvf go1.19.1.linux-amd64.tar.gz
mv go /usr/local/
```
修改配置文件<br>
```
vi ~/.bashrc
```
在~/.bashrc末尾添加以下内容并保存<br>
```
export GO_HOME=/usr/local/go/
export GO_PATH=$HOME/go 
export PATH=${GO_HOME}/bin:$GO_PATH/bin:$PATH
```
继续运行命令<br>
```
#生效.bashrc
source ~/.bashrc
```
运行go进行测试<br>
```
go version
```

[参考文章](https://www.jianshu.com/p/084a5db93599)
