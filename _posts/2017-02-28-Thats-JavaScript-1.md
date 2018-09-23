---
title: 原来JS是这样的 (1)
date: 2017-02-28 22:26:17
tags:
---
## 引子

长久以来一直都没有专门学过 JS ，因为之前有自己啃过 C++ ，又打过一段时间的算法竞赛（写得一手好意大利面条），于是自己折腾自己的网站的时候，一直都把 JS 当 C 写。但写的时候总会遇到一些奇怪的问题，于是打算花点时间看了看《你不知道的JavaScript》。写这篇文章以记录一下一段时间的学习内容，也治疗一下我不爱做笔记和总结的毛病。如果你也是一直按着别的语言的编程习惯来写 JS 而没有专门去了解过它，不妨一起来了解一下 JS 的一些独特之处。

<!-- more -->

首先来看一段代码：

``` JavaScript
"use strict";

console.log("Firstly, i = " + i);
// console.log("BTW, a = " + a);
i = 61;
console.log("Then there it got a value, i = " + i);
for(var i = 1; i <= 5; i++) {
	console.log("In for loop, i = " + i);
}
console.log("At the end, i = " + i);
```

你可能注意到，这段代码一开始就要输出 i 的值，而在输出之前我们似乎并没有写任何声明和定义 i 值的语句，而再之后，我们给 i 赋了一个值，但我们依然没有用 `var` 之类的关键字来做变量声明的工作。在 for 循环，我们终于声明了 i ，但 for 循环之后，我们依然在试图使用 i 。这些代码看上去都很荒唐，或许你可能认为这段代码在第一行的时候就会报 ReferenceError 以提示我们并没有定义变量 i 并停止执行。但实际真的是这样吗？

让我们看一下这段代码的执行结果吧：

```
Firstly, i = undefined
Then there it got a value, i = 61
In for loop, i = 1
In for loop, i = 2
In for loop, i = 3
In for loop, i = 4
In for loop, i = 5
At the end, i = 6
```

这段代码其实非常的谭浩强，但却说明了一个比较明显的 JS 的不同之处，那就是 _提升_ 和 _作用域_ 规则。

## 提升（Hoisting）

或许由于之前的编程语言中所得到的经验，我们可能会认为，在声明语句之后我们才可以使用我们刚刚声明过的变量，我们看这段代码：

``` JavaScript
"use strict";

a = 61;
console.log(a); // 输出 61
var a;
```

你可能认为第一条语句是非法的，但实际上它正常的执行了，但分明我们是在下面才声明了 a ，这就是 _提升_ 的含义了。

实际上， __在 JavaScript 解释一个作用域内的代码时，会把变量和函数的声明在这块作用域中的任何代码执行之前进行处理。这就像是把函数和变量的声明拿到了这个作用域的最上面了一样。__ 这个过程就叫做 _提升_ 。

于是我们再来看下一段代码：

``` JavaScript
"use strict";

console.log(a); // undefined
var a = 61;
```

停！等等！不是会提升么，不应该是 log 一个 61 出来么？但实际上答案就是未定义。实际上，我们可以理解为，编译器在分析这段代码时，这段代码的第二行会被编译器解析成两部分， `var a` 和 `a = 61` 。就像刚刚所提到的，声明的确是要被提升的，于是 `var a` 就被“拿到最上面”去了，而 `a = 61` 则留在原地，所以，这段代码实际会输出一个 `undefined` ，而不是在我们还不知道 _提升_ 这种说法时可能猜测的结果 `ReferenceError` ，以及以为会把赋值也提升上去得到的 61 。

上面提到了，函数的声明也会提升，如果你之前曾经在你定义一个 function 之前就尝试使用这个 function 但没有出错的原因了，这也是为何你可以把外部 js 代码在页面最底部引入你也依然能够使用那些代码的原因。

当然，也有一些需要注意的地方，函数表达式的提升规则比较奇怪，比如下面这段代码。

``` JavaScript
"use strict";

foo(); // TypeError
bar(); // ReferenceError

var foo = function bar() {
	// ...
}
```

它大致上会被这样解释：

``` JavaScript
var foo;

foo(); // TypeError
bar(); // ReferenceError

foo = function() {
	var bar = ...self...
	// ...
}
```

