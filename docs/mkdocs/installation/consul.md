# consul开启acl和tls

:::tip
该文档用于部署的环境中开启consul的acl验证和tls访问。

    以下操作均在 cloudiac 部署目录 `/usr/yunji/cloudiac/var/consulconfig` 下执行。
:::

##  consul 开启acl

### 1. 创建acl和tls配置目录
```bash
mkdir -p /usr/yunji/cloudiac/var/consulconfig
```


### 2. 准备 acl.hcl 配置文件

文件内容如下:

```yaml
cat >> /usr/yunji/cloudiac/var/consulconfig/acl.hcl <<EOF
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
}
EOF
```

### 3. 配置consul的acl
####  容器部署配置acl
::: important

    `如果开启了tls,保证设置了如下环境变量,然后执行生成token`

    - CONSUL_HTTP_SSL_VERIFY=false: 私有化部署SSL证书不验证
    - CONSUL_HTTP_SSL=true: 启动https URI方案和http api的SSl连接
:::

```bash
# 进入容器
docker exec -it consul sh

# 生成token,保存好生成的SecretID
consul acl bootstrap

#退出容器

# 加入SecretID作为token加入acl.hcl配置
cat > /usr/yunji/cloudiac/var/consulconfig/acl.hcl <<EOF
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
  tokens {
    master = "a0419d88-cd14-f96f-e144-a02a0f03f683" 
  }
}
EOF

```
:::tip
    consul acl bootstrap执行结果如下,SecretID为所需要的token
```bash
# consul acl bootstrap
AccessorID:       af48d2cf-690d-eafe-5e5a-40e3239efa9e
SecretID:         a0419d88-cd14-f96f-e144-a02a0f03f683
Description:      Bootstrap Token (Global Management)
Local:            false
Create Time:      2022-04-14 09:00:05.914372 +0000 UTC
Policies:
00000000-0000-0000-0000-000000000001 - global-management
```
:::

##### 修改.env配置
在文件末尾添加开启tls和acl开启信息

```yaml
# consul 配置
## 是否开启consul acl认证
CONSUL_ACL=true
## consul token信息(开启acl认证必填)
CONSUL_ACL_TOKEN=""
```

##### 重启容器
```yaml
# 重启 iac-portal
docker-compose restart iac-portal 

# 重启 ct-runner
docker-compose restart ct-runner
```

---

#### 二进制部署配置acl

::: important

    `如果开启了tls,保证设置了如下环境变量,然后执行生成token`

    - CONSUL_HTTP_SSL_VERIFY=false: 私有化部署SSL证书不验证
    - CONSUL_HTTP_SSL=true: 启动https URI方案和http api的SSl连接
:::

```bash
#创建软连,把acl配置加入consul配置中
ln -s /usr/yunji/cloudiac/var/consulconfig/acl.hcl /etc/consul.d

# 重启consul
systemctl restart consul

# 生成token
consul acl bootstrap

# 加入SecretID作为token加入acl.hcl配置
cat > /usr/yunji/cloudiac/var/consulconfig/acl.hcl <<EOF
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
  tokens {
    master = "a0419d88-cd14-f96f-e144-a02a0f03f683" 
  }
}
EOF
```
::: tip
    consul acl bootstrap执行结果如下,SecretID为所需要的token
```bash
# consul acl bootstrap
AccessorID:       af48d2cf-690d-eafe-5e5a-40e3239efa9e
SecretID:         a0419d88-cd14-f96f-e144-a02a0f03f683
Description:      Bootstrap Token (Global Management)
Local:            false
Create Time:      2022-04-14 09:00:05.914372 +0000 UTC
Policies:
00000000-0000-0000-0000-000000000001 - global-management
```
:::

---

## consul 开启tls认证

### 1. 准备tls证书

:::tip
此处采用openssl生成私有化证书,也可以自己向机构申请证书

    证书名称为 ca.pem,client.key,client.pem,也可以修改自己对应的名称
:::

