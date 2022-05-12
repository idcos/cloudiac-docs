# vcs集成
## 添加vcs
**登录registry以后，选择vcs集成**

![img](../images/registry-vcs1.png){.img-fluid}

如果是首次登录，则要求输入命名空间。

tips：命名空间相当于用户的存储空间，使用registry发布的provider,module，策略组将会存放在命名空间中，

如果要使用发布provider功能，则必须额外提供GPG签名密钥，有关GPG签名密钥的获取，请参考[GPG签名密钥的获取](#gpg)

![img](../images/registry-vcs2.png){.img-fluid}

**选择对应的vcs，输入vcs名称，vcs地址，Token，点击添加集成，添加后可在vcs集成列表中查看已添加的vcs**

![img](../images/registry-vcs3.png){.img-fluid}
tips：如果选择GitHub或者gitee，则地址为默认地址即可，不需要变更，

如果选择GitLab或者gitea，因为是内网系统，则需要输入对应的内网网址

Token为对应vcs平台的私人令牌，各平台Token的获取请参考[token获取](../quick-start/token.md)