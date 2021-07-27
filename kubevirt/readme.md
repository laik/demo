# Kubevirt

KubeVirt的实现方式
KubeVirt充分采用了Kubernetes方式扩展了Kubernetes，主要在以下3个方面进行了扩展：

VM相关的自定义资源CRD被增加到Kubernetes API中间。新增的CRD包括VirtualMachine, VirtualMachineInstance, VirtualMachineInstanceMigration, DataVolume等。
新建的虚拟机控制器，用于实现上述相关CRD在增、删、改时应该执行的相关操作。
每个节点上面的守护进程virt-handler（具体实现方式是运行在Kubernetes集群里面的DaemonSet），可以认为是KubeVirt的kubelet。Virt-handler和kubelet一起，用于创建虚拟机实例(VMI)，以达到CRD中期望的状态。
图6是KubeVirt社区官方的详细架构图，列出了KubeVirt对Kubernetes的扩展组件。

图6 – KubeVirt详细架构

以下是一个创建虚拟机的大致流程：

1. 客户端通过kubectl 创建一个VMI的CRD请求，该请求被K8S API Server收到。
2. K8S API Server转发到virt-api， virt-api经过验证之后创建一个VMI的CRD对象。
3. virt-controller检测到VMI的创建，引发创建一个pod。
4. Kubernetes调度该pod到某个节点。
5. virt-controller检测到对应VMI的pod已经启动，更新VMI的CRD定义里面nodeName字段。现在既然nodeName字段已经赋值，接下来由该节点上面的virt-handler进行相关操作。
6. virt-handler检测到一个VMI已经调度到它所在的节点，它会使用VMI中的定义内容跟virt-launcher通信。virt-launcher会在VMI pod中创建一个虚拟机，并且负责该虚拟机的生命周期管理。(virt-handler创建了tap设备)

在VMI pod内部，virt-launcher是该pod的主要容器。virt-launcher的主要功能是为虚拟机进程准备控制组和命名空间。在接收到来virt-hander创建虚拟机的命令后，virt-launcher将会使用自己容器内部libvirtd创建一个虚拟机实例。