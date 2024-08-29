#!/bin/bash

#====   Colorized variables  ====
if [[ -t 1 ]]; then # is terminal?
  BOLD="\e[1m";      DIM="\e[2m";
  RED="\e[0;31m";    RED_BOLD="\e[1;31m";
  YELLOW="\e[0;33m"; YELLOW_BOLD="\e[1;33m";
  GREEN="\e[0;32m";  GREEN_BOLD="\e[1;32m";
  BLUE="\e[0;34m";   BLUE_BOLD="\e[1;34m";
  GREY="\e[37m";     CYAN_BOLD="\e[1;36m";
  RESET="\e[0m";
fi

#====   Colorized functions  ====

nECHO(){ echo -n -e "${!1}${2}${RESET}"; }
ECHO() { echo -e "${!1}${2}${RESET}"; }
INFO(){ echo -e "${GREEN_BOLD}[INFO] ${1}${RESET}"; }
WARN() { echo -e "${YELLOW_BOLD}[WARNING] ${1}${RESET}"; }
ERROR() { echo -e "${RED_BOLD}[ERROR] ${1}${RESET}"; }
SUCCESS() { echo -e "${GREEN_BOLD}[SUCCESS] ${1}${RESET}"; }
NOTE() { echo -e "${BLUE_BOLD}[NOTE] ${1}${RESET}"; }
INPUT() { echo -e "${CYAN_BOLD}==INPUT==${1}${RESET}"; }
ABORT(){ echo -e "${RED_BOLD}[ABORT] ${1}${RESET}"; }
DEBUG(){ echo -e "${YELLOW}[DEBUG] ${1}${RESET}"; }

# 命令检查
checkCmd(){ type $1 > /dev/null 2>&1; }

# 纯配置检查
checkCfg(){
    if [[ -z $ISCONFIG ]];then
        if [[ -e "$1" ]];then
            return 0
        else
            return 1
        fi
    else
        return 0
    fi
}

# 保存和加载数组
saveMap() {
    local -n __map__=$1
    local output=""
    output+="declare -A $1=("$'\n'
    for key in "${!__map__[@]}"; do
        output+="    [\"$key\"]=\"${__map__[$key]}\""$'\n'
    done
    output+=")"$'\n'

    if [ -n "$2" ]; then
        echo "$output" >> "$2"
    else
        echo "$output"
    fi
}
saveArr() {
    local -n array=$1
    local output=""

    output+="declare $3 -a $1=("$'\n'
    for element in "${array[@]}"; do
        output+="\"$element\" "$'\n'
    done
    output+=")"$'\n'

    if [ -n "$2" ]; then
        echo "$output" >> "$2"
    else
        echo "$output"
    fi
}

# 作为if条件
readReturn(){
    local prompt=$1
    local input

    while true; do
        INPUT "$prompt [y/n] default: y"
        read -r input

        if [ -z "$input" ]; then
            return 0
            break
        fi

        case $input in
            [yY][eE][sS]|[yY])
                return 0
                break
                ;;
            [nN][oO]|[nN])
                return 1
                break
                ;;
            *)
                WARN "请输入 yes 或 no"
                ;;
        esac
    done

}

# 读取-yes/no
readBool() {
    local varName=$1
    local prompt=$2
    local input

    while true; do
        INPUT "$prompt [y/n] default: y"
        read -r input

        if [ -z "$input" ]; then
            eval "$varName=\"y\""
            break
        fi

        case $input in
            [yY][eE][sS]|[yY])
                eval "$varName=\"y\""
                break
                ;;
            [nN][oO]|[nN])
                eval "$varName=\"n\""
                break
                ;;
            *)
                WARN "请输入 yes 或 no"
                ;;
        esac
    done
}

# 读取输入-一整行
readLine() {
    local varName=$1
    local prompt=$2
    local input

    INPUT "LINE= $prompt"
    read -r input

    # 使用 eval
    eval "$varName=\"$input\""
    # 使用间接引用
    # printf -v "$varName" '%s' "$input"
}

# 读取输入-数组
readArr() {
    local var_name=$1
    local prompt_message=$2
    local input

    # 使用提供的提示信息来读取输入
    INPUT "ARRAY= $prompt_message"
    read -r input

    # 将输入分割成数组并赋值给指定的变量
    IFS=' ' read -r -a "$var_name" <<< "$input"
}

