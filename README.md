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
[0;33m[DEBUG] ==================测试开始==================[0m
[0;33m[DEBUG] =======cflow --init初始化.workflows=======[0m
[INFO] Initializing .workflows folder...
[INFO] Modify the files and MODULE.cfg you want to contain in default workflow.
[INFO] After that, use 'cflow --set-init' to set default workflow.
[0;33m[DEBUG] =======cflow --set-init 设定默认工作流=======[0m
[INFO] Setting current workflow as default...
[INFO] Setting current workflow as default...(Use current init_map)
[INFO] File ././Makefile has been copied to .workflows/./Makefile
[INFO] File ./vsrc has been copied to .workflows/vsrc
[INFO] File ./csrc has been copied to .workflows/csrc
[0;33m[DEBUG] =======cflow A/B 基础切换工作流功能=======[0m
[DEBUG] change_workflow A_v0 B 
[INFO] ===== Check weather save =====
[INFO] Using MODULE.cfg workflow configuration file.
[INFO] ===== Saving to .workflows/wf_A_v0 =====
[INFO] ././MODULE.cfg has been moved and overwritten at .workflows/wf_A_v0/./MODULE.cfg
[INFO] ./vsrc has been moved and overwritten at .workflows/wf_A_v0/vsrc
[INFO] ./csrc has been moved and overwritten at .workflows/wf_A_v0/csrc
[INFO] ===== Initializing to B =====
[INFO] File .workflows/./Makefile has been copied to ././Makefile
[INFO] File .workflows/vsrc has been copied to ./vsrc
[INFO] File .workflows/csrc has been copied to ./csrc
[DEBUG] change_workflow B A 
[INFO] ===== Check weather save =====
[INFO] Using MODULE.cfg workflow configuration file.
[INFO] ===== Saving to .workflows/wf_B =====
[INFO] ././MODULE.cfg has been moved and overwritten at .workflows/wf_B/./MODULE.cfg
[INFO] ./vsrc has been moved and overwritten at .workflows/wf_B/vsrc
[INFO] ./csrc has been moved and overwritten at .workflows/wf_B/csrc
[INFO] ===== Initializing to A =====
[INFO] File .workflows/./Makefile has been copied to ././Makefile
[INFO] File .workflows/vsrc has been copied to ./vsrc
[INFO] File .workflows/csrc has been copied to ./csrc
[0;33m[DEBUG] =======cflow -l / --list 交互式列出所有历史工作流=======[0m
[0;33m[DEBUG] =======cflow -q / --quick 快速切换到最近工作流=======[0m
[INFO] Quickly switch to the last workflow...
[DEBUG] quick_workflow A  
Change to: B
[INFO] ===== Check weather save =====
[INFO] Using MODULE.cfg workflow configuration file.
[INFO] ... Do not need to save ...
[INFO] ===== Removing .workflows/wf_A =====
[INFO] Original ././MODULE.cfg has been removed.
[INFO] Original ./vsrc has been removed.
[INFO] Original ./csrc has been removed.
[INFO] ===== Switching to B =====
[INFO] Tar backup created as /tmp/CHANGEFLOW_pDjiuB/.workflows/backup/20240905065527.wf_B.tar.gz
[INFO] Using .workflows/wf_B/MODULE.cfg workflow configuration file.
[INFO] .workflows/wf_B/./MODULE.cfg has been moved and overwritten at ././MODULE.cfg
[INFO] .workflows/wf_B/vsrc has been moved and overwritten at ./vsrc
[INFO] .workflows/wf_B/csrc has been moved and overwritten at ./csrc
[0;33m[DEBUG] =======cflow --clone 克隆当前工作流=======[0m
[INFO] Cloning the current workflow...
[DEBUG] clone_workflow B  
[INFO] ===== Check weather save =====
[INFO] Using MODULE.cfg workflow configuration file.
[INFO] ===== Saving to .workflows/wf_B =====
[INFO] ././MODULE.cfg has been moved and overwritten at .workflows/wf_B/./MODULE.cfg
[INFO] ./vsrc has been moved and overwritten at .workflows/wf_B/vsrc
[INFO] ./csrc has been moved and overwritten at .workflows/wf_B/csrc
[INFO] ===== Switching to B_clone =====
[INFO] Tar backup created as /tmp/CHANGEFLOW_pDjiuB/.workflows/backup/20240905065527.wf_B_clone.tar.gz
[INFO] Using .workflows/wf_B_clone/MODULE.cfg workflow configuration file.
[INFO] .workflows/wf_B_clone/./MODULE.cfg has been moved and overwritten at ././MODULE.cfg
[INFO] .workflows/wf_B_clone/vsrc has been moved and overwritten at ./vsrc
[INFO] .workflows/wf_B_clone/csrc has been moved and overwritten at ./csrc
[0;33m[DEBUG] =======测试A: 完全同名覆盖问题=======[0m
[DEBUG] change_workflow B B 
[ERROR] Current workflow Target workflow are the same name.
[ERROR] change_workflow B B  =====FAILED=====
[0;33m[DEBUG] =======测试B: 可选覆盖问题=======[0m
[DEBUG] change_workflow B A_v0 
[INFO] ===== Check weather save =====
[INFO] Using MODULE.cfg workflow configuration file.
[WARNING] The target workflow B already exists!
==INPUT==Do you want to overwrite it? (yes/no) [y/n] default: y
[INFO] Tar backup created as /tmp/CHANGEFLOW_pDjiuB/.workflows/backup/20240905065527.wf_B.tar.gz
[INFO] ===== Saving to .workflows/wf_B =====
[INFO] ././MODULE.cfg has been moved and overwritten at .workflows/wf_B/./MODULE.cfg
[INFO] ./vsrc has been moved and overwritten at .workflows/wf_B/vsrc
[INFO] ./csrc has been moved and overwritten at .workflows/wf_B/csrc
[INFO] ===== Switching to A_v0 =====
[INFO] Tar backup created as /tmp/CHANGEFLOW_pDjiuB/.workflows/backup/20240905065527.wf_A_v0.tar.gz
[INFO] Using .workflows/wf_A_v0/MODULE.cfg workflow configuration file.
[INFO] .workflows/wf_A_v0/./MODULE.cfg has been moved and overwritten at ././MODULE.cfg
[INFO] .workflows/wf_A_v0/vsrc has been moved and overwritten at ./vsrc
[INFO] .workflows/wf_A_v0/csrc has been moved and overwritten at ./csrc
[0;33m[DEBUG] =======cflow -c B_over -t A_v0 区分 工作流名称 && MODULE=xxx=======[0m
[INFO] Cloning the current workflow...
[DEBUG] clone_workflow A_v0  
[INFO] ===== Check weather save =====
[INFO] Using MODULE.cfg workflow configuration file.
[INFO] ===== Saving to .workflows/wf_A_v0 =====
[INFO] ././MODULE.cfg has been moved and overwritten at .workflows/wf_A_v0/./MODULE.cfg
[INFO] ./vsrc has been moved and overwritten at .workflows/wf_A_v0/vsrc
[INFO] ./csrc has been moved and overwritten at .workflows/wf_A_v0/csrc
[INFO] ===== Switching to A_v0_clone =====
[INFO] Tar backup created as /tmp/CHANGEFLOW_pDjiuB/.workflows/backup/20240905065527.wf_A_v0_clone.tar.gz
[INFO] Using .workflows/wf_A_v0_clone/MODULE.cfg workflow configuration file.
[INFO] .workflows/wf_A_v0_clone/./MODULE.cfg has been moved and overwritten at ././MODULE.cfg
[INFO] .workflows/wf_A_v0_clone/vsrc has been moved and overwritten at ./vsrc
[INFO] .workflows/wf_A_v0_clone/csrc has been moved and overwritten at ./csrc
[DEBUG] change_workflow A_over B 
[INFO] ===== Check weather save =====
[INFO] Using MODULE.cfg workflow configuration file.
[INFO] ===== Saving to .workflows/wf_A_over =====
[INFO] ././MODULE.cfg has been moved and overwritten at .workflows/wf_A_over/./MODULE.cfg
[INFO] ./vsrc has been moved and overwritten at .workflows/wf_A_over/vsrc
[INFO] ./csrc has been moved and overwritten at .workflows/wf_A_over/csrc
[INFO] ===== Switching to B =====
[INFO] Tar backup created as /tmp/CHANGEFLOW_pDjiuB/.workflows/backup/20240905065527.wf_B.tar.gz
[INFO] Using .workflows/wf_B/MODULE.cfg workflow configuration file.
[INFO] .workflows/wf_B/./MODULE.cfg has been moved and overwritten at ././MODULE.cfg
[INFO] .workflows/wf_B/vsrc has been moved and overwritten at ./vsrc
[INFO] .workflows/wf_B/csrc has been moved and overwritten at ./csrc
[0;33m[DEBUG] =======cflow --delete <可选> 删除工作流=======[0m
[INFO] Deleting the workflow...
[DEBUG] delete_workflow B A_over 
[INFO] Tar backup created as /tmp/CHANGEFLOW_pDjiuB/.workflows/backup/20240905065527.wf_DELETE_A_over.tar.gz
[INFO] Deleting the workflow...
[DEBUG] delete_workflow B  
[INFO] ===== Check weather save =====
[INFO] Using MODULE.cfg workflow configuration file.
[INFO] ===== Saving to .workflows/wf_DELETE_B =====
[INFO] ././MODULE.cfg has been moved and overwritten at .workflows/wf_DELETE_B/./MODULE.cfg
[INFO] ./vsrc has been moved and overwritten at .workflows/wf_DELETE_B/vsrc
[INFO] ./csrc has been moved and overwritten at .workflows/wf_DELETE_B/csrc
[INFO] Tar backup created as /tmp/CHANGEFLOW_pDjiuB/.workflows/backup/20240905065528.wf_DELETE_B.tar.gz
[0;33m[DEBUG] =======cflow -r / --restore <可选模糊匹配> 恢复备份=======[0m
[INFO] Restoring the backup...
Backups for module 'B', sorted by time:
Selected: 20240905065527.wf_B.tar.gz    Restore to: B_00 <==INACCURATE
Due to the current MODULE, the 00 might be added one to avoid conflict.

[DEBUG] restore_workflow  B 20240905065527.wf_B.tar.gz
[WARNING] No current workflow name provided.Is it truly empty?
==INPUT==Still to save [y/n] default: y
[INFO] ===== Switching to B_00 =====
[INFO] Tar backup created as /tmp/CHANGEFLOW_pDjiuB/.workflows/backup/20240905065528.wf_B_00.tar.gz
[INFO] Using .workflows/wf_B_00/MODULE.cfg workflow configuration file.
[INFO] .workflows/wf_B_00/./MODULE.cfg has been moved and overwritten at ././MODULE.cfg
[INFO] .workflows/wf_B_00/vsrc has been moved and overwritten at ./vsrc
[INFO] .workflows/wf_B_00/csrc has been moved and overwritten at ./csrc
[0;33m[DEBUG] =======cflow -s / --save 仅保存备份不切换目录=======[0m
[INFO] Saving the current workflow...
[DEBUG] save_workflow B  
[INFO] ===== Check weather save =====
[INFO] Using MODULE.cfg workflow configuration file.
[INFO] ===== Saving to .workflows/wf_B =====
[INFO] ././MODULE.cfg has been moved and overwritten at .workflows/wf_B/./MODULE.cfg
[INFO] ./vsrc has been moved and overwritten at .workflows/wf_B/vsrc
[INFO] ./csrc has been moved and overwritten at .workflows/wf_B/csrc
[INFO] ===== Switching to B =====
[INFO] Tar backup created as /tmp/CHANGEFLOW_pDjiuB/.workflows/backup/20240905065528.wf_B.tar.gz
[INFO] Using .workflows/wf_B/MODULE.cfg workflow configuration file.
[INFO] .workflows/wf_B/./MODULE.cfg has been moved and overwritten at ././MODULE.cfg
[INFO] .workflows/wf_B/vsrc has been moved and overwritten at ./vsrc
[INFO] .workflows/wf_B/csrc has been moved and overwritten at ./csrc
[0;33m[DEBUG] =======cflow --clean-backup 删除备份目录=======[0m
[1;32m[SUCCESS] ==================测试结束==================[0m

## 其他说明

除了上述用法之外，提供了一些额外的功能，方便上传/配置/整理等操作，其中有`[zmr233]`标记则表明不应该去动它

- `--test` 生成并进行交互性测试
- `--gen-readme` 生成README.md(标准输出)
- [zmr233]`--gen-regfile` 生成regfiles配置文件(读取libbash的DOTFILES_CONFIG_MASTER_HOME变量)
- [zmr233]`--gen-git` 生成git提交的脚本(直接git push到Github)
- [zmr233]`--gen-update` 实际上是--gen-regfile和--gen-git的合并命令

## 许可证

本项目采用 MIT 许可证。详情请见 [LICENSE](LICENSE) 文件。

