# List kernel modules to build.
obj-m += hello.o
obj-m += inspector.o

# Path to the currently running kernel build directory.
KDIR := /lib/modules/$(shell uname -r)/build
# Current project directory.
PWD := $(shell pwd)

# Build all kernel modules.
all:
	make -C $(KDIR) M=$(PWD) modules

# Clean generated build files.
clean:
	make -C $(KDIR) M=$(PWD) clean
