# storage
在 spec.volumes 下可以指定多种类型的卷：

cloudInitConfigDrive：【使用】在KubeVirt中使用 Cloud-init 中已经介绍

cloudInitNoCloud：【使用】在KubeVirt中使用 Cloud-init 中已经介绍

containerDisk：指定一个包含 qcow2 或 raw 格式的 docker 镜像，重启 vm 数据会丢失

dataVolume：动态创建一个 PVC，并用指定的磁盘映像填充该 PVC，重启 vm 数据不会丢失

downwardAPI：不清楚用途。。

emptyDisk：从宿主机上分配固定容量的空间，映射到vm中的一块磁盘，与 emptyDir 一样，emptyDisk 的生命周期与 vm 等同，重启 mv 数据会丢失

ephemeral：在虚机启动时创建一个临时卷，虚机关闭后自动销毁，临时卷在不需要磁盘持久性的任何情况下都很有用。

hostDisk：在宿主机上创建一个 img 镜像文件，挂给虚拟机使用。重启 vm 数据不会丢失。

persistentVolumeClaim：指定一个 PVC 创建一个块设备。重启 vm 数据不会丢失。

secret：使用 K8S 的 secret 来存储和管理一些敏感数据，比如密码，token，密钥等敏感信息。并把这些信息注入给虚拟机，如果是可以动态更新到 Pod，但是不能修改 Pod 中生成的 iso 文件，更不能更新到 vm。要想更新，只有重启 vm。emptyDisk

在 yaml 中指定如下相关内容

...more
      domain:
          disks:
          - name: bootdisk
            disk:
              bus: virtio
          - name: emptydisk
            disk:
              bus: virtio
...more
      volumes:
      - name: bootdisk
        containerDisk:
          image: 192.168.56.200:5000/centos72:v3
      - name: emptydisk
        emptyDisk:
          capacity: 2Gi
...more
YAML
创建完虚拟机后，就可以在虚机看到这块 2G 的磁盘

$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
vda    253:0    0   40G  0 disk 
└─vda1 253:1    0   40G  0 part /
vdb    253:16   0  368K  0 disk 
vdc    253:32   0    2G  0 disk 
Bash
对它进行格式化，然后挂载到 /mnt 下，并创建一个文本文件

$ mkfs.ext4 /dev/vdc
$ mount /dev/vdc /mnt
$ echo "k8s" >hello.txt
Bash
重启虚拟机，再次挂载，查看文件是否存在？结果是挂载不了，没有格式化，说明数据被清空了

$ kubectl virt  stop test-vm
$ kubectl virt  start test-vm
$ kubectl virt  console test-vm
$ mount /dev/vdc /mnt
[  349.509706] SGI XFS with ACLs, security attributes, no debug enabled
mount: /dev/vdc is write-protected, mounting read-only
mount: unknown filesystem type '(null)'
Bash
HostDisk
在 yaml 中指定如下内容

...more
      domain:
          disks:
          - name: bootdisk
            disk:
              bus: virtio
          - name: hostdisk
            disk:
              bus: virtio
...more
      volumes:
      - name: bootdisk
        containerDisk:
          image: 192.168.56.200:5000/centos72:v3
      - name: hostdisk
        hostDisk:
          capacity: 50Gi
          path: /data/disk.img
          type: DiskOrCreate
...more
YAML
由于指定的 type 是 DiskOrCreate，因此即使 worker 上没有 /data/disk.img 文件，也会自动为人创建 50Gi 的 img 文件。

persistentVolumeClaim
先创建 PV 和 PVC 先在 worker 上创建一个分区 /dev/sda2

$ fdisk /dev/sda
Command (m for help): n
Partition number (2-14,16-128, default 2): 
First sector (34-2047): 34
Last sector, +sectors or +size{K,M,G,T,P} (34-2047, default 2047): +20 
Created partition 2
Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.