# 读取输入-无空格
readNoSpace() {
    local varName=$1
    local prompt=$2
    local input

    while true; do
        INPUT "NO_SPACE= $prompt"
        read -r input

        # 检查输入是否包含空格或特殊字符
        if [[ "$input" =~ [[:space:][:punct:]] ]]; then
            WARN "输入不能包含空格或特殊字符，请重新输入。"
        else
            break
        fi
    done

    # 使用 eval 动态设置变量名
    eval "$varName=\"$input\""
}

# 读取输入-多行直到Ctrl+D
readMultiLine() {
    local varName=$1
    local prompt=$2
    local result=""

    INPUT "<Ctrl-D>= $prompt"

    while IFS= read -r line; do
        result="${result}${line}"$'\n'
    done

    # 确保变量内容包含换行符并且未解析任何 $ 符号
    eval "$varName=\"\$result\""
}

# 字符串转数组
strToArr() {
    local var_name=$1
    local input=$2
    # 将输入分割成数组并赋值给指定的变量
    IFS=' ' read -r -a "$var_name" <<< "$input"
}

# 生成唯一文件名
genUniName() {
    local fileName=$1
    local timestamp=$(date +%Y%m%d%H%M)
    echo "${fileName}.${timestamp}"
}

# 检查是否在数组内
inArr() {
    [ $# -eq 0 ] && {
        ERROR "argument error"
        exit 2
    }

    [ $# -eq 1 ] && return 0

    declare -n _arr="$1"
    declare v="$2"
    local elem

    for elem in "${_arr[@]}";do
        [ "$elem" == "$v" ] && return 0
    done

    return 1
}

# 函数：从数组中删除指定元素
delFromArr() {
    [ $# -lt 2 ] || [ $# -gt 3 ] && {
        ERROR "argument error"
        exit 2
    }

    declare -n _arr="$1"
    declare v="$2"
    local tempArray=()

    for elem in "${_arr[@]}"; do
        if [[ "$elem" != "$v" ]]; then
            tempArray+=("$elem")
        fi
    done

    _arr=("${tempArray[@]}")

    # 如果传入了三个参数，则更新关联数组
    if [ $# -eq 3 ]; then
        declare -n _map="$3"
        unset _map["$v"]
        for elem in "${_arr[@]}"; do
            _map["$elem"]=1
        done
    fi
}

# 定义倒计时函数
countDown() {
    local tn=$1
    nECHO "YELLOW" "... "
    while [ $tn -ge 1 ]; do
        nECHO "YELLOW" "${tn} "
        sleep 1
        ((tn--))
    done
    nECHO "YELLOW" "0 ..."
    sleep 1
    echo ""
}

# 比较两个目录差异
diffDir() {
  local dir1="$1"
  local dir2="$2"

  # 当两个目录都不存在时，视为没有差异
  if [[ ! -d "$dir1" ]] && [[ ! -d "$dir2" ]]; then
    # echo "Both directories do not exist - no difference."
    return 0
  fi

  # 当其中一个目录不存在时，视为有差异
  if [[ ! -d "$dir1" ]] || [[ ! -d "$dir2" ]]; then
    # echo "Error: One of the directories does not exist."
    return 1
  fi

  # 包括比较内容
  if diff -rq "$dir1" "$dir2" > /dev/null; then
    # echo "Directories are identical."
    return 0
  else
    # echo "Directories differ."
    return 1
  fi
}

# 比较两个文件差异
diffFile() {
  local file1="$1"
  local file2="$2"

  # 当两个文件都不存在时，视为没有差异
  if [[ ! -f "$file1" ]] && [[ ! -f "$file2" ]]; then
    # echo "Both files do not exist - no difference."
    return 0
  fi

  # 当其中一个文件不存在时，视为有差异
  if [[ ! -f "$file1" ]] || [[ ! -f "$file2" ]]; then
    # echo "Error: One of the files does not exist."
    return 1
  fi

  # 比较文件内容
  if diff -q "$file1" "$file2" > /dev/null; then
    # echo "Files are identical."
    return 0
  else
    # echo "Files differ."
    return 1
  fi
}

# 尚未完成的函数:
# tarSafe()

#==============================Safe系列==============================

# 用来控制是否发生备份的全局变量:
isMakeup=DO_MAKEUP

# Internal function to create a backup of a file or directory
_createBackup() {
    if [[ "$isMakeup" == "NO_MAKEUP" ]]; then
        return 0
    fi
    local source=$1
    local backupDir=$2
    local backupName="$(date +%Y%m%d%H%M%S).$(basename "$source").bak"
    local target="$backupDir/$backupName"

    mkdir -p "$backupDir" || { ERROR "Could not create backup directory: $backupDir"; return 1; }
    cp -r "$source" "$target" || { ERROR "Could not create backup of $source"; return 1; }
    INFO "Backup created as $target"
}

# Internal function to create a tar backup of a file or directory without parent path
_createTarBackup() {
    if [[ "$isMakeup" == "NO_MAKEUP" ]]; then
        return 0
    fi
    local source=$1
    local backupDir=$2
    local sourceBaseName=$(basename "$source")
    local sourceDirName=$(dirname "$source")
    local backupName="$(date +%Y%m%d%H%M%S).$sourceBaseName.tar.gz"

    # Convert backupDir to an absolute path
    mkdir -p "$backupDir" || { ERROR "Could not create backup directory: $backupDir"; return 1; }
    local absBackupDir=$(cd "$backupDir"; pwd)
    local target="$absBackupDir/$backupName"

    # Change to the directory containing the source to avoid including parent paths in the tar archive
    pushd "$sourceDirName" > /dev/null
    # echo "$(pwd) $target $sourceBaseName"
    tar -czf "$target" "./$sourceBaseName" || { ERROR "Could not create tar backup of $source"; popd > /dev/null; return 1; }
    popd > /dev/null
    
    INFO "Tar backup created as $target"
}

# Internal function to check if a source file or directory exists
_checkSourceExists() {
    local source=$1
    if [[ -z "$source" ]] || [[ ! -e "$source" ]]; then
        ERROR "The source does not exist: $source"
        return 1
    fi
    return 0
}

# Internal function to check if a target directory exists
_checkTargetDirExists() {
    local targetDir=$1
    if [[ -z "$targetDir" ]] || [[ ! -d "$targetDir" ]]; then
        [[ "$2" ==  "NO_ECHO" ]] || ERROR "The target directory does not exist: $targetDir"
        return 1
    fi
    return 0
}

# Function to safely copy a file with backup
copySafe() {
    local sourceFile=$1
    local targetDir=$2
    local backupSubdir=${3:-$targetDir/backup}

    _checkSourceExists "$sourceFile" || return 1
    _checkTargetDirExists "$targetDir" "NO_ECHO" || mkdir -p "$targetDir" || return 1

    local targetFile="$targetDir/$(basename "$sourceFile")"

    if [ -f "$targetFile" ]; then
        _createBackup "$targetFile" "$backupSubdir" || return 1
    fi

    cp -r "$sourceFile" "$targetFile" && INFO "File $sourceFile has been copied to $targetFile"
}

# Function to safely move a file or directory with backup
moveSafe() {
    local source=$1
    local targetDir=$2
    local backupSubdir=${3:-$targetDir/backup}

    _checkSourceExists "$source" || return 1
    _checkTargetDirExists "$targetDir" "NO_ECHO" || mkdir -p "$targetDir" || return 1

    local target="$targetDir/$(basename "$source")"

    if [[ -f "$target" ]] || [[ -d "$target" ]]; then
        _createBackup "$target" "$backupSubdir" || return 1
    fi

    mv "$source" "$target" && INFO "$source has been moved and overwritten at $target"
}

# Function to safely remove a file or directory with backup
removeSafe() {
    local source=$1
    local backupDir=${2:-backup}

    _checkSourceExists "$source" || return 1

    _createBackup "$source" "$backupDir" || return 1
    rm -rf "$source" && INFO "Original $source has been removed."
}

# Function to backup a file or directory
saveSafe() {
    local source=$1
    local backupDir=${2:-backup}

    _checkSourceExists "$source" || return 1

    _createBackup "$source" "$backupDir"
}

# Function to safely backup a file or directory as a tar archive
tarSafe() {
    local source=$1
    local backupDir=${2:-backup}

    _checkSourceExists "$source" || return 1

    _createTarBackup "$source" "$backupDir"
}

# ==========主要逻辑==========
if checkCfg "MODULE.cfg";then
    source MODULE.cfg
    export MODULE
else
    ERROR "MODULE.cfg not found! Please create it first."
    ERROR "Use $0 -h to get help."
    ERROR "But I think you need to run $0 --readme to learn how to use it."
    exit 1
fi

WF=.workflows
PREFIX=wf_
mkdir -p $WF

# 用来控制在切换旧工作流的时候是否备份
OPTIONAL_MAKEUP=yes

# 内部函数，用于保存或删除文件/目录
_handle_file_dir() {
    local operation=$1  # 操作类型：save, remove, copy, move
    local map_ref=$2    # 引用workflow_map或init_map
    local src_prefix=$3 # 源路径前缀
    local dest_prefix=$4 # 目标路径前缀
    local backup_dir=$5  # 备份目录

    declare -n map=$map_ref

    for key in "${!map[@]}"; do
        if [[ "${map[$key]}" = "*" ]]; then
            case $operation in
                save|remove)
                    "${operation}Safe" "$dest_prefix/$key" "$backup_dir";;
                copy|move)
                    "${operation}Safe" "$src_prefix/$key" "$dest_prefix/" "$backup_dir";;
            esac
        else
            eval "files=(${map[$key]})"
            for file in "${files[@]}"; do
                case $operation in
                    save|remove)
                        "${operation}Safe" "$dest_prefix/$key/$file" "$backup_dir";;
                    copy|move)
                        "${operation}Safe" "$src_prefix/$key/$file" "$dest_prefix/$key/" "$backup_dir";;
                esac
            done
        fi
    done
}

