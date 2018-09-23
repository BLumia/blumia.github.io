---
title: Qt5 多显示器获取不同显示器的分辨率和位置的方法
date: 2016-01-30 22:52:20
tags: ["Qt","c++"]
---
先放官方文档链接：[QDesktopWidget - Qt5 Reference](http://doc.qt.io/qt-5/qdesktopwidget.html)

之前一直在用被我乱搞后的ShadowPlayer作为默认播放器，后来主力系统换成linux了也就没再用了。这两天the Witness发布，也正好想玩一些别的windows only的游戏，于是回到windows打算好好玩一玩游♂戏。而这几天因为集训也还是在机房，于是我拿着我那台电脑显示器连着笔记本玩双屏很爽，回到windows后发现依然很爽，不过播放器mini界面会有bug，总是会回到主显示器的最右面，于是打算修一修，然后就有了这一片水文（
<!-- more -->
在只有一个显示器的时候，获得显示器分辨率的方法是
``` c++
    miRPos = QApplication::desktop()->screenGeometry().width(); //原来的写法,奇怪的变量名先无视
```

然而实际发现无论如何这个得到的分辨率都是主显示器的完整分辨率。然后查了Qt的[Reference](http://doc.qt.io/qt-5/qdesktopwidget.html#screenGeometry)，才发现，这个的原型是
``` c++
	const QRect QDesktopWidget::screenGeometry(int screen = -1) const
```

其中的参数就是显示器的id，默认是-1，如果是多个显示器，则显示器编号依次为0（主显示器）,1,2,3...额，这个编号和你在设置里看到的编号没一点关系 :)

![](http://images2015.cnblogs.com/blog/705452/201601/705452-20160129113413474-159464257.png)

如图，这是我目前的显示设置情况，其中标识为2的显示器是主显示器，1则是扩展显示器。而实际上，我们通过 
``` 
	QDesktopWidget * deskTop = QApplication::desktop();
	int curMonitor = deskTop->screenNumber ( this ); // 参数是一个QWidget*
```

获得到的当前所在屏幕的编号来看，设置中标识为2的实际上是0，标识为1的实际是1.也就是说，系统设置中标识的编号和这里真的是一点关系都没有啦。

当我们获取到显示器编号后，就可以通过这个来获取当前所在屏幕的分辨率啦。
```
	QRect rect = desktop->screenGeometry(curMonitor);
```

这时rect.width和rect.height就是当前屏幕的分辨率了。而rect.x和rect.y是什么呢？回到刚刚的我的显示器设置情况的图，我们可以用上面的函数获取主(编号为2的)显示器rect.x和rect.y，你会发现rect.x=0,rect.y=0。可见，整个显示器“坐标”是以主显示器左上角为（0,0）点的。在扩展(此处编号为1的)显示器获得到的rect.x=-1366,rect.y=161说明这个就是那个扩展显示器左上角的坐标了。那么我们就很容易通过这个来计算我们所需要的屏幕坐标了。

我的需求是让这个仿osu的mini窗口的最右端和当前屏幕最右侧对齐，上端和当前屏幕上端保持25px的边距。那么就应该这样做。
```
    miRPos = rect.x() + rect.width(); //当前屏幕最右侧的位置，别吐槽这个变量名了（╯－＿－）╯╧╧
    this->setGeometry(miRPos - this->width() , rect.y() + 25, this->width(), this->height());
```

然后我突然发现我是个奇葩的例外，因为我在小的显示器上打游戏的时候通常任务栏会挡住游戏窗体，于是我把任务栏拖到右面了...那么上面所得到的结果，窗体则始终会和屏幕的最右面对齐并忽视任务栏的存在，如果翻过reference的话，你会发现这个问题非常好解决，只需要把 ` screenGeometry() ` 换成 ` availableGeometry() ` 就行了。这个获取到的就是当前显示器的可用部分了，在windows下就是不包括任务栏了。

或许你在没创建widget的时候就想要获取一个分辨率信息用于初始化或者别的作用了，你可以通过  ` curMonitor = desktop->primaryScreen(); ` 初始化显示器编号为主显示器的编号并由此获取主显示器的相关信息，或者通过其他提供的函数来达到你自己的目的。哦对了，好像curMonitor初始化为-1的时候获取到的也始终是主显示器的大小。毕竟默认值嘛。

最后的效果图：
![](http://images2015.cnblogs.com/blog/705452/201601/705452-20160129113543583-88812241.png)

完成啦，吃饭饭去

****************

append:
hexo的markdown支持真是一般啊。。cnblogs完全正常显示，hexo完全错乱排版。233333

参考资料：[QDesktopWidget - Qt5 Reference](http://doc.qt.io/qt-5/qdesktopwidget.html)
