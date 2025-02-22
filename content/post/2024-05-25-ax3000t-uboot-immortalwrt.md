---
date: "2024-05-25T19:14:00Z"
tags: []
title: 小米路由器 AX3000T 刷入 U-boot + ImmortalWrt 过程记录
aliases:
  - '/2024/05/25/ax3000t-uboot-immortalwrt.html'
---

## 杂话

没想到八百年不更一次博客，这次更新竟然又是写折腾路由器的...

折腾的原因是之前用的 AC2100 的 Padavan 在配合某些配置时愈加容易出现奇奇怪怪的问题，怀疑问题出在了内核以及特别有限的性能上，加之目前 Wi-Fi 6 甚至 Wi-Fi 7 时代都来了，之前那个也确实差不多该淘汰了，就考虑换一个。于是考虑了几个候选，一个是移动 RAX3000M，然后发现过了个年奸商炒的涨了不少钱。一个是 H68K Mini 这种类似各种 XX 派的玩意儿，但是一方面它本身就很贵，另一方面也担心 ARM 设备的功耗。再一个就是小米 AX3000T 了，也是最后选的产品。和上次一样，也是一次买了两个，另一个会给家里用。

## 步骤

尽管和之前一样，[OpenWrt 官网上的 Xiaomi AX3000T 硬件信息页面](https://openwrt.org/inbox/toh/xiaomi/ax3000t) 已经非常完整的介绍了整个过程实际要做的事情以及原因，但这次开搞之前参考了很多其它资料，最后没有 *完全* 参照 OpenWrt 官网写的步骤来搞。原因的话下面会说。步骤的话总体看也不复杂，大致也就是：拿 root ssh shell、刷第三方 U-boot、刷 ImmortalWrt。

下面的步骤主要是记录我折腾的过程，并非是指导教程目的的文章，所以有点流水账。哦对，顺口一提，我搞它的环境是 Arch Linux，下面的步骤也都是按我实际操作的情况记录的。

### 拿 root ssh shell

首先要做的是，插电然后跑一下首次安装向导，这样后面才能连它...但 **或许** 这个向导里的 SSID 应该填成自己想用的，因为似乎这个路由器带了 NFC 功能，会使用原厂固件设置的 SSID 和密码，而刷掉后这个功能仍然会存在，只是会继续用之前原厂固件最后一次设置的结果...不过我不太在乎这个特性，所以反正我是乱填的就是了...

顺便，别的资料指示说在开始之前需要降级固件到 1.0.47 版，但我看出厂固件就已经是这么个版本了，于是我也不用降级固件（（（（

接下来就是拿 ssh shell 了。其实怀疑小米大概故意的，会留着有漏洞的路由器固件版本给需要折腾的人用，于是也就直接利用后台漏洞来拿了。步骤的话和 OpenWrt 网站上写的一样（这也是 OpenWrt 网站上目前提供的唯一方案），把下面的内容保存为 `ssh.sh`，先登录路由器后台，然后复制从登录后的地址栏就可以得到的 stok 值，作为参数传给 `ssh.sh` 跑，然后就完了。

```bash
#!/bin/bash

if [ "$1" = "" ]; then
  echo "Usage: $0 [stok]"
  echo "e.g. $0 e6ea114ba2cddb0c70fbbc417bb2706c"
  echo "Copy the stok-string from a browser's URL-line, while being logged in to the router"
  exit 1
fi

curl -X POST "http://192.168.31.1/cgi-bin/luci/;stok=${1}/api/misystem/arn_switch" -d "open=1&model=1&level=%0Anvram%20set%20ssh_en%3D1%0A"
sleep 1
curl -X POST "http://192.168.31.1/cgi-bin/luci/;stok=${1}/api/misystem/arn_switch" -d "open=1&model=1&level=%0Anvram%20commit%0A"
sleep 1
curl -X POST "http://192.168.31.1/cgi-bin/luci/;stok=${1}/api/misystem/arn_switch" -d "open=1&model=1&level=%0Ased%20-i%20's%2Fchannel%3D.*%2Fchannel%3D%22debug%22%2Fg'%20%2Fetc%2Finit.d%2Fdropbear%0A"
sleep 1
curl -X POST "http://192.168.31.1/cgi-bin/luci/;stok=${1}/api/misystem/arn_switch" -d "open=1&model=1&level=%0A%2Fetc%2Finit.d%2Fdropbear%20start%0A"
sleep 1
curl -X POST "http://192.168.31.1/cgi-bin/luci/;stok=${1}/api/misystem/arn_switch" -d "open=1&model=1&level=%0Apasswd%20-d%20root%0A"
```

接下来就可以用 ssh 连它了。当然似乎是因为路由器的 ssh server 版本太低或者我本机的 ssh 版本太高，所以在 `ssh` 以及 `scp` 的时候需要一些额外的参数，例如：

```shell
# 使用 ssh 时（不用的话报错是 `no matching host key type found. Their offer: ssh-rsa`）
$ ssh root@192.168.31.1 -o HostKeyAlgorithms=+ssh-rsa
# 使用 scp 时（主要是 -O，不用的话报错是 `ash: /usr/libexec/sftp-server: not found` ）
$ scp -O -o HostKeyAlgorithms=+ssh-rsa ./mt7981_ax3000t_fip-fixed-parts-multi-layout.bin root@192.168.31.1:/tmp/
```

### 刷第三方 U-boot

连上 ssh 后就可以刷 U-boot 了。不同于之前有现成的所谓 “不死 Breed” 可用，这次似乎没什么可选。OpenWrt 官方的 U-boot 是没有网页图形界面的，并且 OpenWrt 的 U-boot 甚至要用不同的固件对应它的 U-boot 用的分区布局（而且似乎不兼容原厂布局），而我想刷 U-boot 的目的则是防止折腾炸了不好救砖所以必然希望有个 webui 用，于是顺着找到了 [GitHub: hanwckf/bl-mt798x](https://github.com/hanwckf/bl-mt798x) 以及对应的 [immortalwrt-mt798x 项目介绍博客](https://cmi.hanwckf.top/p/immortalwrt-mt798x/)。

这个项目的好处是它支持 webui，以及甚至支持在 webui 刷入固件时选不同的布局。不过有意思的是，这位目前提供的最新预编译版本（20240123）对 AX3000T 移除了 multi-layout，而[据 Issue 评论说，如果自己从源码构建则可以使用多布局支持，并且事实上没什么问题](https://github.com/hanwckf/bl-mt798x/issues/52#issuecomment-2066323602)。于是我寻思干脆我自己构建得了，但又懒得搞环境，于是打算写个 GitHub Action 来构建，结果构建的还挺顺利...

于是[我的 fork 仓库在这儿](https://github.com/BLumia/bl-mt798x/)，如果你自己打算用的话，fork 后点 Actions，左侧选 Uboot Ubuntu CI Build（也就只有这一个），然后 Run workflow 下拉框填配置（默认配置就是了，不需要改，我是留着备用的）然后坐和放宽。另外写这个 workflow 的时候还注意到，Ubuntu 24.04 （这个环境目前还是 beta 状态）的 runner 会在重启 systemd 服务的时候把 runner 服务也给停掉，所以当前实质上只能在 ubuntu-22.04 环境上跑。当然目前 ubuntu-latest 仍然是 22.04 就是了（（（

跑完构建就可以得到编译后的版本了。我博客丢出去后大概会把目前的 binary 也丢到 release 一份备用，~~到时候也把链接更新到这儿吧~~（edit：[我自己目前所用的、自己构建的版本见这里](https://github.com/BLumia/bl-mt798x/releases/tag/24.05.25)）。得到 binary 后就是把它丢到路由器的 `/tmp/` 目录下（参见上一节示例里的 `scp` 命令），然后 `mtd` 写入进去。OpenWrt 推荐搞之前备份分区，我嫌麻烦没搞，直接上了：

```shell
# 注意最后的 FIP 是全大写的
mtd write mt7981_ax3000t_fip-fixed-parts-multi-layout.bin FIP
```

刷完后就可以准备进入 U-boot 了。顺便，这个 U-boot 是可以引导原厂固件的，所以目前直接重启的话还是会进入原厂系统（

进 U-boot 方式倒是也不特殊，断电情况下按住重置键然后连接电源，等待大概五秒多（指示灯变蓝）后松手就是了，然后电脑有线网线连到路由器上，改成静态 IP `192.168.1.100`（100 可以是 1 之外的随便一个有效数字）然后访问 `192.168.1.1` 进入 webui。

比较蛋疼的是这个 U-boot 的原作者写的是 `192.168.31.1`，和我实际情况不符，[看网上图](https://www.cnblogs.com/jxsme/p/18117846)似乎原作者自己提供的 release 也确实是 `.31.1`，搜了下代码也没看到有什么相关的配置...反正不影响使用就是了。

然后访问 webui 后也会发现，自己编译的带 multi-layout 版本也确实能在 webui 手动选布局。好事，好事。

### 刷 ImmortalWrt

选 ImmortalWrt 的原因比较杂。如果选 OpenWrt 官方固件的话，有很多需要的第三方包就只能自己搞定，或者就是干脆自己构建，但显然自己也没精力去维护版本更新。剩下的可选项大概就是类似 openwrt.ai 的这种“特色定制服务”，以及 ImmortalWrt 这种社区版本了，也显然我会倾向于选后者。

ImmortalWrt 可以认为是很符合大陆特色的一个 OpenWrt 再发行版，仓库里有很多 OpenWrt 官方仓未收录的、对大陆开发者而言非常实用的工具，并且版本也会随 OpenWrt 官方更新。以及就之前的体验而言，它支持的设备范围也比 openwrt.ai 这种要广一些。另外，ImmortalWrt 也提供了 [OFS](https://github.com/openwrt/firmware-selector-openwrt-org/) 来供用户在线定制固件，例如 AX3000T 用的 [Xiaomi Mi Router AX3000T (stock layout)](https://firmware-selector.immortalwrt.org/?version=23.05.2&target=mediatek%2Ffilogic&id=xiaomi_mi-router-ax3000t) 或是 [Xiaomi Mi Router AX3000T (OpenWrt U-Boot layout)](https://firmware-selector.immortalwrt.org/?version=23.05.2&target=mediatek%2Ffilogic&id=xiaomi_mi-router-ax3000t-ubootmod)。我最终用的是 stock layout 版本并通过网页自定义 `Installed Packages` 得到的固件。

因为我主要参考了 OpenWrt 官网的步骤，所以我最开始是试图在 U-boot 刷入 initramfs-factory.ubi 的，刷入后自动重启发现没有 Wi-Fi，有线连接改回自动获取后重连并通过 `192.168.1.1` 访问后台后发现一方面 Network 下没有 Wireless 选项，另一方面提示 initramfs 的设置不会保存（倒也正常），需要在 luci 后台刷一次 sysupgrade 包。刷完 sysupgrade 包后确实这两个问题都解决了，相当于大功告成只需要进行后续的路由器按需配置就可以了。

不过，我在刷第二台的时候在 U-boot 直接刷了 sysupgrade 包而不是 initramfs-factory.ubi 包，这次则是重启后非常符合预期的有了名为 ImmortalWrt 的 Wi-Fi，于是也不需要改有线连接才能进后台配置了。所以如果你是刚巧搜到了我这个博客还没开始刷的话，也在 U-boot 这步直接刷 sysupgrade 包更省事一些。

然后就结束了，我的后续配置是装了 luci-app-argon-config（主题和配置），因为官方主题太丑以及我希望改 argon 的默认行为（默认是联网获取 bing 每日一图的，据说获取失败还会卡登录界面）（这个也该定制的时候加进去的，当时漏写了）。以及把网段改成了 `192.168.123.*` 来保持和之前 Padavan 近似的配置（以及避免和光猫网段冲突）。还有“对大陆开发者而言非常实用的工具”则是定制固件的时候就加进去了，所以不需要额外装，只需要配置好就可以了。

顺带一提，关于 multi-layout。因为上面第一次刷的是 initramfs-factory 而不是 sysupgrade 导致重启路由器后没有预期的 Wi-Fi，于是当时把我手上备的几个版本都试了一遍，测试结果是 112m 布局确实可以成功刷入 ImmortalWrt 的 U-boot layout 版，基本和 [上面提到的那个 Issue 里的 comment](https://github.com/hanwckf/bl-mt798x/issues/52#issuecomment-2066323602) 情况是相符的。当然那个评论还提到一句：

> 据网上资料称，openwrt和immoralwrt的ubootmod分区上有差异，谨慎起见没有测试能否刷入openwrt(ubootmod)版本

根据我查到的资料的话，我觉得这位指的“网上资料”是：

> 由于OpenWrt主线的ubootmod固件未开启nmbm支持，因此不支持任何ubootmod分区布局的主线固件（包括OpenWrt, X-Wrt等带有ubootmod字样的固件），请使用OpenWrt主线提供的uboot启动ubootmod固件 --[来源](https://cmi.hanwckf.top/p/mt798x-uboot-usage/#%E5%85%B6%E5%AE%83%E6%B3%A8%E6%84%8F%E4%BA%8B%E9%A1%B9)

但我反正也没意图刷 OpenWrt 主线原版固件，也就没有做出尝试就是了。另外事实上网上有一大堆的第三方 OpenWrt 定制版本，但看上去大部分是再恩山论坛的帖子里分发与更新的。我觉得这类或许有一些类似闭源固件或者别的预先配置好的实用的东西，但考虑到后续获取更新大概很麻烦/耗精力，于是也就懒得试了。

哦还有一件事。我的 ImmortalWrt 并没有配置软件源镜像，因为默认源目前体验上也挺快的。不过值得一提的是，曾经我在别的设备使用 ImmortalWrt 时试过一些别的镜像源，但发现那些源缺失了一些“对大陆开发者而言非常实用的工具”。我在写这段话时刻意重新检查了下之前发现存在这个问题的镜像源，发现那些缺失的包现在又存在了。所以如果你打算配置类似的镜像的话，建议配置之前检查下你要用的镜像有没有这种问题。

### 其它杂话

感觉上面写的内容已经很杂了。这里就简单吐点槽。我查资料的时候就越发感觉目前的互联网资源分享氛围有点两极分化，一拨人致力于打造自己的信息围墙花园（近年来有个什么词儿来着对应这个情况，忘掉了），把资源“注册可见”、“回复可见”、“付费可见”，甚至一个 U-boot 还要放到付费平台上去卖个几块钱（这里就不贴出来“挂人”了），而另一拨人主动的提供详尽的资料和指南供参阅。造就了当下这种畸形互联网的原因太多了，虽说我希望（并且已经在）以身作责身体力行的成为后者，但还是感觉今后的互联网或许会愈加封闭，算是一种奇特的悲哀吧。

### 参考资料

下面的链接大都是上面贴过的，再贴一次当汇总吧：

 - [OpenWrt 官网上的 Xiaomi AX3000T 硬件信息页面](https://openwrt.org/inbox/toh/xiaomi/ax3000t)
 - [GitHub: hanwckf/bl-mt798x U-boot 源码与预编译文件](https://github.com/hanwckf/bl-mt798x)
   - [原作者的 “mt798x uboot 功能介绍” 博客](https://cmi.hanwckf.top/p/mt798x-uboot-usage/)
   - [“AX3000T 为什么在 20240123 的 release 中移除了 multi-layout” 讨论](https://github.com/hanwckf/bl-mt798x/issues/52)
   - [我自己的 GitHub Action 在线构建用的 Fork 版](https://github.com/BLumia/bl-mt798x/)
     - [可供直接使用的编译好的版本](https://github.com/BLumia/bl-mt798x/releases/tag/24.05.25)
 - [ImmortalWrt：Xiaomi Mi Router AX3000T (stock layout) 固件下载与定制页面](https://firmware-selector.immortalwrt.org/?version=23.05.2&target=mediatek%2Ffilogic&id=xiaomi_mi-router-ax3000t)
   - [ImmortalWrt：Xiaomi Mi Router AX3000T (OpenWrt U-Boot layout) 固件下载与定制页面](https://firmware-selector.immortalwrt.org/?version=23.05.2&target=mediatek%2Ffilogic&id=xiaomi_mi-router-ax3000t-ubootmod)
 - 其它参考内容
   - [假行僧me 的 “XiaomiAX3000T—Openwrt” 博客](https://www.cnblogs.com/jxsme/p/18117846)
 - 其它未实际采用的（或许）可用的固件
   - [hanwckf （上面所用 U-boot 同作者）的 “immortalwrt-mt798x项目介绍”](https://cmi.hanwckf.top/p/immortalwrt-mt798x/)
   - [“QWRT for Xiaomi AX3000T R23.11.11更新+刷机小白图文教程及备份”](https://www.right.com.cn/forum/thread-8312035-1-1.html)

惯例，2024年5月25日，21点13分。