# 检查目录是否为空
_check_empty_dir() {
    local map_ref=$1
    local prefix=$2

    declare -n map=$map_ref

    for key in "${!map[@]}"; do
        if [[ "${map[$key]}" == "*" ]]; then
            if ! diffDir "$key" "$prefix/$key"; then
                return 1  # 目录不为空
            fi
        else
            eval "files=(${map[$key]})"
            for file in "${files[@]}"; do
                if ! diffFile "$key/$file" "$prefix/$key/$file"; then
                    return 1  # 文件不同，目录不为空
                fi
            done
        fi
    done

    return 0  # 目录为空
}

changeflow() {
    local target=$1
    local cur=${2:-$MODULE}
    local SAVEN="${PREFIX}${cur}"
    local TARN="${PREFIX}${target}"
    
    INFO "===== Check weather save ====="
    local isempty
    if _check_empty_dir init_map "$WF";then
        isempty=yes
    else
        isempty=no
    fi

    # 检查部分
    local issave=no
    if [[ $isempty == "no" ]]; then
        if [ -d $WF/$SAVEN ]; then
            WARN "The target workflow $cur already exists!"
            if readReturn "Do you want to overwrite it? (yes/no)"; then
                rm -rf $WF/$SAVEN
                issave=yes
            else
                issave=no
                INFO "Skipping saving current workflow as user opted not to overwrite."
                return 1
            fi
        else
            issave=yes
        fi
    fi

    # 保存部分
    if [[ $issave == "yes" ]]; then
        INFO "===== Saving to $WF/$SAVEN ====="
        _handle_file_dir move workflow_map "." "$WF/$SAVEN" "$WF/backup/$SAVEN"
    else
        isMakeup=NO_MAKEUP
        INFO "... Do not need to save ..."
        INFO "===== Removing $WF/$SAVEN ====="
        _handle_file_dir remove workflow_map "" "." "$WF/backup/$SAVEN"
        isMakeup=DO_MAKEUP
    fi

    # 切换部分
    if [ -d "$WF/$TARN" ]; then
        INFO "===== Switching to $target ====="
        case $OPTIONAL_MAKEUP in
            yes|tar)
                tarSafe "$WF/$TARN" "$WF/backup" # 打成tar包
                ;;
            folder)
                saveSafe "$WF/$TARN" "$WF/backup" # 完全不打包
                ;;
        esac
        _handle_file_dir move workflow_map "$WF/$TARN" "." "$WF/backup"
        rmdir $WF/$TARN # 经常用于检查错误
    else
        INFO "===== Initializing to $target ====="
        _handle_file_dir copy init_map "$WF" "." "$WF/backup"
        {
            echo "MODULE=$target"
            echo ""
            saveMap workflow_map
            echo ""
            saveMap init_map
            echo ""
        } > MODULE.cfg
    fi
}

