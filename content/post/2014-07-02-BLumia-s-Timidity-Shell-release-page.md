---
categories: 个人产物
date: "2014-07-02T20:06:00Z"
tags:
- 个人产物
title: BLumia's Timidity Shell软件发布及更新页
aliases:
  - /个人产物/2014/07/02/BLumia-s-Timidity-Shell-release-page.html
---

> 2020/05/30 edit:  
> 这个软件已经很久没维护了，个人也不是特别建议使用，这个页面仅作归档保留目的。  
> 如果您有对本地 .mid 格式文件支持使用指定 soundfont 进行回放的需求，建议考虑尝试 [Chris 的 QMidiPlayer](https://github.com/chirs241097/QMidiPlayer)，它能够跨平台使用，且功能非常完善，非常值得尝试。

软件信息：

![软件主界面（未展开播放列表时）](http:/blumia.github.io/media/bl_timidity_shell_screenshot.png)

 - 软件名称：BLumia's Timidity Shell 
 - 软件版本：Build 122 （Banana 122 - 20180126）
 - 软件类型：开源midi播放器 （[源码](https://github.com/BLumia/BLumiaTimidityShell)）
 - 软件下载地址：[GitHub Release](https://github.com/BLumia/BLumiaTimidityShell)   [BLumia的分享盘载点(旧版)](https://garysoft.wodemo.com/file/305609)  [霏凡软件站载点(旧版)](https://www.crsky.com/soft/62713.html)   [2345软件站载点(旧版)](http://www.duote.com/soft/4194.html)

<!--more-->

软件简介：BLumia's Timidity Shell是一个方便简单的midi播放器，支持自定义音源（SoundFont），支持将midi转换为wav格式音频。是一个基于Timidity调用的播放器。 BLumia's Timidity Shell可以方便的将midi使用自定义的音源播放，你可以从网络上获取对应你的midi的sf2音源用以播放midi。软件支持关联midi文件，支持拖放即播放midi文件，支持aero皮肤，支持查看控制台状态。
播放列表使用帮助：

1. 可以通过导入文件夹的方式导入mid，但请注意，文件夹内若有子文件夹，其内的mid也将被导入
2. 可以通过Delete键删除列表中的选中项目
3. 可以通过Insert键添加mid文件到列表
4. 支持导入和保存列表
5. 列表播放和批量格式转换都是从选中项开始进行到最后一项停止，若未选中任何项则默认选中第一项。

---------------------------

嘛。。这是我去年某天心血来潮研究制作的一个播放器，其实是基于[chirs同志的一个播放器](https://chrisoft.org/#projects)的改造增强版。说起来也只是为了方便懒虫使用timidity的。软件可以可视化选择音源文件方便加载，可以列表播放，也可以批量将mid使用指定音源转换为wav。虽说是简陋的播放器，不过相比一些基于wmp调用或者xx控件实现的，至少高级一些。

软件的最显著缺点就是。。。没有进度条，不能调整播放位置。当然，我有打算使用fluidsynth来搞一个原生midi播放器，到时候会更高级一些了.

Build118的更新其实很搞笑，最初chirs在关于页面埋下的彩蛋我从来没注意过，于是这回知道了这儿还有个彩蛋。。于是我给完善了一下彩蛋= =然后修复了一个bug，别的没啥..

Build119的更新其实在意料之外，今天在外突然就发现QQ有好友添加提示，备注有写Timidity字样于是就加了。然后发现的确是我这个软件反馈bug的人，我自己都很意外。下午回到家后修复了bug，并且和反馈者交流了一下。发现他也很棒。是研究生，还搞出过[这样高级](https://www.guokr.com/post/480573/)的东西。关于大学之类的他也给出了一些建议，不管怎样，非常感谢他。

至于这软件会不会再次更新的问题...如果依然发现有存在问题我就更新，别的特色就不加 了。最近有计划写一个基于bass库bassmidi的midi播放器，当然会比这个高级很多，所以这个软件如果不出什么差错的话就不再维护咯。

就是这样

-------

Build 122 更新说明：将近四年前的软件，竟然更新了... 原因是神犇 [2jjy](https://github.com/instr3) 搞的什么深度学习识别和弦的神奇 proj 大概需要批量转 mid 到 wav 于是正巧用到了，提到有 bug 就顺带修了。包括文件格式判断的，以及程序单实例工作机制的...修复后顺带把代码也扔 GitHub 上了。 

于是现在看自己四年前的代码写的真是蠢啊.. 顺便， Lazarus 这 IDE 怎么到现在还是这么奇葩...
