
# changeflow 使用说明

changeflow | cflow 是一个用于轻松切换和管理工作流的脚本工具，它介于手动管理和 git 管理之间，提供了一种轻量化的解决方案。

## 命令行选项

- `-h|--help|-h=zh|--help=zh`   **显示帮助信息**
- `--readme `                   **显示极为详细的使用说明(可以重定向到README.md)**
- `-l, --list`                  **列出所有历史工作流(以及当前MODULE名称)**
- `--clean`                     **清除所有备份($WF/backup)**
- `--makeup`                    **实际控制OPTIONAL_MAKEUP变量**
    - `yes`     使用默认
    - `no`      不备份(仅适用于切换旧工作流时不备份)
    - `tar`     打包备份(默认)
    - `folder`  不打包备份
- `-c xxx |--cur xxx`           **设置当前工作流名称xxx(默认用MODULE)**
- `-t xxx |--target xxx`        **切换到目标工作流xxx**


## 使用步骤

1. **准备 MODULE.cfg 文件**：首先，需要创建一个 `MODULE.cfg` 文件来定义工作流的结构。

   示例 `MODULE.cfg` 文件内容：
   ```shell
   MODULE=top

   declare -A workflow_map=(
       ["."]="MODULE.cfg"
       ["csrc"]="*"
       ["vsrc"]="*"
   )

   declare -A init_map=(
       ["csrc"]="*"
       ["vsrc"]="*"
   )
   ```

2. **初始工作流状态**：假设你的项目目录已经按照 `MODULE.cfg` 中的定义进行了初始化，目录结构可能如下所示：
   ```
   MODULE=top
   ├── .workflows
   │   ├── csrc
   │   │   └── marco.h
   │   └── vsrc
   │       └── TEMPLATE.v
   ├── MODULE.cfg
   ├── csrc
   │   ├── main.cpp
   │   ├── marco.h
   │   ├── top.cpp
   │   └── utils.cpp
   ├── changeflow.sh
   └── vsrc
       ├── TEMPLATE.v
       └── top.v
   ```

3. **创建新工作流**：若要创建一个名为 `add` 的新工作流，可使用以下命令之一：
   ```shell
   changeflow add
   changeflow add top
   changeflow -c top -t add
   ```
   创建后，目录结构更新如下：
   ```
   MODULE=add
   ├── .workflows
   │   ├── csrc
   │   │   └── marco.h
   │   ├── vsrc
   │   │   └── TEMPLATE.v
   │   └── wf_top
   │       ├── MODULE.cfg
   │       ├── csrc
   │       │   ├── main.cpp
   │       │   ├── marco.h
   │       │   ├── top.cpp
   │       │   └── utils.cpp
   │       └── vsrc
   │           ├── TEMPLATE.v
   │           └── top.v
   ├── MODULE.cfg
   ├── csrc
   │   ├── adder.cpp
   │   └── marco.h
   ├── changeflow.sh
   └── vsrc
       └── add.v
   ```

4. **切换回之前的工作流**：要切换回 `top` 工作流，可以使用以下命令之一：
   ```shell
   changeflow top
   changeflow top add
   changeflow -c add -t top
   ```
   切换回后，目录结构如下：
   ```
   MODULE=top
   ├── .workflows
   │   ├── backup
   │   │   └── 20240828165616.wf_top.tar.gz
   │   ├── csrc
   │   │   └── marco.h
   │   ├── vsrc
   │   │   └── TEMPLATE.v
   │   └── wf_add
   │       ├── MODULE.cfg
   │       ├── csrc
   │       │   ├── adder.cpp
   │       │   └── marco.h
   │       └── vsrc
   │           └── add.v
   ├── MODULE.cfg
   ├── csrc
   │   ├── main.cpp
   │   ├── marco.h
   │   ├── top.cpp
   │   └── utils.cpp
   ├── changeflow.sh
   └── vsrc
       ├── TEMPLATE.v
       └── top.v
   ```

## 其他说明

- **无修改时不备份**：如果在新创建的工作流中没有进行任何修改，切换或创建下一个工作流时，脚本不会进行备份操作。
- **强制备份**：即使设置了 `--makeup no` 参数，遇到冲突操作时，脚本仍会进行强制备份，以避免数据丢失。
- **删除工作流**：出于安全考虑，脚本不支持直接删除工作流的操作。如果需要删除某个工作流，需要手动进行。