如果你不清楚函数声明和函数表达式的区别，可以参见[这个](https://stackoverflow.com/questions/1013385/what-is-the-difference-between-a-function-expression-vs-declaration-in-javascrip#3344397)和[这个](https://stackoverflow.com/questions/16631708/javascript-functions-like-var-foo-function-bar) 。

## 作用域（Scope）

当你知道了提升的概念，反过来看最上面的示例代码，可能依然会觉得不正常——我们分明是在for循环这个代码块里才声明了变量，为什么在外面也能用它？刚刚不是说，代码只被提升到一个作用域之内的最上面吗？于是我们来看下面的这段代码：

``` JavaScript
"use strict";

//console.log(bar);
function foo() {
	console.log(bar);
	if(true) {
		var bar = 61;
	}
	console.log(bar);
}
foo();
```

最直观的印象里，这段代码在函数 foo 内的一个条件语句成立的条件下会声明变量 bar 并赋值 61，而实际上我们会发现，除了函数外我们注释掉的那个语句之外，我们都可以访问到 bar 。

刚刚不是说，提升仅限所在的作用域吗？对，的确如此，但实际上，JavaScript的作用域本身并不处理这样的，由 if, for 等后面的花括号构成的块作用域。因此，此处声明的 bar 实际所在的作用域是函数 foo 之内，而不是由 if 构成的块级作用域。不过例外的，需要注意的是， `with` 和 `try/catch` 是可以创建自己单独的作用域的。

当然，实际在 ES6 引入的新关键字 `let` 解决了这个问题，使用 `let` 声明的变量就只存在于块级作用域内了，这解决了 var 导致的名称污染问题。

那么我们回到最开始的例子，我们看上去是在 for 循环中才声明的变量实际被提升到了 for 循环之外的作用域，于是剩下的内容就没有什么说不通的问题了。额外的一点是，对于已经声明过的变量，再次发现声明同名变量的行为会被忽略。

## 严格模式 （Strict Mode）

如果你一直是把 JS 当作你之前熟悉的语言来写，可能会不太熟悉严格模式，而跟据名字，我们就可以猜测出，严格模式的含义就是 __使得Javascript在更严格的条件下运行__ 了。

[@沙堆里的金子](https://www.cnblogs.com/blumia/p/Thats-JavaScript-Hoisting-Scope-n-Closure.html#3628848) 在这篇文章的评论提到，没有 `var` 的声明似乎应该就是全局变量，在哪里都可以访问得到。而实际上，引擎的行为是这样的：

首先编译器会检查在调用某个变量（即RHS查询）的位置所在的词法作用域有没有这个变量被声明，如果没有，则往上一层词法作用域查询，直到查找到最上层的全局作用域看看是否能够找到该变量。在没有开启严格模式的情况下，如果编译器在全局作用域依然无法找到要找的变量，那么编译器就会“热心”的在全局作用域（浏览器中的情况即 window 下）创建一个变量以便使用，而这种“热心”有时并不是好事。

假设我们声明了一个变量仅仅使用于某个循环，但我们忘记使用 `var` 进行声明了，那么非严格模式下，会导致我们在全局作用域创建这个变量，这就对全局作用域造成了污染。

如果在严格模式下，如果我们没有通过显式的方式声明变量（使用 `var` ，或者 ES6 新增的 `let`），编译器就会报错告诉我们出了问题了。

严格模式本身不仅仅是检查变量是否显式的声明了这么简单，你可以在 [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Strict_mode) 上查看更详细的内容。

## 闭包（Closure）

跟据刚刚讲的内容，看下面这段代码

``` JavaScript
"use strict";

function foo() {
	var t = 61;
	function bar() {
		console.log(t);
		t++;
	}
	return bar;
}
var baz = foo();
baz(); // 61
baz(); // 62
```

显然，我们在 foo 内声明的变量 t 所在的作用域就是 foo 函数本身，我们不能在外部访问 foo ，而实际上我们可能总是需要访问封闭在 foo 作用域内的变量 t ，于是，为了能够访问这个变量，我们使 foo 返回了 bar 用以访问 t 变量，并用 baz 来保存了对 bar() 的引用。于是当我们执行 baz() 的时候，会看到输出了 t 的值，并且 t 的值会加一。

事实上，我们通过 baz 引用 bar 以防止 bar 所处的作用域被引擎回收，于是我们保住了这个作用域里的变量，以便以后再次使用，并且我们还可以在外部访问它（这种需求就像面向对象语言中一个类对象中的私有成员一样）。而我们做的这种事情，实际就叫做闭包。

为了不搞混，还是重新说一下闭包的概念：当函数可以记住并访问所在的词法作用域时，就产生了闭包，即使函数是在当前词法作用域之外执行。

我们来看下面一段代码

``` JavaScript
"use strict";

var a = 61;
(function IIFE(){
	console.log(a);
})();
```

如上是一个立即执行函数（IIFE），而这是一个闭包吗？答案是：并不是。因为函数本身并不是在它之外的词法作用域所执行的，其中使用的变量 a 也并不是函数 IIFE 所封闭的变量。所以，这不是一个闭包。

再考虑下面一段代码

``` JavaScript
"use strict";

for(var i = 1; i <= 5; i++) {
	(function IIFE(){
		setTimeout(function timer() {
			console.log(i);
		}, i * 1000);
	})();
}
```

这段代码我们把直接执行函数塞到了 for 循环里，IIFE里的内容则是延迟 i 秒后输出 i 的值。看上去应该输出的是1到5，一秒一个，而实际上输出的则是66666（一秒一个6）。

其实和上一段代码一样，这个立即执行函数和这段代码中的并没有什么异样，使用的i依然是外部作用域的i（而不是IIFE构成的作用域内的自有变量）。于是，因为函数被延迟执行，执行的时候for循环已经循环完了，自然输出了66666。而如果想要达到本身的目的，只需要这样修改：

``` JavaScript
"use strict";

for(var i = 1; i <= 5; i++) {
	(function IIFE(j){
		setTimeout(function timer() {
			console.log(j);
		}, j * 1000);
	})(i);
}
```

这看上去是一个很蛋疼的把戏，但我们通过参数传入的 i 在 IIFE 内成了隐式声明的变量 j ，而j的作用范围是 IIFE 所构成的语法作用域内，自然不会有问题。

最后我们简单提及一下模块机制。回到闭包段落的第一个例子，我们可以看到我们以通过返回一个可以访问闭包内部变量的函数来达到访问闭包内部的变量的目的（听上去好像是废话），而当我们在编写一个模块时，我们通常需要通过这种行为去模拟一个类，这种行为的实现方式很多，比如这样：

``` JavaScript
"use strict";

function moduleFoo() { // ps: 以函数表达式的方式声明该函数，就可以达到单例的效果
	var privateVar = "CarraIsMine";
	var yetAnotherPrivateVar = "TejiLang";
	function doSomething() {
		console.log(privateVar);
	}
	function doSomethingTeji() {
		console.log(yetAnotherPrivateVar);
	}
	
	return {
		doSomething: doSomething,
		doSomethingTeji: doSomethingTeji
	};
}

var bar = moduleFoo();
bar.doSomething(); // 嘿！
bar.doSomethingTeji(); // 蛤！
```

我们依然通过返回东西的形式以便访问闭包内的变量（实际是做一些想要的事），只不过我们这回不止返回了一个函数的引用，而是返回了一大坨。

关于更多模块机制的实现方式，其实可以展开成单独的文章来说了，这里就不再阐述，而需要额外提到的是，ES6引入了 `import` 关键字可以将一个单独的文件视为一个模块来引入和使用。当然，这就不在刚刚所讨论的闭包的范围内了。

## 最后

以上讲述的内容就是关于 JS 的 提升，作用域以及闭包的相关简单解释。如果你对这些内容仍然感兴趣，不妨去读一读《You don't know JS - Scope & Closures》一书（这一本并没有多长）。这是一本开源书，你可以在[这里](https://github.com/getify/You-Dont-Know-JS)在线阅读这本书，或者购买这本书的电子版或实体版。这本书的中文译本涵盖在《你所不知道的JavaScript 上卷》中，你也可以考虑看中文版。

JavaScript 的很多地方一直被人诟病，倘若不去了解 JS 而是简单粗暴的按照别的编程语言带来的惯性思维去写 JS ，则很容易踩一些坑，抽出一定的时间去了解它，不仅可以让你避开这些坑，还可以让你在使用它时更得心应手。

以及，尽管这一篇我写的时候检查了很多次是否有问题，但也不保证这篇文章中一定不会有错误，如果您发现文章哪里有问题，请在下面留言指正，感激不尽～
