---
title: 隐藏的小宝石：QStringIterator
categories: 翻译
tags: [翻译]
date: 2020-03-17 15:52:00
---

本文译自：[A little hidden gem: QStringIterator](https://www.kdab.com/a-little-hidden-gem-qstringiterator/)

几天前，我在 KDAB 的一个同事，也是本文的作者之一 Marc Mutz ，发现了 Qt 源代码中有这样一段很有趣（[文档](https://doc.qt.io/qt-5/qstring.html#isUpper)）：

``` cpp
/*!
    Returns \c true if the string only contains uppercase letters,
    otherwise returns \c false.
*/
bool QString::isUpper() const
{
    if (isEmpty())
        return false;
 
    const QChar *d = data();
 
    for (int i = 0, max = size(); i < max; ++i) {
        if (!d[i].isUpper())
            return false;
    }
 
    return true;
}
```

抛开它把空字符串认为是 **非** 大写的这个还是很容易处理的问题不谈，这部分代码中的循环看上去好像没什么毛病。我们如何就像上述代码中注释文档所提到的那样，判断一个字符串是只包含大写字符呢？

 - 逐字符的遍历字符串；
 - 看到非大写的字符，那这个字符串就不是大写的；
 - 否则，它就是大写的。

这完全就是上面那段代码所做的事情了，对吧？

然而并非如此。

**这段代码它是有缺陷的。**

它和其它无数多的代码都掉进了相似的坑中：它完全没有关心 `QString` 中不包含字符/码位的情况，也没有关心 UTF-16 **编码单元**[^1]的问题。

[^1]: 译注：编码单元（code unit），有时也被称作代码单元或码元，就是每个编码的基础大小单位，比如 UTF-16 就是 16 位的。为避免与通信工程术语中的码元混淆，也便于读者理解，这里选取了我认为更符合实际行为的译名。

所有对 `QString` 的操作（取长度、分割、迭代之类）都总是以 UTF-16 编码单元为基准运作，而不是码位[^2]。实际情况是：`QString` 能适用于 Unicode 是因为其算法合理，显然不是因为其存储方式。

[^2]: 译注：[**码位**](https://en.wikipedia.org/wiki/Code_point)（code point），有时也被称作**编码位置**（code position），表示文字中的一个字符的数据。如果你熟悉 Golang，可以对应到[其 `rune` 基本类型](https://golang.org/doc/go1#rune)（用以表示独立的 Unicode 码位）

举个例子，如果我们的一个字符串只包含一个字符“𝐀”——这是个*数学符号大写 A（U+1D400）*——那么 `size()` 就会汇报这个 QString 实际上存储了两个“字符”（还是得重申，这里并非在说字符码位，而是说这里有两个 UTF-16 编码单元）：0xD835 和 0xDC00。

上面那段代码中的天真迭代法就会把这两个编码单元挨个检查一下是否是大写，猜猜怎样，当然都不是大写，于是最终得到结论是这字符串不是大写的——然而实际上它就是大写的。（这两个编码单元是“特殊的”并且被用来编码在[基本多语言平面（BMP）](https://zh.wikipedia.org/wiki/Unicode%E5%AD%97%E7%AC%A6%E5%B9%B3%E9%9D%A2%E6%98%A0%E5%B0%84#%E5%9F%BA%E6%9C%AC%E5%A4%9A%E6%96%87%E7%A7%8D%E5%B9%B3%E9%9D%A2)外的字符，即**代理对（surrogate pair）**。若单独拿出来，就是无效的了。）

## Unicode, 尔于何方?

如果你想指导更多关于 Unicode 的故事，可以先抽几分钟读一下[这个](https://www.joelonsoftware.com/2003/10/08/the-absolute-minimum-every-software-developer-absolutely-positively-must-know-about-unicode-and-character-sets-no-excuses/)和[这个](http://utf8everywhere.org/)所链接的资源也很值得一读。

**针对字符串进行适用于 Unicode 的迭代方式的需求其实非常常见，于是 2014 年时我就为 Qt 编写了一个新的类去解决这个问题。**类名就是，`QStringIterator`，毫不意外，对吧？

从其文档中来看：

> `QStringIterator` 是一个 Java 风格的，双向的常量迭代器来迭代一个 `QString` 的内容。与 `QString` 自己的迭代器这种管理其所有编码单元的行为不同，`QStringIterator` 适用于 Unicode 的：它将透明的处理 `QString` 中可能存在的 *代理对*，并返回独立的 Unicode 码位，（[原文](https://github.com/qt/qtbase/blob/5.11/src/corelib/tools/qstringiterator.qdoc)）

**任何需要遍历 `QString` 内容的代码都应该考虑使用 `QStringIterator`**，以免犯下类如上面例子中 Qt 代码内把 UTF-16 字符串按一系列码位来处理的这种错误。实际上，`QStringIterator` 现在已经在 Qt 中的诸多地方有在实际的应用了（文本编码、字体处理等等）。

## 我应该怎样使用它？

由于诸多原因（下述），`QStringIterator` 目前是 Qt 的私有 API。若希望使用它，则代码就得包含对应的头文件并且启用私有 Qt API 的支持，例如使用 qmake 的情况应当：

``` qmake
QT += core-private
```

cmake 大概是这样：

``` cmake
target_link_libraries(my_target Qt5::CorePrivate)
```

然后我们就可以使用它来实现一个正确的 isUpper() 了：

``` cpp
#include <private/qstringiterator_p.h>
 
bool QString::isUpper() const
{
    QStringIterator it(*this);
  
    while (it.hasNext()) {
        uint c = it.next();
        if (!QChar::isUpper(c))
            return false;
    }
 
    return true;
}
```

对 `next()` 的调用将会读取能够完全解码下个码位是所有编码单元，并且它也会做错误检查。

（有时候它可能会返回具有 *非* 大写属性的 U+FFFD (替代字符)，因此使得函数返回 false。但这是个实现细节的事情，对包含无效 UTF-16 编码数据的字符串进行这样的操作本身就是未明确的行为了，所以这里就不再管它了。）

`QStringIterator` 提供的 API 非常丰富，它支持双向迭代，允许自定义解码失败时的行为，以及无检查迭代的支持（即假定 `QString` 的内容为有效的 UTF-16 编码的内容，以跳过一些检查）。

**就是这样，别找借口了，今天就开始使用 `QStringIterator` 吧！**

关于我们今天的这场“旅程”的起始，关于修复 `QString::isUpper()` 函数行为的缺陷相关的代码审核和讨论内容，你可以前往[这里](https://codereview.qt-project.org/c/qt/qtbase/+/284810)和[这里](https://codereview.qt-project.org/c/qt/qtbase/+/284678)查看。

## 为啥 QStringIterator 是非公开的 API？

这里是有一些原因使得我让 `QStringIterator` 保持是一个私有 API 的。尽管原因并非是由于其代码和接口可能会频繁变化——实际上，它在过去 6 年都没有变过了。`QStringIterator` 甚至有着完整的文档、测试以及例子（文档可以在[这里](https://github.com/qt/qtbase/blob/5.11/src/corelib/tools/qstringiterator.qdoc)阅读）。

个人来看的话，原因有这些：

 - 这个 API 如果变得更有 C++ 风味，更少 Java 风味的话，会更振奋人心。与其这样写：
 ``` cpp
QStringIterator i(str);
while (i.hasNext())
  use(i.next());
 ```
 我们*也应当*这样写：
 ``` cpp
 // C++11
 for (auto cp : QStringIterator(str))
   use(cp);
 
 // C++20
 auto stringLenInCodePoints = std::ranges::distance(QStringIterator(str));
 bool stringIsUpperCase = std::ranges::all_of(QStringIterator(str), &QChar::isUpper);
 
 // C++20 + P1206
 auto decodedString = QStringIterator(str) | std::ranges::to<QVector<uint>>;
 ```

 然而这些期望的 API 目前都做不到——`QStringIterator` 既不是范围也不是可迭代类型。

 开放接口的话就会导致诸如此类的很多很多问题，比如像是 `QStringIterator` 这名字好不好的小问题，以及像是如何添加自定义如何处理畸形的 UTF-16 数据的逻辑（跳过？替换？终止？抛异常？）这种大的设计问题。
 
 - 目前的实现是以清楚起见的，而没有做速度优化。目前这种实现并没有使用 SIMD 或者其它的黑科技。我感觉如果重新设计 API 并应用这些特性的话，大家都会因此收益（例如把错误处理模式作为定制点）。
 
 - 目前还有很多其它的，近似的，更特定于此目的的项目和工作也在进行当中。比如，值得称赞的[ICU 库](http://site.icu-project.org/home)，[SG16 WG21 学习小组](https://github.com/sg16-unicode/sg16)的研究内容，以及推荐的 [Boost.Text](https://github.com/tzlaine/text) 实现方案等等。我们也许可以讨论决定使用这些成果，而不是再在 Qt 中造一个轮子。
 
 - Unicode 是个复杂的玩意儿，我们可能也遗漏了一些边界情况没有正确处理。如果我们（把它放到公开接口中因而）固化了 `QStringIterator` 的 API/ABI 的话，将来处理意料外的问题可能会很棘手。
 
 - 多数 Qt 代码中假定 `QString` 中的 UTF-16 数据是有效的。我们需要一个站在项目的角度的决策来决定如何检测和处理无效的 UTF-16 数据，然后保持任何地方都一致这样处理。`QStringIterator` 也应当跟随这种决定，若是直接把其接口公开，再作出这样的决策，那我们就又被公开 API 接口无法随意变动的限制所约束了。

因此，我目前觉得就这样把它公开为公共 API 并不合适。当然，你仍然可以从现在起开始使用它，也许你还可以考虑给我们[提供一些反馈](https://www.qt.io/contribute-to-qt)。

Happy hacking!
