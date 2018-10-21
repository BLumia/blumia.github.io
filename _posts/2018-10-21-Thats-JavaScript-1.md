---
title: 原来JS是这样的 (2)
date: 2018-10-21 18:54:17
---

## 引子

习惯了别的语言的思维习惯而不专门了解 JavaScript 的语言特性的话，难免踩到一些坑。 [上一篇文章]({% post_url 2017-02-28-Thats-JavaScript-1 %}) 中简单总结了关于 *提升*, *严格模式*, *作用域* 和 *闭包* 的几个常见问题，当然这仅仅是了解 JavaScript 的一个开始，这次则依然从另一个大多人都见过但很容易搞错的概念开始了解 JavaScript 的不同之处 —— `this`。

首先看这段代码：

``` JavaScript
function plusOne() {
	this.count++;
	console.log("plusOne get called, this.count: " + this.count);
}
plusOne.count = 0;
plusOne(); // 改成 plusOne.call(plusOne);
console.log("plusOne.count = " + plusOne.count);
console.log("window.count = " + window.count);
```

我们知道 JavaScript 中所有的东西都是对象，那么很可能会把 `this` 自然的理解成当前对象“身上”的属性，对于上面的代码（注意，并非严格模式下），我们为 `plusOne` 创建了一个属性 `count` 并试图通过在 `plusOne()` 中使用 `this.count++` 改变它的值。然而如果实际执行这段代码（注：假设是在浏览器 F12 的 Console 中），得到的结果会是这样：

``` plain
plusOne get called, this.count: NaN
plusOne.count = 0
window.count = NaN
```

可以看出 `plusOne()` 中的 `this.count` 实际是 `NaN`，`plusOne.count` 却没有变化，并且 window.count 被创建了。而尝试按照上面代码中的注释那样把 `plusOne()` 改成 `plusOne.call(plusOne)` ，就会发现结果成了：

``` plain
plusOne get called, this.count: 1
plusOne.count = 1
window.count = undefined
```

那么为什么会这样呢？

## `this` 是运行时到某个对象的绑定

首先分析上面的输出结果就可以知道，在我们使用 `plusOne();` 时，`this` 并不是像想象的那样是一个指向 `plusOne` 的变量，而我们可以发现在浏览器中执行时 windows.count 被意外创建了，显然在这个情况，这里的 `this.count` 无意中在全局范围（即浏览器的 `window`）创建了 `count` ，而很明显 `this` 在此时 `this` 即绑定到了全局对象。至于值 `NaN` ，则是简单的 `undefined++` 的结果。

而当我们改用 `plusOne.call()` 时，可以看出这时候 `this.count` 才真正改变了 `plusOne.count` 的值，此时 `this` 即指向 `plusOne` 对象了。这是因为 [`Function.prototype.call()
`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/call) 改变了 `this` 所绑定的值。

于是我们知道了 `this` 并非指向自身，并且其所绑定到的对象是变化的，那么，规则是什么呢？

### 1. 隐式绑定

其实在仔细研究 `this` 的规则之前，我并没有被 JavaScript 的 `this` 规则坑到过，而我通常使用的写法像是这样：

``` JavaScript
function printA() {
	console.log(this.a);
}
var obj = {
	a: 616, print: printA
};
obj.print(); // 输出为 616
```

在这段代码中，我们使用了 `obj.print()` 来调用被引用到 `obj.print` 的 `printA()` 函数。这时候 `printA()` 所处于被 `obj` 调用的上下文，故此时 `this` 被绑定到了 `obj`。这种根据被调用情况将 `this` 绑定到对应对象上的情况我们称之为 **隐式绑定**。而称之为隐式绑定的原因则是，我们是在一个对象（上例中为 `obj`）内包含一个指向函数的属性（上例中的 `obj.print`），并通过这个属性间接（隐式）引用函数。

当然这里其实有一个比较有意思的地方，在了解它之前，我一直认为这里 `printA()` 就直接属于了 `obj`，并认为 `obj.print` 就总表示被 `obj` 所拥有的 `printA()`，即只要我们使用 `obj.print` ，`this` 就一定是绑定到 `obj` 的。当然实际并非如此：

``` JavaScript
function printA() {
	console.log(this.a);
}
var obj = {
	a: 616, print: printA
};

var alias = obj.print;
alias(); // 输出为 undefined

function callFunc(fn) {
	fn();
}
callFunc(obj.print); // 输出为 undefined
```

这个例子中我们把 `obj.print` 赋值给了 `alias` ，本意为给 `obj.print` 起的别名，却发现结果得到了 `undefined` 。实际上，`obj.print` 持有的只是对 `printA()` 的引用而已，而 `alias` 也自然实际是指向 `printA()` 了。此时 `alias()` 显然不是由 `obj` 调用的，故并不能遵循隐式绑定的规则，此时发生的情况也就和本文最初的例子一样了。至于 `callFunc()` ，我们传递进来的 `obj.print` 实际也是 `printA()` ，故它也不是被 `obj` 调用的，所以结果也是 undefined 了。

