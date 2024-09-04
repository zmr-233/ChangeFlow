# ChangeFlow / cflow 2.0 Document

changeflow | cflow 是一个用于轻松切换和管理工作流的脚本工具，它介于手动管理和 git 管理之间，虽然提供了一种轻量化的解决方案，但却功能完备实用性强。

## 安装方法(以bash为例)

1. 克隆项目 `git clone https://github.com/zmr-233/changeflow ~/changeflow`
2. 设置别名 `echo -e " alias changeflow='bash ~/.changeflowrc';\n alias cflow=changeflow;" >> ~/.bashrc`
3. 重载终端 `source ~/.bashrc`
4. 正常使用 `cflow -h`

## 命令行选项

- `-h, --help [lang]`           **显示帮助信息 (default: en, support: en, zh)**
- `--init`                      **初始化.workflows文件夹和MODULE.cfg文件**
- `--set-init`                  **将当前工作流设置为默认工作流**
- `-c, --cur [名称]`            **指定当前工作流的名称**
- `-t, --target [名称]`         **指定要切换到的目标工作流**
- `-l, --list`                  **列出所有历史工作流**
- `-q, --quick`                 **快速切换到最后一个工作流**
- `--clone [新名称]`            **克隆当前工作流为新的工作流**
- `-s, --save`                  **保存当前工作流而不切换**
- `-r, --restore [名称]`        **恢复指定工作流的备份**
- `--backup [值]`               **使用指定的方法备份当前工作流**
    - `yes`                     **备份（默认行为）**
    - `no`                      **不进行备份**
    - `tar`                     **以tar文件形式备份**
    - `folder`                  **以文件夹形式备份**
- `--delete [名称]`             **删除指定的工作流**
- `--clean-backup`              **清除所有备份文件**

## 详细使用步骤

1. **cflow --init初始化.workflows**

	创建了一个MODULE.cfg的模板文件和一个空文件夹

	Command : `cflow --init`

	```bash
	==> MODULE=NAME_HERE <==
	├── .workflows
	└── MODULE.cfg
	```

2. **cflow --set-init 设定默认工作流**

	创建你每次创建新工作流都会自带的默认文件(比如头文件之类)，然后在`MODULE.cfg`中设定相应的映射`init_map`

	比如此处创建两个文件并修改模块名称:

	Touch `csrc/marco.h`, `vsrc/TEMPLATE.v` and `Makefile`

	其中让你不得不使用cflow的，可能是因为你在Makefile里需要固定编译的目录，更有可能是一个每次都必须要手动更改的变量；但是现在你可以用如下命令，让你的Makefile去MODULE.cfg中查找它需要的变量：

	```Makefile
	MODULE := $(shell awk -F '=' '/^MODULE=/{print $$2}' MODULE.cfg)
	```

	于是`MODULE.cfg`就要按照如上文件目录填写 `--set-init`，键为目录，值为文件名(用空格分隔)，也可以填写*符号代表所有文件:

	```bash
	MODULE=NAME_HERE
	# You need to set the MODULE variable to the name of the current workflow
	
	# The workflow_map array defines which files you want to contain in current workflow.
	declare -A workflow_map=(
	    [.]="MODULE.cfg"
	    [vsrc]="*"
	    [csrc]="*"
	)
	
	# The init_map array defines which files you want to contain in new workflow.
	declare -A init_map=(
	    [.]="Makefile"
	    [vsrc]="*"
	    [csrc]="*"
	    # init_map does not need to contain MODULE.cfg
	)
	
	# MODULE.cfg is created by changeflow script
	```

	接着执行 `--set-init`参数，该参数将按照`init_map`把对应文件复制到`.workflows`文件夹下作为真正的默认文件

	Command : `cflow --set-init`

	```bash
	==> MODULE=NAME_HERE <==
	├── .workflows
	│   ├── MODULE.cfg
	│   ├── Makefile
	│   ├── csrc
	│   │   └── marco.h
	│   └── vsrc
	│       └── TEMPLATE.v
	├── MODULE.cfg
	├── Makefile
	├── csrc
	│   └── marco.h
	└── vsrc
	    └── TEMPLATE.v
	```

