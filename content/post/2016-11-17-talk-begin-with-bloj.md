---
categories: 土产日杂
date: "2016-11-17T01:14:24Z"
tags:
- 土产日杂
title: 一些事情 - 从OJ开发谈起
aliases:
  - /土产日杂/2016/11/17/talk-begin-with-bloj.html
---

## 杂话

BLumiaOJ 这个repo被我闲置了大概有快一年了吧，现在因为一些事情不得不拾起来这个repo，于是打算谈一下相关的事情，当然，不止会谈OJ本身，也会叙叙事，所以这篇依然算是一篇杂记吧。

<!--more-->

## 为何打算做BLumiaOJ

所有计算机专业的基础课必定是C语言或者C++吧，我们学校也不例外，选择了C语言作为编程基础的入门课，共两个学期[^1]，伴随整个大一。略微奇怪的是，我们学校似乎意外的重视ACM/ICPC比赛，整个院上下都在鼓励参加ACM，这本身不是坏事，甚至是非常好的事情，但这个重视似乎有点过头，因为这种重视已经导致整个C语言课程都变得环绕算法题和刷OJ展开了，对，这就用着OJ了。

我称之奇怪的原因是，我个人认为，并不是所有人都愿意走ACM这条路，事实上也并不是所有人想走都能走成的，如此的话，贯彻整个大一的OJ平台为核心的教学绝对会枯燥的让人不几天就失去兴趣，并认为C语言只是个用来刷题的无聊玩意儿而已。

当时正巧在接触php，了解到学校使用的 hustoj 正是 php 写的之后，我就开始读它的代码了。hustoj 本身并没有非常复杂的代码结构和逻辑关系，于是我很快就了解了hustoj的代码结构，并开始做一些小的修改（最初只是改了改界面和加了一个非常无关紧要的功能）。

因为上面我提到的，我认为学校拿着存粹的为了算法竞赛而生的OJ去不加调整的做教学使用，必然存在很多的问题，而让学校或者老师改变教学策略基本是不可能的，于是我认为，如果OJ能够具备一些引导性的工作，应该是可以缓解一些问题的严重性的。

于是我当时参考了诸多OJ，以及一些在线教学平台（计蒜客之类），感觉方案的确可行，想了想我可以以此为动力学 html，php，js，css，sql 什么的一堆东西，于是就决定开了这个坑。

## 为何不修改现有的而是决定重写

最初的确尝试改 hustoj ，但很快发现，这套代码真要改起来并不是那么简单，一些功能有着换花样一般的实现，大量相互耦合的逻辑，因为 hustoj 开发时期早，现在一些被遗弃的东西要改就是牵一发动全身，甚至我改的时候一些逻辑读起来也不是非常方便（好多地方缩进都没...），这成大概是我决定重写BLumiaOJ的原因之一了。[^2]

除了修改困难外，也是更根本的原因[^3]，就是我当时认为我要添加的新功能还是重写比较合适，比如知识结构网，问题标签，教学资源与题目的关系关联整合，好友挑战之类。我当时觉得这些东西的工作量也许不小，所以觉得改人家的劳神费力不如重写。

不过如果较真的说，只是觉得看着不舒服又想加功能根本不足及成为一个说得过去的理由。我其实一直有一个我自己也不知道为什么会这么想的想法——在我的能力范围内尽可能的帮助更多的人[^4]——或许是因为我自己的弯子走多了不希望别人走，或者一种奇怪的感觉觉得我就应该这样做吧。也大概也是因为这种想法，我对教育质量改善一直有着比较奇怪的兴趣，有时的确会研究怎么教可以让受众更好的掌握一些知识，这也算帮助了一些人吧。这个或许让别人看会觉得很难以理解，但是这点的确也是除了“帮我学很多东西”之外的又一原动力。

当然还有一个原因是我单方面单纯的不喜欢 GPL [^8] 。当然这点蛮有趣的，下面还会提到。

如果还要说有点别的的话，这算为学校做了点微小的工作吧。

## 打算怎么做

按照当时的脑洞，我列了这么个清单：

* 代码便签盒 （学生的作业有哪里不明白？直接通过便签盒分享代码吧~）
* 竞赛模式和作业模式 
* 题目分类
* 探索模式 （渐进的难度，引导对算法更深入的探索）
* ProblemAwesome （新的开放题库和题库模式）
* Open API 接口 （更自由，更开放）
* 支持由HustOJ的数据导入 （相近的数据库结构，不必担心题目不足或是信息丢失）

便签盒是个非常小的目标，因为当时教学时学生经常有下课也没来得及写完的代码，有个地方放还是比较科学的，当时我用 paste.ubuntu ，感觉挺方便，于是觉得这个功能可以整合进来。不过实现的话，其实就是不编译的代码提交而已，非常容易实现，于是这算是当时定的非常小的目标了。

