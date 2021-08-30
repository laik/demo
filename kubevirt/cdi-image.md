# 安装cdi 
不需要什么技术含量，直接apply operator/cr就可以了

kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/v1.37.1/cdi-operator.yaml
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/v1.37.1/cdi-cr.yaml

# 不建议使用这种上传代理的方式，有个bug
virtctl image-upload dv fedora-cloud-base --namespace vm-images  --size=5Gi --image-path Fedora-Cloud-Base-34-1.2.x86_64.qcow2  --uploadproxy-url=https://127.0.0.1:18443 --insecure

# port-forward 上传

```
下载 Fedora Cloud x86_64 qcow2镜像

kubectl create ns vm-images
kubectl port-forward -n cdi service/cdi-uploadproxy 18443:443
virtctl image-upload dv fedora-cloud-base --namespace vm-images  --size=5Gi --image-path Fedora-Cloud-Base-XX-X.X.x86_64.qcow2  --uploadproxy-url=https://127.0.0.1:18443 --insecure
kubectl get pvc -n vm-images
```


# datavolume的方式上传

```
cat << END > Dockerfile
FROM scratch
ADD Fedora-Cloud-Base-XX-X.X.x86_64.qcow2 /disk/
END
docker build -t laiks/fedora:cloud-base .
docker push laiks/fedora:cloud-base

cat << END > fedora-cloud-base-datavolume.yaml
apiVersion: cdi.kubevirt.io/v1alpha1
kind: DataVolume
metadata:
  name: fedora-cloud-base-docker
  namespace: vm-images
spec:
  source:
    registry:
      url: "docker://laiks/fedora:cloud-base"
  pvc:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 6Gi
END
kubectl create -f fedora-cloud-base-datavolume.yaml


kubectl describe datavolume fedora-cloud-base -n vm-images

```

# http/s3上传,没测试，谁爱用谁用，反正上面的docker方式忒香

```
示例：从 http 或 s3 端点导入图像

虽然我不会在这里提供详细的示例，但将 VM 映像导入 PVC 的另一种选择是将映像托管在 http 服务器上（或作为 s3 对象），然后使用 DataVolume 将 VM 映像导入到来自 URL 的 PVC。

将本示例中的 url 替换为托管 qcow2 图像的 URL。可以在此处找到有关此导入方法的更多信息。

复制
kind: DataVolume
metadata:
  name: fedora-cloud-base
  namespace: vm-images
spec:
  source:
    http:
      url: http://your-web-server-here/images/Fedora-Cloud-Base-XX-X.X.x86_64.qcow2
  pvc:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 5Gi
```