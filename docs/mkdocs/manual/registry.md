# CloudIaC Registry

## Registry 简介
CloudIaC Registry（以下简称 Registry）是 CloudIaC 提供的内容管理仓库， 在 Registry 中提供了大量 Providers、Modules、Polices，用户可以直接浏览并下载使用。

Registry 实现了 Terraform 的 provider registry 协议以及 network mirror 协议，用户可以直接配置 network mirror 以代理的方式实现 Provider 的缓存和下载，也可以提前在CloudIaC Registry网站上选择要使用的provider进行预下载，从而解决国内 Terraform 用户因为网络原因导致的使用困难问题。

除了缓存 Providers 之外，我们在为客户提供服务的过程中也开发了许多 Providers，同时也沉淀了许多 Modules 和合规策略的最佳实践，这些内容都会一起在 Registry 中进行提供，用户可以根据需要进行下载使用。

有关github的介绍，请访问[github介绍](https://github.com/about)

要想使用registry，则必须拥有cloudiac账号或者github账号

cloudiac账号的获取请联系管理员

github账号请访问github官网注册


## 产品功能
### vcs管理
#### 什么是vcs

VCS是版本控制系统的简称（Version Control System）

registry中模块发布以及合格策略组的发布都通过VCS（版本控制系统）进行管理

registry通过添加VCS的方式来集成版本控制系统，从而获取代码仓库中的配置文件

#### vcs的类型

registry目前支持以下四种VCS集成：

- GitHub
- GitLab
- Gitee
- Gitea

### 签名密钥管理
#### GPG签名密钥在registry中的作用

为了保证 Provider 的完整性和可靠性，Provider 在发布前都需要使用 GPG 密钥进行签名。在 Provider 发布时，registry 平台会对其签名做验证，因些您必须将 Provider 签名时使用的 GPG 密钥对的公钥添加到命名空间。 同时在执行 terraform init 时也会使用公钥对 provider 签名做验证

### provider管理
#### 什么是provider
Terraform是由hashipcorp开源的基础设施即代码(IAC)管理工具，通过 Terraform 可以将基础设置配置代码在云环境应用实现云资源的供给和维护。

Terraform 目前己支持所有主流云商，目前官方以验证的云服务有200+，更多云服务也在持续接入。

为了对接各云商 Terraform 提供一套插件框架，云服务只需要接入这套插件框架，即可在 terraform 中使用，实现云资源的 CRUD 操作。

这些云服务的插件在 Terraform 中称为 Provider。
#### provider发布

请参考[provider发布流程](/tutorials/mkdocs/cases/provider-publish.md/)

### module管理
### 什么是module

registry module基于terrafrom module开发，简单来讲module就是包含一组Terraform代码的文件夹，由此可以达到代码
复用的效果，更多关于module的介绍，请参考[terraform module](https://www.terraform.io/language/modules)

#### module发布

请参考[modle发布流程](/tutorials/mkdocs/cases/module-publish.md/)

### 策略组管理
#### 什么是策略组

策略组是cloudiac定义的包含一组合规策略的一个集合，在registry中发布的策略组可以在cloudiac中直接使用

#### 策略组发布

请参考[策略组发布流程](/tutorials/mkdocs/cases/policy-group-publish.md/)