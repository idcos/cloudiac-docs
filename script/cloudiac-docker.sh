#!/bin/bash
echo -e "This script will install the cloudiac environment for you"
echo
echo "+++++++++++++++++++++++CloudIac++++++++++++++++++++++++++"

# 第一步创建环境目录
echo "Start creating the project directory ##################################"
mkdir -p /usr/yunji/cloudiac/var/{consul,mysql} && cd /usr/yunji/cloudiac/

# 第二步生成docker-compose.yml文件
echo
echo "Generate docker-compose.yml file #########################"
read  -p "Please enter the version to be installed---default [v0.11.0]：" version </dev/tty
if [ -z "${version}" ];then
  version=v0.11.0
fi

cat > /usr/yunji/cloudiac/docker-compose.yml << EOF
# auto-replace-from: docker/docker-compose.yml
version: "3.2"
services:
  iac-portal:
    container_name: iac-portal
    image: "${DOCKER_REGISTRY}cloudiac/iac-portal:$version"
    volumes:
      - type: bind
        source: /usr/yunji/cloudiac/var
        target: /usr/yunji/cloudiac/var
      - type: bind
        source: /usr/yunji/cloudiac/.env
        target: /usr/yunji/cloudiac/.env
    ports:
      - "9030:9030"
    depends_on:
      - mysql
      - consul
    restart: always

  ct-runner:
    container_name: ct-runner
    image: "${DOCKER_REGISTRY}cloudiac/ct-runner:$version"
    volumes:
      - type: bind
        source: /usr/yunji/cloudiac/var
        target: /usr/yunji/cloudiac/var
      - type: bind
        source: /usr/yunji/cloudiac/.env
        target: /usr/yunji/cloudiac/.env
      - type: bind
        source: /var/run/docker.sock
        target: /var/run/docker.sock
    ports:
      - "19030:19030"
    depends_on:
      - consul
    restart: always

  iac-web:
    container_name: iac-web
    image: "${DOCKER_REGISTRY}cloudiac/iac-web:$version"
    ports:
      - 80:80
    restart: always
    depends_on:
      - iac-portal

  mysql:
    container_name: mysql
    image: "mysql:8.0"
    command: [
        "--character-set-server=utf8mb4",
        "--collation-server=utf8mb4_unicode_ci",
        "--sql_mode=STRICT_TRANS_TABLES,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
    ]
    volumes:
      - type: bind
        source: /usr/yunji/cloudiac/var/mysql
        target: /var/lib/mysql
    environment:
      - MYSQL_RANDOM_ROOT_PASSWORD=yes
      - MYSQL_USER
      - MYSQL_PASSWORD
      - MYSQL_DATABASE
    restart: always

  consul:
    container_name: consul
    image: "consul:latest"
    volumes:
      - type: bind
        source: /usr/yunji/cloudiac/var/consul
        target: /consul/data
    ports:
      - "8500:8500"
    command: >
      consul agent -server -bootstrap-expect=1 -ui -bind=0.0.0.0
      -client=0.0.0.0 -enable-script-checks=true -data-dir=/consul/data
    restart: always
EOF

echo
echo "Generate .evn configuration file #########################"
echo
read  -p "Please enter a system administrator account name, the default is [admin@example.com]:" admin </dev/tty
if [ -z "${admin}" ];then
  admin=admin@example.com
fi
echo
read  -p "Please enter the platform administrator password, the default is [admin123]:" password </dev/tty

if [ -z "${password}" ];then
  password=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 6)
fi

echo
read  -p "Encryption key configuration, the default is [admin]:" secret_key </dev/tty

if [ -z "${secret_key}" ];then
  secret_key=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)
fi

echo
read  -p "Please enter the database password, the default is [password]:" mysql_psword </dev/tty

if [ -z "${mysql_psword}" ];then
  mysql_psword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 6)
fi


echo
read -p "Add mirror address, the default is [docker hub]:  " registry_address </dev/tty

if [ -z "${registry_address}" ];then
  registry_address=""
fi



cat > /usr/yunji/cloudiac/.env << EOF
# 平台管理员账号，只在初始化启动时进行读取
IAC_ADMIN_EMAIL="$admin"

## 平台管理员密码(必填)，要求长度大于 8 且包含字母、数字、特殊字符
IAC_ADMIN_PASSWORD="$password"

# cloudiac registry 服务地址(选填)，示例：http://registry.cloudiac.org/
REGISTRY_ADDRESS="$registry_address"

# 加密密钥配置(必填)
SECRET_KEY="$secret_key"

# mysql 配置(必填)
MYSQL_HOST=mysql
MYSQL_PORT=3306
MYSQL_DATABASE=cloudiac
MYSQL_USER=cloudiac
MYSQL_PASSWORD="$mysql_psword"

# portal 服务注册信息配置
SERVICE_IP=iac-portal
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
RUNNER_SERVICE_IP=ct-runner
RUNNER_SERVICE_ID=ct-runner-01
RUNNER_SERVICE_TAGS="ct-runner;runner-01"
EOF

#echo CONSUL_ADDRESS='"'$(/sbin/ifconfig eth0|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"):8500'"' >> /usr/yunji/cloudiac/.env
echo CONSUL_ADDRESS='"'$(ip -4 route get 8.8.8.8 | awk '/src/ { print $7 }'):8500'"' >> /usr/yunji/cloudiac/.env
echo PORTAL_ADDRESS='"'$(curl ip.sb)'"' >> /usr/yunji/cloudiac/.env

# 第四步 启动环境
echo "create iac environment #########################"
docker-compose up -d
echo "Environment created successfully #########################"


public_ip=$(curl ip.sb)

echo ""
echo ""
echo -e "current version: \033[33m $version \033[0m "
echo -e "manager username:\033[33m $admin \033[0m "
echo -e "password:\033[33m $password \033[0m "
echo -e "visit address: \033[32m[$public_ip]\033[0m "
echo -e "project address: \033[32m https://github.com/idcos/cloudiac\033[0m "
echo -e "documents: \033[32m https://docs.cloudiac.org \033[0m "



