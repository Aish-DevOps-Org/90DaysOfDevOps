Deploy Nginx server



1. Install nginx
```
sudo apt install nginx
```
2. Check Nginx service status
```
systemctl status nginx -> Active 
```
3. access Nginx webpage on - https://VMpublicIP:80 
4. Not able to access NGINX webpage
5. Check /var/log/nginx/access.log -> empty
6. Enable port 80 on VM inbound rule
7. Able to access Nginx server
```
Welcome to nginx page
```
8. Check /var/log/nginx/access.log ->

```

aishuser@aish-ubuntu-tws:/var/log/nginx$ cat access.log

49.***.***.192 - - \[26/Mar/2026:12:23:58 +0000] "GET / HTTP/1.1" 200 409 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36"

49.***.***.192 - - \[26/Mar/2026:12:23:58 +0000] "GET /favicon.ico HTTP/1.1" 404 196 "http://20.38.37.11/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36"

```



9\. Successfully downloaded the access.log from Vm to local machine

```

aishuser@aish-ubuntu-tws:/var/log/nginx$ cp access.log /home/aishuser/nginx.logs.txt



C:\\Users\\aish>scp aishuser@20.38.37.11:\~/nginx.logs.txt .

Enter passphrase for key 'C:\\Users\\aish/.ssh/id\_ed25519':

nginx.logs.txt                                     100% 2667     5.7KB/s   00:00



