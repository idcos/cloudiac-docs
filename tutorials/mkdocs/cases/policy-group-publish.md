# 策略组发布

## 准备策略组

### 策略组规范

- 请确保策略组必须是您VCS仓库中的公共仓库
- 请确保仓库中含有.rego格式结尾的文件

以 opa-policy-example 为例：[https://github.com/cong2960/opa-policy-example](https://github.com/cong2960/opa-policy-example)

## 发布策略组

### 集成vcs

参考[vcs集成](../cases/create-vcs.md)

**注意：集成vcs时请使用您自己的vcs仓库**

### 策略组发布

**必填参数：vcs，代码仓库，策略组名称，输入完毕后，点击提交**

![img](../images/registry-policy-group-publish1.png)

![img](../images/registry-policy-group-publish2.png)

发布后的策略组可在regisrty查看