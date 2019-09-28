#!/bin/bash 
#By benji
#2019/09/20
#You can use this script to init the basic build tools
#I recommd you use a clean Ubuntu 18.
#This script only build bochs by default.
#You can run this script like this:
#>:bash BuildToolsInit.sh
#If you want to build all of they. you can change the parameter like this:
#	BOCHS=1
#	BOCHSDEBUGGER=0
#	BOCHSGDB=0
#	EDK=1
#	OVMF=1
#	DOCKER=1
#If you want to build edk2 and don't want to build the bochs.
#You can change parameter like this:
#	BOCHS=0
#	BOCHSDEBUGGER=0
#	BOCHSGDB=0
#	EDK=1
#	OVMF=1
#	DOCKER=0
#If you want to only build bochs with gdb debugger. 
#You can change parameter like this:
#	BOCHS=1
#	BOCHSDEBUGGER=0
#	BOCHSGDB=1
#	EDK=0
#	OVMF=0
#	DOCKER=0
#The BOCHSDEBUGGER and BOCHSGDB depends on BOCHS. if BOCHS=0, they are meaningless.
#In the similar way, The OVMF depends on EDK. Because OVMF.fd is a firmware of UEFI. 
#If EDK=0, the OVMF is meaningless.
#If you don't know the docker. you don't need to care about the parameter DOCKER.
#If you want to complie the edk2 basetools using your physical machine. you can run this script like this 
#>:bash BuildToolsInit.sh -nodocker
#Good lock!

BOCHS=0
BOCHSDEBUGGER=0
BOCHSGDB=0

EDK=0
OVMF=1

DOCKER=1

while [ -n "$1" ]
do	
    case "$1" in
	-nodocker) DOCKER=0 ;;
        -repair) rm -r -f edk2 
		 mv /etc/apt/sources.list /etc/apt/sources.bak
		 cp ./ToolSource/sources.list /etc/apt/sources.list
		 str=$(gcc --version)
		 while [[ $str =~ "gcc" ]]
		 do 
		 sudo yum remove -y gcc
		 sudo apt-get remove gcc -y
		 str=$(gcc --version)
		 done ;;
        *) echo "$1 is not an option" 
	   exit ;;
    esac
    shift
done

#check if the program in docker
if [ $DOCKER -eq 1 ];then
	sudo apt-get install docker.io -y

	#install application for CentOS-like system
	sudo yum install -y yum-utils device-mapper-persistent-data lvm2 
	sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 
	sudo yum install docker-ce-17.12.1.ce -y
	sudo systemctl start docker 
	
	echo "install the application please waite mins."
	docker pull ubuntu 
	PWD=`pwd`
	echo $PWD
	docker run -it -v $PWD:/dolphin ubuntu bash /dolphin/BuildToolsInit.sh -nodocker
	exit
fi

#clear the build envirment of docker ubuntu
cd /dolphin 
cp ./ToolSource/sources.list /etc/apt/sources.list
apt-get update


#install bochs with debugger
if [ $BOCHS -eq 1 ];then
apt-get install sudo -y
sudo apt-get install dpkg-dev -y
sudo apt-get -y install gcc
#sudo apt-get -y install g++
sudo apt-get install xorg-dev -y
sudo apt-get install libgtk2.0-dev -y
rm boch* -f
rm boch* -r -f 
apt-get source bochs -y
rm bochs-2.* -r -f
tar -vxf bochs_2.*.or*
cd bochs-2.*
./configure --enable-debugger --enable-disasm
cp ../ToolSource/Makefile.bochsdebugger ./Makefile
	if [ $BOCHSGDB -eq 1 ];then
		./configure --enable-gdb-stud --enable-disasm
	fi
script -a "../output.bochs" -c "make" 
cp ../ToolSource/BIOS-* ./bios/
cp ../ToolSource/VGABIOS-* ./bios/
fi

pwd

if [ $EDK -eq 1 ];then
cd /dolphin
#install sudo 
apt-get install sudo -y

#install make
sudo apt-get install make -y

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
if [ $OVMF -eq 1 ];then
rm Conf/target.txt
cp ../ToolSource/target.txt Conf/target.txt
BaseTools/BuildEnv 
. ./edksetup.sh
script -a "../output.ovmf" -c "build" 
	if [ ! -d "../ovmf" ];then
	mkdir ../ovmf
	fi
cp ./Build/OvmfX64/DEBUG_GCC48/FV/OVMF.fd ../ovmf
fi
fi

#Check if the compilation is successful
if [ $EDK -eq 1 ];then
grep "tests in" ../output.tools >/dev/null
if [ $? -eq 0 ]; then
    echo -e "[\033[32m Build base tools success \033[0m]"
else
    echo -e "[\033[31m Build base tools failed \033[0m]"
    echo    "f" > ../failed.txt
fi 
if [ -f "../output.ovmf" ]; then
grep "\- Done \-" ../output.ovmf >/dev/null
	if [ $? -eq 0 ]; then
   	 	echo -e "[\033[32m Build OVMF.fd success \033[0m]"
	else
    		echo -e "[\033[31m Build OVMF.fd failed \033[0m]"
    		echo    "f" > ../failed.txt
	fi
fi
fi
if [ $BOCHS -eq 1 ]; then
pwd
grep "g++ \-o bxcommit \-g \-O2 \-D_FILE_OFFSET_BITS=64 \-D_LARGE_FILES -pthread \-fPIC misc/bxcommit.o" ../output.bochs >/dev/null
	if [ $? -eq 0 ]; then
   	 	echo -e "[\033[32m Build bochs success \033[0m]"
	else
		echo -e "[\033[31m Build bochs failed \033[0m]"
    		echo    "f" > ../failed.txt
	fi
fi


if [ -f "../failed.txt" ]; then
grep "f" ../failed.txt >/dev/null
	if [ $? -eq 0 ]; then
   		 echo -e "\033[33mDo you want to repair this error, you can run script like this:"
		 echo -e "\033[33m>:bash BuildToolsInit.sh -repair \033[0m"

	fi
fi

rm -f ../failed.txt
rm -f ../output.tools
rm -f ../output.ovmf
rm -f ../output.bochs
rm bochs_2* -f

exit
