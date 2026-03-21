# Mirzakhani

Mirzakhani SDR (Software Defined Radio)

# Introduction

This is an extract from the development of the Mirzakhani SDR intended to serve as a demonstration. I intend it to serve as educational documentation and a template for others wishing to construct a software defined radio. The repository is divided into several folders.

## Vivado and Vitis

This combination Vivado and Vitis project is partitioned as follows

- **vivado:** Vivado source code
    1. **rtl:** Verilog and SystemVerilog (design)
    2. **sim:** Testbenches
    3. **constraints:** XDC files
    4. **scripts:** TCL build scripts
    5. **ip:** (Optional) IP source/config
    6. **docs:** README and diagrams
- **vitis:** Vitis source code
    1. **app:** Applicaton source code
    2. **bsp:** (Optional) BSP settings
    3. **scripts:** TCL build scripts
- **platform:** (Optional) generated from Vivado
- **build:** Vivado generated files (ignored)
- README.md
- Other (material not related to Vivado or Vitis)
    1. **hardware:** Hardware
    2. **misc:** Miscellaneous material

## Vivado Only

In general, a Vivado only project is divided into the following directories

1. **rtl:** Verilog and SystemVerilog (design)
2. **sim:** Testbenches
3. **constraints:** XDC files
4. **scripts:** TCL build scripts
5. **ip:** (Optional) IP source/config
6. **docs:** README and diagrams
7. **build:** Vivado generated files (ignored)
8. **hardware:** Hardware
9. **misc:** Miscellaneous material

## Instructions

To start Vivado, use the following command
```
source /tools/Xilinx/2025.2/Vivado/settings64.sh
vivado &
```