#==============================Main==============================

_readme(){
cat << 'EOF'

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


EOF

}


# 显示工作流信息
_list_workflows() {
    # local WF=".workflows"
    # local PREFIX="wf_"

    if [[ ! -d $WF ]]; then
        ERROR "Directory $WF does not exist."
        return 1
    fi

    # Find directories with the given prefix, sort by modification time, and extract the suffix
    local workflows=($(find "$WF" -type d -name "${PREFIX}*" -printf "%T@ %f\n" | sort -nr | awk '{print substr($2, length("'"$PREFIX"'") + 1)}'))

    # Display the results, 8 per line
    local count=0
    for workflow in "${workflows[@]}"; do
        nECHO CYAN_BOLD "$workflow "
        ((count++))
        if (( count % 8 == 0 )); then
            echo
        fi
    done

    # Print a final newline if the last line didn't end with one
    if (( count % 8 != 0 )); then
        echo
    fi
}

_gen_git(){
    TEST_DIR=$(mktemp -d -t CHANGEFLOW_XXXXXX)
    # mkdir -p "$TEST_DIR/changeflow"
    git clone git@github.com:zmr-233/ChangeFlow.git $TEST_DIR/changeflow
    {
        cat "$0"
    } > "$TEST_DIR/changeflow/changeflow.sh"
    {
        _readme
    } > "$TEST_DIR/changeflow/README.md"

cat << 'QWE' > $TEST_DIR/changeflow/ADD_TO_BASHRC_ZSHRC.sh
# Add the following line to your .bashrc or .zshrc file

# Alias for changeflow
alias changeflow='bash ~/changeflow.sh'
alias cflow=switchwf

QWE

    echo "cd $TEST_DIR/changeflow"


}