竞赛和作业分开的原因也很简单，因为学校没有分开，于是课上学生的提交也是按着竞赛这套规则来的，我个人认为普通入门学生不应该一开始就关心算法的复杂度，严格的格式化输出之类对于入门而言蛋疼至极的问题，以及错误提交的罚时问题（就上个课罚时什么罚时...）之类。于是我认为这个应该分开。实现的话并没有什么麻烦的地方。

题目分类则是给 acm 队员用的。因为我的确以校赛上还算不错的成绩入了acm队，刷题时觉得我经常找不到某个对应知识点的相关题目，于是感觉这个功能应该很有用，以及这个功能对于非算法竞赛学生也会用得到，于是这点感觉还是挺有用的。

探索模式是我看极客学院[^5]的时候想的，极客学院有提供一个学习路线图，我觉得，对于自学某个东西的情况，路线图是个非常有用的东西[^6]，我虽然可以从教程，书上看到学习的顺序，但都不如整合的路线图来的快，一个好的知识网图的确能节省很多时间，如果能和OJ整合（比如问题关联知识点）的话大概也不错。

剩余就是一些我认为 hustoj 做的不好的东西了，当时听说过 ajax 于是觉得用这个会更科学，于是打算搞 API ，以及问题导出格式也搞个科学些的什么的。至于 hustoj 兼容，这是刚需，如果不做，学校百分之百不会用我的东西的，原因很简单，这个坑是我自己挖的，也不是学校要求我做的，我当时只是有学校OJ的维护权限，换了我的东西，旧数据全没了学校还不得把我杀了（x）...

当然我也没想到学校会打算做二次开发和商业化...

## 怎么看待之前的代码和弃坑

坑是我开的，除了我偶然跟别人谈起我有在写OJ之外，大多人都不知道有这么回事，当然，我也给学校提起过我有在写新OJ，但是没说原因，我向学校提起的原因是...学校有人说我看着是维护OJ但是看上去什么都没干...当然我提起新OJ也没人过多留意。

OJ写初，连着写了有一段时间，结构上也和原版的hustoj非常接近[^7]，写了一段时间后，后台内容和普通用户提交问题判题这些功能基本就全了，于是我在我的服务器上部署了hustoj并把我的代码也放上去，可以对比使用了。当然，竞赛部分并没有写，只是写了页面大致的样子，功能并没有，虽说后来也写了一点。

个人习惯而言，几乎不可能把一长段的时间完全拿给某一个东西用，因为毕竟学生，我还要学新的东西，要不然出了校门都找不到工作的，于是我做OJ的同期还有学别的新东西。

于是我就了解到了更多更科学的东西，安全问题啦（这个很重要），MVC框架啦，RESTful API啦，Vue.js啦，前后端分离啦，更多语言支持啦，判题后端更科学的做法啦等等。了解的越多，我开始愈发觉得我写的东西并不比原版好到哪里去，于是我自己都开始质疑我写这些东西的意义..

后来我还在 github 看到，原版 hustoj 的确也有人重写过，有个叫做 freefcw 的人使用了一个 php 的 MVC 框架重写了 hustoj 的前端，于是我甚至打算不在继续我的 OJ 开发了，一是我本身就是完全重写，到当时那个程度都不能做到完全替换原版功能使用，二是安全问题我也不清楚我处理的是不是还过得去...于是我试着部署了 freefcw 的重写版本，但是因为自己本身没接触过 php 的 MVC 框架，遇到一些问题，解决后又有各种新问题，解决了一天也没正常跑起来，最终放弃部署。

关于怎么看我写的代码，学习的过程中不断学到新的方法，与此同时我就一直在“否定”（暂且这么叫）我之前的做法，比如意大利面一般的代码结构，不变维护，前后端依然不分离，压根没法做api来看待的 api 之类..几乎可以认为，新的知识一直在让我认为我的旧代码没有意义，大概是这样的吧。

于是，我开始认为继续写当前版本的 OJ 不会让我学到更多的东西，并且剩下的都是一些重复的繁杂工作，加之本身并没有谁要求我或者需要我去写这套东西，于是失去动力之后，加之更多新东西要学，我就暂缓，直到最终暂停了 BLOJ 的开发，并打算等闲了再用更科学的方法写吧...

谈起商业化和学校的二次开发

上面也说了，本身这就是我众多坑中的一个，只不过坑的半径（x）比较大而已，目的本身就是学习，并且我也本身就有可能会做不完以及做的肯定不好的心理准备。当时最高的期望就是功能完备，学校可以采用，得到好评并且的确改善了一部分教学方面的缺陷。如是我就很满足了，这样的初衷，谈何商业化？

至于不选GPL，单纯的是因为我觉得GPL的传染性蛋疼一些，然后我觉得也不大有可能有人拿着我的代码去搞大新闻，于是选了MIT协议，署我名，别的你随便。即便如此我依然用了hustoj的一些代码，因为目前毕竟半成品，成品的时候肯定还要做一次 Clean Room 的，而成品之前，还是怎么快怎么来比较好。以及我觉得，就我这质量，真要商业化了，估计代码早就改的我自个儿都不认识了... [^8]

