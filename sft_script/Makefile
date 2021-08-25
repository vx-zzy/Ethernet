
TOOLCHAIN_PREFIX = riscv-none-embed-

ARCH= -march=rv32im -mabi=ilp32

#CCFLAGS = -march=rv32im -mabi=ilp32 -Wall
CCFLAGS = -march=rv32im -mabi=ilp32

FIRMWARE_OBJS = output/firmware.elf
VERILOG_OBJS  = output/firmware.verilog
DUMP_OBJS     = output/firmware.S
FPGA_OBJS	  = output/instr.coe output/instr.verilog
C_HEADERS += soc_define.h
C_SRCS += ${wildcard *.c}
ASM_SRCS += start.S

C_OBJS := $(C_SRCS:.c=.o)
ASM_OBJS := $(ASM_SRCS:.S=.o)
.PHONY:all clean
all : clean $(FPGA_OBJS) 
#firmware: firmware.bin
#	python makehex.py $< $(RAM_SIZE) $(BLOCK_RAM_SIZE) #> $(addsuffix _B0.hex,$@)
$(FPGA_OBJS) : $(VERILOG_OBJS)
	python machine_code.py >> $(DUMP_OBJS)
	#cp -f $(FPGA_OBJS) 'G:\ZYNQ7000_X7Z015-2CLG485L\Ethernet_1G\IP'
	cp -f $(FPGA_OBJS) "../../IP/"
$(VERILOG_OBJS) $(DUMP_OBJS): $(FIRMWARE_OBJS)
	$(TOOLCHAIN_PREFIX)objcopy -O verilog $< $(VERILOG_OBJS);
	size $(FIRMWARE_OBJS)
	#$(TOOLCHAIN_PREFIX)objdump $< -s -d 
	$(TOOLCHAIN_PREFIX)objdump $(FIRMWARE_OBJS) -D > $(DUMP_OBJS)

$(FIRMWARE_OBJS) : sections.lds $(ASM_OBJS) $(C_OBJS)  $(C_HEADERS)
	$(TOOLCHAIN_PREFIX)gcc $(CCFLAGS) -Os -ffreestanding -nostdlib --specs=nano.specs -o $@ \
		-Wl,-Bstatic,-T,sections.lds $(C_HEADERS) $(ASM_OBJS) $(C_OBJS) -lgcc

$(ASM_OBJS) : %.o : %.S
	$(TOOLCHAIN_PREFIX)gcc -c $(CCFLAGS) -o $@ $<

$(C_OBJS) : %.o : %.c
	$(TOOLCHAIN_PREFIX)gcc -c $(CCFLAGS) -o $@ $<

clean:
	rm -f *.o