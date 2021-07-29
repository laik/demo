1. 创建datavolume的时候需要注意的一点，由于创建datavolume会创建一个pod来对数据的导入，例如出现磁盘过小的状况，pod会进入CrashLoopBackOff,需要对pod中的log查看才能知道（这里可以提升，改成POD的状态对datavolume的状态影响）

```
importer-my-right-create-vm        0/1     CrashLoopBackOff   4          2m40s
virt-launcher-cirros-nginx-nx68x   1/1     Running            0          5m20s
root@kubevirt-test:~# k logs -f importer-my-right-create-vm
I0729 06:42:32.659101       1 importer.go:52] Starting importer
I0729 06:42:32.659541       1 importer.go:135] begin import process
I0729 06:42:32.659718       1 data-processor.go:323] Calculating available size
I0729 06:42:32.659815       1 data-processor.go:335] Checking out file system volume size.
I0729 06:42:32.659932       1 data-processor.go:343] Request image size not empty.
I0729 06:42:32.659946       1 data-processor.go:348] Target size 5Gi.
I0729 06:42:32.660389       1 data-processor.go:231] New phase: TransferScratch
I0729 06:42:32.660576       1 registry-datasource.go:82] Copying registry image to scratch space.
I0729 06:42:32.660589       1 transport.go:173] Downloading image from 'docker://laiks/fedora:latest', copying file from 'disk' to '/scratch'
I0729 06:42:35.160011       1 transport.go:197] Processing layer {Digest:sha256:6cb35ddc59c610a0e8a358d1bd136a07801523155a2c5ec606171ae47e5d6be0 Size:254754898 URLs:[] Annotations:map[] MediaType:application/vnd.docker.image.rootfs.diff.tar.gzip CompressionOperation:0 CompressionAlgorithm:<nil> CryptoOperation:0}
I0729 06:42:36.020995       1 transport.go:149] File 'disk/Fedora-Cloud-Base-34-1.2.x86_64.qcow2' found in the layer
I0729 06:42:36.024249       1 util.go:168] Writing data...
I0729 06:42:40.811642       1 registry-datasource.go:150] VM disk image filename is Fedora-Cloud-Base-34-1.2.x86_64.qcow2
I0729 06:42:40.811801       1 data-processor.go:231] New phase: Convert
I0729 06:42:40.811838       1 data-processor.go:237] Validating image
E0729 06:42:40.845457       1 data-processor.go:228] Virtual image size 5368709120 is larger than available size 5073430118 (PVC size 5368709120, reserved overhead 0.055000%). A larger PVC is required.
Unable to convert source data to target format
kubevirt.io/containerized-data-importer/pkg/importer.(*DataProcessor).ProcessDataWithPause
	pkg/importer/data-processor.go:217
kubevirt.io/containerized-data-importer/pkg/importer.(*DataProcessor).ProcessData
	pkg/importer/data-processor.go:165
main.main
	cmd/cdi-importer/importer.go:189
runtime.main
	GOROOT/src/runtime/proc.go:225
runtime.goexit
	GOROOT/src/runtime/asm_amd64.s:1371
I0729 06:42:40.845883       1 util.go:39] deleting file: /scratch/disk
E0729 06:42:40.848175       1 importer.go:191] Virtual image size 5368709120 is larger than available size 5073430118 (PVC size 5368709120, reserved overhead 0.055000%). A larger PVC is required.
Unable to convert source data to target format
kubevirt.io/containerized-data-importer/pkg/importer.(*DataProcessor).ProcessDataWithPause
	pkg/importer/data-processor.go:217
kubevirt.io/containerized-data-importer/pkg/importer.(*DataProcessor).ProcessData
	pkg/importer/data-processor.go:165
main.main
	cmd/cdi-importer/importer.go:189
runtime.main
	GOROOT/src/runtime/proc.go:225
runtime.goexit
	GOROOT/src/runtime/asm_amd64.s:1371
```

当然出现这种错误先调大datavolume的storage.