3. **cflow A/B 基础切换工作流功能**

	这是cflow的基础功能，用于快速在不同的工作流之间切换

	比如初始化如下两个工作流`A_v0`和`B`；首先设置工作流A_v0的文件:

	Set `MODULE=A_v0`

	Touch `csrc/A_v0.cpp` and `vsrc/A_v0.v`

	```bash
	==> MODULE=A_v0 <==
	├── .workflows
	│   ├── MODULE.cfg
	│   ├── Makefile
	│   ├── csrc
	│   └── vsrc
	├── MODULE.cfg
	├── Makefile
	├── csrc
	│   ├── A_v0.cpp
	│   └── marco.h
	└── vsrc
	    └── A_v0.v
	```

	现在我需要一个新工作流`B`，可以直接输入如下指令进行切换：

	Command : `cflow B`

	可以看到`A_v0`工作流被存储了起来，由于存储中并没有`B`，这里使用默认文件进行创建了

	```bash
	==> MODULE=B <==
	├── .workflows
	│   ├── MODULE.cfg
	│   ├── Makefile
	│   ├── csrc
	│   │   └── marco.h
	│   ├── vsrc
	│   │   └── TEMPLATE.v
	│   └── wf_A_v0
	│       ├── MODULE.cfg
	│       ├── csrc
	│       │   ├── A_v0.cpp
	│       │   └── marco.h
	│       └── vsrc
	│           └── A_v0.v
	├── MODULE.cfg
	├── Makefile
	├── csrc
	│   └── marco.h
	└── vsrc
	    └── TEMPLATE.v
	```

	在工作流`B`中，修改/增加了不少文件，同时不要忘记修改模块名称：

	Set `MODULE=B`

	Touch `csrc/B.cpp` 、`csrc/Just_for_fun.h` and `vsrc/B.v`

	现在的目录结构如下：

	```bash
	==> MODULE=B <==
	├── .workflows
	│   ├── MODULE.cfg
	│   ├── Makefile
	│   ├── csrc
	│   ├── vsrc
	│   └── wf_A_v0
	├── MODULE.cfg
	├── Makefile
	├── csrc
	│   ├── B.cpp
	│   ├── Just_for_fun.cpp
	│   └── marco.h
	└── vsrc
	    ├── B.v
	    └── TEMPLATE.v
	```

	如果我需要切换回`A_v0`工作流，可以直接输入如下指令进行切换：

	Command : `cflow A`

	可以看到`B`工作流被存储，`A_v0`工作流被恢复

	```bash
	==> MODULE=A <==
	├── .workflows
	│   ├── MODULE.cfg
	│   ├── Makefile
	│   ├── csrc
	│   │   └── marco.h
	│   ├── vsrc
	│   │   └── TEMPLATE.v
	│   ├── wf_A_v0
	│   │   ├── MODULE.cfg
	│   │   ├── csrc
	│   │   │   ├── A_v0.cpp
	│   │   │   └── marco.h
	│   │   └── vsrc
	│   │       └── A_v0.v
	│   └── wf_B
	│       ├── MODULE.cfg
	│       ├── csrc
	│       │   ├── B.cpp
	│       │   ├── Just_for_fun.cpp
	│       │   └── marco.h
	│       └── vsrc
	│           ├── B.v
	│           └── TEMPLATE.v
	├── MODULE.cfg
	├── Makefile
	├── csrc
	│   └── marco.h
	└── vsrc
	    └── TEMPLATE.v
	```

4. **cflow -l / --list 交互式列出所有历史工作流**

	如果你有很多工作流，可以用`-l`参数列出所有历史工作流，并直接用序号选择目标工作流

	Command : `cflow -l`

	```bash
	Sorted by time, you can choose one as target:
	1) top                  6) alu32b             11) mux41b
	2) Map_Scan2ASCII_NV    7) testseg            12) adder
	3) LSFR_seg             8) decode24           13) top
	#? 3
	Change to: LSFR_seg
	```

5. **cflow -q / --quick 快速切换到最近工作流**

	如果你需要反复在最近两个工作流之间来回切换，可以使用`-q`参数，这里我们又从`B`快速切回来`A_v0`工作流

	Command : `cflow -q`

	```bash
	==> MODULE=B <==
	├── .workflows
	│   ├── MODULE.cfg
	│   ├── Makefile
	│   ├── csrc
	│   ├── vsrc
	│   └── wf_A_v0
	├── MODULE.cfg
	├── Makefile
	├── csrc
	│   ├── B.cpp
	│   ├── Just_for_fun.cpp
	│   └── marco.h
	└── vsrc
	    ├── B.v
	    └── TEMPLATE.v
	```

