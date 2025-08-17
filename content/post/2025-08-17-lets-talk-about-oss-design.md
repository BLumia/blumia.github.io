---
date: "2025-08-17T17:33:00+0800"
tags: ["Wayland", "设计"]
title: 来扯一扯开源软件设计
---

其实一直都很想写博客扯一些东西的，主题的话大致脑子里分两类，一类是如今的“AI”热之下的生成式绘图、“Vibe Coding”等工具的看法，一类是写个文章喷一喷 Wayland。之前苦于社畜腾不出太多时间加上懒，所以一直没成功开坑。这两天刚好不巧被传染感冒发烧了，浑身乏力啥都干不了也不想费脑子，但好在还能按的动键盘，于是来写这么一篇，扯一扯“开源软件设计”。

## 那就让我们从 Wayland 开始吧

上一段已经很明显的暴露了我的观点——我并不待见当前的 Wayland——那么为什么呢？让我来先引用一个大概大家都看过的...我暂且称之为帖子吧：[Think twice before abandoning X11. Wayland breaks everything!](https://gist.github.com/probonopd/9feb7c20257af5dd915e3a9f2d1f2277)。

这个“帖子”列举了一大堆 X11 和 Wayland 的差异，描述了很多 Wayland 现在根本不存在替代方案的功能缺失。这个帖子目前仍在频繁更新，截至当前，帖子里通过一大堆 X11 API 来列举了哪些东西 Wayland 目前还做不到，而让我们抛开 X11 不谈，作为纯粹应用程序开发者的角度，描述一下我的关注点：

1. 程序是否可以给窗口设置图标？
   - 多窗口程序可能会希望对自己的不同窗口设置不同的图标和窗口标题以让用户更好的区分不同窗口
   - 一个“程序管理器”可能会spawn其他第三方程序，例如 MC 启动器、通用的类 Spotlight 快速启动器、Distrobox
2. 程序是否可以自由的获取和控制窗口位置？
   - 使窗口位置居中展示
   - 多窗口程序，记住窗口上次被关闭时的位置以供恢复
   - 获取显示器主副屏信息，提供更好的多显示器支持
3. 程序是否可以主动置顶或取消置顶窗口？
   - 应用程序自身的临时 HUD 提示、自定义通知、参考图软件置顶等
   - 也是在 DAW 类程序中非常常见的需求

第一条的现状比较有意思，这个功能是 2024 年 6 月 6 日合入的 [xdg-toplevel-icon](https://gitlab.freedesktop.org/wayland/wayland-protocols/-/merge_requests/269) 协议提供的特性，涵盖在 [Qt 6.9](https://doc-snapshots.qt.io/qt6-dev/whatsnew69.html) 中（参考信息：最近才发布的 [debian trixie 使用 Qt 6.8.2](https://packages.debian.org/trixie/qt6-base-dev)，deepin 25 也仍在使用 Qt 6.8），而至于一众 Wayland 合成器，目前也[只有 KWin 和 Labwc 对其进行了支持](https://wayland.app/protocols/xdg-toplevel-icon-v1)。

如果认为这个协议太“新”了，那让我们顺便引用一段[来自四个月前的 Reddit 帖子的一段回复](https://www.reddit.com/r/gnome/comments/1k2cxt3/its_not_exactly_a_problem_but_im_curious_why_the/)：

> Gnome fought very hard against adding the xdg-toplevel-icon protocol into Wayland, which allows windows to set a window icon. Sebastian Wick even went so far as to propose an alternate, limited version of the protocol that would make using a different icon per window impossible. Gnome is fundamentally opposed to the idea that a program should be able to use different icons on different windows. As it currently works, Gnome uses the icon from a program's application id, and if one doesn't exist, uses that default icon.
>
> Gnome won't implement xdg-toplevel-icon, because, as far as Gnome believes, a program should only have one icon.

上面只提到 Qt 而未提到 GTK 的原因其实比较类似，GTK3 存在 [`gtk_window_set_icon()`](https://docs.gtk.org/gtk3/method.Window.set_icon.html) 供此需求使用，GTK4 虽说并没有砍掉这个 API，但[文档给定的描述](https://docs.gtk.org/gtk4/method.Window.set_icon_name.html)是：

> On some platforms, the window icon is not used at all.

而实际情况则是，除了 x11 外的所有平台都不支持（[参考](https://discourse.gnome.org/t/set-window-icon-gtk4/10183)）。

第二条和第三条则更是有趣，现状是——目前 Wayland 不支持这种功能，而提议支持此协议的提案 [ext-zones](https://gitlab.freedesktop.org/wayland/wayland-protocols/-/merge_requests/264)（以及其前身）则是打了数年的口水仗仍然处于未合入的状态，置于 API，GTK4 则是选择直接干掉了 GTK3 中可用的 [`gtk_window_set_position()`](https://docs.gtk.org/gtk3/method.Window.set_position.html)，不给应用程序任何使用此功能的机会，全然不顾 GTK 是一个（自称）跨平台的应用程序开发工具集。

## ...等等，你是不是跑题了？

其实...并没有。上述的这些问题其实是一些“Design Decision”，是一些设计理念被体现在 Wayland 与 GTK 中的例子。一些人认为“窗口不应该能随便移动自己的位置”云云，随之导致 Wayland 整个平台以及使用 GTK4 的所有程序都无法**直接**做到这点。于是我的第一个观点就是：“在做出设计决策前，应当先足够了解自己的用户群体”。

还记得 pipewire 吗？它是一个现代的 Linux 音频后端，旨在替代 Jack 和 PulseAudio，而其目前也确实做到了替代——因为它真的直接提供了替代原始平台所对应的相应功能，是个合格的平替，用户也不会感知到太大的变化。而 Wayland 则设计上有意的限制了诸多——它所意图要替代的平替（X11，甚至 Windows 和 macOS）本就能轻松完成——的行为。

于是 Wayland 到底是不是 X11 的替代反倒成了一个很有争议的有趣话题。当用户或开发者遇到了 Wayland 无法做到的事情后，很多情况可以看到“Wayland不是X11替代”的说法，而现状则是各个 DE 都将逐步放弃 X11 转而使用 Wayland。更有趣的是，现如今的 Wayland 合成器列表中，只有 KWin 和 Labwc 是层叠式窗口合成器而其他均为平铺或类平铺合成器——平铺合成器当然不会关心上面提到的几个问题，但你（Wayland）的**目标**用户都是平铺用户吗？Wayland 开发者们这辈子所用过的应用程序，上述的三个需求关注点就真的一个也没见过吗？如果没有，是不是完全不了解自己的目标用户群体？如果有...我不信（

于是说起来 Wayland 到底是不是 X11 替代品这点上，稍微有点相关的，我也不是特别喜欢把 GIMP 称为 Photoshop 的替代品——因为他们在功能和工作方式上有相比非常大的差异，甚至在 GIMP 3 之前，GIMP 完全不支持破坏性编辑，而如果以此方式把 GIMP “安利”出去的话，大概只能被对方鄙视——八成是无法用 GIMP 完成自己想做的任务的。若真的要称 Y 是 X 的替代品，那至少 X 和 Y 在所宣传的替代功能上至少有八成以上的重叠，比如 MuseScore 替代 Sibelius。

## ...我感觉你要讲完全不同的东西了

和具有强硬设计理念和态度的 GNOME 相比，开源软件中所更多面临的问题是——压根没有设计，MuseScore 2~3 就差不多是这么个情况，如果你看过我之前的博客那么你大概才得到我会[举 MuseScore 这个例子](https://www.youtube.com/watch?v=4hZxo96x48A)，因为...发这个吐槽视频的人最后成了 MuseScore 的首席设计师并[在 MuseScore 4 解决了提到的几乎所有设计问题](https://www.youtube.com/watch?v=Qct6LKbneKQ)。相比，Blender 2.8 起的蜕变其实也是个不错的例子，从 UI/UX 角度解决了大量问题，才真正吸引了潜在用户进行尝试。Audacity 也将成为一个新的例子——当然，也出自前面那位接管了 MuseScore 的设计师之手。

就个人角度而言，GIMP、Kdenlive、Inkscape 是三个我能立即想到的“糟糕的设计导致了糟糕的体验”的应用，以 Kdenlive 为例，“在视口中添加一张图片并调整这个图片使其显示到自己想要的位置”是一个非常复杂和痛苦的操作，在不知道自己要找的东西的名字的前提下，在“效果”或“合成”中找到自己想要的效果也非常困难，就更不要提时间轴动画了。这两点怎样做更合理实际也不需要我来回答，作为基础功能而言，各个免费的 NLE 软件都有对等的功能实现，Resolve、剪映（CupCut）甚至 AviUtl 都是很好的例子。

当然，“压根没有设计”有一个类似的奇怪场景：“不觉得有设计问题”。例如 [这个关于 Inkscape 部分设计问题的 talk](https://youtu.be/12TJ-zTgiH0?si=VWbkMdJ4gQKH54EQ&t=1779) 就有位老哥质疑说“关于 user onboarding”的问题对于他们的目标用户（“experts”）没有太多相关性，而倘若真的横向对比过 Inkscape 的同类软件，就会知道 Inkscape 是（无论出于何种原因）将本能简单的问题复杂化，导致只能剩下一些所谓“expert”用户了。

## ...你是在质疑别人真的懂设计吗？

委实说，某种层面上，确实是这样。很多人认为设计是个“众口难调”的东西，但却忽略了设计本身的一些硬性原则和指标，例如设计的目的（形式服从于功能）和设计有效性的衡量标准（其中有明确衡量标准的例子之一是无障碍）。前者而言，我已经亲身体会到非常多次设计/产品不理解功能的情况对着其他类似产品照搬行为的情况了，而其中很多时候也需要我来主动解释一些地方为什么在别的平台要这么做或者为什么不这么做（考虑到可能有涉密风险，此处不举例）。后者而言，最近的“Liquad Glass”则是一个非常经典的例子——官方宣传视频都可以有非常显著的无障碍（主要是可读性）问题，目前迭代了多个版本虽然确实有所改善，但初版的设计渲染视频和宣传图就存在问题就已经说明问题的严重性了——因为这是设计问题而不是实现问题——当然，也可能是出于各种原因，他们是明知有问题硬着头皮上了个有问题的版本也不好说。

当然，就前者的例子而言，好歹我还可以和相关的人直接沟通（虽然也免不了一些问题讲不通），而后者...苹果显然自己也是在改了（

## ...开源不是“你行你上”吗？

要提的最后一点则是关于设计问题的反馈上了。设计问题由于主观性很强，对于没有明确衡量标准的方面是很难有对错之分的——这就回到了 Wayland 的例子之上，比如“窗口应不应该能够知道并设置自己的位置”是一个纯粹的设计理念问题，假如决策人士全都在做售货机车机广告牌等单应用嵌入式场景或者全都日常只用浏览器、播放器和 IDE，那自然不会有人 care 为什么一个 DAW 会关心它的插件的窗口位置和缩放应当怎么管理。对于其他开源项目也类似，例如上面的 Inkscape “专业用户”的例子，或是对于一些用户基数偏少的软件可能本就是刻意的实现了一些非常规用户预期的行为。这些理念性问题的讨论导致设计问题的沟通讨论成本变得非常大。而对于一些用户数量较大的软件（比如 Firefox 和 Thunderbird），则可能因为用户数量太大而无法注意到真正有效的讨论了。

很惭愧的说，上面提到的所有项目中，我只参与过 Kdenlive 很少数的代码贡献来解决一些我遇到的使用方面的痛点问题，也试图进行过 Firefox 和 Thunderbird 的一些反馈（但都石沉大海）。我事实上有兴趣参与一些我认为会接受设计方面讨论的项目的交互设计贡献但苦于没有大片的时间。当然，好在至少我还是能看到很多有精力参与设计讨论的人在参与推动一些设计问题的改善，总而言之是好事吧。

现在嗓子还是很难受，考虑到目前感冒发烧还没好彻底，感觉我应该准备洗洗睡了。那么暂且希望这次胡扯了一篇不会显得太没道理（被喷了好拿感冒当挡箭牌（bushi

惯例，2025年8月17日22点45分。