```bash

cd /usr/yunji/cloudiac/var/consulconfig && openssl genrsa -out ca.key 2048 && openssl req -new -x509 -days 7200 -key ca.key   -out ca.pem -subj "/C=CN/ST=GD/L=SZ/O=iac/OU=dev/CN=iac.com/emailAddress=yy@vivo.com" && openssl genrsa -out client.key 2048 && openssl req -new -key client.key  -out client.csr -subj "/C=CN/ST=GD/L=SZ/O=iac/OU=dev/CN=iac.com/emailAddress=cloud@iac.com" && echo subjectAltName = IP:$IAC_DOMAIN_IP > extfile.cnf && openssl x509 -req -days 365 -in client.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out client.pem -extfile extfile.cnf

```

### 2. 准备tls配置文件 tls.json

```bash
cat >> /usr/yunji/cloudiac/var/consulconfig/tls.json <<EOF
{
  "verify_incoming": false,
  "verify_incoming_rpc": true,
  "ports": {
    "http": -1,
    "https": 8500
  },
  "ca_file": "/consul/config/ca.pem",
  "cert_file": "/consul/config/client.pem",
  "key_file": "/consul/config/client.key"
}
EOF
```


### 3. 配置consul的tls
#### 容器部署配置tls

修改 docker-compose.yml 文件

文件路径 /usr/yunji/cloudiac/docker-compose.yml，内容如下:

```yaml
#version: "3.2"
#services:
#  consul:
#    container_name: consul
#    image: "consul:latest"
    environment:
      - CONSUL_HTTP_SSL_VERIFY=false
      - CONSUL_HTTP_SSL=true
    volumes:
      - type: bind
        source: /usr/yunji/cloudiac/var/consul
        target: /consul/data
      - type: bind
        source: /usr/yunji/cloudiac/var/consulconfig
        target: /consul/config
    ports:
      - "8500:8500"
    command: >
      consul agent -server -bootstrap-expect=1 -ui -bind=0.0.0.0
      -client=0.0.0.0 -enable-script-checks=true -data-dir=/consul/data -config-dir=/consul/config
    restart: always

```

> 配置说明

::: important
`docker-compose.yaml` 中 **consul** 新增以下配置，其他配置可根据需要修改

    - CONSUL_HTTP_SSL_VERIFY=false: 私有化部署SSL证书不验证
    - CONSUL_HTTP_SSL=true: 启动https URI方案和http api的SSl连接
    - -config-dir=/consul/config: 容器启动Command新增挂载指定配置目录
    - /usr/yunji/cloudiac/var/consulconfig:/consul/config:新增挂载目录 
:::

修改完成后执行以下命令，重启 consul 使配置生效:

```bash
docker-compose up -d consul --force-recreate
```

##### 修改.env配置
在文件末尾添加开启tls和acl开启信息

```yaml
# consul 配置
## 是否开启consul tls认证
CONSUL_TLS=true
### tls证书地址(开始tls认证必填)
CONSUL_CERT_PATH=""
```

##### 重启容器
```yaml
# 重启 iac-portal
docker-compose restart iac-portal 

# 重启 ct-runner
docker-compose restart ct-runner
```

---

#### 二进制部署配置tls

```bash
#创建软连,把tls配置加入consul配置中
ln -s /usr/yunji/cloudiac/var/consulconfig/tls.json /etc/consul.d

# 新增环境变量
cat >> /etc/profile <<EOF
export CONSUL_HTTP_SSL=true
export CONSUL_HTTP_SSL_VERIFY=false
EOF

#环境变量生效
source /etc/profile

# 重启consul
systemctl restart consul
```

::: tip
    环境变量说明

    - CONSUL_HTTP_SSL_VERIFY=false: 私有化部署SSL证书不验证
    - CONSUL_HTTP_SSL=true: 启动https URI方案和http api的SSl连接
:::

#####  修改.env配置
在文件末尾添加开启tls和acl开启信息

```yaml
# consul 配置
## 是否开启consul tls认证
CONSUL_TLS=true
### tls证书地址(开始tls认证必填)
CONSUL_CERT_PATH=""
```


##### 重启consul服务
```yaml
# 重启服务
systemctl restart iac-portal ct-runner

# 确定服务状态
systemctl status -l iac-portal ct-runner

```