#!/bin/bash 
#By benji
#2019/09/20
#You can use this script to init the basic build tools
#I recommd you use a clean Ubuntu 18.
#This script build OVMF.fd by default.
#If you don't want to build the OVMF.fd module, you have the OVMF.fd and you know how to run qemu with OVFM.fd. 
#if you want to build all. You can run script like this: bash BuildToolsInit.sh


echo
while [ -n "$1" ]
do
    case "$1" in
        -repair) rm -r -f edk2 
		 str=$(gcc --version)
		 while [[ $str =~ "gcc" ]]
		 do 
		 apt-get remove gcc -y
		 str=$(gcc --version)
		 done ;;
	withoutovmf) echo "You will not compile ovmf" ;;
        *) echo "$1 is not an option" 
	   exit ;;
    esac
    shift
done

#install gcc
sudo apt-get -y install gcc

#install g++
sudo apt-get -y install g++

#install the git
sudo apt-get -y install git

#install the basic compile tools
sudo apt-get -y install build-essential uuid-dev nasm python iasl

#download the edk2 source code. please waiter some mins. 
#The speed of download up to your network.
#I changed the github.com 
echo " "
echo "Now, We download the edk2 source code, It's speed may slow. It up to your network."
git clone https://gitee.com/dolphinos/edk2.git

#enter the work directory. preparing the build base tools of edk2
cd edk2
export WORKSPACE=`pwd`
git checkout UDK2015
rm ./BaseTools/Source/C/VfrCompile/VfrUtilityLib.cpp
cp ../ToolSource/VfrUtilityLib.cpp ./BaseTools/Source/C/VfrCompile/

#compiling the base tools
script -a "../output.tools" -c "make -C BaseTools"

#Change the GCC version to gcc48
sudo apt-get -y install gcc-4.8
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 100
sudo update-alternatives --config gcc
gcc -v

#compile the OVMF.fd
rm Conf/target.txt
cp ../ToolSource/target.txt Conf/target.txt
BaseTools/BuildEnv 
. ./edksetup.sh
script -a "../output.ovmf" -c "build" 
cp ./Build/OvmfX64/DEBUG_GCC48/FV/OVMF.fd ../ovmf/

#Check if the compilation is successful
grep "tests in" ../output.tools >/dev/null
if [ $? -eq 0 ]; then
    echo -e "[\033[32m Build base tools success \033[0m]"
else
    echo -e "[\033[31m Build base tools failed \033[0m]"
    echo    "f" > failed.txt
fi 
if [ -f "../output.ovmf" ]; then
grep "\- Done \-" ../output.ovmf >/dev/null
	if [ $? -eq 0 ]; then
   	 	echo -e "[\033[32m Build OVMF.fd success \033[0m]"
	else
    		echo -e "[\033[31m Build OVMF.fd failed \033[0m]"
    		echo    "f" > failed.txt
	fi
fi
if [ -f "../failed.txt" ]; then
grep "f" ../failed.txt >/dev/null
	if [ $? -eq 0 ]; then
   		 echo -e "\033[33mDo you want to repair this error, you can run script like this: bash BuildToolsInit.sh -repair \033[0m"
	fi
fi

rm -f ../failed.txt
rm -f ../output.tools
rm -f ../output.ovmf
