## Stack 使用方法
以下步骤关于Stack如何通过CloudIac实现快速部署  (以VMWare虚拟机安装Redis服务为例)。

#### 在『Stack』页面点击『从Exchange导入』
![picture 39](../images/importStack.png){.img-fluid}

#### 选择您所需的『Stack』
![picture 40](../images/selectStack.png){.img-fluid}

#### 点击要使用的『Stack』 可查看详情，选择要使用的『Stack』版本然后点击『创建 Stack』
![picture 41](../images/createStack.png){.img-fluid}

#### 在新建Stack界面『导入Terraform变量』，并赋予变量值
![picture 42](../images/importVariables.png){.img-fluid}
![picture 43](../images/assignVariables.png){.img-fluid}

#### 关联您基础设施认证信息的『资源账号』
![picture 44](../images/ReferenceAccount.png){.img-fluid}

#### 选择您『ansible playbook』文件以及『ssh密钥』（『小提示：』不一定每个Stack部署都需要）。此处因以VMWare虚拟机安装Redis服务为例，以便于在虚拟机上部署Redis服务
![picture 45](../images/selectFile.png){.img-fluid}

#### 填写 Stack 在 CloudIaC 平台的『显示名称』和『描述』，以及『Terraform版本』
![picture 46](../images/fullInfo.png){.img-fluid}

#### 最后『关联项目』，即可在项目部署该环境
![picture 47](../images/releatProject.png){.img-fluid}

