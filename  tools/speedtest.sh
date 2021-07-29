精选文章 Linux下如何测网速
Linux下如何测网速
作者：aAnthony 时间: 2021-02-05 08:56:16
标签：linuxserver测网速
【摘要】Linux下测网速可以使用speedtest的命令，它是由Python语言编写，适用于Python2.4-Python3.4等版本。具体操作如下： 1.下载这个文件wget https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py（注：以前的是speedtest-cil,本文以centos7为例） 2....
  Linux下测网速可以使用speedtest的命令，它是由Python语言编写，适用于Python2.4-Python3.4等版本。具体操作如下：

 1.下载这个文件

wget https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
（注：以前的是speedtest-cil,本文以centos7为例）

 2.修改文件名，增加执行权限，移动到默认路径 

mv speedtest.py speedtest
chmod a+x speedtest
mv speedtest /usr/local/bin/
 3.测试（直接执行即可）

结果如下

[root@www ~]# speedtest 

Retrieving speedtest.net configuration...

Testing from 263 (211.157.166.229)...

Retrieving speedtest.net server list...

Selecting best server based on ping...

Hosted by China Mobile Group Beijing Co.Ltd (Beijing) [1.69 km]: 106.603 ms

Testing download speed................................................................................

Download: 2.50 Mbit/s

Testing upload speed................................................................................................

Upload: 3.11 Mbit/s

我们可以看出下载速度为2.5MB/s,上传3.11MB/s.