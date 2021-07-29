cat << "EOF" | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage

provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: fedora-nginx
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem # Filesystem/Block
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage
  local:
    path: /data/volumes
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - kubevirt-test
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fedora-nginx
  # namespace: xx
spec:
  accessModes: ["ReadWriteOnce"]
  storageClassName: local-storage
  volumeMode: Filesystem
  resources:
    requests:
      storage: 10Gi
EOF