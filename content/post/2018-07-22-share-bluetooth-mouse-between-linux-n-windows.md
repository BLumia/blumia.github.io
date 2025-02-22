---
date: "2018-07-22T15:09:33Z"
tags: null
title: 在 Linux 和 Windows 下共享蓝牙鼠标
aliases:
  - /2018/07/22/share-bluetooth-mouse-between-linux-n-windows.html
---

因为会去玩一些游戏和各种 DAW 大都不支持 Linux 桌面，我一直没离开 Windows ，而我自打来 D 司之后就一直在用我带过来的一个坏了的有线鼠标。上个月初 bktcon [^1] 后我拿到了卡拉否椰页的 Logitech M336 蓝牙鼠标 [^2] ，在 Windows 下用着还蛮舒服的，跑到 Arch 下发现找不到蓝牙适配器，由于人太懒就没过脑子直接没去研究。后来 Deepin 社区版升级 15.6 偶然试了试发现能够正常配对使用蓝牙鼠标，这才反应过来我 Arch 下开机压根没启蓝牙服务，切回去启动发现配对使用还是没啥问题的，然而却发现每次切什么系统都得重新配对...

<!--more-->

尽管知道可能改改什么配置文件就可以做到不需要每次都重新配对，但是由于当时实在是很少有切系统做什么事情的需求就没去研究，即便也正巧偶然看到乔老师发了一篇 [Linux 与 Windows 双系统共享蓝牙鼠标](https://blog.nanpuyue.com/2018/040.html) 的博客，我也还是没去折腾。而最近一段时间由于 D 司任务，曹哥把窗管的 `Alt+Tab` 切任务的视图的窗口预览给 _优化_ 掉了，并且也没能说服加配置项而是直接去掉了窗口预览的功能，我就打算闲了的时候看看能不能加个可配置项给自个儿用，于是就有了切 Linux 搞东西的需求，也就有了搞好蓝牙鼠标的需求...

处理步骤其实就是 [乔老师那篇博客](https://blog.nanpuyue.com/2018/040.html) 的内容了，这篇只是顺手记一下。大致无非是

 1. 在 Linux 下配对蓝牙鼠标（用于生成配置文件）
 2. 切换到 Windows 下配对蓝牙鼠标（用于读取配对信息）
 3. 修改 Linux 下的配对信息与 Windows 一致

这三步。前两步很明显我都干过了，那接下来剩下的就是读出 Windows 下的配对信息并把 Linux 下的信息修改一致。配对信息其实在 Windows 的 `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Keys\<本机蓝牙 MAC>` 下存储，然而读这个 Keys 下的值需要系统权限，于是看到有 dumphive 工具可以在 Linux 下 dump 注册表，就选择试试这个东西。

dumphive 源代码仓库在 [Gitorious](https://gitorious.org/canaima-gnu-linux/dumphive) 还可以找到一份，然而看 Gitorious 首页写的给我一种随时会跪的感觉，我就搞了个当前状态的[副本](https://bitbucket.org/BLumia/dumphive/src/master/) ..构建倒是挺简单， `git clone` 下来之后跑 `src` 目录直接 `make` 就行了（这玩意儿竟然是 pascal 写的..），那么接下来就是 dump 注册表找到要用的配对信息了。

Windows 的注册表存储在 `<系统盘>:\Windows\System32\config\` 下的 `SYSTEM` 文件里，于是挂载上 Windows 所在分区后 `cd` 过去 `dumphive SYSTEM ~/system.reg` 就完事儿了，然后只需要找到相关配对信息在哪就是了。

``` bash
$ cd /run/media/blumia/SSD-Win/Windows/System32/config # 我挂载过了...
$ /home/blumia/Code_Lab/dumphive/src/dumphive SYSTEM ~/system.reg # 只是编译了，没把二进制扔到 PATH 里
$ grep -Pn 'BTHPORT.*\\Keys(\\[\da-f]{12})' ~/system.reg # 找一下是哪行
```

和乔老师的步骤不太一样的地方大致就是我这儿没有 `HKLM\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Keys\<本机蓝牙 MAC>\<鼠标蓝牙 MAC>`，所以上面那条正则不太一样，不过找不找其实都一样，打开编辑器里面搜 `BTHPORT\Parameters\Keys\` 应该也就只能找到一处...（不必要的信息我处理成了61）

``` plain
[ROOT\ControlSet001\Services\BTHPORT\Parameters\Keys\a0a8cd616161]
"0ce725b61616"=hex:9b,4d,97,4f,49,f9,24,e4,e2,ae,86,61,61,61,61,61
"34885d561616"=hex:b8,de,85,0a,92,70,fd,cf,79,43,e1,61,61,61,61,61
```

我一时半会儿还真想不起来我哪来的俩蓝牙设备，不过具体哪个是我的鼠标，看一眼 Linux 下的就是了

``` bash
# ls "/var/lib/bluetooth/A0:A8:CD:61:61:61"
34:88:5D:61:61:61  cache  settings
```

于是确定了我的设备是这个，配置文件看上去像是这样（这个是我修改之后的）：

``` plain
[General]
Name=Bluetooth Mouse M336/M337/M535
Class=0x000580
SupportedTechnologies=BR/EDR;
Trusted=true
Blocked=false
Services=00001000-0000-1000-8000-00805f9b34fb;00001124-0000-1000-8000-00805f9b34fb;00001200-0000-1000-8000-00805f9b34fb;

[LinkKey]
Key=B8DE850A9270FDCF7943E16161616161
Type=4
PINLength=0

[DeviceID]
Source=2
Vendor=1133
Product=45078
Version=4611
```

需要修改的就只是配对 Key 了，规则则是简单的把 `[ROOT\ControlSet001\Services\BTHPORT\Parameters\Keys\<本机蓝牙 MAC>]` 下的对应蓝牙设备的 Key 后面的值，小写转大写并去掉空格。于是只需要

``` bash
$ echo b8,de,85,0a,92,70,fd,cf,79,43,e1,61,61,61,61,61|tr -d ,|tr a-z A-Z
B8DE850A9270FDCF7943E16161616161
```

然后把值改到上面配置文件的 Key 一项中即可。最后 `systemctl start bluetooth.service` 打开蓝牙服务，选择配对过的鼠标进行连接，万事大吉。

最后几句闲话，在看 `deepin-wm` 的代码的时候，注意到这玩意儿也是 vala 写的（我为啥要用也字...），然后发现 vscode 对 vala 支持也就限于高亮了，就试了试 `gnome-builder` ，对 autotools 支持是开箱即用的倒是有点小意外，然而似乎没能正确识别被魔改过的 `DeepinClutter` （构建倒是一点毛病都没..）。涉及的俩文件晃了一眼貌似不是很复杂，不过也只是晃了一眼而已，还没细看。 `Alt+Tab` 能看窗口预览这个需求对我来说还是挺有用的，不过我也不知道我啥时候会去改那就是另一回事了。特技狼之前问能不能给控制中心加关闭鼠标加速的功能 [^3] ，我反映过去之后好像相关的维护人员没加这个功能的意思，于是我也只能自己上了，却发现这个看着很简单的需求得动 `dde-api`（操作 libinput），`dde-daemon` （等 dbus 信号来调 `dde-api`），`dde-qt-dbus-factory`（提供 dbus 接口）和 `deepin-control-center`（终于...）四个 proj 。虽然不清楚是不是过度设计但是挨着改估计还是得要点时间的。于是这个搞完之前估计也不会有时间去动 wm 这个需求？以及我在来之前喷过的系统亮色暗色主题和 DDE 全家桶亮色暗色主题的切换压根不相关的事情，估计还是得我处理。以及文管列表模式下列宽不能调的事情其实也还是我处理的，我吐槽的这些东西最终都还是得我处理，想想觉得还是有点自己挖坑自己跳的感觉。

上周末写了个和现在 Mutter (我那个博客脚手架程序，不是窗管..)长得一样的 Jekyll 主题，打算把 ghpages 重新用回来，但是看博客文章格式和 font-matter 上好像有点区别，懒癌犯了，不知道又得拖到啥时候。

最后惯例，时间：2018/07/22 16:19

[^1]: HackxSJTU
[^2]: 头回用蓝牙鼠标..以及发现尽管是蓝牙鼠标，延迟还是没想象的那么大的。试了试几个 osu! 4+ star 的图，还是打的挺顺利的，5 star 打不过那是因为长时间不打早就打不来了..
[^3]: 这个功能其实如果有我是肯定也会用的，尽管我也不打算在 Linux 下玩 osu! ..