### 2. 显式绑定

回顾最初的例子，我们使用了 [`Function.prototype.call()
`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/call) 把 `plusOne()` 函数被调用时的 `this` 绑定到了 `plusOne` 对象。如果你查阅 MDN ，会发现它和 [`Function.prototype.apply()
`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/apply) 都可以显式的把 `this` 绑定到向 `call()` 或 `apply()` 所提供的第一个参数上。我们把这种 `this` 绑定规则称为显式绑定。

回顾我们在隐式绑定中后面提到的例子，我们试图使用 `var alias = obj.print` 来创建别名以达到得到一个关联着 `obj` 作为上下文的函数 `printA()`，但是失败了。我们则可以使用显式绑定创建一个辅助函数解决这个问题：

``` JavaScript
function printA(extra) { console.log(this.a + extra); }

function bind(fn, _obj) {
	return function() {
		return fn.apply(_obj, arguments);
	};
}

var obj = { a: 616 };
var alias = bind(printA, obj);
console.log(alias(" CodingCat!"));
```

显然，我们的 `bind()` 内返回了一个函数，其使用 `apply()` 将 `this` 绑定到了其参数 `_obj` 上。所以我们调用 `alias()` 时 `this` 总是绑定在了我们指定的 `obj` 上了。

当然，实际由于这个需求很常见，所以我们可以直接使用 `Function.prototype.bind()` 而不再需要编写自己的辅助函数了。其用法类似 `var alias = printA.bind(obj)`。

另外，由于很多时候我们需要指定 `this` 所要绑定的对象，一些较新的内置函数和第三方 API 都会提供一个可选的参数供显式指定这个对象（称之为 **上下文** (context)），比如 `forEach()` 。

### 3. `new` 绑定

JavaScript 在遇到 `new` 操作符时也会改变 `this` 所绑定的对象，会将其绑定到所新创建的对象上。这个规则看上去的确没有什么问题，但 `new` 操作符的工作方式却可能和你想象的不太一样。

在很多种面向对象语言中你很可能已经见过 `someVariable = new SomeClass();` 的这种写法，`new` 会调用对应类的构造函数，然而 JavaScript 并没有“类”的概念[^1]，就连某个对象内的函数其实也只是持有的函数的引用而已。实际上 JavaScript 的 `new` 操作符只是调用了某个函数并执行了一些其它操作而已，于是在 JavaScript 语境下，“构造函数” 其实就是被 `new` 操作符所调用的一个普通函数，而 `new` 操作符所作的 “其它操作” 就包含了修改对 `this` 的绑定。

使用 `new` 来调用构造函数（或者说，发生构造调用时），所执行的操作实际是这些：

 1. 创建一个全新的对象（这是为什么我们称之为 “构造函数” 或 “构造调用”）
 2. 对这个新对象执行 `[[Prototype]]` 链接（不再本次讨论范围内）
 3. 将新对象绑定到 `this` （嗯哼）
 4. 将这个新对象作为 `new` 表达式的返回值（如果函数没有返回其它对象的话）

``` JavaScript
function setA(a) {
	this.a = a;
}
var bar = new setA(61);
console.log(bar.a); // 61
```

上面例子中的 `new foo(61);` 即通过调用函数 `setA` 创建了一个新的对象，由于这时执行了对 `this` 的绑定，故这里 `this.a` 就是 `bar` 上的 `a` 了。另外，这也是又一个可以说明 `this` 所指向的对象是随运行时的调用情况而改变的不错的例子。

### 4. 默认绑定

如果你到现在还没有忘掉第一个例子，会发现第一个例子并不符合上述的三种绑定规则。默认绑定则就是在不符合上面所说的规则时所会执行的绑定了，而说是默认不如说这是一种 fallback 策列，而默认绑定的例子实际也就是在此情况将 `this` 绑定到全局对象的策列了。

你肯定见过很多做法来避免污染全局对象，而默认绑定显然在有时不是我们想要的，于是在严格模式下，就不再会允许将 `this` 绑定到全局对象了（而是绑定到了 `undefined` ）。不过当混合使用严格模式和非严格模式时则会有一些别的规则：

``` JavaScript
a = 61;

function foo() {
	"use strict";
	console.log(this.a); // 位于严格模式范围内，不允许默认绑定发生。
}
foo(); // TypeError: this is undefined

function bar() {
	console.log(this.a); // 并非位于严格模式范围内。
}
(function IIFE() {
	"use strict"; // 尽管是严格模式范围，但该范围内并未发生默认绑定，绑定发生在对严格模式范围外的函数调用内。
	bar(); // 61
})();
```

