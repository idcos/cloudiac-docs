# 一键部署

可以依据提供的shell脚本,在docker环境或者Kubernetes环境进行一键部署cloudiac环境

## docker环境一键部署
:::note
docker环境一键部署,需要您安装了docker环境同时支持docker-compose部署
:::

```shell
## 获取仓库代码,shell目录,可执行文件iac-docker.sh
https://github.com/idcos/cloudiac.git

##执行 bash iac-docker.sh,按照提示选择对应的版本安装
bash iac-docker.sh
```

## Kubernetes环境一键部署
:::note
Kubernetes环境一键部署,需要您安装了Kubernetes环境和git环境
:::

```shell
## 获取仓库代码,shell目录,可执行文件iac-k8s.sh
https://github.com/idcos/cloudiac.git

##执行 bash iac-k8s.sh,按照提示选择对应的版本安装
bash iac-k8s.sh
```