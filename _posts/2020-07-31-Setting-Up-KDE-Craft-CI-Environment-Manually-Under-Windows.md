---
title: 在 Windows 10 上手动部署 KDE Craft CI 测试环境
tags: []
date: 2020-07-31 20:09:52
---

KDE Craft 官方 Wiki 写的还是比较简陋的，没有太深入去研究，所以下面的一部分内容可能不准确或者有误，若发现任何问题还请联系我更正，非常感谢！

若是希望在自己的 Windows 上使用 KDE Craft 环境进行构建，推荐的还是走官方提供的方式进行安装，虽然国内安装由于显而易见的网络缘故可能会比较蛋疼。本篇尽管也是在 Windows 10 上安装和使用 KDE Craft，但我们这里的目的是能够在 CI 上部署 Craft 来进行自动构建，本文的目标则是在和 CI 玩乒乓之前把路走通，所以尽管本文是在描述如何在 Windows 10 上手动安装 craft ，但所使用的为适用于 CI 的步骤，实际得到的结果和直接使用官方步骤进行安装是有差异的。

### 前置知识

读这篇文章的话你可能已经知道了 KDE Craft 是一个很近似 emerge 的元构建系统加包管理工具（不知道的话你很可能没必要继续读下去了，或者也可以[去了解一下](https://community.kde.org/Craft)看看是不是确实有兴趣），它会帮助获取依赖并帮助进行构建。工具名称为 `craft`，大致提供的命令行用法是这样的：

``` shell
craft packagename # 安装 packagename 包（仓库内存在二进制将直接获取二进制并安装，否则自动获取源码进行编译）
```

对，这里不写别的用法（下面再说..），因为整个环境的安装过程基本就是在用这个。例如安装（或者更新） craft 自身的方式就是执行 `craft craft`...

当然，在还没有 craft 环境时，我们没有 `craft` 命令，下面会写实际的步骤。

### 准备工作

#### 必要的软件

我们需要事先准备一些东西。

 - CraftMaster 初始仓库（ <https://invent.kde.org/packaging/craftmaster> ）
 - Python >= 3.6
 - MSYS2
 - PowerShell

上面提到的 MSYS2 可能是可选的，但我的环境本身就有 MSYS2 所以直接使用了我环境中的 MSYS2，并没有尝试如果不主动配置的话会不会在部署过程中下载。以及在我的尝试中，我使用 Windows 商店提供的 Python 时遇到了问题，于是后续从官网获取安装了 Python 并修改配置使其使用了我另外安装的 Python。另外整个过程基本全程是在 PowerShell 操作的，所以需要找个舒服的终端模拟器来用 PowerShell，系统自带版本即可，不过注意官方不建议使用 PowerShell ISE。

下文中我们做如下假定：

 - 假定 CraftMaster 被克隆到了 `D:\Craft\craftmaster\` 位置。
 - 假定提供的 Craft 配置文件位于 `D:\Craft\config\test.ini` （配置文件的名字是无所谓的）。
 - 假定我们的 CraftRoot 将会是 `D:\Craft\root\` （此目录不需要事先存在）。

#### 准备工作和配置

上面的东西都准备好之后就可以准备开始了。首先是解决所谓“我们没有 `craft` 这个命令”的问题。craft 本身是 python 程序，我们这里通过上面提到的 `CraftMaster` 仓库来获取它。在克隆好它后，我们会写一个 PowerShell 函数来执行仓库内的某个 python 脚本并传递必要的参数，并把函数名命名为 `craft`，然后就可以使用了。

``` powershell
function craft() {
	& python "D:\Craft\craftmaster\CraftMaster.py" --config "D:\Craft\config\test.ini" --target windows-mingw_64-gcc -c $args
}
```

我们的函数是放到 PowerShell 的 [Profile 文件](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7)中的，这里理解为 Profile 是个和 `.bashrc` 很近似的东西，其路径可以 `echo $PROFILE` 来查看。看到路径后把上面的函数复制粘贴进去，把路径改对就行了。

这里使用了当前 `$env:PATH` 中能找到的 python 来执行 CraftMaster.py ，并通过 `--config` 指定了配置文件，以及 `--target` 指定了我们要构建的目标 ABI，最后把别的参数传过去。`--target` 后所跟的架构名称是需要配置文件中有指定的，下面就是我所使用的配置文件（上面提到的 `test.ini`，当然说是 ini 其实这个格式更接近 `.desktop` 文件，分号并不表示注释，而是表示列表项的分割符）。

``` desktop
# Avalible variables are
# Variables:Root: Root is defined relative to CraftMaster and points to the subdirectory work
[General]
Branch = master
ShallowClone = True

# Variables defined here override the default value
# The variable names are casesensitive
[Variables]
Root = D:\Craft\root\

#Values need to be overwritten to create a chache
UseCache = True
CreateCache = False
Ignores = dev-util/perl
Msys = C:\tools\msys64\

# Settings applicable for all Crafts matrices
# Settings are Category/key=value
# Category is case sensitive

[GeneralSettings]
Paths/Python = D:\Python\Python38-32
Paths/downloaddir = ${Variables:Root}\downloads
Paths/Msys = ${Variables:Msys}
ShortPath/emerge_use_short_path = False
Packager/CacheDir = ${Variables:Root}\cache
Packager/UseCache = ${Variables:UseCache}
Packager/CreateCache = ${Variables:CreateCache}
Packager/RepositoryUrl = https://mirrors.ustc.edu.cn/kde-application/craft/master/;https://files.kde.org/craft/master/
Compile/BuildType = Release
ContinuousIntegration/Enabled = True
Portage/Ignores = ${Variables:Ignores};win32libs/icu;binary/mysql;win32libs/dbus
CraftDebug/DumpSettings = True

[windows-mingw_64-gcc]
QtSDK/Compiler = mingw73_32
General/Architecture = x64
```

请额外留意上面所写的本地路径，都需要更改为你实际的路径或者期望的路径（比如 Craft Root 以及 downloaddir 等路径本身可以不存在，在安装过程 craft 本身会进行创建。

`[windows-mingw_64-gcc]` 一节就是描述对应的 target 相关的配置了。如果你期望使用 MSVC，则需要提供 `[windows-msvc2019_64-cl]` 一节来描述对应的配置。craft 在获取软件包时，会根据 `Packager/RepositoryUrl` 中提供的路径先查找是否有构建好的 binary，查找方式则是根据所提供的 target 配置来查找了，所以这里的配置得写对。另外由于显而易见的缘故，这里加了 ustc 的镜像位置，可以看自己的情况调整。

上面配置文件中的 `Paths/Python` 其实也可以删掉不提供（会使用 `$env:PATH` 中的，如果之前没折腾过的话，很可能你在用巨硬商店内的版本），但如果安装过程发现提示报错比如 pip 版本问题之类的情况的话，还是建议去官网自己下个装然后改配置指向你安装的版本，或者如果不嫌麻烦的话，自己解决遇到的问题。

好了好了我们可以开始了。当然其实整个事情的困难的地方其实在于官方并没有提供适用于 CI 的部署文档所以整个过程要做的步骤我是通过参考现有配置摸索得到的，如果文档不缺的话，其实要做的事情也很简单：一切就绪后就可以打开一个 PowerShell 环境并通过我们的 `craft` “函数”开始安装 craft 环境了。

``` powershell
craft craft
```

执行之后 craft 会获取其所需的所有东西并进行安装，我们则只需要看输出中有没有异样然后进行处理就可以了。常规情况更新 craft 的方式其实也是这个命令。如果上面的命令执行没有任何问题的话，恭喜你，已经成功了。

### 使用 Craft 环境

#### CI

既然提到是 CI，所以上面的步骤肯定是适用于 CI 的步骤。整个过程读下来的话你很可能也清楚我们要在 CI 上用的话应该怎么办了。首先获取 CraftMaster 仓库，然后声明 powershell 函数，最后 `craft craft` 初始化 craft 环境，就可以用了。

当然，结合 CI 使用的话还有一些别的东西可配置，例如实际场景中 CI 上是这样定义 `craft()` 的：

``` powershell
function craft() {
	& C:\python36\python.exe "C:\CraftMaster\CraftMaster\CraftMaster.py" --config "$env:APPVEYOR_BUILD_FOLDER\appveyor.ini" --variables "APPVEYOR_BUILD_FOLDER=$env:APPVEYOR_BUILD_FOLDER" --target $env:TARGET -c $args
	if($LASTEXITCODE -ne 0) {exit $LASTEXITCODE}
}
```

`if($LASTEXITCODE -ne 0) {exit $LASTEXITCODE}` 的目的是在遇到错误时直接退出掉，我们本地测试自然不需要这个。另外则是这里通过 `--variable` 传递了额外的变量进去以供配置文件使用。对应不同的场景，我们自然需要一些针对环境的不同配置，这里可以按需更改配置文件，当然也建议参考现有项目的配置，现有的项目基本都是使用 AppVeyor 进行自动构建的，由于 AppVeyor 的 Windows 环境预制的东西相当全，所以使用 Craft 也会很方便。关于可参考的现有项目的配置，文末会提供链接。

#### CraftMaster 和 Craft

我并没有深入去研究这两个仓库的实质区别，暂时的理解是 CraftMaster 是更适用于 CI 的版本，可以更主动的配置一些内容然后让 craft 完成自举，而官方提供的 Craft 安装方式则是提供了交互式的安装脚本来帮助获取仓库和生成配置，并获取了常规开发所需的实用工具。

两种安装方式的最值得一提的区别就在于官方提供的安装方式会提供工具（例如 `craftenv`）来配置正确的环境变量等信息，以便环境中的程序执行时能找到正确的其它程序。查看 `craftenv.ps1` 的内容即可发现实际它就是提供了 `craft` 命令的来源文件，一些其它的辅助命令例如 `cs` 之类也由它提供。若在我们的 CI 方式所安装的环境中直接执行 `craftenv.ps1` 则似乎无法获得对应的效果（原因很好猜到，但怎么解决则又是需要摸瞎的内容了），环境变量可能也需要我们自行准备。

由于环境变量的差异确实可能造成我们“只是能用 `craft` 这个指令来安装东西而不能得到一个 craft 环境来构建程序”的问题，这里还待研究...

#### 提供和使用蓝图

如果我们希望 craft 可以构建自己的程序（以及可能希望把配置分享给其它使用 craft 的用户使它们能构建自己的程序）的话，我们可以提供自己的蓝图给 craft 用。在一个蓝图中可以提供若干个程序（软件包）的元信息，这些信息告诉 craft 应当怎样构建对应的程序，获取哪些依赖等。

给 craft 添加蓝图的方法很简单，例如：

``` powershell
craft --add-blueprint-repository https://code.blumia.cn/blumia/craft-shmooprint-bkt.git
```

蓝图内直接提供元信息配置即可，可以直接参考现有的软件包的配置来写。

#### 构建程序

当你使用 `craft packagename` 时，就是在安装对应的软件包了，如上面所提到的，如果在配置的仓库中已存在 binary 则会获取 binary 并尝试安装，若不存在或 binary 安装失败，则会获取源码进行安装了。所以假设你添加了上面所给的蓝图，则：

``` powershell
craft pineapple-pictures
```

将会获取对应配置描述内的版本的源码以及构建依赖，然后进行构建。

当然，如果你是包本身的开发者，在获取依赖后你可能会尝试反复构建程序，而每次 craft 都将尝试获取缓存数据，我们则可以通过 `--install-dep` 来获取依赖，并通过 `--no-cache` 参数来避免走 cache。以及，我们也可以指定 craft 来构建我们提供的源码而不是根据蓝图中的配置来下载源码进行构建：

``` powershell
craft --install-dep pineapple-pictures # 仅获取依赖
craft --no-cache pineapple-pictures # 无视 cache 进行安装（构建）
craft --no-cache --src-dir $env:APPVEYOR_BUILD_FOLDER pineapple-pictures # 指定源码目录，这里目录使用了环境变量表示
```

其它的就是一些常规的 craft 操作了，通过官方 wiki 或者 `--help` 来了解即可，这里就不再描述了。

### 参考资料和链接

#### 官方链接

 - 当前官方仓库位置： https://invent.kde.org/packaging/craft
 - 官方提供的（似乎是）适用于 CI 的版本： https://invent.kde.org/packaging/craftmaster
 - 官方提供的安装方式（Windows）： https://community.kde.org/Guidelines_and_HOWTOs/Build_from_source/Windows
 - KDE Craft 文件仓库： https://files.kde.org/craft/
 - KDE Craft 文件仓库的 ustc 镜像： https://mirrors.ustc.edu.cn/kde-application/craft/

#### 非官方的参考链接

 - FatCRM 的 appveyor 自动部署脚本： https://github.com/KDAB/FatCRM/blob/master/appveyor.yml
 - [CraftMaster](https://invent.kde.org/packaging/craftmaster#examples) 读我文件中提到的两个示例项目（[Gammaray](https://github.com/KDAB/GammaRay/blob/master/appveyor.yml) 和 [Charm](https://github.com/KDAB/Charm/blob/master/appveyor.yml)）

### 杂话

写这篇的目的上面写过了，是为了在 CI 上能用 KDE Craft 来构建 Windows 应用程序，而这个需求来源其实并不是上面举例用的 pineapple-pictures 看图工具，只是因为它算是可以拿来测试的最简单的应用程序，而尽管我的辣鸡看图工具使用 Craft 构建的过程相当顺利，但在我实际想使用的场景上进行试验结果还是遇到了很多问题，到时候解决了再来更新这篇文章吧。

另外上面的内容可能有一部分理解也是有误的，比如我写 `craft craft` 这个步骤是“自举”但实际感觉很可能这个说法并不对，以及按我的猜测，如果本机的 `$env:PATH` 比较复杂的话，很可能有比预期更多的问题，而我还没有研究清真的 craft 环境和自己手动准备的 craft 环境到底有多少差异，也等搞清楚再来更新吧。以及，上方有一些内容并没有放在 GitHub 上而是在我自己的小水管服务器上，在适当的时候我再考虑移过去...

不过说起来，之前很少写这类博客的一个原因是自己会给自己施加压力。因为自己看到很多国内的博客错误很多，会误导很多人，而自己也不想写一篇到处都是疏漏甚至错误的文章来误人子弟，于是我通常会尽力搞清楚某一块大部分的内容之后才会去写这种技术博客，要么就干脆不写。但前段时间看到群里的 T 分享了一篇从 i2ex 看到的互喷，大致有这样一句话：

> 你的博客是很快，但是你从来不写这方面的教程，只写了一篇文章说你的博客有多快。像你这样不分享教程的人有什么资格看不起我们这些小白？（[来源](https://blog.skk.moe/post/how-to-make-a-fast-blog/)）

于是突然觉得，尽管写出的内容可能会有很多疏漏，但仍然能通过这种分享帮助到更多的人。如果我明确的告知可能有疏漏且鼓励读者进行思考的话，分享这种不算丰富的可能有坑的经验应该也不会是什么坏事吧。当然，也因此，如果你发现任何疏漏，都可以以你想得到的方式联系我来更正以及分享你的经验。