# 显示英文帮助信息
show_help_en() {
    ECHO "BOLD" "Usage: ${BLUE_BOLD}changeflow${RESET} [options]"
    echo ""
    ECHO "BOLD" "Examples:"
    ECHO "GREEN" "    changeflow foo            # Switch to foo workflow, save cur as MODULE"
    ECHO "GREEN" "    changeflow foo bar        # Switch to foo workflow, save cur as bar"
    ECHO "GREEN" "    changeflow -t foo -c bar  # Switch to foo workflow, save cur as bar"
    echo ""
    ECHO "BOLD" "Options:"
    nECHO "GREEN" "  -h, --help [lang]    "; ECHO "GREY" "Show help information (default: en)"
    nECHO "GREEN" "      --readme         "; ECHO "GREY" "Show detailed usage instructions (can be redirected to README.md)"
    nECHO "GREEN" "  -l, --list           "; ECHO "GREY" "List all historical workflows (and the current MODULE name)"
    nECHO "GREEN" "      --clean          "; ECHO "GREY" "Clean all backups (.workflow/backup)"
    nECHO "GREEN" "      --makeup         "; ECHO "GREY" "Control the OPTIONAL_MAKEUP variable"
    nECHO "GREEN" "          yes          "; ECHO "GREY" "Use default"
    nECHO "GREEN" "          no           "; ECHO "GREY" "Do not backup (only applicable when switching to old workflows)"
    nECHO "GREEN" "          tar          "; ECHO "GREY" "Backup as tar (default)"
    nECHO "GREEN" "          folder       "; ECHO "GREY" "Backup as folder"
    nECHO "GREEN" "  -c xxx, --cur xxx    "; ECHO "GREY" "Set the current workflow name to xxx (default is MODULE)"
    nECHO "GREEN" "  -t xxx, --target xxx "; ECHO "GREY" "Switch to the target workflow xxx"
}

