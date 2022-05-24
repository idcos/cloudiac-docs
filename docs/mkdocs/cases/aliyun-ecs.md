## 使用云模板创建 aliyun ecs

一般来说, 如果我们想要在云平台上创建一台 vps 实例, 通常会有以下几种方案  

1. 直接登陆阿里云门户操作创建;
2. 编写程序, 调用阿里云 api 创建;
3. 使用 Terraform;

CloudIaC 基于 terraform 提供了一个交互更加友好的方案: 通过从 vcs 仓库导入 terraform 代码生成云模板, 再使用这套云模板去创建资源环境, 用户仅需在 CloudIaC 的图形界面上操作就能管理这套环境; 
这样的好处在于 CloudIaC 为不同的项目团队在 devops 过程中不同职责的成员提供统一的集中式的管理;  
每一个项目团队都能在 CloudIaC 上建立属于自己的项目, 降低了团队成员在 devops 流程中的协作成本, 如: vcs 仓库的维护者和环境的创建者可以不是一个人, 编写 terraform 可以是熟悉云原生的运维工程师, 而创建环境的是可以是从不关心 terraform 的测试人员(他们甚至不需要学习 terraform)、而创建出的资源环境也能根据需要销毁到再创建, 数十乃至上百个环境都能被高效的管理起来; 

接下来, 我们将使用 CloudIaC 演示从创建阿里云 ecs 到销毁环境的全过程;

### 准备工作

为了能够创建一个阿里云的 ecs 示例, 我们至少需要以下内容:

- 一个阿里云的资源账号和用于授权的 acesss_key、secret_key;
- 一对 ssh 密钥, 我们将会使用它通过登录创建出的 ecs 实例;
- 一个事先准备好 terraform 的 vcs 仓库和用于 CloudIaC 导入使用的访问令牌(access_token);
  
::: note
这个 vcs 仓库, 读者如果熟悉 terraform 的话可以自己编写, 只要支持创建阿里云 ecs 即可, 如果读者不熟悉 terraform, 可以使用 CloudIaC 的内置 vcs 仓库(详情后面会提及), 在仓库下有针对场景业务场景提供的样例仓库;
:::

### 实战

#### 创建一个项目

> 如果你已经拥有了一个自己的项目, 可以跳过这一步;

在「组织视图」界面, 选择「项目」选项卡, 点击红框中的「创建项目」来新建项目, 这里我们使用一个提前准备好的「演示项目」;

![CloudIaC 创建项目](../images/aliyun-ecs-add-project.jpg)

#### 设置阿里云资源账号

CloudIaC 需要用户提供一个阿里云账号的 access_key 与 secret_key;

在「设置」-「资源账号」点击「添加资源账号」按钮添加阿里云资源账号;

![CloudIaC 资源账号](../images/aliyun-ecs-add-resourc-account.jpg)

点击「添加资源账号」后, 你要输入对应的里云账号信息, 这里主要是 access_key 与 secrete_key, ***注意输入 ak/sk 变量后需要勾选敏感使其值隐藏***;

这里展示一下图中已经添加好的资源账号详情

![CloudIac 添加资源账号](../images/aliyun-ecs-add-resource-account-details.jpg)

资源账号需要填写的字段值如下

```bash
# 不要忘记勾选“敏感”以隐藏变量值
ALICLOUD_ACCESS_KEY="你的 access_key"
ALICLOUD_SECRET_KEY="你的 secret_key"
```
绑定项目那一栏选择与前文中创建的「演示项目」进行关联绑定;
provider 选择的是 alicloud;
我们这里是演示项目就不勾选费用预估与统计了, 点击「确定」选项保存;

#### 生成 ssh 密钥

如果你的操作系统是 MacOS 或者任意常见的 Linux 发行版, 可以直接在终端下执行以下命令生成 ssh 所需的密钥;  
如果你的操作系统是 windows, 可以使用 GitBash 执行此命令(这需要用户安装 git);  

```bash
# 如果你已经有了 ssh 密钥, 可以跳过此命令;
# vm_rsa 可以使用任意你想使用的名字替代, 这里仅仅是随机使用了这个名字;
ssh-keygen -t rsa -b 4096 -f ~/.ssh/vm_rsa -N ""

# 执行完成后, 你会在 ~/.ssh/ 目录下看到 vm_rsa 与 vm_ras.pub 两个文件
ls ~/.ssh/
vm_rsa vm_rsa.pub
```
:::caution 安全提示
请妥善保管你的密钥, 不要轻易泄漏给任何人;
:::

