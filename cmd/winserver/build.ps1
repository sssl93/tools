$VERSION = "1.1.0"
$dockerfile = "Dockerfile.windows"
$baseImageTag = "lts-nanoserver-1809"

$OSVersion = (Get-WMIObject win32_operatingsystem).name
if ($OSVersion.contains("Windows Server 2022")) {
    $VERSION += "-win2022"
    $baseImageTag = "nanoserver-ltsc2022"
}

$baseImage = "mcr.microsoft.com/powershell:$baseImageTag"
$IMAGE = "beyond.io:5000/winserver:$VERSION"

go build -o bin/main.exe main.go

docker build -t $IMAGE --build-arg BASE_IMAGE=$baseImage -f $dockerfile .
docker push $IMAGE