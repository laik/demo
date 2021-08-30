# demo

# 一个简单vmi
```
cat << "EOF" | kubectl apply -f -
apiVersion: kubevirt.io/v1alpha3
kind: VirtualMachineInstance
metadata:
  name: testvmi-nocloud
spec:
  terminationGracePeriodSeconds: 30
  domain:
    resources:
      requests:
        memory: 1024M
    devices:
      disks:
      - name: containerdisk
        disk:
          bus: virtio
      - name: emptydisk
        disk:
          bus: virtio
      - disk:
          bus: virtio
        name: cloudinitdisk
  volumes:
  - name: containerdisk
    containerDisk:
      image: kubevirt/fedora-cloud-container-disk-demo:latest
  - name: emptydisk
    emptyDisk:
      capacity: "2Gi"
  - name: cloudinitdisk
    cloudInitNoCloud:
      userData: |-
        #cloud-config
        password: fedora
        chpasswd: { expire: False }
EOF
```

# pause 与unpause时vmi 状态变化
```
  status:
    activePods:
      5c4b1bb1-ad1d-460d-a209-93535870c3c0: ym-ops-160056
    conditions:
    - lastProbeTime: null
      lastTransitionTime: null
      message: cannot migrate VMI which does not use masquerade to connect to the
        pod network
      reason: InterfaceNotLiveMigratable
      status: "False"
      type: LiveMigratable
    - lastProbeTime: null
      lastTransitionTime: "2021-07-26T04:53:47Z"
      status: "True"
      type: Ready
    - lastProbeTime: "2021-07-26T08:16:45Z"                     //--->pause
      lastTransitionTime: "2021-07-26T08:16:45Z"
      message: VMI was paused by user
      reason: PausedByUser
      status: "True"
      type: Paused
      

																															 // -->unpause
  status:
    activePods:
      5c4b1bb1-ad1d-460d-a209-93535870c3c0: ym-ops-160056
    conditions:
    - lastProbeTime: null
      lastTransitionTime: null
      message: cannot migrate VMI which does not use masquerade to connect to the
        pod network
      reason: InterfaceNotLiveMigratable
      status: "False"
      type: LiveMigratable
    - lastProbeTime: null
      lastTransitionTime: "2021-07-26T04:53:47Z"
      status: "True"
      type: Ready
      
      
```