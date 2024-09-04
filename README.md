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

## 其他说明

除了上述用法之外，提供了一些额外的功能，方便上传/配置/整理等操作，其中有`[zmr233]`标记则表明不应该去动它

- `--test` 生成并进行交互性测试
- `--gen-readme` 生成README.md(标准输出)
- [zmr233]`--gen-regfile` 生成regfiles配置文件(读取libbash的DOTFILES_CONFIG_MASTER_HOME变量)
- [zmr233]`--gen-git` 生成git提交的脚本(直接git push到Github)
- [zmr233]`--gen-update` 实际上是--gen-regfile和--gen-git的合并命令

## 许可证

本项目采用 MIT 许可证。详情请见 [LICENSE](LICENSE) 文件。

