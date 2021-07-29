# 请参考cdi.md上传镜像

```
cat << "EOF" | kubectl apply -f -
apiVersion: kubevirt.io/v1alpha3
kind: VirtualMachine
metadata:
  labels:
    kubevirt.io/vm: nginx-provisioner
  name: nginx-provisioner
  namespace: vm-images
spec:
  runStrategy: "RerunOnFailure"
  template:
    metadata:
      labels:
        kubevirt.io/vm: nginx-provisioner
    spec:
      domain:
        devices:
          disks:
          - disk:
              bus: virtio
            name: datavolumedisk1
          - disk:
              bus: virtio
            name: cloudinitdisk
        machine:
          type: ""
        resources:
          requests:
            memory: 1Gi
      terminationGracePeriodSeconds: 0
      volumes:
      - dataVolume:
          name: fedora-nginx
        name: datavolumedisk1
      - cloudInitNoCloud:
          userData: |
            #!/bin/sh
            yum install -y nginx
            systemctl enable nginx
            # removing instances ensures cloud init will execute again after reboot
            rm -rf /var/lib/cloud/instances
            shutdown now
        name: cloudinitdisk
  dataVolumeTemplates:
  - metadata:
      name: fedora-nginx
    spec:
      pvc:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 10Gi
      source:
        pvc:
          namespace: vm-images
          name: fedora-cloud-base-docker
EOF
```


# 重点...
1. runStrategy 的用法：“RerunOnFailure”。这告诉 KubeVirt 将 VM 的执行视为类似于 Kubernetes 作业。我们希望 VM 继续重试，直到VM正常关闭。
2. cloudInitNoCloud 该卷允许我们将脚本注入到VM的启动过程中。在我们的例子中，我们希望这个脚本安装 nginx，配置 nginx 在启动时启动，然后在完成后立即优雅地关闭来宾。
3. dataVolumeTemplates 部分的用法。这允许我们定义一个新的 PVC，它是我们的 fedora-cloud-base 基础镜像的克隆。附加到我们的 VM 的结果 VM 映像将是一个预填充了 nginx 的新映像。


kubectl delete vm nginx-provisioner -n vm-images --cascade=false
