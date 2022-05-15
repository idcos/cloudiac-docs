# 一键部署

可以依据提供的shell脚本,在docker环境或者Kubernetes环境进行一键部署cloudiac环境

## docker环境一键部署
:::note
支持操作系统:centos,Ubuntu
docker环境一键部署,需要您安装了docker环境同时支持docker-compose部署
:::

```shell
##执行 cloudiac-docker.sh,按照提示选择对应的版本安装
curl -fsSL https://raw.githubusercontent.com/idcos/cloudiac-docs/master/script/cloudiac-docker.sh | bash
```

## Kubernetes环境一键部署
:::note
支持操作系统:centos,Ubuntu
Kubernetes环境一键部署,需要您安装了Kubernetes环境和git环境
:::

```shell
##执行 cloudiac-k8s.sh,按照提示选择对应的版本安装
curl -fsSL https://raw.githubusercontent.com/idcos/cloudiac-docs/master/script/cloudiac-k8s.sh | bash
```