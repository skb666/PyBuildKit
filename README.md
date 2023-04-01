# PyBuildKit

一个强大的 C/C++ SDK 编译框架，基于 CMake 和 Kconfig，结合了 Python 脚本进行项目管理。

基于 [Neutree](https://github.com/Neutree) 的代码构建框架: [c_cpp_project_framework](./framework.md)

## 开发环境

```bash
# 基本环境
apt install build-essential pkg-config cmake python3 git curl wget zip unzip tar
# 拉取项目代码
git clone https://github.com/skb666/PyBuildKit.git --recursive ~/PyBuildKit
# vcpkg(非必须)
git clone https://github.com/microsoft/vcpkg.git ~/vcpkg
~/.vcpkg/bootstrap-vcpkg.sh
# 设置系统环境变量(非必须)
export VCPKG_ROOT="$HOME/vcpkg"
export PATH="$PATH:$VCPKG_ROOT"
export MY_SDK_PATH="$HOME/PyBuildKit"
```

## 编译、运行测试

```bash
# 切换到项目目录
cd template/test_sample
# menuconfig
python project.py menuconfig
# 编译
python project.py build
# 运行
python project.py run
```

## 添加项目

+ 新建项目目录，结构参照 `template`
+ 普通 `c/c++` 的应用参考 `template/test_sample`
+ 使用 `vcpkg` 的应用参考 `template/test_vcpkg`
+ 在 `<application>/main` 中放应用代码文件
+ 在 `<application>/compile/priority.conf` 中设置依赖组件的编译顺序
+ 在 `<application>/config_defaults.mk` 或 `<application>/.config.mk` 中设置组件是否启用（`.config.mk` 优先）

## 添加组件

+ 全局组件：参考 [template.md](components/template.md)
+ 项目共享组件：参考 `template/components/event`
+ 应用私有组件：与 `<application>/main` 同级
