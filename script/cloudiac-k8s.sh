#!/bin/bash

# step1 创建工作目录
echo "Start creating the project directory ##################################"
mkdir -p /usr/yunji/cloudiac/var/{consul,mysql} && cd /usr/yunji/cloudiac/

echo
read  -p "Please enter the version to be installed---default [v0.9.4]：" version
if [ -z "${version}" ];then
  version=v0.9.4
fi

all_variables="version=$version"

#生成portal.yaml
protal_templ=`cat ./k8s-iac-standard/portal.template.yaml`
printf "$all_variables\ncat << EOF\n$protal_templ\nEOF" | bash > ./portal.yaml

web_variables="web_version=$version"
#生成web.yaml
web_templ=`cat ./k8s-iac-standard/web.template.yaml`

printf "$web_variables\ncat << EOF\n$web_templ\nEOF" | bash > ./web.yaml


# step2 clone样板间代码
if [ ! -d "$/"cloudiac-k8s-template/"" ]; then

  git clone https://github.com/xiaodaiit/cloudiac-k8s-template.git

fi

## 下载镜像
docker mysql:mysql:8.0
docker pull consul:latest
docker pull cloudiac/iac-portal:$version
docker pull cloudiac/iac-web:$version
docker pull cloudiac/ct-runner:$version



# step3 创建consul
kubectl apply -f ./k8s-iac-standard/consul.yaml

# step4 创建mysql
kubectl apply -f ./k8s-iac-standard/mysql.yaml

# step3 创建portal组件
## 创建portal的config-portal和.env文件
kubectl create cm config-portal --from-file=./k8s-iac-standard/config-portal.yml


echo
echo "Generate .evn configuration file #########################"
echo
read  -p "Please enter a system administrator account name, the default is [admin@example.com]:" admin
if [ -z "${admin}" ];then
  admin=admin@example.com
fi
echo
read  -p "Please enter the platform administrator password, the default is [admin123]:" password

if [ -z "${password}" ];then
  password=admin123
fi

echo
read  -p "Encryption key configuration, the default is [admin]:" secret_key

if [ -z "${secret_key}" ];then
  secret_key=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 6)
fi

echo
read  -p "Please enter the database password, the default is [password]:" mysql_psword

if [ -z "${mysql_psword}" ];then
  mysql_psword=password
fi

echo
read -p "Add mirror address, the default is [docker hub]:  " registry_address

if [ -z "${registry_address}" ];then
  registry_address=""
fi

public_ip="$(ip -4 route get 8.8.8.8 | awk '/src/ { print $7 }')"


cat > /usr/yunji/cloudiac/.env << EOF
# 平台管理员账号，只在初始化启动时进行读取
IAC_ADMIN_EMAIL="$admin"

## 平台管理员密码(必填)，要求长度大于 8 且包含字母、数字、特殊字符
IAC_ADMIN_PASSWORD="$password"

# cloudiac registry 服务地址(选填)，示例：http://registry.cloudiac.org/
REGISTRY_ADDRESS="$registry_address"

# 加密密钥配置(必填)
SECRET_KEY="$secret_key"

JWT_SECRET_KEY ="q"
# mysql 配置(必填)
MYSQL_HOST=$public_ip
MYSQL_PORT=30078
MYSQL_DATABASE=cloudiac
MYSQL_USER=cloudiac
MYSQL_PASSWORD=cloudiac

# portal 服务注册信息配置
SERVICE_IP=$public_ip
SERVICE_ID=iac-portal-01
SERVICE_TAGS="iac-portal;portal-01"

## logger 配置
LOG_DEVEL="debug"

# SMTP 配置(该配置只影响邮件通知的发送，不配置也能启动)
SMTP_ADDRESS=smtp.example.com:25
SMTP_USERNAME=user@example.com
SMTP_PASSWORD=""
SMTP_FROM_NAME=IaC
SMTP_FROM=support@example.com

######### 以下为 runner 配置 #############
# runner 服务注册配置
RUNNER_SERVICE_IP=$public_ip
RUNNER_SERVICE_ID=ct-runner-01
RUNNER_SERVICE_TAGS="ct-runner;runner-01"
EOF

#echo CONSUL_ADDRESS='"'$(/sbin/ifconfig eth0|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"):8500'"' >> /usr/yunji/cloudiac/.env
echo CONSUL_ADDRESS='"'$(ip -4 route get 8.8.8.8 | awk '/src/ { print $7 }'):30099'"' >> /usr/yunji/cloudiac/.env
echo PORTAL_ADDRESS='"'$(ip -4 route get 8.8.8.8 | awk '/src/ { print $7 }')'"' >> /usr/yunji/cloudiac/.env
#echo PORTAL_ADDRESS='"'$(curl ip.3322.net)'"' >> /usr/yunji/cloudiac/.env


## 生成portal.yaml

## 创建.env的configmap
kubectl create cm env --from-file=.env

## 创建portal组件
kubectl apply -f ./k8s-iac-standard/portal.yaml




cat > /usr/yunji/cloudiac/iac.conf << EOF
server {
  listen 80;
  server_name _ default;

  gzip  on;
  gzip_min_length  1k;
  gzip_buffers 4 16k;
  gzip_http_version 1.1;
  gzip_comp_level 9;
  gzip_types text/plain application/x-javascript text/css application/xml text/javascript \
    application/x-httpd-php application/javascript application/json;
  gzip_disable "MSIE [1-6]\.";
  gzip_vary on;

  location / {
    try_files $uri $uri/ /index.html /index.htm =404;
    root /usr/nginx/cloudiac-web;
    index  index.html index.htm;
  }

  location = /login {
    rewrite ^/login /login.html last;
  }

  location /api/v1/ {
    proxy_buffering off;
    proxy_cache off;

    proxy_read_timeout 1800;
    proxy_pass http://$public_ip:32100;
  }

  location /iac/api/v1/ {
    rewrite /iac/api/v1/(.*) /api/v1/$1 last;
  }

  location /repos/ {
    proxy_pass http://$public_ip:32100;
  }
}

EOF



# step4 创建web组件
## 创建web的configmap
kubectl create cm iac-web --from-file=iac.conf

## 创建web组件pod
kubectl apply  -f ./k8s-iac-standard/web.yaml



## 启动runner
docker run -p 19030:19030 --restart=always --name=runner-01 -v /usr/yunji/cloudiac/var:/usr/yunji/cloudiac/var -v /var/run/docker.sock:/var/run/docker.sock -v /usr/yunji/cloudiac/.env:/usr/yunji/cloudiac/.env -d registry.idcos.com/cloudiac/ct-runner:$version

echo ""
echo "The access address is your ip port: [$public_ip:32102]"
echo ""

echo "Your initial installation version is: $version, your system account initialization password is: $admin, your system account initialization password is: $password,
Your encryption key is: $secret_key, your database initial password is: $mysql_psword"

echo "For more details, please check the official documentation: [https://idcos.github.io/cloudiac/]"