在「设置」-「ssh密钥」界面点击「添加密钥」按钮;

![CloudIaC add-ssh-key](../images/aliyun-ecs-add-ssh-key.jpg)

这里展示一下我们已经准备好的密钥 vm_rsa, 用户需要将刚才创建好的**私钥**内容粘贴到「私钥」文本框中, 点击「确定」按钮保存;

![CloudIac add-ssh-key-details](../images/aliyun-ecs-add-ssh-key-details.jpg)

:::note 密钥说明
在 CloudIaC 中, ssh 密钥添加后就无法再修改了, 如果你有修改错误的密钥的需求, 可以通过删除并重新添加的方式实现;
:::

#### 导入 VCS acess_token
:::tip 没有可以使用 vcs?
您可以跳过导入 vcs access_token 的步骤, 直接进入「新建云模板」的环节(详情参考后文)
:::

CloudIac 支持主流的 vcs 仓库, 为了能让 iac 访问你仓库, 需要先获取对应 vcs 平台上获取安全访问令牌, 然后添加到 CloudIaC 中;

在「设置」-「VCS」界面中, 点击「添加VCS」按钮;

![CloudIaC add-ssh-key](../images/aliyun-ecs-add-vcs.jpg)

在「添加VCS」界面中, 输入你 VCS 信息与 access token;

![CloudIaC add-ssh-key-details](../images/aliyun-ecs-add-vcs-details.jpg)

如上图所示, 共有四个输入框需要填写:

- **名称**: 用来描述 VCS 的来源与目的, 是给人阅读的;  
- **类型**: 一个下拉选择框, 代表你的 VCS 平台类型, 目前支持 Gitlab, GitHub, Gitea, Gitee 四种常见 vcs 平台;   
- **地址**: 由用户提供的 VCS 平台 URL;  
- **token**: VCS 平台的安全令牌, 不同 VCS 平台生成令牌的规则不同;  

以 GitLab 为例, 一个填写好的 VCS 信息应如下所示

![CloudIaC add-vcs-done](../images/aliyun-ecs-add-vcs-done.jpg)

#### 新建云模板
在添加 VCS 完成后, 用户可以通过导入想要使用代码仓库分支来新建云模板;

在 Demo 组织下, 选择「云模板」, 点击「新建云模板」按钮;

![CloudIaC add-template](../images/aliyun-ecs-add-template.jpg)

在「新建云模板」界面, 进入第一步, 填写必要的 VCS 仓库信息;

这里以一个准备好的 GitLab 仓库「aliyun_ecs_demo」为例;

- **VCS**: 选择之前添加的 vcs, 此处选择了名为 `gitlab_acesss_token` 的 vcs;
- **仓库名称**: 选择准备好的 vcs 仓库名, CloudIaC 会自动导入远程仓库的信息数据;
- **分支/标签**: 选择 vcs 仓库的一条分支, 此处选择了 master 分支;
- **工作目录**: Terrafrom 运行时的工作目录;
- **Terraform 版本**: 不确定 terraform 版本, 可以选择「自动选择」选项;

![CloudIaC add-template-detail01](../images/aliyun-ecs-add-template-detail01.jpg)

如果你没有现成的 terraform 代码, 可以使用 CloudIaC 提供的默认仓库来创建阿里云 ecs;

如下图所示, vcs 选择「默认仓库」, 分支选择「terraform-alicloud-ecs-instance」选项;

![CloudIaC add-template-default](../images/aliyun-ecs-add-template-default.jpg)

填写完成后, 选择下一步, 来到「变量」步骤;
在此页面, 我们可以定义额外需要传递的 terraform 变量, 环境变量以及额外变量;  
在「环境变量」一栏中, 我们选择右侧的「添加变量」按钮, 导入之前在系统里设置阿里云资源账号的 acess_key 和 secre_key;  
因为本次仅仅创建 ecs, 故只在「额外变量」一栏中引入 ssh 密钥, 并指定代码仓库中的使用的 tfvars 文件;  

![CloudIaC add-template-detail02](../images/aliyun-ecs-add-template-detail02.jpg)

填写完成后, 选择下一步, 进入「设置」步骤;  
在此界面, 我们可以添加此云模板的名字和描述信息, 如下图所示, 我们将本次创建的云模板命名为 aliyun_ecs_demo;  

![CloudIaC add-template-detail03](../images/aliyun-ecs-add-template-detail03.jpg)

