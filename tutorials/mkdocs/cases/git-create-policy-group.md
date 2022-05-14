# 通过 Git 仓库创建策略组

## 场景描述

在使用cloudiac时，如果想要对云模板绑定的tf文件资源或者对环境执行plan以后的资源进行合规检测，则需要为云模版或者环境开启合规检测功能，开启此功能云模板或者环境必须要绑定若干个策略组，此时就必须创建策略组

## 场景示例

使用示例仓库创建一个策略组作为示例说明：

**仓库由若干个合规策略文件和配置文件组成**

![img](../images/git-create-policy-group1.png)

有关合规策略，请参考[安全合规](/docs/mkdocs/manual/compliance.md)

### 创建策略组

进入系统页面后，选择【进入合规】

![img](../images/git-create-group1.png)

选择菜单【策略管理】下的【策略组】，点击【新建策略组】按钮

![img](../images/git-create-group2.png)

先选择【VCS】，再选择其中需要新建的【VCS】、【仓库】、【分支】、【工作目录】(可选)，点击【下一步】

![img](../images/git-create-group3.png)

可以配置策略组的【名称】，【描述】(可选)和【标签】(可选)。配置之后点击【提交】按钮。

![img](../images/git-create-group4.png)