$ lsblk
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda       8:0    0   10G  0 disk 
├─sda1    8:1    0   10G  0 part 
├─sda2    8:2    0 1007K  0 part 
└─sda15   8:15   0    8M  0 part 
vda     253:0    0   40G  0 disk 
└─vda1  253:1    0   40G  0 part /
loop0     7:0    0   10G  0 loop 
Bash
然后指定这个分区，创建 pv

apiVersion: v1
kind: PersistentVolume
metadata:
  name: example-pv
spec:
  capacity:
    storage: 1Gi
  volumeMode: Block
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  local:
    path: /dev/sda2
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: Kubernetes.io/hostname
          operator: In
          values:
          - worker02
YAML
然后创建 pvc

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
  namespace: default
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: local-storage
  volumeMode: Block
  resources:
    requests:
      storage: 1Gi
YAML
然后指定这个 PVC 去创建

...more
      domain:
        devices:
          disks:
          - name: pvc-disk
            disk:
              bus: virtio
...more
      volumes:
      - name: pvc-disk
        persistentVolumeClaim: 
          claimName: local-pvc
...more
YAML
创建后就可以在虚拟机里 lsblk 看到这块盘。

Secret/configMap/serviceAccount
创建一个 secret

# 将信息写入userdata文件中
cat << END>userdata
#cloud-config
vhost_queues: 2
admin_pass: "6nWR5NgAU/F/mcDwJeiQk6Um0vEq26tZ8MYVTMWa39M5FCQzlHJU5fM7lkxfN1Dfj/3Zxfw4DfiwLzUDZAmWLkl.YNdmfqvwQZz."
END

# 创建 secret
$ kubectl create secret generic vmi-userdata-secret --from-file=userdata=userdata
Bash
指定这个 secret 创建虚拟机

...more
      domain:
        devices:
          disks:{}
          - name: app-secret-disk
            # set serial
            serial: D23YZ9W6WA5DJ487
...more
      volumes:
      - name: app-secret-disk
        secret:
          secretName: vmi-userdata-secret
...more
YAML
创建出来 的虚拟机会出多个 /dev/sda 设备，查看他的序列号，刚好和我们指定的一致

$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0  372K  0 disk 
vda    253:0    0   40G  0 disk 
└─vda1 253:1    0   40G  0 part /
vdb    253:16   0  368K  0 disk 
vdc    253:32   0 1007K  0 disk 

$ lsblk --nodeps -no name,serial | grep D23YZ9W6WA5DJ487
sda  D23YZ9W6WA5DJ487

$ mount /dev/sda /mnt
$ cd /mnt/ &&  ls -l
total 1
-rw-r--r-- 1 root root 85 Jun  9 05:25 networkdata
$ cat networkdata 
#cloud-config
vhost_queues: 2
admin_pass: "/F/mc/3Zxfw4DfiwLzUDZAmWLkl.YNdmfqvwQZz."
Bash
containerDisk
指定一个 image 做为系统盘创建虚拟机，系统盘的数据不能持久化，每一次重启都是一个全新的虚拟机。

apiVersion: Kubevirt.io/v1alpha3
kind: VirtualMachine
metadata:
  name: testvm
spec:
  running: true
  template:
    metadata:
      labels:
        kubevirt.io/size: small
        kubevirt.io/domain: testvm
    spec:
      domain:
        devices:
          disks:
            - name: containerdisk
              disk:
                bus: virtio
          interfaces:
          - name: default
            bridge: {}
      networks:
      - name: default
        pod: {}
      volumes:
        - name: containerdisk
          containerDisk:
            image: quay.io/kubevirt/cirros-container-disk-demo
configMap：能类似为 secret，把 configMap 里的信息写入到 iso 磁盘中，挂给虚拟机。
serviceAccount：功能类似为 secret，把 serviceAccount 里的信息写入到 iso 磁盘中，挂给虚拟机。
sysprep：以 secret 或 configMap的形式，往虚机写入 sysprep


