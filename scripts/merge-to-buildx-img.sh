TargetIMG=beyond.io:5000/ryu-controller-prebuild:1.4
SrcAMDIMG=beyond.io:5000/ryu-controller-prebuild-amd64:1.4
SrcARMIMG=beyond.io:5000/ryu-controller-prebuild-arm64:1.4

docker manifest create --insecure $TargetIMG $SrcAMDIMG $SrcARMIMG; \
docker manifest annotate  $TargetIMG $SrcAMDIMG --os linux --arch amd64; \
docker manifest annotate  $TargetIMG $SrcARMIMG --os linux --arch arm64; \
docker manifest push --insecure $TargetIMG; \
docker manifest inspect --insecure $TargetIMG