# 显示中文帮助信息
show_help_zh() {
    ECHO "BOLD" "Usage: ${BLUE_BOLD}changeflow${RESET} [options]"
    echo ""
    ECHO "BOLD" "Examples:"
    ECHO "GREEN" "    changeflow foo            # Switch to foo workflow, save cur as MODULE"
    ECHO "GREEN" "    changeflow foo bar        # Switch to foo workflow, save cur as bar"
    ECHO "GREEN" "    changeflow -t foo -c bar  # Switch to foo workflow, save cur as bar"
    echo ""
    ECHO "BOLD" "Options:"
    nECHO "GREEN" "  -h, --help [语言]    "; ECHO "GREY" "显示帮助信息 (默认: en)"
    nECHO "GREEN" "      --readme         "; ECHO "GREY" "显示详细的使用说明 (可以重定向到 README.md)"
    nECHO "GREEN" "  -l, --list           "; ECHO "GREY" "列出所有历史工作流 (以及当前 MODULE 名称)"
    nECHO "GREEN" "      --clean          "; ECHO "GREY" "清除所有备份 (.workflow/backup)"
    nECHO "GREEN" "      --makeup         "; ECHO "GREY" "控制 OPTIONAL_MAKEUP 变量"
    nECHO "GREEN" "          yes          "; ECHO "GREY" "使用默认"
    nECHO "GREEN" "          no           "; ECHO "GREY" "不备份 (仅适用于切换旧工作流时不备份)"
    nECHO "GREEN" "          tar          "; ECHO "GREY" "打包备份 (默认)"
    nECHO "GREEN" "          folder       "; ECHO "GREY" "不打包备份"
    nECHO "GREEN" "  -c xxx, --cur xxx    "; ECHO "GREY" "设置当前工作流名称为 xxx (默认是 MODULE)"
    nECHO "GREEN" "  -t xxx, --target xxx "; ECHO "GREY" "切换到目标工作流 xxx"
}

# 默认值
# OPTIONAL_MAKEUP="tar"
CURRENT_WORKFLOW=""
TARGET_WORKFLOW=""

# 解析命令行选项
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help|-h=en|--help=en)
            show_help_en
            exit 0
            ;;
        -h=zh|--help=zh)
            show_help_zh
            exit 0
            ;;
        -h=*|--help=*)
            ERROR "Invalid language for help: $lang"
            exit 1
            ;;
        --readme)
            _readme
            exit 0
            ;;
        -l|--list|-H|--history)
            INFO "Listing all historical workflows ..."
            nECHO YELLOW "======> " ; nECHO GREEN_BOLD "$MODULE";  nECHO YELLOW " <======\n"
            _list_workflows
            exit 0
            ;;
        --clean)
            INFO "Cleaning all backups..."
            rm -rf $(WF)/backup
            exit 0
            ;;
        --makeup)
            shift
            if [[ "$#" -gt 0 ]]; then
                case $1 in
                    yes|no|tar|folder)
                        OPTIONAL_MAKEUP=$1
                        ;;
                    *)
                        ERROR "Invalid value for --makeup: $1"
                        show_help_en
                        exit 1
                        ;;
                esac
            else
                ERROR "Missing value for --makeup"
                show_help_en
                exit 1
            fi
            ;;
        -c|--cur)
            shift
            if [[ "$#" -gt 0 ]]; then
                CURRENT_WORKFLOW=$1
            else
                ERROR "Missing value for -c|--cur"
                show_help_en
                exit 1
            fi
            ;;
        -t|--target)
            shift
            if [[ "$#" -gt 0 ]]; then
                TARGET_WORKFLOW=$1
            else
                ERROR "Missing value for -t|--target"
                show_help_en
                exit 1
            fi
            ;;
        --gen-git)
            shift
            INFO "Generating for git submit"
            _gen_git
            exit 0
            ;;
        *)
            ERROR "Unknown option: $1"
            show_help_en
            exit 1
            ;;
    esac
    shift
done


# 在这里添加主逻辑
# echo "OPTIONAL_MAKEUP = $OPTIONAL_MAKEUP"
# echo "CURRENT_WORKFLOW = $CURRENT_WORKFLOW"
# echo "TARGET_WORKFLOW = $TARGET_WORKFLOW"

changeflow "$TARGET_WORKFLOW" "$CURRENT_WORKFLOW"