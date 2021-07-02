# AlteraDMA_L4T_driver

Modifications to original Altera DMA driver for Linux.

Adapted to Linux4Tegra (L4T) (Compiled for Cyclone10).

Tested on custom CHIMERA board with Nvidia Jetson TX2 (with L4T 32.4.3) with the Cyclone 10 GX (with Quartus 17.1 Pro).

altera_dma -- Linux driver
--------------------------

Make sure to have turrned on and programmed the Intel Cyclone 10 GX FPGA with a compatible .SOF with PCI gen2 x4 lane Hard IP using the Intel Quartus 17.1 edition. The FPGA must be ready at boot. In case of out-of-sync issues soft reboot the system.The PCI co-processor device must be usable and visible using:

    sudo lspci -vv

INSTALL & RUN
-------------

To make and install the driver:

    sudo ./install "device_family"

device_family = arria10,cyclone10,stratix10

To bring up a simple menu to issue commands to the driver:
    
    sudo ./run

