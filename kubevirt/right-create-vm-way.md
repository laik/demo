# right create vm way

1. create datavolume for pvc, at this, my image from docker registry

create datavolume process : DataVolume --> create Pod --> upload image to PVC

cat << "EOF" | kubectl apply -f -
apiVersion: cdi.kubevirt.io/v1alpha1
kind: DataVolume
metadata:
  name: my-right-create-vm
  namespace: vm-images
spec:
  source:
    registry:
      url: "docker://laiks/fedora:latest"
  pvc:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 10Gi
EOF


2. plan Fixed IP allow the pod (pass)
```
...

```

3. create vm reference datavolume "my-right-create-vm" new vm name "my-right-create-vm-nginx-provisioner"

note: password setting in cloudInitNoCloud

```
cat << "EOF" | kubectl apply -f -
apiVersion: kubevirt.io/v1alpha3
kind: VirtualMachine
metadata:
  labels:
    kubevirt.io/vm: my-right-create-vm-nginx-provisioner
  name: my-right-create-vm-nginx-provisioner
  namespace: vm-images
spec:
  runStrategy: "RerunOnFailure"
  template:
    metadata:
      labels:
        kubevirt.io/vm: my-right-create-vm-nginx-provisioner
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
          name: my-right-create-vm
        name: datavolumedisk1
      - cloudInitNoCloud:
          userData: |-
            #cloud-config
            password: 12345
            chpasswd: 
              expire: False
              list:
              - root:12345
        name: cloudinitdisk
  dataVolumeTemplates:
  - metadata:
      name: my-right-create-vm
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
          name: my-right-create-vm
EOF
```

# output

root@kubevirt-test:~# kg pod,vm,vmi
NAME                                                           READY   STATUS              RESTARTS   AGE
pod/virt-launcher-my-right-create-vm-nginx-provisioner-tdmss   1/1     Running             0          2m4s

NAME                                                              AGE     STATUS    VOLUME
virtualmachine.kubevirt.io/my-right-create-vm-nginx-provisioner   4m33s   Running

NAME                                                                      AGE    PHASE     IP           NODENAME
virtualmachineinstance.kubevirt.io/my-right-create-vm-nginx-provisioner   2m4s   Running                kubevirt-test


# let me(Does it feel like the Queen of England) attach to vm with virtctl console
virtctl console my-right-create-vm-nginx-provisioner

root/12345