当填写完成后, 选择下一步, 进入「关联项目」步骤;  
在这一步, 我们选择关联之前创建的「演示项目」即可;

![CloudIaC add-template-detail04](../images/aliyun-ecs-add-template-detail04.jpg)

这样子, 我们就完成了一个云模板的创建;  

#### 创建环境

接下来, 我们可以使用准备好的云模板来创建期望的环境;  
在「项目」界面, 点击已经创建好的「演示项目」进入项目;  

![CloudIaC project](../images/aliyun-ecs-project.jpg)

点击左侧选项卡中的「环境」选项, 再点击左侧右上角的「部署新环境」按钮;

![CloudIaC project-env](../images/aliyun-ecs-project-env.jpg)

这会跳转到「云模板」界面, 你能看到目在前项目下的所有云模板, 选择「aliyun_ecs_demo」, 点击「部署」;

![CloudIaC project-deploy-env](../images/aliyun-ecs-env-deploy.jpg)

在部署之前, 我们将会看到本次部署前的环境信息, 新环境会从云模板的基层设定的各种变量(terraform 变量、环境变量、其他变量), 当然你也可以传修变量来覆盖继承的默认值, 从而创建一个与云模板不同规格的环境(本次修改仅本次生效), 本次我们不修改任何变量;

给这个环境命名为「阿里云 ecs 实例环境」, 并且在高级设置「模板」一栏中的 tfvar 选择框选择一个 tfvars 文件;

![CloudIaC project-deploy-env-var](../images/aliyun-ecs-deploy-env-var.jpg)

这里要注意, 记得要在「执行」选项卡中选一个执行通道(cloudiac 可能存在多个执行通道, 这里任选一个即可);  

![CloudIaC project-deploy-env-var](../images/aliyun-ecs-deploy-env-runner.jpg)

##### plan 计划与执行部署

在「环境信息」页面最下方有两个按钮:「plan 计划」与「执行部署」;  
二者分别对应 terraform 的 plan 和 apply 操作,「plan 计划」只会展示本次环境将要变更的资源数据但不执行创建, 而「执行部署」会先展示变更的资源, 等审批通过后再执行部署;  

![CloudIaC project-deploy-env-var](../images/aliyun-ecs-deploy-or-plan.jpg)

这里我们选择点击「执行部署」, iac 会执行到 plan 阶段, 展示本次涉及到的变更数据, 接下来等待审核;

![CloudIaC project-env-do-plan](../images/aliyun-ecs-env-plan.jpg)

##### apply 
点击「审核」按钮, 检查确认过这次的变更数据之后, 再选择点击「通过」, 让 iac 继续执行 apply;  

![CloudIaC project-env-check](../images/aliyun-ecs-env-do-check.jpg)

接下来 iac 就会开始进入到 apply 阶段, 开始调用阿里云的 provider 执行真正的变更, 仅仅需要耐心等待一会, 一台 aliyun esc 实例就会创建出来了;

![CloudIaC project-env-do-apply](../images/aliyun-ecs-env-do-apply.jpg)

现在让我们在终端上用之前创建的 ssh 密钥登陆验证一下;

![CloudIaC aliyun-ecs-ssh-login](../images/aliyun-ecs-ssh-login.jpg)

##### destory  

当这台 aliyun ecs 使用完后, 用户可以点击「环境详情」面包屑, 跳转到环境详情页面, 再点击右上角的「销毁资源」按钮来销毁这台机器;

![CloudIaC aliyun-ecs-destory](../images/aliyun-ecs-env-destory.jpg)

「销毁资源」是一个高危操作, 在销毁前, IaC 会要求用户输入一次环境的名称来确认用户是否真的要销毁环境;

![CloudIaC aliyun-ecs-destory-check](../images/aliyun-ecs-env-destory-check.jpg)

在确认销毁后, 同样也会有一个类似部署前的审核过程, 审核通过后会执行销毁动作，稍后创建的阿里云 ecs 实例资源就会被回收销毁；

![CloudIaC aliyun-ecs-do-destory](../images/aliyun-ecs-env-do-destory.jpg)

销毁仅仅代表这个环境当前的状态, 如果以后用户有需要这台 ecs 的场景时, 可以通过「重新部署」的方式重新部署这台阿里云 ecs 实例进行环境复用; 

![CloudIaC aliyun-ecs-do-destory-again](../images/aliyun-ecs-env-do-apply-again.jpg)

至此, 我们通过 CloudIaC 就完成对一台阿里云 ecs 实例从「创建」到「销毁」再到「重新部署」的全过程;