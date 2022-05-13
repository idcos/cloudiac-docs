# CloudIaC Registry

## Registry 简介
CloudIaC Registry（以下简称 Registry）是 CloudIaC 提供的内容管理仓库， 在 Registry 中提供了大量 Providers、Modules、Polices，用户可以直接浏览并下载使用。

Registry 实现了 Terraform 的 provider registry 协议以及 network mirror 协议，用户可以直接配置 network mirror 以代理的方式实现 Provider 的缓存和下载，也可以提前在CloudIaC Registry网站上选择要使用的provider进行预下载，从而解决国内 Terraform 用户因为网络原因导致的使用困难问题。

除了缓存 Providers 之外，我们在为客户提供服务的过程中也开发了许多 Providers，同时也沉淀了许多 Modules 和合规策略的最佳实践，这些内容都会一起在 Registry 中进行提供，用户可以根据需要进行下载使用。

