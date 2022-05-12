# module发布

## 准备module

### module规范

- 请确保Module必须是您VCS仓库中的公共仓库
- Module仓库必须以terraform--三段式命名为该Module主要使用的Provider，为该Module主要管理的资源类型
- 仓库结构请参考：[Terraform官方模块结构说明](https://www.terraform.io/registry/modules/publish)
- 仓库描述：Module的一句话描述
- x.y.z 标签：Registry使用标签来标识Module版本，标签名必须使用语义版本，如：v1.0.1或1.0.1 看起来不像版本的标签将被忽略

以 terraform-alicloud-vpc 为例：[https://github.com/terraform-alicloud-modules/terraform-alicloud-vpc](https://github.com/terraform-alicloud-modules/terraform-alicloud-vpc)

## 发布module

### 集成vcs

参考[vcs集成](../cases/create-vcs.md)

**注意：vcs集成时请使用您自己的vcs平台**

### 发布module

**必填参数：vcs，代码仓库，输入完毕后，点击发布**

![img](../images/registry-module-publish1.png)

发布后的module可在registry查看