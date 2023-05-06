# PyBuildKit

一个强大的 C/C++ SDK 编译框架，基于 CMake 和 Kconfig，结合了 Python 脚本进行项目管理。

基于 [Neutree](https://github.com/Neutree) 的代码构建框架: [c_cpp_project_framework](./framework.md)

## 安装

**curl 安装**

```bash
# 仅安装 PyBuildKit
curl -fsSL https://raw.githubusercontent.com/skb666/PyBuildKit/master/install.sh | bash
# 安装 PyBuildKit 和 vcpkg
curl -fsSL https://raw.githubusercontent.com/skb666/PyBuildKit/master/install.sh | bash -s -- -w
```

**wget 安装**

```bash
# 仅安装 PyBuildKit
wget -qO- https://raw.githubusercontent.com/skb666/PyBuildKit/master/install.sh | bash
# 安装 PyBuildKit 和 vcpkg
wget -qO- https://raw.githubusercontent.com/skb666/PyBuildKit/master/install.sh | bash -s -- -w
```

**通过源码安装**

```bash
git clone https://github.com/skb666/PyBuildKit.git --recursive
cd PyBuildKit
chmod +x ./install.sh
# 仅安装 PyBuildKit
./install.sh -d $HOME/.mysdk
# 安装 PyBuildKit 和 vcpkg
./install.sh -w -d $HOME/.mysdk
```

**安装完成后，你可以通过执行 `. $HOME/.mysdk/env` 以临时配置编译环境；或者将 `. $HOME/.mysdk/env` 写入 `~/.profile`、`~/.bashrc`、`~/.zshenv` 等文件后重新登入 shell 以使环境配置永久生效。**

> 若提示 *"Please run as root"*，请使用 `sudo` 以管理员身份重新执行脚本，使其可以自动安装必须的一些软件包;  
> 若提示 *"[warning] You should ensure 'xxx' is already installed."*，请根据提示，确保系统已安装软件包 'xxx';  
> 你也可以手动安装这些软件包后重新运行安装脚本：`git` `python3` `cmake` `build-essential` `pkg-config` `curl` `wget` `zip` `unzip` `tar`

## 编译、运行测试

### template/test_sample

```bash
# 切换到项目目录
cd template/test_sample
# 编译
python project.py build
# 运行
python project.py run
```

### template/test_vcpkg

```bash
# 切换到项目目录
cd template/test_vcpkg
# 配置 vcpkg 子模块（只需要执行一次，自动生成 .config.mk）
python project.py config --toolchain ${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake
# 查看、更改配置控制选项
python project.py menuconfig
# 编译
python project.py build
# 运行
python project.py run
```

## 添加项目

+ 新建项目，目录结构参照 `template`
+ 普通 `c/c++` 的应用参考 `template/test_sample`
+ 使用 `vcpkg` 的应用参考 `template/test_vcpkg`
+ 在 `<application>/main` 中放应用代码文件
+ 在 `<application>/main/CMakeLists.txt` 中添加要编译的源码及其他
+ 在 `<application>/main/Kconfig` 中添加 `menuconfig` 控制选项
+ 在 `<application>/compile/priority.conf` 中设置依赖组件的编译顺序
+ 在 `<application>/compile/compile_flags.cmake` 中设置编译器编译参数
+ 在 `<application>/compile/gen_binary.cmake` 中添加编译后自定义命令
+ 在 `<application>/config_defaults.mk` 或 `<application>/.config.mk` 中设置控制选项的值
+ 在 `<application>/vcpkg.json` 配置 `vcpkg` 项目依赖的包，参考 [vcpkg-json](https://learn.microsoft.com/zh-cn/vcpkg/reference/vcpkg-json)

## 添加组件

+ 全局组件：参考 [template.md](components/template.md)
+ 项目共享组件：参考 `template/components/event`
+ 应用私有组件：与 `<application>/main` 同级
