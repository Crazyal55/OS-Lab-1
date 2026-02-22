#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

// Runs when the module is loaded into the kernel.
static int __init hello_init(void)
{
    printk(KERN_INFO "CS 4500 Project 2: Hello World loaded.\n");
    return 0;
}

// Runs when the module is removed from the kernel.
static void __exit hello_exit(void)
{
    printk(KERN_INFO "CS 4500 Project 2: Goodbye.\n");
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");