6. **cflow --clone 克隆当前工作流**

	如果你需要克隆当前工作流(相当于git创建新分支)，那么仅仅需要--clone参数即可

	Command : `cflow --clone`

	你可以看到`wf_B`中的文件和当前的完全相同，但是请注意，此时我们还没修改MODULE=B，意味着有同名情况

	```bash
	==> MODULE=B <==
	├── .workflows
	│   ├── MODULE.cfg
	│   ├── Makefile
	│   ├── csrc
	│   │   └── marco.h
	│   ├── vsrc
	│   │   └── TEMPLATE.v
	│   ├── wf_A_v0
	│   │   ├── MODULE.cfg
	│   │   ├── csrc
	│   │   │   ├── A_v0.cpp
	│   │   │   └── marco.h
	│   │   └── vsrc
	│   │       └── A_v0.v
	│   └── wf_B
	│       ├── MODULE.cfg
	│       ├── csrc
	│       │   ├── B.cpp
	│       │   ├── Just_for_fun.cpp
	│       │   └── marco.h
	│       └── vsrc
	│           ├── B.v
	│           └── TEMPLATE.v
	├── MODULE.cfg
	├── Makefile
	├── csrc
	│   ├── B.cpp
	│   ├── Just_for_fun.cpp
	│   └── marco.h
	└── vsrc
	    ├── B.v
	    └── TEMPLATE.v
	```

7. **测试A: 完全同名覆盖问题**

	不修改当前的MODULE.cfg，如果直接cflow B，会发生同名覆盖问题；你会看到报错，但cflow什么也不会做，你不用担心文件丢失

	Command : `cflow B`

	```bash
	[ERROR] Current workflow Target workflow are the same name.
	```

8. **测试B: 可选覆盖问题**

	从刚才可知，自己切换到自己非常愚蠢，不被允许；可是在.workflows/wf_B同名的情况下，切换到`A_v0`，按照逻辑，为了保存当前工作流，会使得.workflows/wf_B被覆盖造成文件丢失吗？

	为了更加直观，进行一些修改，并尝试切换到`A_v0`：

	Touch `csrc/B_over.cpp` and `vsrc/B_over.v`

	```bash
	==> MODULE=B <==
	├── .workflows
	│   ├── MODULE.cfg
	│   ├── Makefile
	│   ├── csrc
	│   │   └── marco.h
	│   ├── vsrc
	│   │   └── TEMPLATE.v
	│   ├── wf_A_v0
	│   │   ├── MODULE.cfg
	│   │   ├── csrc
	│   │   │   ├── A_v0.cpp
	│   │   │   └── marco.h
	│   │   └── vsrc
	│   │       └── A_v0.v
	│   └── wf_B
	│       ├── MODULE.cfg
	│       ├── csrc
	│       │   ├── B.cpp
	│       │   ├── Just_for_fun.cpp
	│       │   └── marco.h
	│       └── vsrc
	│           ├── B.v
	│           └── TEMPLATE.v
	├── MODULE.cfg
	├── Makefile
	├── csrc
	│   └── B_over.cpp
	└── vsrc
	    └── B_over.v
	```

	Command : `cflow A_v0`

	弹出了警告，询问你是否需要覆盖.workflows/wf_B；如果选择y，就能看到.workflows/wf_B已经被覆盖了，同时工作流`A_v0`被恢复

	```bash
	[WARNING] The target workflow B already exists!
	==INPUT==Do you want to overwrite it? (yes/no) [y/n] default: y
	yes
	```

	```bash
	==> MODULE=A_v0 <==
	├── .workflows
	│   ├── MODULE.cfg
	│   ├── Makefile
	│   ├── csrc
	│   │   └── marco.h
	│   ├── vsrc
	│   │   └── TEMPLATE.v
	│   └── wf_B
	│       ├── MODULE.cfg
	│       ├── csrc
	│       │   └── B_over.cpp
	│       └── vsrc
	│           └── B_over.v
	├── MODULE.cfg
	├── Makefile
	├── csrc
	│   ├── A_v0.cpp
	│   └── marco.h
	└── vsrc
	    └── A_v0.v
	```

