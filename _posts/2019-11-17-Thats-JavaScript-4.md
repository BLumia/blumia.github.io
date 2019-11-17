---
title: 原来JS是这样的 (4)
date: 2019-11-17 16:13:17
---

上一篇提到属性描述符 `[[Get]]` 和 `[[Put]]` 以及提到了访问描述符 `[[Prototype]]`，看它们的特性就会很容易的让人想到经典的面向对象风格体系中对类操作要做的事情，但带一些 introspector 的味道。回想到之前所写来自用的辣鸡[私有云音乐](https://github.com/BLumia/Private-Cloud-Music)应用中所附带了一个建议的类似 `jQuery` 的简易常用功能实现，就用到了简单的 `[[Prototype]]` 特性。但我们前几篇都没有详细的提及 js 的原型链相关的内容，本篇就将讨论 js 的 `[[Prototype]]` 属性和相关的内容。

*注：ES6 的 Proxy 和 class 的概念不在本篇讨论范围内。*

## `[[Prototype]]`

JavaScript 中的特殊对象属性除了 `[[Get]]` 和 `[[Put]]` 外，还有一个很重要的特殊内置属性就是 `[[Prototype]]` 了。

`[[Prototype]]` 是一个**几乎**所有对象在创建时都会被赋予一个非空值的属性，还记得在之前提到 `new` 操作符的行为吗？其中的行为之一就是把其 `[[Prototype]]` 关联指向到对应的内置对象上。**通常** `[[Prototype]]` 所指向的即为创建此对象时所使用的对象了。

来看下面一个例子

``` JavaScript
var macat = { a: 1 };

var codingcat = macat; // 和 macat 指向的内容相同
codingcat.b = 2;
console.log(macat.b); // 2

var pineapple = Object.create( macat ); // 新对象，但其 [[Prototype]] 链向 macat
pineapple.c = 3; // 新对象的属性
console.log(macat.c); // undefined
codingcat.d = 4;
console.log(pineapple.d) // 4;
```

上例中， 变量 `codingcat` 显然是指向和 `macat` 相同的内容，实质完全一致，而 `pineapple` 则是通过 [`Object.create()`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Object/create) 创建的变量。显然 `pineapple` 和 `macat` 是不同的两个对象。不过我们会发现我们依然可以通过 `pineapple.d` 访问 `macat.d` 的值，这就是因为在 `Object.create()` 中，会把 `pineapple` 的 `[[Prototype]]` 指向我们的原型对象 `macat` 了。

那 `[[Prototype]]` 引用的作用是什么呢？看上去这是一个确定这种像 fallback 一样的取值操作应该 fallback 到谁的属性标记，而准确的说，这种 `pineapple.d` 形式的属性引用会触发 `[[Get]]` 操作（上篇的内容），而默认的 `[[Get]]` 则会在对象本身没有此属性时会去查找 `[[Prototype]]` 引用的变量了。这样的引用成为了链状，故被称作原型链。

当然，这个行为其实我们已经“用过”很多次了，比如 `.toString()`、 `.valueOf()`、`hasOwnProperty()`，我们 `Object.create()` 等形式构建的新对象显然并没有附带一份这些函数的副本，而是因为普通的 `[[Prototype]]` 链最终都会指向内置的 `Object.prototype`，而它提供了这些功能。

## 属性设置和屏蔽

不过上例中有个有趣的坑，我们考虑在上例的基础上做如下操作：

``` JavaScript
...
pineapple.a++; // 交互式终端会输出 1
console.log(pineapple.a); // 2
console.log(macat.a); // 1
```

`pineapple.a++` 看上去是进行了变量自增的操作，但这一行后，我们发现 `pineapple.a` 不再等于 `macat.a` 了，这是因为实际上 `pineapple.a` 本来并不存在，但可以通过原型链找到 `macat.a`，而 `pineapple.a++` （相当于 `pineapple.a = pineapple.a + 1`）最终进行的赋值操作创建了 `pineapple.a` ，故最终这两个变量的值自然不再相等。

这个例子来看，如果本身即通过对 `pineapple` 的属性（`a`）进行访问操作，那么不同情况下访问得到的结果可能是不同的甚至是出人意料的。无意中创建的属性“阻止”了原型链上查找这个属性的行为，我们称之为**属性屏蔽**。

属性屏蔽根据变量本身情况的不同会有很多不同的状态表现，例如原型链上层变量的数据访问属性标记为只读的情况，（如果不是严格模式下）尝试进行的赋值操作会被忽略等。

## 类 （迫真）

我们早已知道 JavaScript 中不存在“类”的概念，而为了能够“写着爽”，很多开发者都在想尽办法在 JavaScript 中模仿其它 OO 语言中“类”的行为。其中很常见的做法类似下面这样：

``` JavaScript
function Person(name) {
    console.log("I'm " + name + "!");
    this.name = name;
}

Person.prototype.getName = function() {
    return this.name;
}

var chris = new Person("Chris"); // I'm Chris
var sophie = new Person("Sophie"); // I'm Sophie
chris.getName(); // "Chris"
```

看上去我们的 `Person` 像极了一个包含 `name` 成员变量和 `getName()` 方法的类，并且在其“构造函数”中会输出 "I'm xxx"。不过在之前的文章中我们已经讲过了，并不存在所谓的构造函数，`new` 只是把 `Person()` 函数作为构造对象所需调用的函数进行了一次调用而已。不过你可能还会比较奇怪为什么 `.getName()` 是可以使用的，既然我们在原型链这一章提起这件事，显然是因为原型链，于是回顾之前第二章我们含糊提到的一句话是（[`new` 操作符所执行的操作步骤](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/new#Description)之一是）“对这个新对象执行 `[[Prototype]]` 链接”，实际上，这里我们被 `new` 出来的对象的 `[[Prototype]]` 被关联到了 `Person.prototype` 上，于是当我们尝试进行属性访问的时候，自然就可以访问到 `Person.prototype.getName()` 上了。

不过这个过程还是可能会引起一些蛋疼的误会，比如假设我们在上面例子的基础上：

``` JavaScript
...
sophie.constructor === Person; // true
sophie.constructor === Person.prototype.constructor; // true
Person.prototype = {};
var koishi = new Person("Koishi");  // I'm Koishi
koishi.constructor === Person; // false
koishi.constructor === Object; // true
sophie.constructor === Person; // true
sophie.constructor === Person.prototype.constructor; // false
```

由于“构造函数”这种表现形式的理解，我们有时候会认为 `变量名.constructor` 实际就总是构造调用时指向的函数，甚至 `sophie.constructor === Person` 返回也是 `true` ，但实际并不是这样，这里返回为真，仅仅是因为 `Person.prototype.constructor` 默认指向的就是 `Person` 罢了。于是我们尝试替换 `Person.prototype` 之后创建了变量 `koishi`，再检查 `koishi.constructor === Person` 就不再为真了，在原型链的查找过程最终找到了 `Object.prototype`，然后 `Object.prototype.constructor` 其实指向了 `Object`。

不过，后面我们接着尝试检查了 `sophie.constructor` 却发现似乎它并未受到影响，这个就不要往原型链方面想了，这里的原因仅仅是 `sophie` 的原型链指向的是曾经 `Person.prototype` 所指向的东西上，而我们 `Person.prototype = {}` 的操作只是让 `Person.prototype` 指向了新的东西，旧的东西并没有改变，所以 `sophie` 自然看上去“没有受到影响”了。当然，`koishi` 这个变量被构造时所被调用的函数仍然是 `Person()`，这和 `koishi.constructor` 或者 `Person.prototype.constructor` 的指向没有什么关系。

## 对象实例关系

当然我们还有一点需要重新强调的是，`[[Prototype]]` 和 `.prototype` 不是一回事，`[[Prototype]]` 是描述对象实例关系的属性描述符，而 `.prototype` 只是 `Function` 对象的一个属性而已。`new` 操作符会把新建的对象的 `[[Prototype]]` 指向原对象的 `.prototype` 属性上，仅此而已。

既然 `[[Prototype]]` 实际描述了对象之间的实例关系，那么我们自然就可以想到 `instanceof` 的实际作用了，其所做的事情就是告诉你在 `a instanceof Foo` 中， `a` 的整个原型链中是否有指向 `Foo.prototype` 的对象。

绝大多数浏览器支持一个 `.__proto__` 属性（实际位于 `Object.__proto__`）指向了 `[[Prototype]]` ，这对于我们调试时希望直接访问内部的 `[[Prototype]]` 提供了便利，不过它并不是标准，所以除了调试便利之外还是不要使用它比较好。

## 最后

于是关于原型链相关的简单讨论就到此结束了。和上篇一样，如果你对这些内容仍然感兴趣，不妨去读一读《You don’t know JS - this & object prototypes》一书。这是一本开源书，你可以在这里在线阅读这本书，或者购买这本书的电子版或实体版。这本书的中文译本涵盖在《你所不知道的 JavaScript 上卷》中，你也可以考虑看中文版。

由于近期工作过于繁忙的精力占用缘故，“原来JS是这样的”系列可能就暂时告一段落了。最后，尽管我会尽可能仔细的检查文章内容是否有问题，但也不保证这篇文章中一定不会有错误，如果您发现文章哪里有问题，请在下面留言指正，或通过任何你找得到的方式联系我指正。感激不尽～