我真的没想到过学校会打算搞商业化...

即便我自己本身没打算搞任何商业化方面的东西，但其实我个人不反对商业化一个这样的平台，毕竟hustoj自己也做 PaaS（大概算吧，为不会搞OJ的学校提供付费支持的OJ平台），但听到学校说要搞商业化之后我还是有点意外，因为，不知道哪里的感觉，我觉得商业化会让教学平台更加变味。

我觉得大概我个人性格一直比较执拗吧，我一直都尽可能的保证我做的事情正确，不违背初衷。比如即便我非常清楚学校送我到北京的培训机构学j2ee是出于好意但我依然决定回来（去培训班是学不到什么有技术含量的东西的，以及我并不喜欢 java web 开发），以及学校说让我提前实习我也没有去（因为代价是不上课，而课程的确是我并不了解并且很有必要学习的）。我很清楚这样做会导致老师或者学校对我有负面看法，但我还是做了，因为我觉得，不违背初衷有更高的价值。而我认为，如果去做一个不是为了提高/改善教学质量的OJ平台，这完全违背了我的初衷。

那么，为什么我觉得商业化会让教学平台变味？我也不清楚，但大概算一种直觉吧。比如C语言教学，学校一直是以ACM形式教学的，而普遍有一种观点（我也觉得有道理）是，弱校ACM出成绩快，给学院带来荣誉也就快一些了。如果这个观点成立，那么可以说这样教学本身是一种非常功利的做法，为了出成绩而教学，自然不会有非常高的质量的吧。

当然，这只是一个非常没有由来的猜测，但不管从哪个方面看，我都觉得学校很多地方都很功利，比如几乎所有实验室（ACM实验室或许真的是个例外）都是校企合作，商业驱动的，而没有存粹的研究性实验室。以及大三学生被建议前往北京培训机构学习，以及大四（现已毕业）的学生曾经在校做项目的实验室外面挂牌写了达内....我并不能确保我的猜测是正确的，也没准是因为学校刚升本没几年还有待发展呢？

学校说要做二次开发，到现在我依然是待定是否要做的状态的。如果学校真的要做我肯定会帮忙，但不见得就一定会全身心投入去做二次开发。原因也很功利，做这个项目的人大多是全职可以专心做这些事情的，而我还是个学生，而且很快面临着找工作或考研的选择。全身心的投入必然会影响学习任何东西。

于是我最终告诉学校我的想法，首先是使用我的代码是否有意义和风险（维护成本上等）以及代价有多高（依然是只维护成本上），是否有必要按照科学的方法重写以及我的一些想法等。事实上我并不是非常建议直接使用我现在的代码（因为完成度不高，维护成本却很高），而无论用与不用，都是学校说了算的。

但是，无论如何，在没有定数之前，我依然决定继续完成我现在版本的OJ，无论是否有人会使用。如果学校会用也好，学校会提供资金支持也好（虽然仅就OJ开发而言从来没指望过），或者完全不用也好，我试图传达给学校一个 我希望教学质量变得更好 的想法吧。

似乎有点跑题了，写到现在这个点也有点脑子糊涂，那么就先到这儿吧，如有别的相关有必要补充我再补好了。

顺便立个 flag ，如果年初我开时间囊之前能换安卓机，我就开篇博客好好的黑一黑 Windows Phone 。

惯例，时间：2016年11月17日01:06:53。

[^1]: 大概一本院校或者好些的别的院校都是一个学期吧，我所听闻的范围内除了我校，都是一个学期。
[^2]: 当时并没有想太多，于是现在我看我当时写的代码的时候觉得我当时的想法和原版一样幼稚..
[^3]: 让我在这个过程中学到东西是作为动力的，说起来，我经常为了学某个东西去开一个相关方面的坑。当然，动力归动力，原因归原因，开坑肯定有“学东西”之外的原因，不然的话我还不如接着魔改，改烦了扔着不管了就是了。
[^4]: 我这种想法也算是我做一些事情的动力。比如我高中很想做一个帮助高中生被化学方程式的平台或者工具（最后没做），大学后曾想做一个分享我觉得好的东西的平台（一开始做成了静态网页，后来试着用django做了现在的“Awesome”分享我觉得好的游戏，软件以及资源链接。顺便这个平台也没完工且被晾着...）
[^5]: 学一些东西的时候当时有看过一小段的这个网站，后来也还看过一段时间的lynda，再后来就只看文档，推荐书籍和普遍认为值得阅读的文字教程了。
[^6]: 至今这么认为，比如我至今没找到一个明确的符合我的目的的适合业余学习的绘画路线图....
[^7]: 事实上我算是读hustoj代码入门的php吧，也算野路子了，自然有很大影响。虽然我到现在都认为我所看到的那个hustoj的代码很烂，但至少还是很感激有hustoj的代码看的。
[^8]: 于 2018-9-23： 看来写这篇的时候我对 GPL 有挺大的误解...如果有时间的话回头可以写一篇谈谈这个事情。
