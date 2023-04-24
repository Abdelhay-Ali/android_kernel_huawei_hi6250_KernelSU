#!/bin/bash

rm -r out

echo " "
echo "***Setting environment...***"
# 交叉编译器路径
#export PATH=$PATH:$(pwd)/toolchain/linux-x86_64/bin
#export CROSS_COMPILE=aarch64-linux-android-

export PATH=$PATH:/home/abdelhy/Desktop/P20_lite_Kernels/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-elf/bin
export CROSS_COMPILE=aarch64-elf-

#export PATH=$PATH:/home/abdelhy/Desktop/P20_lite_Kernels/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-elf/bin
#export CROSS_COMPILE=aarch64-elf-

export GCC_COLORS=auto
export ARCH=arm64
if [ ! -d "out" ];
then
	mkdir out
fi


echo "***Building for V9 version...***"
make ARCH=arm64 O=out p20_defconfig
make ARCH=arm64 O=out -j8

date="$(date +%d%m%Y-%I%M)"
echo "***Packing V9 version kernel...***"
	tools/mkbootimg --kernel out/arch/arm64/boot/Image.gz --base 0x0 --cmdline "loglevel=4 coherent_pool=512K page_tracker=on slub_min_objects=12 unmovable_isolate1=2:192M,3:224M,4:256M printktimer=0xfff0a000,0x534,0x538 androidboot.selinux=enforcing buildvariant=user" --base 0x00478000 --pagesize 2048 --kernel_offset 0x00008000 --ramdisk_offset 0x0ff88000 --second_offset 0x00e88000 --tags_offset 0x07988000 --os_version 9.0.0 --os_patch_level 2020-01 --header_version 0 --output Kernel-4.9.148-KSU-enforcing-${date}.img


	tools/mkbootimg --kernel out/arch/arm64/boot/Image.gz --base 0x0 --cmdline "loglevel=4 coherent_pool=512K page_tracker=on slub_min_objects=12 unmovable_isolate1=2:192M,3:224M,4:256M printktimer=0xfff0a000,0x534,0x538 androidboot.selinux=permissive buildvariant=user" --base 0x00478000 --pagesize 2048 --kernel_offset 0x00008000 --ramdisk_offset 0x0ff88000 --second_offset 0x00e88000 --tags_offset 0x07988000 --os_version 9.0.0 --os_patch_level 2020-01 --header_version 0 --output Kernel-4.9.148-KSU-permissive-${date}.img
	
