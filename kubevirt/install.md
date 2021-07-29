# Requirements
A few requirements need to be met before you can begin:

Kubernetes cluster or derivative (such as OpenShift, Tectonic) based on Kubernetes 1.10 or greater
Kubernetes apiserver must have --allow-privileged=true in order to run KubeVirt's privileged DaemonSet.
kubectl client utility

检查api-server
```
ps -ef | grep api | grep allow-privileged=true

// 检查cpu支不支持libvirt ,如果不支持虚拟化，那么可以开启软件模拟
# grep -Eoc '(vmx|svm)' /proc/cpuinfo
```


debian机器安装kvm
sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils libguestfs-tools genisoimage virtinst libosinfo-bin

检查libvirt 

如果没有virt-host-validate命令安装 libvirt 

centos: yum install libvirt

```
$ virt-host-validate qemu
  QEMU: Checking for hardware virtualization                                 : PASS
  QEMU: Checking if device /dev/kvm exists                                   : PASS
  QEMU: Checking if device /dev/kvm is accessible                            : PASS
  QEMU: Checking if device /dev/vhost-net exists                             : PASS
  QEMU: Checking if device /dev/net/tun exists                               : PASS
...
```

安装kubevirt operator

```
# Pick an upstream version of KubeVirt to install
$ export RELEASE=v0.43.0
# Deploy the KubeVirt operator
$ kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-operator.yaml
# Create the KubeVirt CR (instance deployment request) which triggers the actual installation
$ kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-cr.yaml
# wait until all KubeVirt components are up
$ kubectl -n kubevirt wait kv kubevirt --for condition=Available

```

如果硬件虚拟化不可用，那么可以通过在 KubeVirt CR spec.configuration.developerConfiguration.useEmulation 中设置为 true 来启用软件模拟回退，如下所示：

```
$ kubectl edit -n kubevirt kubevirt kubevirt

Add the following to the kubevirt.yaml file
    spec:
      ...
      configuration:
        developerConfiguration:
          useEmulation: true
```

通过标签限定daemonset运行（ 是否可以限定只发布的节点,待测试)
```
Restricting virt-handler DaemonSet
You can patch the virt-handler DaemonSet post-deployment to restrict it to a specific subset of nodes with a nodeSelector. For example, to restrict the DaemonSet to only nodes with the "region=primary" label:

kubectl patch ds/virt-handler -n kubevirt -p '{"spec": {"template": {"spec": {"nodeSelector": {"region": "primary"}}}}}'

```
