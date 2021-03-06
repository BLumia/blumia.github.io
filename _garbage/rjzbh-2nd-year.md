---
title: 两年期的软件正版化尝试
date: 2020-10-01 17:03:00
---

*几乎是流水账性质的文章，阅读的意义不大*

[上一篇文章](https://www.blumia.net/garbage/rjzbh-1st-year)写好了后忘了及时发出来，后来的一段时间越来越忙于是就忘掉了这回事。现在逐渐不再那么忙的时候才发现快又过去一年了，索性另写一篇出来，也和上篇能做个对比。

说来也奇怪，就在前不久，由于我的新住处网络很糟糕于是在尝试 SimpleDnsCrypt 来解决一部分问题时，意外发现在 chrome 启动时会有奇怪的 DNS 请求的情况[^1]，非常像是有恶意软件，但我的新电脑开始用到现在都几乎没有用过任何来路不明的软件，后来尝试定位了一下也没找到是哪个进程在作怪，倒是发现了当初没删干净的 OEM 的 McAFee 杀毒软件...最后省事起见还是选择了重装。也算是回到了一个干净很多的环境吧。

[^1]: 这篇不是为了讲这件事，不过如果感兴趣的话，我遇到的情况和 https://www.v2ex.com/t/661712 这个帖子的描述完全一样，目前怀疑也是联想 OEM 软件不干净，实际则没精力去研究了。

## Setup

重装后我的常用软件也在后续的一段时间内分别装了回去，下面是我目前的软件使用情况清单：

  \       | Windows								| Linux(x11)
----------|-------------------------------------|-----------
IDE       |Visual Studio Community, QtCreator	| QtCreator
DAW		  |Cakewalk by BandLab, FL Studio Signauture Edition | N/A
NLE		  |DaVinci Resolve, Kdenlive			| Kdenlive
3D建模	  |Blender								| Blender
录屏和串流  |ShareX, ScreenToGif, OBS Studio		| OBS Studio
音频编辑器  |OcenAudio, Audacity					| Audacity, OcenAudio
文本编辑器  |Kate, Visual Studio Code, Geany, Notepad++ | Kate, Visual Studio Code, Geany, Notepadqq
虚拟机     |VirtualBox							| VirtualBox
位图编辑器  |mspaint, [Paint.NET](https://www.getpaint.net/), Affinity Photo, Krita | Kolourpaint, Krita, GIMP
矢量图编辑器|Affinity Designer, Inkscape			| Inkscape
涂鸦		  |FireAlpaca							| N/A
音频播放器  |ShadowPlayerBL						| pineapple-music
视频播放器  |PotPlayer, mpv, VLC					| mpv, VLC
浏览器	  |Chrome, Firefox						| Chrome, Firefox

IDE 方面其实没啥变化，不过由于目前工作并不再是完全在 Linux 中进行，所以 VS 的使用比重有所提升。另外由于工作内容很散，也会用一些别的 IDE，比如 Android Studio 之类，至于同事推荐的 CLion 之类则没考虑用，毕竟那个价格并不便宜，我的使用频率也不高，也不知道能提高多少甚至能不能提高生产效率...DAW 方面，FL 从 Fruity 升级到了 Signauture 版本，Fruity 缺乏音频编辑功能，而这个功能还是太重要了。如果有需求还需要拿到别的地方处理还是很麻烦的。视频编辑方面，Resolve 虽然是免费的但是下载还是太麻烦了（虽然我有屯安装包），而且甚至没有单独保存的工程文件还是让我用着不是很踏实。Kdenlive 在 Windows 下的表现还是一如既往的容易炸，但版本迭代来看目前似乎好多了，尽管还是得多按着点保存。建模工具我基本很少用上，倒是前段时间做了一个 ballance 关卡用到了，并且体验还算不错（虽然我还是不会用的程度）。或许今年晚些时候还会用一次，或许到时候会更熟吧。

录屏和串流工具没啥变化，深度录屏被换掉了，由于新版的实在不敢恭维。Windows 上的文本编辑器则由 Geany 换成了主要使用 Kate。Notepad++ 不知道哪次更新开始 break 掉了暗色主题下的 Markdown 中文渲染，打开之后全是白的，于是几乎变成没法用的程度了...矢量图编辑器上了 Affinity Designer，其实尝试了 Inkscape 做比较复杂的 svg 图形，然后发现崩溃率很高，操作也很复杂，最后甚至发现视口的效果和存完了别的软件查看到的效果可能不一样...由于 Affinity Designer 的需求，也顺带买了 Affinity Photo，不过并不常用就是了。

音频播放器方面，由于自动导入当前目录的文件到播放列表的需求很大，于是后来在 Linux 中自己用 Qt 顺手写了个凑合用。视频播放器则是发现 mpv 非常顺手后就逐渐的开始转用 mpv 了。至于浏览器，尝试过几天的开始重度使用 Firefox，发现很多体验方面的细节问题，最后还是回到了 Chrome...

## 免费与付费，自由与非自由的选择

上面其实列举了去年到今年里这个表格中一些变化的原因，有的时候用自由或非自由的免费替代确实会不顺手，然后考虑到时间需求需要 get the job done 就只能先考虑用付费商业软件了，而在有充足的时间和精力的时候，则会考虑支持下自由软件以及一些尽管是非自由但是仍然免费的软件。

但其实帮助改善自由软件提供有用的贡献也是很麻烦的一件事，比如 gitea 社区响应贡献者的速度就非常的缓慢，可能是由于维护人员的精力不足吧。又如很多软件或社区仍然在以邮件列表的形式接受讨论，使得不适应的人（我）甚至不敢提供反馈[^2]。

[^2]: 以及打 IRC command 的时候，给我一种 deploy in production 的感觉，如果格式什么的有问题没法直接改，所有人都看得到，非常丢人。

另外，尽管是自由软件，有时候使用时也会有一些无奈。一个软件的背后可能是一个希望把它做好的维护团队，也可能只是一个闲暇时间开发然后分享给大众的个人。每个软件的定位，目标，支持程度都是不同的，故有时候一个软件可能确实可以朝着某个方向进行修改，但原作者并没有意图（比如设计如此的情况）或没有精力去对它进行修改。诚然，我们有权利派生一个新的分支出来自己动手做，但显然并不是所有人都有这种能力，即便有能力也不见得有这种精力。所以当发现一个软件不能满足自己使用需求的时候，转而使用别的软件也是没办法的事情。而由于自由软件并没有人去约束软件本身必须达到何种标准才能发布，故这样的事情发生在自由软件上的情况或许相对更多一些。

于是上面的表格中，能选择自由软件的我基本选择了自由软件，而若自由软件不能满足要求时，就只能按实际情况看怎样的折衷方案比较不疼了。下面则是一些例子：

### Blender

Blender 是一个相当正面的例子。即便是早于 2.8x 的版本，在稍微上手后也能很好的完成需求，而 2.8x 版本后的 UI 改善 也大幅改善了 UX，降低了门槛和学习成本。早些时候在帮助码喵接触 Blender 2.8x 时，也确实发现了 bug，不过能够稳定复现问题后我就[汇报在了 Blender 的 Jira 上](https://developer.blender.org/T78037)，拜开源所赐，我也在官方处理此问题前通过阅读源码定位到了导致问题的代码（尽管当时并没有把握说我的修复就是正确的修法），最终 Blender 也在主线修复了这个问题并 cherry-pick 到了 LTS 版本中。以及后续一段时间内，Chris 和 yyc 两位爷爷在研究 ballance 制图相关的内容时，yyc 也开发了一些特定于 ballance 的制图相关的插件。

这些例子确实可以很大程度说明开源软件的优势了，我们可以获取软件后使用它自由的创作而不需和软件开发商共享版税分成，也可以从源码自行构建处理遇到的问题或是反馈给官方一同改善软件本身，Blender Foundation 和它的社区目前非常健康，处理问题也非常及时。另外我们也可以自由的使用其软件进行二次开发来辅助我们完成任务。这种情况下，对于我来说，似乎没有什么理由再去选择昂贵的同类专有软件了。

### Flym

我一直都有订阅自己常看网站提供的 RSS 来获取最新文章的习惯，Flym 则是我在手机上所使用的客户端。不过由于家里人并不懂英文，故家里并不会用这个软件。好在是自由软件，于是提供了一个 PR 来翻译软件界面到中文。尽管是独立的个人在维护，但还是很及时的处理了 PR，最终也包含了中文，家里也就可以无障碍的使用这个软件了。尽管专有软件进行汉化很多时候也不是很困难，但对自由软件进行这样的贡献显然可以帮助到更多人，即便原作者不打算进行这样的维护，我也可以很轻松的完成汉化然后打包给家里用以及分发给其它需要的人。

类似的，我也和一些其他的软件提交过中文本地化翻译，以及一些其他的特性方面的 PR，我可以轻松的按我的需求进行更改，也可以贡献出去帮助到更多人，这里就不再列举其他的了。

### Inkscape -> Affinity Designer：

因为我并不是一个专职设计师，编辑 svg 基本是我制作矢量图的几乎唯一的需求了，而宣称 [uses the standardized SVG file format as its main format](https://inkscape.org/about/) 的 Inkscape 看上去非常符合需求[^3]，实际上我曾经也使用 Inkscape 做过一些不算复杂的小图标给我的程序用。但后续的一次打算给 Chris 的 QMidiPlayer 制作图标的尝试则发现了更多的问题。一方面，很多较为高级的操作的操作方式看上去都很反直觉，需要搜索才能知道我预期的做法应该怎样操作。另一方面，发现同样的需求，进行同样的操作步骤，却无法达到相同的效果（很可能是 bug，但我不是专门做图标设计的，有些步骤甚至不知道怎么描述清楚，就别提反馈 bug 了）。当然最蛋疼的是，当终于做出比较近似预期效果的图时，却发现[保存出来的 svg 图片](https://blumia.github.io/media/qmidiplyr-inkscape.svg)在任何 Inkscape 之外的软件中都无法得到 Inkscape 中所显示出的效果...

[^3]: “符合需求”这个表述，脑子里的第一反应是 sound promising，不知道怎么原味的用中文表述...

由于我根本无法提供合适的 bug report，按 Inkscape 的更新频率来看我也不能指望能多快去修复，于是只能考虑换别的。Adobe 的订阅制加昂贵的价格属于我无法接受的程度，于是 Affinity Designer 成了比较好的选择。尽管一开始尝试导出 svg 发现效果并不理想，简单搜索后发现其实是我的操作问题，后续尝试发现确实还可以，很多操作也很符合直觉，于是当需要制作较为复杂的矢量图时，就选择用它了，无奈之举。

### GIMP -> 任何不是 GIMP 的软件

我的图像编辑需求很少，而且几乎从来都不至于动用重型的图像编辑器，并且我比较确信 GIMP 的编辑功能可以涵盖我的几乎所有实际编辑的需求，但 GIMP 的操作逻辑相比更加的反直觉。但凡稍微复杂一点点的需求都没法直接反应过来应当怎样操作，以至于每次稍微复杂一些的需求我都要查一下才能用，然后过不了几天就又忘了，下次还得重新查...

于是很期望 GIMP 啥时候能学学 Blender 能有一次更新宣布一个 Revamped UI，但搜了一下发现 [他们确实有 UI 重新设计相关的页面，但不见动静](https://gui.gimp.org/index.php/GIMP_UI_Redesign)，于是我还是换别的用吧...

事实上由于我的编辑需求很简单，大部分操作在 mspaint 下都可以完成，于是 mspaint 和 kolourpaint 成了首选，稍微复杂的需求则用 [Paint.NET](https://www.getpaint.net/) 或 Krita（尽管 Krita 并不是专门进行图片编辑的软件）之类，抠图的话有时候甚至会用 Paint3D（Windows 10 带的那个）或者 PowerPoint （对你没有看错，PPT 是可以抠图的）。若真的都没法满足需求则再考虑 Affinity Photo，毕竟这个我也不算熟悉，该查怎么操作还是得查，但至少操作比 GIMP 符合直觉...

### Kdenlive <-> Davinci Resolve

我在 Linux 桌面环境的时候用 Kdenlive 感觉挺顺手的，但 Kdenlive 的 Windows 版则一直都比较感人，崩溃的概率比 Linux 下要高的多。鉴于此，后续还是尝试了比如 Resolve 之类的视频编辑软件。Resolve 确实比 Kdenlive 要顺手很多，比如非常方便的交叉叠化和字幕/文字生成工具之类。若在 Kdenlive 中进行交叉叠化，则很难调成和 Resolve 中相近的效果（Kdenlive 中无论怎么调都会中间暗一下），并且步骤比 Resolve 也多一些。

不过 Resolve 甚至不暴露工程文件的概念给用户，使得视频编辑过程还是让自己不太安心（遇到过一次，编辑没问题，渲染一定会在最后失败，怎么调都不行），而且 Kdenlive 直接支持很多格式的导入编辑， Resolve 中则需要先转格式，加上 Resolve 非常肥大并且下载需要先填表，于是 Kdenlive 在更多时候成了首选，尽管确实没 Resolve 编辑更顺手，但 Kdenlive 总体还是很不错的选择，甚至体验优于之前用过的一些其他的专有付费软件了。

### SPBL, pineapple-\*

因为别的软件无法满足需求的情况确实也存在，我其实因此也造过轮子，比如我比较依赖音频播放软件的自动载入当前目录文件作为播放列表的功能，也基本不希望别的软件帮我管理我的文件的行为存在，于是这种需求毙掉了一大票甚至可以说几乎所有的音频播放器。因此我的音频播放器长久以来都在用一个修改自 [ShadowPlayer](https://github.com/ShadowPower/ShadowPlayer) 的 [派生版本](https://github.com/Blumia/ShadowPlayer-BLumia)，而在 Linux 中则是 [顺手写了另一个](https://github.com/Blumia/pineapple-music) 凑合用。图像查看工具也类似，Windows 自带的图像查看器看不了 gif，UWP 的那个又太慢了，我也不希望有图像管理功能，也希望操作方式能尽可能接近 QQ 原本自带的看图工具（因为确实感觉很顺手），于是最终也是 [自己写了一个](https://github.com/Blumia/pineapple-pictures)。

这些看上去像是初学界面库的人写的哈喽沃德的程序尽管可能对于除了我之外的人并不实用，但至少也满足了我的需求。以及这种需求而言，大概比 fork 一个拿来改要轻松一些吧。

## 结论和建议？

如开头所说，这篇几乎是流水账性质的文章目的并不在于说服你应该怎么做，但一定要写个结论或者建议之类的段落出来的话，我还是建议在条件允许的情况下，尝试一下不再随大流的使用一些昂贵的专有软件的盗版，如果你是能决定工作环境所使用工具的决策者的话，也建议在足够的调研后考虑选择能够符合自己需求的自由软件替代。

这两年内我确实也有使用我实际没有使用许可的应用，例如我有一次非常好奇于是就去找了个不清真版本体验了一下 zbrush 2020 ，尽管只是开了几次，完全没打算真正拿来去做东西。所以如果真的要说完全使用“正版软件”的话，我觉得并不是什么做不到的事情。不过说起来在我制作我的那个 ballance 自制图时仍然使用了 Virtools[^4]，不知道这个应该怎么算（（

[^4]: 当然，我也没有 ballance 的清真拷贝。不过有趣的是，yyc 后续联系达索试图寻找更接近 ballance 所用的 virtools 版本时，达索竟然意外的提供了一份 virtools...

不过如果真的换了别人，可能就会有更尴尬的情况发生了。例如重度依赖 office 办公套件时，office 套件是没有替代品可以选择的，而一些公司也不会给员工提供正版 office。不过，也有很多情况就只是大家在随大流的使用软件，而压根没有在乎什么正版不正版，有没有许可之类。为什么用 PS？因为大家都在用，也因如此，一个在国内之前甚至很难购买正版许可的软件却早就成了图像编辑的代名词，PSD 也甚至成为了一种公认的文件交换可用的格式，而即便其他软件可能更易用且符合需求，也不会有多少用户去注意它们了，也因此，很多自由软件的“生态”也陷入了鸡生蛋蛋生鸡的死循环——因为用的人少，所以资料也少很多，能提供相应帮助的人也少很多——也因为这种种信息的匮乏，用的人也不会变多。

于是，两年过去了，我觉得我的这个所谓的正版化尝试并不算失败，也不算毫无意义。我会继续尝试这么做下去并试图发现和解决更多问题，也鼓励你，在有条件的情况下做出类似的尝试吧。

2020/10/1 17点03分
