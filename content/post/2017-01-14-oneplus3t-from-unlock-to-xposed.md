---
date: "2017-01-14T11:31:06Z"
tags:
- 土产日杂
- 技术
- 安卓
- 刷机
title: OnePlus3T 从解锁 BootLoader 到 Xposed
aliases:
  - /2017/01/14/oneplus3t-from-unlock-to-xposed.html
---
我[之前]({{ site.baseurl }}{% post_url 2016-11-17-talk-begin-with-bloj %})立了个flag，说如果年前换了手机我就要好好黑一黑wp来着。于是年前真换了手机，于是就有了这一篇，打算写写折腾1+3T的过程以及顺便黑一黑垃圾WP。

<!--more-->

## 新手机为何是 OnePlus3T

wp用了一年多，越用越不爽，于是偶尔会翻到底什么手机合适，最初觉得Nexus不错但是一来得海淘我没这么玩过也不太敢，而来之后谷歌直接改出Pixel了。不过Pixel也得海淘啊，于是还是没办法。后来看到评价上有人说买Pixel还不如买OnePlus3，于是我才知道了这么个手机，而且还是国产（不用海淘），于是开始关注。

至于国内其他品牌，小米的红米[用过一次](https://blumia.net/?/post/%E7%BA%A2%E7%B1%B3note%E5%A2%9E%E5%BC%BA%E4%B9%8B%E6%8D%A2%E8%B4%A7%E8%AF%84%E4%BB%B7%E7%AD%89%E6%97%A5%E6%9D%82)就再也不敢用了，不过之前还是觉得小米的旗舰机可能还不错，而“基友”Chris用的 mi max 的屏幕也出现了质量问题，针对网上一些别的评价，我还是放弃了从小米品牌选择。

作为硬件盲，联想，华为什么的因为型号繁多（ps.三星太贵了），我又没研究过那些硬件参数，于是不敢从中选择，以及我也希望获得一些可靠的技术支持，包括刷机折腾之类，看上去OnePlus一直都很友好，之前甚至被CM推荐，于是进一步敲定选1+3。

最后1+3的升级版1+3T出来了，oing问我打算买嘛我说打算，但是怎么也得等到放假回家后。恰巧oing自己的旧手机大限到了，他就先买了，然后...没有然后，我放假回家后就买了。

哦对了，吐个槽，1+官网的那个抢购真的很蛋疼，我本来不在意颜色但是家长似乎更喜欢白的，试图抢了两次都没抢到，最后还是在京东买了黑（枪灰）的。

## 从解锁 BootLoader 到 Xposed

**免责声明：以下内容仅供参考，如果您要做，请搞清楚您在做什么，如果不清楚，请不要做！以下内容只是我个人情况的记录，如果照做导致问题本人不对产生的后果负责！**

这篇文章的标题和[oing写的](https://oing9179.github.io/blog/2017/01/OnePlus3T-from-Unlocking-Bootloader-to-Xposed-Installed/)那篇的标题完全一样，虽然只是因为我懒得想标题了...而这部分内容不同大概只有我少刷了OpenGApps以及我用的是SuperSU了。大致过程如下

### 准备工作

其实没什么可准备的，就是下载一些东西待用（要不然你刷什么..）。需要下的是这些：

 - Android SDK 中的 `platform-tools` （需要用到fastboot）
 - 适用于1+3T的 [TWRP Recovery](https://dl.twrp.me/oneplus3t/)
 - 一个可用的 Root 权限管理软件 （我选的是[SuperSU](http://www.supersu.com/download)）
 - Xposed用的[卡刷安装包](http://dl-xda.xposed.info/framework/sdk23/arm64/)，[卡刷卸载包](http://dl-xda.xposed.info/framework/uninstaller/) 以及[XposedInstaller_3.1.1.apk](https://forum.xda-developers.com/showthread.php?t=3034811)

fastboot从任何地方搞到都行，不过还是推荐从 Android SDK 获取。然后是 Recovery 啊权限管理啊什么的东西挨个下就是了。SuperSU是去下载页下载可以刷（flash）的zip包，全部准备就绪，就可以开始了。

顺便附带一个表

参数      |值 
---------|-------
Platform |ARM64  
Android  |6.0  
Variant  |micro

### 开始安装

我的安装过程意外的顺利， ~~大概是因为晚上十二点装的老天想让我早点睡觉吧，~~ 基本上按着步骤做就完成了。不过我之前不清楚刷Recovery是会清掉用户信息的，于是手机刚到手装的东西都没了，好在没装多少= =

**重申！刷Recovery过程会清掉手机里的东西！**

 - 开机  
首次开机其实啥也不用干。向导能过去就直接过去了，因为后面刷Recovery会清掉你设置的东西，所以你老实填了也没啥用。而开机的目的是去开发者选项打开OEM Unlocking。
 - 打开OEM Unlocking  
去 “Setting” 最下面选择 “About phone” ， 找到 “Build number”，点七次直到提示开发者选项好使了。然后回到 “Setting” 下面找开发者选项 “Developer options”。找到 “OEM Unlocking” 然后打开就好。
 - 解锁 BootLoader  
关机，然后开机时按住 `音量+` 和 `电源` 键，会进入fastboot，然后松开，再把手机和电脑连接。接下来到 fastboot 所在目录开启命令行，执行
``` shell
    fastboot oem unlock
```
完事儿手机上确认一下就好了，手机会自动重启回安卓系统。
 - 安装TWRP  
首先准备好下好的TWRP卡刷包镜像（假定叫 `twrp.img`），然后放到fastboot所在同文件夹以便使用。接下来手机关机并使用上面说过的办法进入到fastboot，接下来输入如下命令
``` shell
    fastboot flash recovery twrp.img
    fastboot boot twrp.img
```
然后稍等片刻，手机就会启动到TWRP了。询问 `Keep System Read only?` 时去下面 `Swipe to Allow Modifications` 就好。（ps：和oing一样，我也没遇到出发 dm-verity 的问题，非常顺利，如果你遇到了，请参考[这里](https://forum.xda-developers.com/oneplus-3t/development/recovery-twrp-oneplus-3t-t3507308)）
 - 卡刷 SuperSU  
因为发现在 fastboot / TWRP 的时候电脑上依然有识别手机设备并且可以传送文件，所以我直接在电脑上把需要复制的东西复制到手机了。当然你也可以选择用 `adb` 传东西到手机。  
现在你应该处于TWRP主界面（在TWRP时你可以通过触屏的虚拟Home键随时回到这里），这时候把你在[SuperSU](http://www.supersu.com/download)官网下好的包复制到手机存储，然后在手机的TWRP主界面选择 `Install` ，并选择你刚刚传到手机的zip包，然后滑动刷入（`Swipe to confirm Flash`）即可。完事儿后你可以开机看看效果，TWRP推荐你安装它的检查更新app，这个我选择不装。开机后能看到SuperSU已经可以用了，就算成功了。
 - 安装Xposed  
检查完你的SuperSU好使后，别急着关机，这时把你下好的 `XposedInstaller_3.1.1.apk` （版本号以你的为准）安装上（装完不需要打开），再把Xposed的卡刷安装包和卸载包传送到手机机身存储，最后再次关机，来到 fastboot 并来到 TWRP，按照之前刷 SuperSU 的方式选择 Xposed的卡刷安装包 刷进去就好了。完毕后开机，等待处理完毕后打开你刚刚装好的Xposed应用，应该就会提示成功了，然后显示你Xposed的版本号～

### 参考资料和后话

如果你是想要做同样事情的读者，我建议你参考更多的人的做法，以便出现任何意外情况时能够知道如何应对，于是下面是我参考的一些链接。当然，除这些链接外，你应该也会自己寻找一些其他链接，以及能够在出现问题时使用谷歌搜索找到解决方案。

 - [oing写的 OnePlus3T 从解锁 BootLoader 到 Xposed](https://oing9179.github.io/blog/2017/01/OnePlus3T-from-Unlocking-Bootloader-to-Xposed-Installed/)（推荐阅读）
 - [XDA - Recovery : Official TWRP for the OnePlus 3T](https://forum.xda-developers.com/oneplus-3t/development/recovery-twrp-oneplus-3t-t3507308)（推荐阅读）
 - [OnePlus 3T: How to Unlock Bootloader | Flash TWRP | Root | Nandroid & EFS Backup and More](https://forums.oneplus.net/threads/guide-oneplus-3t-how-to-unlock-bootloader-flash-twrp-root-nandroid-efs-backup-and-more.475142/)
 - [How to Install TWRP Recovery and Root OnePlus 3T](http://www.stechguide.com/install-twrp-recovery-and-root-oneplus-3t/)

oing在我搞这些之前对我的一些问题进行了答疑，再次感谢。

另外关于我不装OpenGApps，只是我个人不依赖谷歌的云服务全家桶而已。我只用个GMail而且邮箱名本身就很奇怪，GMail我也可以单独安装，另一方面本身OnePlus就带有谷歌服务框架，我装GooglePlay后会自动激活谷歌应用框架，于是不刷这个OpenGApps也行。

其余暂时没遇到什么特别的需要记的东西了。于是黑wp时间到。

## 垃圾WP

最初买WP是因为我当时看 Windows 画的 Windows 10 大饼的确挺吸引我，我那时候忘记是装的 Insider 版本的 Windows 10 还是升级过来的 Windows 10 了，感觉如果真如巨硬所说，手机和电脑协作（continuum）会巨有生产力（一定程度上说我是奔着这个去的），那岂不美哉？正赶上红米质量问题蛋疼了，于是脑子一抽，买了 Lumia 640。

由于当时的宣传都是画饼，当时销售的手机还都是 WindowsPhone 8.1 系统，微软说给所有wp8手机都推送w10m系统更新享有新特性，于是我就直接选了官网推荐的Lumia640，最后在苏宁易购购买。

手机到手后，巨难用。我需要第三方软件去达到快速关闭手机流量的需求，以及的确没什么应用可用，不过还好，有QQ，有微信，有云音乐，有第三方知乎（当feed看的），有博客园（当Hackernews看的），也有支付宝。好在我没什么别的需求，就这么凑合的用了一段时间。后来系统更新发现提示存储空间不足但我又腾不出地方了，并且我也的确有些受不了那些反人类的设计了，于是升级到了预览版的w10m。

预览版的w10m的确改了很多痛点，比如我终于可以下拉快速关闭流量了（WTF）什么的。然而东西依然只是凑合能用的成度，后来，巨硬宣布，必须达到xxxx标准的手机才可以使用continuum，于是我的lumia640就这么被微软正式宣告成为垃圾功能机。再后来，wp跑安卓的项目被砍了，wp的一堆新特性国内也用不了，能用的还都一堆毛病（正式版出来我就切回正式版了，还是一堆毛病，闪退什么的）。最后，一些应用开发者相继不陪着巨硬玩了，于是知乎日报和豆瓣一刻跪了，我手写了rss源生成并改用了rss阅读器，博客园不维护了，我接着rss，支付宝跪了，我的刚需，我去学校外面吃饭不带钱的唯一方式都没了，于是我觉得，是时候给wp说再见了。

事实上我觉得，系统好与坏实际比不上有个好生态，某种程度上和IM软件或者别的社交软件一样，没人陪你玩了，你活不下去的。于是我就这么“享受”了一年多没红包的QQ（这本身到没啥，我用redmi note的时候也一直在用没红包的国际版QQ），没扫码支付的支付宝（于是卖饭的都认识我了，直接输手机号转账付的），没云盘的云音乐（于是我写了PrivateCloudMusic，当然后来良心网易云更新支持音乐云盘了），以及自家应用都会崩溃的“高”质量UWP...

抛去应用质量而言，系统本身也是有很多黑点的，除了上面提到的w10m才解决的快速切换区，uwp不能独立设置代理也很不方便（于是我自己的丝袜服用不成，wp我就从来不指望科学上网了），以及电话本的匹配到现在都有问题（我给家里打电话有时会被加播国际区号，当然，还好打不出去，提示我没开国际拨号业务），以及w10m的短信我都没找到区分1，2卡的除了看颜色之外的方式。自带小娜几乎是逢问题就开必应网页的（有一次推送广告说可以问小娜找我的手机在哪里，而这条推送我电脑却没收到，想了想我手机要丢了我估计也看不到这条推送，然后我闲着试了试按着提示问小娜我手机在哪，结果给我打开了必应搜索...）

哦对了，我至今没在wp上找到一个能后台播ogg音频的软件。edge浏览器也不支持ogg这个“包装”...

另外有趣的是，我用WP后，我的PC主力系统就变成Debian了，当然后来换成Arch，一个Linux用户（虽然算小白）配着使用一个WP，听着也挺别扭的吧。

最后，现在有了安卓用，的确舒服了很多吧，以及，我觉得对于我这种不是在任何时候都喜欢自己折腾的人，iOS的确也是个不错的选择吧，不过也太贵了...

下午5:34补：垃圾wp，想迁移个通讯录，人脉联系人不能导出vCard格式，联系人转存到SIM卡功能完全不管用。微信的通讯录备份也不管用了，登录不上。  
15日中午12:50：昨晚我爸问我wp怎么改成自己的铃声，我才想起我用了一年多的默认铃声，然后试了半天没发现哪里改铃声，百度（没用谷歌）之，说wp8可以把mp3放到 `铃声` 文件夹就可以被识别了，试了试不好使（当前w10m），后来应用商店下了个叫 `铃声制作` 的来自微软的应用才改成......
