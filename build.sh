#
 # Custom build script
 #
 # This software is licensed under the terms of the GNU General Public
 # License version 2, as published by the Free Software Foundation, and
 # may be copied, distributed, and modified under those terms.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # Please maintain this if you use this script or any part of it
 #

# Paths
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/arch/arm64/boot/Image
DTBTOOL=$KERNEL_DIR/dtbToolCM

RESOURCE_DIR=~/tools
TOOLCHAIN_DIR="$RESOURCE_DIR/tc"
MODULES_DIR="$RESOURCE_DIR/kenzo/modules"
OUT_DIR="$RESOURCE_DIR/kenzo"
ZIP_MOVE="$RESOURCE_DIR/output"

BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

toolchain ()
{
clear
echo -e " Select which toolchain you want to build with?$white"
echo -e " 1.LINARO 6.3.1 Toolchain"
echo -n " Enter your choice:"
read choice
case $choice in
1) export CROSS_COMPILE=$TOOLCHAIN_DIR/aarch64-linux-android-4.9-UBERTC/bin/aarch64-linux-android-
   export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/aarch64-linux-android-4.9-UBERTC/lib/
   STRIP=$TOOLCHAIN_DIR/aarch64-linux-android-4.9-UBERTC/bin/aarch64-linux-android-strip
   echo -e " You selected LINAROTC"
   TC="LINARO"
   ;;
*) toolchain ;;
esac
}
toolchain

# vars
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="MurdererFight"
export KBUILD_BUILD_HOST"Xubuntu16.10"

#Adamanteous Kernel Details
BASE_VER="Adamanteous"
VER="-v0-$(date +"%Y-%m-%d"-%H%M)-"
Dominator_VER="$BASE_VER$VER$TC"

compile_kernel ()
{
echo -e "**********************************************************************************************"
echo "                                                                                                 "
echo "                                        Compiling Adamanteous Kernel                               "
echo "                                                                                                 "
echo -e "**********************************************************************************************"
make kenzo_defconfig
make Image -j4
make dtbs -j4
make modules -j4
if ! [ -a $KERN_IMG ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
$DTBTOOL -2 -o $KERNEL_DIR/arch/arm64/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
strip_modules
}

strip_modules ()
{
echo "Copying modules"
rm $MODULES_DIR/*
find . -name '*.ko' -exec cp {} $MODULES_DIR/ \;
cd $MODULES_DIR
echo "Stripping modules for size"
$STRIP --strip-unneeded *.ko
cd $KERNEL_DIR
}

case $1 in
clean)
make ARCH=arm64 -j4 clean mrproper
rm -rf $KERNEL_DIR/arch/arm/boot/dt.img
;;
*)
compile_kernel
;;
esac

rm -rf $OUT_DIR/Adamanteous*.zip
rm -rf $OUT_DIR/Kernel*.zip
rm -rf $MODULES_DIR*.zip
rm -rf $OUT_DIR/zImage
rm -rf $OUT_DIR/dtb
rm -rf $ZIP_MOVE/*
cp $KERNEL_DIR/arch/arm64/boot/Image  $OUT_DIR/zImage
cp $KERNEL_DIR/arch/arm64/boot/dt.img  $OUT_DIR/dtb
cd $OUT_DIR
zip -r `echo $Adamanteous_VER`.zip *
mv   *.zip $ZIP_MOVE
cd $KERNEL_DIR
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
echo -e "**********************************************************************************************"
echo "                                                                                                 "
echo "                                        Enjoy Adamanteous                                          "
echo "                                      $Adamanteous_VER.zip                                         " 
echo "                                                                                                 "
echo -e "**********************************************************************************************"  
cd
cd $ZIP_MOVE
ls
