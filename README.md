<<<<<<< HEAD
# dolphinos
	This is new dolphinos. It is a new beginning!
	I chose the edk2 to build my bootload.efi in uefi. It doesn't like before we use the BIOS to boot our os.
	BuildToolsInit.sh is a script that automatically deploys edk2.
	How do you run use this script?
	Frist of all, You need clone dolphin.git like this:
	>:git clone https://github.com/xubenji/dolphin.git
	Then, you need go to the work directory.
	>:cd dolphinos/dolphin
	You can run this script like this: 
	>:bash BuildToolsInit.sh
	If you want to build all of they. you can change the parameter in BuildToolsInit.sh like this:
	BOCHS=1
	BOCHSDEBUGGER=0
	BOCHSGDB=0
	EDK=1
	OVMF=1
	DOCKER=1
	If you want to build edk2 and don't want to build the bochs.
	You can change parameter like this:
	BOCHS=0
	BOCHSDEBUGGER=0
	BOCHSGDB=0
	EDK=1
	OVMF=1
	DOCKER=0
	If you want to only build bochs with gdb debugger. 
	You can change parameter like this:
	BOCHS=1
	BOCHSDEBUGGER=0
	BOCHSGDB=1
	EDK=0
	OVMF=0
	DOCKER=0
	The BOCHSDEBUGGER and BOCHSGDB depends on BOCHS. if BOCHS=0, they are meaningless.
	In the similar way, The OVMF depends on EDK. Because OVMF.fd is a firmware of UEFI. 
	If EDK=0, the OVMF is meaningless.
	If you don't know the docker. you don't need to care about the parameter DOCKER.
	If you want to complie the edk2 basetools using your physical machine. you can run this script like this 
	>:bash BuildToolsInit.sh -nodocker
	Good lock!
=======
