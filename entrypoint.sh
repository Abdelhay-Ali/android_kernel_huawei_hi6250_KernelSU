#!/usr/bin/env bash

msg(){
    echo
    echo "==> $*"
    echo
}

err(){
    echo 1>&2
    echo "==> $*" 1>&2
    echo 1>&2
}

set_output(){
    echo "$1=$2" >> $GITHUB_OUTPUT
}

extract_tarball(){
    echo "Extracting $1 to $2"
    tar xf "$1" -C "$2"
}
#: <<'END'
workdir="$GITHUB_WORKSPACE"
arch="$1"
compiler="$2"
defconfig="$3"
image="$4"
repo_name="${GITHUB_REPOSITORY/*\/}"
zipper_path="${ZIPPER_PATH:-zipper}"
kernel_path="${KERNEL_PATH:-.}"
name="${NAME:-$repo_name}"
python_version="${PYTHON_VERSION:-3}"

msg "Updating container..."
apt update && apt upgrade -y
msg "Installing essential packages..."
apt install -y --no-install-recommends git make bc bison openssl \
    curl zip kmod cpio flex libelf-dev libssl-dev libtfm-dev wget \
    device-tree-compiler ca-certificates python3 python2 xz-utils
ln -sf "/usr/bin/python${python_version}" /usr/bin/python
set_output hash "$(cd "$kernel_path" && git rev-parse HEAD || exit 127)"

msg "Installing toolchain..."
if [[ $arch = "arm64" ]]; then
    arch_opts="ARCH=${arch} SUBARCH=${arch}"
    export ARCH="$arch"
    export SUBARCH="$arch"

    if [[ $compiler = gcc/* ]]; then
        ver_number="${compiler/gcc\/}"
        make_opts=""
        host_make_opts=""
        apt update && apt install sudo

        if ! apt install -y --no-install-recommends gcc-9 g++-9; then
            err "Compiler package not found, refer to the README for details"
            exit 1
        fi
        
        wget -c https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-elf/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-elf.tar.xz --no-check-certificate
        tar -xvf gcc-linaro-7.5.0-2019.12-x86_64_aarch64-elf.tar.xz
        git config --global --add safe.directory /github/workspace

        ln -sf /usr/bin/gcc-"$ver_number" /usr/bin/gcc
        ln -sf /usr/bin/g++-"$ver_number" /usr/bin/g++
        # ln -sf /usr/bin/aarch64-linux-gnu-gcc-"$ver_number" /usr/bin/aarch64-linux-gnu-gcc
        # ln -sf/github/workspace/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-elf/bin/aarch64-elf-gcc-7.5.0 /usr/bin/aarch64-linux-gnu-gcc

        #ln -sf /usr/bin/aarch64-linux-gnu-gcc-"$ver_number" /usr/bin/aarch64-linux-gnu-gcc

        ln -sf /usr/bin/arm-linux-gnueabi-gcc-"$ver_number" /usr/bin/arm-linux-gnueabi-gcc

        #export CROSS_COMPILE="aarch64-linux-gnu-"
        export CROSS_COMPILE="/github/workspace/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-elf/bin/aarch64-elf-"
        export CROSS_COMPILE_ARM32="arm-linux-gnueabi-"
  fi

cd "$workdir"/"$kernel_path" || exit 127
start_time="$(date +%s)"
date="$(date +%d%m%Y-%I%M)"
tag="$(git branch | sed 's/*\ //g')"
echo "branch/tag: $tag"
echo "make options:" $arch_opts $make_opts $host_make_opts
msg "Generating defconfig from \`make $defconfig\`..."
make ARCH=arm64 distclean
if ! make ARCH=arm64 O=out2 p20_defconfig; then
    err "Failed generating .config, make sure it is actually available in arch/${arch}/configs/ and is a valid defconfig file"
    exit 2
fi
msg "Begin building kernel..."

#make O=out $arch_opts $make_opts $host_make_opts -j8 prepare

if ! make ARCH=arm64 O=out2 -j8; then
   err "ccb Failed building kernel, probably the toolchain is not compatible with the kernel, or kernel source problem"
  #  exit 3
fi

set_output elapsed_time "$(echo "$(date +%s)"-"$start_time" | bc)"
msg "Packaging the kernel..."

    
tools/mkbootimg --kernel out2/arch/arm64/boot/Image.gz --base 0x0 --cmdline "loglevel=4 coherent_pool=512K page_tracker=on slub_min_objects=12 unmovable_isolate1=2:192M,3:224M,4:256M printktimer=0xfff0a000,0x534,0x538 androidboot.selinux=enforcing buildvariant=user" --base 0x00478000 --pagesize 2048 --kernel_offset 0x00008000 --ramdisk_offset 0x0ff88000 --second_offset 0x00e88000 --tags_offset 0x07988000 --os_version 9.0.0 --os_patch_level 2020-01 --header_version 0 --output Kernel-4.9.148-KSU-enforcing-${date}.img

set_output Kernel-4.9.148-KSU-enforcing-${date}.img

    exit 0