9. **cflow -c B_over -t A_v0 区分 工作流名称 && MODULE=xxx**

	其实你有另外的办法让两个B共存，现在我可以告诉你————__**工作流名称 和 MODULE=xxx 实际上毫不相干**__

	只是为了方便，我让绝大多数时候工作流名称都直接等于`MODULE.cfg`其中定义的`MODULE=xxx`；于是你可以用其他命令行参数设置工作流名称

	```bash
	$ cflow A_v0 B_over # 基于位置：第一个默认是目标工作流名称，第二个是当前工作流名称 
	$ cflow -c B_over -t A_v0 # 基于命令行参数 
	$ cflow --cur B_over --target A_v0 # 基于命令行参数
	```

	这里快速用A_v0来克隆并进行测试，并尝试把`B`工作流切换出来:

	Command : `cflow --clone`

	Command : `cflow -c A_over -t B`

	```bash
	==> MODULE=B <==
	├── .workflows
	│   ├── MODULE.cfg
	│   ├── Makefile
	│   ├── csrc
	│   │   └── marco.h
	│   ├── vsrc
	│   │   └── TEMPLATE.v
	│   ├── wf_A_over
	│   │   ├── MODULE.cfg
	│   │   ├── csrc
	│   │   │   ├── A_v0.cpp
	│   │   │   └── marco.h
	│   │   └── vsrc
	│   │       └── A_v0.v
	│   └── wf_A_v0
	│       ├── MODULE.cfg
	│       ├── csrc
	│       │   ├── A_v0.cpp
	│       │   └── marco.h
	│       └── vsrc
	│           └── A_v0.v
	├── MODULE.cfg
	├── Makefile
	├── csrc
	│   └── B_over.cpp
	└── vsrc
	    └── B_over.v
	```

	可以看到两个有着完全相同MODULE的工作流同时存储了，用cat可以查看

	```bash
	$ cat .workflows/wf_A_v0/MODULE.cfg | head -n 1
	MODULE=A_v0
	$ cat .workflows/wf_A_over/MODULE.cfg | head -n 1
	MODULE=A_v0
	```

10. **cflow --delete <可选> 删除工作流**

	如果你需要删除`A_over`工作流的一切，可以--delete参数

	Command : `cflow --delete A_over`

	可以看到`wf_A_over`已经消失了

	```bash
	==> MODULE=B <==
	├── .workflows
	│   ├── MODULE.cfg
	│   ├── Makefile
	│   ├── csrc
	│   ├── vsrc
	│   └── wf_A_v0
	├── MODULE.cfg
	├── Makefile
	├── csrc
	│   └── B_over.cpp
	└── vsrc
	    └── B_over.v
	```

	如果你需要删除当前工作流的一切，可以：

	Command : `cflow --delete`

	可以看到当前目录里按照`workflow_map`映射的文件/文件夹已经消失了

	```bash
	NO_CURRENT_MODULE
	├── .workflows
	│   ├── MODULE.cfg
	│   ├── Makefile
	│   ├── csrc
	│   ├── vsrc
	│   └── wf_A_v0
	└── Makefile
	```

11. **cflow -r / --restore <可选模糊匹配> 恢复备份**

	在之前的所有高危险操作中，包括删除/覆盖/移动等，其实都进行了备份，并被存储为.tar.gz文件，位于backup文件夹下

	```bash
	NO_CURRENT_MODULE
	├── .workflows
	│   ├── MODULE.cfg
	│   ├── Makefile
	│   ├── backup
	│   │   ├── 20240905065226.wf_A_v0.tar.gz
	│   │   ├── 20240905065226.wf_B.tar.gz
	│   │   ├── 20240905065226.wf_B_clone.tar.gz
	│   │   ├── 20240905065227.wf_A_v0_clone.tar.gz
	│   │   ├── 20240905065227.wf_B.tar.gz
	│   │   ├── 20240905065227.wf_DELETE_A_over.tar.gz
	│   │   └── 20240905065227.wf_DELETE_B.tar.gz
	│   ├── csrc
	│   │   └── marco.h
	│   ├── vsrc
	│   │   └── TEMPLATE.v
	│   └── wf_A_v0
	│       ├── MODULE.cfg
	│       ├── csrc
	│       │   ├── A_v0.cpp
	│       │   └── marco.h
	│       └── vsrc
	│           └── A_v0.v
	└── Makefile
	```

	如果你需要恢复，可以使用`-r`参数交互选择，并可能看到如下列表

	Command : `cflow -r`

	```bash
	Backups, sorted by time: 
	1) 2024/09/05 05:34:26 B 
	2) 2024/09/05 05:34:26 B_clone 
	3) 2024/09/05 05:34:27 A_v0 
	4) 2024/09/05 05:34:27 A_v0_clone 
	5) 2024/09/05 05:34:27 B 
	6) 2024/09/05 05:34:27 DELETE_A_over 
	7) 2024/09/05 05:34:27 DELETE_B 
	#? Selected: 20240905053426.wf_B.tar.gz    Restore to: B_00 <==INACCURATE 
	Due to the current MODULE, the 00 might be added one to avoid conflict.
	```

	如果你需要恢复，也可以使用`-r B`限定模糊匹配只与B相关的，并可能看到如下列表

	Command : `cflow -r B`

	 Backups for module 'B', sorted by time: 
