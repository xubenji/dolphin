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
	This script build OVMF.fd by default.
	If you don't want to build the OVMF.fd module, you have the OVMF.fd and you know how to run qemu with OVFM.fd.
	You can run script like this
	>:bash bash BuildToolsInit.sh -noovmf
=======
