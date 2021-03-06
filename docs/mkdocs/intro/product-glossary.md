# 术语解释

## IaC （Infrastructure as Code）
IaC就是基础设施即代码，有时也称为"可编程基础设施"，可将基础设施配置视为软件编程。

IaC通过声明式语言配置和管理基础设施，消除了手动配置、更新各个硬件的需要，这就使得基础设施极具“弹性”， 即可重复且可扩展。一个操作人员使用同一组代码，即可部署并管理若干基础设施；IaC带来的优势包括速度提升、成本节约和风险降低。

IaC 的概念是催生 DevOps 的框架，运行应用的代码和配置基础设施的代码之间越来越难以区分，这意味着开发人员和运维人员在工作上的共同职责日益增加。

## Terraform
Terraform是一个开源的基础设施即代码自动化工具，该工具使用存储在配置文件中的模型来构建云环境，通过 Terraform，您可以自动配置基础设施，实现基础设施模块化，然后自由组合来实现各种云资源构建；Terraform已成为IaC事实上的标准。

## Terraform Provider
Terraform被设计成一个多云基础设施编排工具，可以同时编排各种云平台或是其他基础设施的资源，其实现多云编排的方法就是Provider插件机制。用户在定义描述基础设施配置时可以指定使用的Provider名称和版本，Terraform在执行部署时将根据指定的Provider来判断将在哪个云平台上创建相应的基础设施。

## Terraform Module
对于编写好的一组基础设施描述文件，如果想创建另一套相同的基础设施，一种方法是将写好的tf文件复制并粘贴到另一个文件夹，但我们也可以使用更方便的方法来避免复制粘贴，那就是Module。

Module是包含一组基础设施描述的代码文件集合，我们在编写tf文件时可以直接以module的方式进行引用，从而实现代码的复用，通常对于常用基础设施我们都可以抽象成Module，以便于在日常编写tf文件时直接进行引用，

## Ansible
Ansible是一个自动化运维工具，可通过该工具的 playbook 功能，用配置文件来描述软件应用的部署及状态，从而实现在云端资源构建后的应用自动化部署。

## OPA（Open Policy Agent）
OPA是一个开源的通用策略引擎，可以统一整个堆栈的策略执行。CloudIaC中集成了OPA引擎，可通过引入编写的策略代码，实现对基础设施资源的合规检查。

## VCS（Version Control System）
VCS（Version Control System，版本控制系统）是指用来记录文件内容变化，以便将来查阅特写版本修订情况的系统，通常用来管理软件编程的代码文件，常见的VCS如：Github、Gitlab、Gitee、Gitea等。

## Stack
若干基础设施以及其上部署的应用的组合定义，通常指代 Terraform 的资源描述文件以及应用部署 Playbook 文件的集合，对应 VCS 中的一个仓库

## 变量
变量是用来在环境部署时传递可变参数的一组key/value，在CloudIaC中变量分为Terraform变量和环境变量。

Terraform变量是指tf代码中定义的变量，在实际传递给Terraform执行之前会自动加上TF_VARS_前缀；

环境变量通常用来传递云平台AK/SK或Region等信息。

## 资源帐号
资源帐号是CloudIaC中来用方便管理云平台帐号（AK/SK/Region）的一组环境变量集合。