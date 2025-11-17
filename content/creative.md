---
title: "Creative"
subtitle: "Check out what I created."
aliases:
  - 'Creative.html'
---

Since I am interested in a lot of stuff like programming and music producing, I created lots of "Things" like my open source projects and my soundtracks / remixes (and maybe my artwork someday?). So here you can get a list of projects.

## Programming

Here is a list of projects I am / was working on. Most of them are open source project and host on my [GitHub](https://github.com/BLumia/). There are also some projects not maintained by me but I was taking part in development, just check it out if you are interested.

Most newer projects come with a license file, please refer to them for licensing details. If there is no license file for a repo but you would like to use it, you may need to submit an issue or contact me directly.

### My Working Gears

 - [Visual Studio Code](https://code.visualstudio.com/) and [code-server](https://github.com/coder/code-server) IDE for general purpose development.
 - [Zed](https://zed.dev/) In case sometimes I don't want to use VSCode.
 - [Qt Creator](https://www.qt.io/download-open-source/) My "RAD" IDE for Qt and/or C++ related development.
 - [Visual Studio Community](https://www.visualstudio.com/vs/community/) Free IDE offered by Microsoft, for some of my project on Windows.
 - [Kate](https://kate-editor.org/get-it/) Taking notes, plain text editing.
 - [MSYS2](https://www.msys2.org/) When working on Windows C/C++ projects.
 - [Vim](http://www.vim.org/)/[NeoVim](https://neovim.io/) with [NvChad](https://nvchad.com/) ~~Edit config files~~ Help poor blumia in Uganda!

### Active Projects

> [!NOTE] This section is outdated, please see ["Applications" page]({{< ref "apps" >}})

// TODO 19-12-09: update this page.

{{< details summary="[Private Cloud Music](https://github.com/BLumia/Private-Cloud-Music) a really simple and easy to use online music player." >}}

Private Cloud Music, short for PCM. It's a really simple and easy to use online music player, designed for quick private music hosting and sharing.

The project contains a single PHP script to provide the PCM API (Actually there is also a [Go version](https://github.com/BLumia/CloudMusicGo)) and all you need to do is upload it and your music files.

[Jxpxxzj](https://github.com/jxpxxzj) also did a react version of PCM front-end, [check it out here](https://github.com/BearKidsTeam/private-music-react).

I also wrote an [Android client](https://github.com/BLumia/PCM-Droid) for support offline listening and multi-server switching, but since I'm new to android, that android app is just.. emm.. doesn't works like what I want.
{{< /details >}}
{{< details summary="[Pineapple Synth (Mini)](https://github.com/BLumia/PineappleSynth) a simple subtraction synthesizer (VSTi)." >}}

This is a simple subtraction synthesizer, delivered as VSTi plugin for DAWs like Cakewalk SONAR, FL Studio and etc.

Since it's just a simple synthesizer, and the project need a redesign [for some reason](https://github.com/BLumia/PineappleSynth/issues/2). Future development may comes with another new repo(omit the "mini" word from the project name). But I don't have enough time to working on this, maybe someday..
{{< /details >}}
{{< details summary="[TouHou Player](https://github.com/BearKidsTeam/thplayer) a TouHou BGM player for all platform." >}}

Co-op project with [Chris241097](https://github.com/chirs241097) .

This is a TouHou BGM player for all platform, with directly support for Linux, tested under my laptop (running Arch linux and Windows 10) and chris' laptop (running Gentoo).

Thanks to [thpacth/thtk](https://github.com/thpatch/thtk/), this player support all majer version (>=th07) of TouHou game. And it's possible to run under Mac but I can't test it since I never have a Mac computer.
{{< /details >}}
{{< details summary="[Pineapple Pictures](https://github.com/BLumia/pineapple-pictures) a simple Tencent QQ style image viewer." >}}

This is a very casual project for my personal use, and it just works under both Windows and [Archlinux](https://aur.archlinux.org/packages/pineapple-pictures-git/).

The reason of this project is just because the default image viewer under Windows cannot play gif animation and the UWP version of the new image viewer start so slow and it's too fat for me. Then when this project become usable, I found it also works fine under my Arch KDE desktop and feel it way more comfortable than using Gwenview.

Since this project is not for people other than me at all, I still list it here in case someone may like it.
{{< /details >}}
{{< details summary="[Mutter](https://github.com/BLumia/Mutter) a lightweight scaffold for blogging and creating web pages." >}}

Mutter is a lightweight scaffold for blogging and creating web pages. It's free and open source, and it works on any hosts which provides a PHP enviroment like LAMP, WAMP, LNMP, etc.

Mutter is created for this site which you are visiting, and designed to be portable(so no composer, no extra plugin installation required) and hackable(means if you want to use it, you need to edit the source code to fit your need).
{{< /details >}}
{{< details summary="[Awesome](https://github.com/BearKidsTeam/Awesome) a simple and lightweight stuff-sharing web app. " >}}

Awesome is a simple and lightweight stuff-sharing web app write in django.

The original purpose is create a site for easily stuff sharing, but it's still complex than I've ever thought. Maybe you can treat this as a half-archived project.
{{< /details >}}

### Learning Purpose Projects

Some of my projects are write in learning purpose, comes with bearly no document but they are still functional. Maybe it is helpful for you?

{{< details summary="[Lajihttpd](https://github.com/BLumia/lajihttpd) a **high concurrence** HTTP server for static files." >}}

This project's goal is write a **high concurrence** HTTP server for static files. Refer to the repo's README file for more details.
{{< /details >}}
{{< details summary="[LajiPan Server](https://github.com/BLumia/LajiPan-Server) and [Client](https://github.com/BLumia/LajiPan-Client) a distributed cloud storage service with server and client." >}}

This is a distributed cloud storage service (like dropbox, BaiduPCS, etc) with server and client. Server using a [GFS-like](https://en.wikipedia.org/wiki/Google_File_System) approach to implement a distributed file system, using [Moduo](https://github.com/chenshuo/muduo) for request handling. Client built with Qt.

Nearly no document(we got a [slide](https://blumia.github.io/LajiPan-Server/), but I don't think it's useful for you) and usage for this repo. I also almost forget how to use it. Dig into the source code if you really like.
{{< /details >}}
{{< details summary="[udptun](https://github.com/BLumia/udptun) a L3 VPN program WITHOUT ANY encryption and obfuscation support." >}}

This is actually a L3 Virtual Private Network program WITHOUT ANY encryption and obfuscation support.

There is a blog post(Chinese) for this repo. [See here](https://www.cnblogs.com/blumia/p/Make-a-simple-udp-tunnel-program.html).
{{< /details >}}

### Archived Projects

Some of my projects are old or stopped for support for some reason, or just archived because there's no need for update. It may still works and maybe in someday I will probable pick up some projects.

{{< details summary="[BLumiaOJ](https://github.com/BLumia/BLumiaOJ) a HUSTOJ compatible, Online Judge system." >}}

This is a HUSTOJ compatible, Online Judge system's front-end.

Actually I was planning to write a judge core to make it become a fully functional Online Judge system, but for now I think it's not necessary to reinvent the wheel. So please use HUSTOJ's judge core or write your own, refer to the repo and check out the README file for more details.
{{< /details >}}
{{< details summary="[BLumia's Timidity Shell](https://github.com/BLumia/BLumiaTimidityShell) a Timidity / Timidity++ shell program." >}}

This is a Timidity / Timidity++ shell program. A simple GUI program for midi playback and batch midi->wav convert with timidity. The project started at about 4 years ago, quite old. I recently fixed some bug for my friend who want to use it, but since the codebase is ugly for now, I'm not going to continue develop this program.

If you are looking for a MIDI player with soundfont support, checkout [Chris241097/QMidiPlayer](https://github.com/chirs241097/QMidiPlayer), whick can run on both Linux and Windows.
{{< /details >}}
{{< details summary="[ShadowPlayer::BLumia](https://github.com/BLumia/ShadowPlayer-BLumia) a fork of [ShadowPlayer](https://github.com/ShadowPower/ShadowPlayer) with a-b loop, osu! style mini UI and playlist autoload features." >}}

It's a fork of [ShadowPlayer](https://github.com/ShadowPower/ShadowPlayer) by [ShadowPower](https://github.com/ShadowPower). With a-b loop, osu! style mini UI and playlist autoload features.

At that time I upload ShadowPlayer to GitHub, I didn't know how to use git, so I uploaded some compiled stuff inside the repo. Just ignore them is okay, I am a little bit lazy to do a clean up.

Fan fact: It is an archived project, but I am still using it under Windows till now! Maybe I am the only user since ShadowPower doesn't even use his version..
{{< /details >}}
{{< details summary="[GUI Masser](https://gitee.com/blumia/GUI-Masser) a WYSIWYG GUI editor for older Torque Game Engine." >}}

This is a WYSIWYG GUI editor for older Torque Game Engine(now it called Torque3D, I'm not going to link it here since GUI Masser may won't work with the new engine). The main purpose is write a GUI editor for the game Marble Blast to make modding easily. I and some of my friends were creating a mod named Happy Roll at that time.
{{< /details >}}
{{< details summary="[TGE dif Tester](https://blumia.github.io/2014/08/10/TGE-dif%E6%96%87%E4%BB%B6%E8%B0%83%E8%AF%95%E5%8A%A9%E6%89%8B-%E8%BD%AF%E4%BB%B6%E5%8F%91%E5%B8%83%E9%A1%B5/) yet another project for the Marble Blast mod." >}}

Yet another project for the Marble Blast mod. Source code... may upload someday.
{{< /details >}}
{{< details summary="**Happy Roll** a mod of game Marble Blast, makes me know a lot of people and we becomes great friend till now!" >}}

A mod of the game Marble Blast.

For copyright reason I can't upload the game file here since it contains the original game's binary. And it ended with beta version with severial new gameplay modes, awesome levels and soundtracks.

We may release some of the content somedays, but not now. Also, if we comes up with a really great idea for making marble rolling game, this project may be picked up somedays, and comes with a brand new game, not a mod(to avoid copyright issue).

Thanks by the mod creating and another game Ballance, I knows a lot of people and we becomes great friend till now! In someway to say it changed my life!
{{< /details >}}
{{< details summary="[Typecho2Hexo Helper](https://github.com/BLumia/Typecho2Hexo-Helper) a script for Typecho to Hexo archive exporting." >}}

This is a helper script for people who wants to move his archives from Typecho to Hexo. I list this repo here because it's still very useful if you want to do that.

This script will save your archives with YAML [Front-matter](https://hexo.io/docs/front-matter.html) for hexo or other blogging engine like [Jekyll](https://jekyllrb.com/) or [Mutter](https://github.com/BLumia/Mutter)!
{{< /details >}}

*There are also some project doesn't list here because IMO it's useless or I just couldn't. You can find some of my ~~forbidden~~ antique project in somewhere if you got crazy finding my old stuff.*

### Not My Projects

There are also some project which is not mine but I taking part in the development / testing / other contributions, more or less. Listed below.

{{< details summary="[Deepin Desktop Environment](https://github.com/linuxdeepin/dde-file-manager) for the distro *deepin*." >}}

Deepin Desktop Environment, or DDE, is a linux desktop enviroment mainly designed for the distro [Deepin](https://distrowatch.com/table.php?distribution=deepin) (be aware, this linked to the distrowatch site) but also available under Archlinux, Fedora, Gentoo and other linux distro. I used to take part in maintain DDE componments include DTK and some DDE apps like Deepin File Manager.

Actually I **was** an fulltime employee in Wuhan Deepin Technology Co.,Ltd. , and that's what I did mainly works on. I also managed to review and help merge some community patches from GitHub, but due to some internal reason, not all community patches can get merged into the main codebase...
{{< /details >}}

{{< details summary="[Fidel Dungeon Rescue](http://store.steampowered.com/app/573170/Fidel_Dungeon_Rescue/) a fast-paced puzzle crawler game (beta testing and translation)." >}}

Fidel Dungeon Rescue is a fast-paced puzzle crawler game. I helped do beta testing and zh-CN translation.
{{< /details >}}
{{< details summary="[7Gif](http://www.xtreme-lab.net/7gif/en/index.html) a free of charge animated GIFs player for Windows (translation)." >}}

7Gif is a free of charge, features filled, easy to use and multilanguage animated GIFs player for Windows. I helped do beta testing and zh-CN translation.
{{< /details >}}
{{< details summary="[QMidiPlayer](https://chrisoft.org/QMidiPlayer) and [SMELT](https://github.com/BearKidsTeam/SMELT) MIDI player and hardware-accelerated OpenGL wrapper by Chris241097." >}}

These project created by Chris241097 is quite awesome, ~~I did taking part in but just really a little work, few lines of code~~ (no longer true since my crappy code get removed during updates, but I'll still leave this project here since it's very good, and-). I write these project into this because I hope I can contribute to the project in upcoming future.
{{< /details >}}
{{< details summary="[LearnOpenGL-CN](https://github.com/LearnOpenGL-CN/LearnOpenGL-CN) Chinese translation of [LearnOpenGL site](https://learnopengl.com/)." >}}

Chinese translation of [LearnOpenGL site](https://learnopengl.com/)

Since I am learning OpenGL before, I read the tutorial from here, and found some translation issue. To help more other people with better translation, I did join the translation group and do fix mistakes when I got free time.
{{< /details >}}
 
## Soundtracks

I make soundtracks at sometimes, in many style. I post my soundtracks at [Bandcamp](https://blumia.bandcamp.com/), [Netease Musician](https://music.163.com/artist/album?id=12194546) and also [SoundCloud](https://soundcloud.com/blumia/tracks). For the most *official* release page, please be suject to the [Bandcamp](https://blumia.bandcamp.com/) version (Global) or [Netease Musician](https://music.163.com/artist/album?id=12194546) version (if you are in China).

You can use my tracks with [CC BY-NC](https://creativecommons.org/licenses/by-nc/3.0/) license if you like. If you would like to use the track(s) in commercial project and something like that, please contact me first.

### My Working Gears

#### DAWs

 - [FL Studio (Producer Edition)](https://www.image-line.com/flstudio/) (w/o any extra plugins not included in the Producer Edition)
 - [Cakewalk SONAR Platinum](http://www.cakewalk.com/Products/SONAR) (Now it's named "[Cakewalk by BandLab](https://cakewalk.bandlab.com/)")

I got quite a lot of DAWs for playing around, some are bought from sale, some are bundled with hardware like MIDI keyboard. The DAW I got but not using will not list here.
 
#### Synth and Plugins

 - Cakewalk TTS-1 (DXi) (Free[^1])
 - SFZ / [SFZ+ Professional](https://www.cakewalk.com/Products/sfz) (VSTi)
 - [Z3TA+ 1/2](https://www.cakewalk.com/products/z3ta/) (VSTi)
 - Acoustica Instruments (VSTi) (bundled in any level of [Mixcraft](https://www.acoustica.com/mixcrafths/) DAW)
 - [Acoustica Pianissimo Virtual Grand Piano](https://www.acoustica.com/pianissimo/) (VSTi)
 - [Ample Guitar M Lite II](http://www.amplesound.net/cn/pro-pd.asp?id=7) (VSTi) (Free)
 - [AAS Session Bundle](https://www.applied-acoustics.com/session-bundle/) (VSTi)
 - [Kontakt Player](https://www.native-instruments.com/en/products/komplete/samplers/kontakt-6-player/) (VSTi) (Free)
 - [Tweakbench Peach](https://www.tweakbench.com/vst-plugins/peach) (VSTi) (Free[^2])
 - [Edirol HQ Orchestral](https://www.roland.com/global/products/hq_orchestral/) (VSTi) (DISCONTINUED)
 - [Tunefish Synth 4](https://www.tunefish-synth.com/) (VSTi) (Free)

{{< details summary="A wishlist..." >}}
 - [KORG Collection 2 - M1](https://korg.shop/korg-collection-m1.html) (VSTi) (Known lowest price at $39.99)
 - [True Piano](http://www.truepianos.com/) (VSTi)
 - [Strum GS-2](https://www.applied-acoustics.com/strum-gs-2/) (VSTi)
 - [Roland Sound Canvas VA](https://www.roland.com/global/products/sound_canvas_va/) (VSTi)
{{< /details >}}

I actually also use some other virtual instruments bundled with the current DAW which my project is using, they are not on this list because I just use them not very often.

Almost all of audio fx plugins I am using is from the current DAW which my project is using.

#### Hardwares

 - Launchkey 25

I hope this list can be longer...

### Soundtracks / Albums

I hardly have free time update my site so you need checkout by yourself at the following places for now...

Please navigate to [Bandcamp](https://blumia.bandcamp.com/) or [Netease Musician](https://music.163.com/artist/album?id=12194546) to checkout my tracks.

I also do some casual upload on [SoundCloud](https://soundcloud.com/blumia/tracks) and another private site(for personal storage), you can checkout if you like.

[^1]: Following the acquisition of the Cakewalk Inc. from Gibson Brands, BandLab Technologies announced the relaunch of SONAR as Cakewalk by BandLab and it's free-to-download to all BandLab users worldwide. As the result some built-in plugins of SONAR now become free to everyone.
[^2]: This plugin (and all plugins by Tweakbench) is free sometimes ago. Check out [here](https://web.archive.org/web/20170804143220/http://www.tweakbench.com:80/archives) for more details.