上面的例子中， `foo()` 中的 `this.a` 由于位于严格模式下，于是并不能发生默认绑定。而下方的 `bar()` 包含的 `this.a` 由于并非位于严格模式范围内，故不受严格模式的影响，换句话说，严格模式并非影响整个运行时内的调用栈范围。

值得一提的是，同样作为 “fallback” ，有时候我们希望在出现问题时将 `this` 绑定到我们希望的别的变量上而不是全局对象或 undefined 对象上，我们可以通过自己实现这种策列来达到这样的目的，这种做法有些时候被称为 [软绑定](https://github.com/getify/You-Dont-Know-JS/blob/master/this%20%26%20object%20prototypes/ch2.md#softening-binding)。

## 优先级和例外，以及箭头函数

我们知道了 `this` 绑定的这些规则，接下来需要关心的就是他们之间的优先级关系了。他们的关系是 **new 绑定 > 显式绑定 > 隐式绑定 > 默认绑定** 。这个规则看上去并不使人意外，故这里不再讨论这个顺序相关的细节了。而此处则简单讨论几个 “试图破坏这个规则” 所产生的 “意外”。

回到 **显式绑定** 的范畴，想象我们传入的 `this` 所要绑定的对象参数，如果是 `null` 会怎样？我们会发现它最终会使用默认绑定，尽管这看上去或许也不算是个例外——我们不能绑定到 `null` 上，故只能采取 fallback 方案，也就是默认绑定了。

虽然这种做法看上去很奇怪，但我们实际使用场景也会使用给 `apply()` 或类似函数传入 `null` 的做法，而这种做法通常表示我们并不需要关心 `this` ，例如假定存在一个 `function teji(a, b)`，我们可以使用类似 `teji.apply(null, [61, 616])` 的写法来达到将参数展开以供函数使用的目的。或是类似 `var wolf = teji.bind(null, 61); wolf(616);` 这样使用 bind 来达到为函数进行[柯里化](https://en.wikipedia.org/wiki/Currying) （Currying，即预先设置一些参数的值）的目的。

然而，对于上述的这类应用场景，一旦函数中使用了 `this` ，他们显然还是会使用默认绑定，并可能因此造成难以排查的 bug ，于是更好的做方法则是传入一个空对象而不是 `null` ，这样如果发生了绑定，那么也会绑定到我们所传入的空对象上，而不是意外的绑定到全局对象上了。简单的做法是使用 `{}` ，当然也可以使用 `Object.create(null)`，后者相比前者而言并不会创建 `[[Prototype]]`，故实际后者更加 halal 一些。

尽管在这篇文章的讨论范围内并不打算涵盖太多 ES6 的相关内容，但 ES6 新增的 [箭头函数](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions)（`=>` 胖箭头）还是值得一提的。箭头函数中的 `this` 并不使用上述的四种规则，而是使用更符合正常人脑回路的策略，即使用外层（函数或全局）作用域来决定 `this` 所绑的对象。

尽管不知道你是否使用过这种做法，我肯定是用过...

``` JavaScript
function foo() {
	var self = this; // 存储 this 以供使用
	setTimeout(function(){
		console.log(self.a);
	}, 100);
}

var obj = { a:61 };
foo.call(obj); // 61
```

而如果使用箭头函数，则可以把 `foo()` 写成这样了：

``` JavaScript
function foo() {
	setTimeout(() => {
		console.log(this.a);
	}, 100);
}
```

于是如果你写习惯了 `var self = this` 又怕被上面讲到的规则搞得头大，箭头函数则是个不错的方案。

## 最后

上面就是对 JavaScript 中 `this` 行为的简单讨论了。和上篇一样，如果你对这些内容仍然感兴趣，不妨去读一读《You don’t know JS - this & object prototypes》一书（这篇只覆盖了该书中 `this` 相关的章节的内容）。这是一本开源书，你可以在这里在线阅读这本书，或者购买这本书的电子版或实体版。这本书的中文译本涵盖在《你所不知道的 JavaScript 上卷》中，你也可以考虑看中文版。

尽管 JavaScript 由于历史包袱或语言设计的原因造成了很多和常规思想不一致的行为，因而导致被很多人诟病，但在逐渐熟悉 JavaScript 的过程中我们依然可以从中发现一些有用或者有趣的思想。无论是否选择使用 JavaScript ，能在了解的过程中学得任何东西也都是一种收获了，不是吗？

最后，尽管我会尽可能仔细的检查文章内容是否有问题，但也不保证这篇文章中一定不会有错误，如果您发现文章哪里有问题，请在下面留言指正，或通过任何你找得到的方式联系我指正。感激不尽～

[^1]: ES6 新增的 class 不再本次讨论范围内，如想了解 [请参阅 MDN](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Classes) 或其它相关文档。
