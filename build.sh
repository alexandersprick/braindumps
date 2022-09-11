#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd "$SCRIPTPATH"

if ! docker images | grep -q openwrt_builder ; then
    rm -rf docker-openwrt-builder
    git clone https://github.com/mwarning/docker-openwrt-builder.git
    cd docker-openwrt-builder/
    docker build -t openwrt_builder .
fi
cd "$SCRIPTPATH"

rm -rf docker-build 
mkdir docker-build
cp -r files docker-build/
cat<<'EOF'> docker-build/run.sh
#!/bin/bash
wget https://downloads.openwrt.org/snapshots/targets/ramips/mt76x8/openwrt-imagebuilder-ramips-mt76x8.Linux-x86_64.tar.xz
tar -Jxf openwrt-imagebuilder-ramips-mt76x8.Linux-x86_64.tar.xz 
cd openwrt-imagebuilder-ramips-mt76x8.Linux-x86_64
mv ../files .
PACKAGES="luci luci-proto-wireguard luci-app-vpn-policy-routing wget sshtunnel sshpass"
PROFILE="xiaomi_mi-router-4a-100m-intl"
FILES="files"
make image PROFILE="$PROFILE" PACKAGES="$PACKAGES" FILES="$FILES"
cp /home/user/openwrt-imagebuilder-ramips-mt76x8.Linux-x86_64/bin/targets/ramips/mt76x8/openwrt-ramips-mt76x8-xiaomi_mi-router-4a-100m-intl-squashfs-sysupgrade.bin /home/user/
EOF
chmod +x docker-build/run.sh
docker run --rm --name openwrt-build -v $(pwd)/docker-build:/home/user -it openwrt_builder /home/user/run.sh
mv docker-build/openwrt-ramips-mt76x8-xiaomi_mi-router-4a-100m-intl-squashfs-sysupgrade.bin openwrt-ramips-mt76x8-xiaomi_mi-router-4a-100m-intl-squashfs-sysupgrade-$(date +%F_%H%M%S)$1.bin
