#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/sched/signal.h>   // for task_struct access
#include <linux/pid.h>
#include <linux/sched.h>

// Module parameter: PID to inspect.
static int target_pid = -1;
module_param(target_pid, int, 0);

// Runs when the module is loaded.
static int __init inspector_init(void)
{
    struct task_struct *task;
    struct pid *pid_struct;

    printk(KERN_INFO "=== Inspector Module Loading ===\n");
    printk(KERN_INFO "Target PID parameter: %d\n", target_pid);

    // Convert PID to task_struct pointer.
    pid_struct = find_vpid(target_pid);
    printk(KERN_INFO "find_vpid returned: %p\n", pid_struct);

    if (!pid_struct) {
        printk(KERN_INFO "ERROR: find_vpid returned NULL for PID %d\n", target_pid);
        return -EINVAL;
    }

    task = pid_task(pid_struct, PIDTYPE_PID);
    printk(KERN_INFO "pid_task returned: %p\n", task);

    // Convert PID to task_struct pointer.
    task = pid_task(find_vpid(target_pid), PIDTYPE_PID);

    // If PID is invalid, print a message and stop.
    if (!task) {
        printk(KERN_INFO "ERROR: pid_task returned NULL for PID %d\n", target_pid);
        return -ESRCH;
    }

    // Walk up the parent chain until we reach PID 1 (init).
    while (task) {
        printk(KERN_INFO "PID: %d | Name: %s | State: %ld\n",
               task->pid, task->comm, task->__state);

        if (task->pid == 1)
            break;

        task = task->real_parent;
    }

    printk(KERN_INFO "=== Inspection Complete ===\n");
    return 0;
}
// Runs when the module is removed.
static void __exit inspector_exit(void)
{
    printk(KERN_INFO "Inspector module unloaded.\n");
}

module_init(inspector_init);
module_exit(inspector_exit);

MODULE_LICENSE("GPL");