1) 2024/09/05 05:44:32 B 
2) 2024/09/05 05:44:32 B_clone 
3) 2024/09/05 05:44:33 B 
4) 2024/09/05 05:44:33 DELETE_B 
#? Selected: 20240905054432.wf_B.tar.gz    Restore to: B_00 <==INACCURATE 
Due to the current MODULE, the 00 might be added one to avoid conflict.  

	这里直接选择恢复工作流`B`，然后被删除的工作流就又回来了

	```bash
	==> MODULE=B <==
	├── .workflows
	│   ├── MODULE.cfg
	│   ├── Makefile
	│   ├── backup
	│   │   ├── 20240905065226.wf_A_v0.tar.gz
	│   │   ├── 20240905065226.wf_B.tar.gz
	│   │   ├── 20240905065226.wf_B_clone.tar.gz
	│   │   ├── 20240905065227.wf_A_v0_clone.tar.gz
	│   │   ├── 20240905065227.wf_B.tar.gz
	│   │   ├── 20240905065227.wf_B_00.tar.gz
	│   │   ├── 20240905065227.wf_DELETE_A_over.tar.gz
	│   │   └── 20240905065227.wf_DELETE_B.tar.gz
	│   ├── csrc
	│   │   └── marco.h
	│   ├── vsrc
	│   │   └── TEMPLATE.v
	│   └── wf_A_v0
	│       ├── MODULE.cfg
	│       ├── csrc
	│       │   ├── A_v0.cpp
	│       │   └── marco.h
	│       └── vsrc
	│           └── A_v0.v
	├── MODULE.cfg
	├── Makefile
	├── csrc
	│   ├── B.cpp
	│   ├── Just_for_fun.cpp
	│   └── marco.h
	└── vsrc
	    ├── B.v
	    └── TEMPLATE.v
	```

12. **cflow -s / --save 仅保存备份不切换目录**

	该命令可以看作是`cflow --clone`的新版本，但是区别是`--save`不会占用.workflows文件夹，而是直接打包成.tar.gz在`backup`文件夹中

	Command : `cflow -s`

	可以看到现在有两个时间戳的`B`，最新的那个是刚刚保存的

	```bash
	==> MODULE=B <==
	├── .workflows
	│   ├── MODULE.cfg
	│   ├── Makefile
	│   ├── backup
	│   │   ├── 20240905065226.wf_A_v0.tar.gz
	│   │   ├── 20240905065226.wf_B.tar.gz
	│   │   ├── 20240905065226.wf_B_clone.tar.gz
	│   │   ├── 20240905065227.wf_A_v0_clone.tar.gz
	│   │   ├── 20240905065227.wf_B.tar.gz
	│   │   ├── 20240905065227.wf_B_00.tar.gz
	│   │   ├── 20240905065227.wf_DELETE_A_over.tar.gz
	│   │   └── 20240905065227.wf_DELETE_B.tar.gz
	│   ├── csrc
	│   │   └── marco.h
	│   ├── vsrc
	│   │   └── TEMPLATE.v
	│   └── wf_A_v0
	│       ├── MODULE.cfg
	│       ├── csrc
	│       │   ├── A_v0.cpp
	│       │   └── marco.h
	│       └── vsrc
	│           └── A_v0.v
	├── MODULE.cfg
	├── Makefile
	├── csrc
	│   ├── B.cpp
	│   ├── Just_for_fun.cpp
	│   └── marco.h
	└── vsrc
	    ├── B.v
	    └── TEMPLATE.v
	```

13. **cflow --clean-backup 删除备份目录**

	__**警告：删除备份目录意味着再也无法恢复，这也是作为最后一个介绍的参数的原因**__

	可能后面的版本会使用时间戳过滤删除较为久远的备份，不过现在只能一次性删除

## 其他说明

除了上述用法之外，提供了一些额外的功能，方便上传/配置/整理等操作，其中有`[zmr233]`标记则表明不应该去动它

- `--test` 生成并进行交互性测试
- `--gen-readme` 生成README.md(标准输出)
- [zmr233]`--gen-regfile` 生成regfiles配置文件(读取libbash的DOTFILES_CONFIG_MASTER_HOME变量)
- [zmr233]`--gen-git` 生成git提交的脚本(直接git push到Github)
- [zmr233]`--gen-update` 实际上是--gen-regfile和--gen-git的合并命令

## 许可证

本项目采用 MIT 许可证。详情请见 [LICENSE](LICENSE) 文件。

