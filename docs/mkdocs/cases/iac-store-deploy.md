以下文档中域名 exchange.example.com 为演示域名，部署时请替换为实际的域名或 IP。

## 1. 容器化部署

该部署方案使用 docker-compose 管理所有服务，可用于快速部署环境进行体验。



#### 1. 创建部署目录

我们以部署到 /usr/yunji/cloudiac-registry/ 目录为例。

创建并进入部署目录

```bash
mkdir -p /usr/yunji/cloudiac-registry/var/{mysql,registry-storage} && cd /usr/yunji/cloudiac-registry
```

#### 2. 创建 .env 配置文件

创建 .env 文件，写入如下内容:

所有项都为必填

```bash
# iac-store 服务使用的域名或IP，示例: exchange.example.com
REGISTRY_DOMAIN=

# MySQL 连接信息
MYSQL_USER=dbuser
MYSQL_PASSWORD=dbpassword
MYSQL_DATABASE=registry

# docker 镜像
MYSQL_IMAGE="mysql:5.7"
REGISTRY_IMAGE="cloudiac/iac-registry:v0.2.0"
REGISTRY_WEB_IMAGE="cloudiac/iac-registry-web:v0.2.0"
```

- 注意配置 REGISTRY_DOMAIN，其他项可以使用默认配置。

#### 3. 创建 config-registry.yaml

创建文件: /usr/yunji/cloudiac-registry/config-registry.yaml

```bash
dsn: "mysql://dbuser:dbpassword@tcp(mysql:3306)/registry?charset=utf8mb4&parseTime=True&loc=Local"
listen: "0.0.0.0:9233"
serverId: "iac-registry-01"
storage: "var/registry-storage"

secretKey: ""

auth:
  cloudiac:
    address: "http://cloudiac.example.com"
    disabled: false
  github:
    clientId: ""
    clientSecret: ""
```

- mysql 的账号密码和 db 名称需要与 .env 中配置的相同
- secretKey 必须填写
- auth.cloudiac.address 为对接的 cloudiac 服务地址
- auth.github 配置下文会进行介绍



#### 4. 创建 Github OAuth Application

如果要接入 github 登录则需要创建 Github OAuth Application，否则可以跳过该步骤。

创建 Github OAuth Appication 的步骤请参考文档：https://docs.github.com/cn/developers/apps/building-oauth-apps/creating-an-oauth-app。

其中回调地址配置为 reigstry 服务地址，如 "https://exchange.example.com"，域名与 REGISTRY_DOMAIN 变量相同。

创建完成后将生成的 client id 和 client secret 添加到配置文件中即可开启 github 登录。

#### 5. 创建 SSL 证书

terraform 只允许通过 https 协议查询 provider，所以我们需要部署 ssl 证书。

如果己有证书可以直接使用，或者申请证书，获取证书后将证书文件(命名为 server.crt) 和私钥文件(命名为 server.key)保存到 var 目录。

如果是测试使用也可以使用自签名证书，执行以下命令中的一条生成自签名证书：

- REGISTRY_DOMAIN 使用的域名则执行以下命令：

```bash
source .env && openssl req -x509 -days 3650 -out "var/server.crt" -keyout "var/server.key" -newkey rsa:2048 -nodes -sha256 -subj "/CN=$REGISTRY_DOMAIN" -extensions EXT -config <(printf "[dn]\nCN=$REGISTRY_DOMAIN\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS.1:$REGISTRY_DOMAIN\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
```

- REGISTRY_DOMAIN 使用的是 IP 则执行以下命令：

```bash
source .env && openssl req -x509 -days 3650 -out "var/server.crt" -keyout "var/server.key" -newkey rsa:2048 -nodes -sha256 -subj "/CN=$REGISTRY_DOMAIN" -extensions EXT -config <(printf "[dn]\nCN=$REGISTRY_DOMAIN\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=IP.1:$REGISTRY_DOMAIN\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
```

如果使用了自签名证书，则需要将生成的证书导入到执行 terraform 的机器才可以正常使用 iac registry 中发布的 provider，导入方式参考：https://idcos.yuque.com/kyco54/rgsunw/lkqo4s#bVqvH

#### 6. 创建 docker-compose.yml 文件

创建 docker-compose.yml 文件，内容如下：

```yaml
version: "3.2"
services:
  iac-registry:
    image: "${REGISTRY_IMAGE}"
    command: ["serve", "-c", "config-registry.yaml"]
    volumes:
      - type: bind
        source: ./var/registry-storage
        target: /app/var/registry-storage
      - type: bind
        source: ./config-registry.yaml
        target: /app/config-registry.yaml
    environment:
      - https_proxy
    ports:
      - "9233:9233"
    depends_on:
      - mysql
    restart: always

  iac-registry-web:
    image: "${REGISTRY_WEB_IMAGE}"
    volumes:
      - type: bind
        source: ./var/server.crt
        target: /etc/nginx/conf.d/server.crt
      - type: bind
        source: ./var/server.key
        target: /etc/nginx/conf.d/server.key
    ports:
      - 80:80
      - 443:443
    restart: always

  mysql:
    image: "${MYSQL_IMAGE:-mysql:5.7}"
    command: ["--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci"]
    volumes:
      - type: bind
        source: ./var/mysql
        target: /var/lib/mysql
    environment:
      - MYSQL_RANDOM_ROOT_PASSWORD=yes
      - MYSQL_USER
      - MYSQL_PASSWORD
      - MYSQL_DATABASE
    restart: always
```

#### 7. 启动服务

```bash
docker-compose up -d
```

docker-compose 的安装请参考官方文档: https://docs.docker.com/compose/install/


**至此部署完成。**