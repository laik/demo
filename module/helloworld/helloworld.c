#include <linux/init.h>
#include <linux/module.h>

static int hello_init(void)
{
    printk(KERN_INFO " Hello World enter\n");
    return 0;
}

static void hello_exit(void)
{
    printk(KERN_INFO " Hello World exit\n ");
}

module_init(hello_init);        // / 模块初始化 /
module_exit(hello_exit);        // / 卸载模块 /
MODULE_LICENSE("Dual BSD/GPL"); // / 许可声明 /
MODULE_AUTHOR("Linux");
MODULE_DESCRIPTION("A simple Hello World Module");
MODULE_ALIAS("a simplest module");