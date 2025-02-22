---
date: "2019-09-08T20:18:17Z"
title: 原来JS是这样的 (3)
aliases:
  - /2019/09/08/Thats-JavaScript-3.html
---

## 引子

在上一篇（原来JS是这样的 (2)）刚发布的时候就阅读了那篇文章的人可能会注意到那篇曾用过“JavaScript 中万物皆对象”的说法，而在随后我发现错误后立即更新改掉了这个错误的说法。另外上一篇实质上整篇都在描述 `this` 到底在什么情况下会绑定到哪个对象上，看上去 JavaScript 中的对象概念的确很容易让人困惑。再看下面一个例子：

``` JavaScript
var strPrimitive = "I'm mamacat";
typeof strPrimitive; // "string"
strPrimitive instanceof String; // false

var strObject = new String("I'm mamacat");
typeof strObject; // "object"
strObject instanceof String; // true

strPrimitive.substr(8, 3); // "cat"
```

同样的字符串赋值到对象，一会儿是字符串类型一会儿是对象，而明明不是对象类型的变量还是可以使用对象属性，为什么会这样呢？

## 类型和内置对象

JavaScript 中一共有六种主要（语言）类型，即 `string`, `number`, `boolean`, `null`, `undefined` 和 `object`，其中前五个基本类型都不是对象（对 `null` 进行 typeof 得到的是 "object"，这是语言本身的 BUG）。而在此之外，则有许多特殊的对象子类型，例如数组、函数和内置对象等。

有些内置对象的名字看着和简单基本类型一样，就比如 `String`，`Boolean`，`Object` 之类。这些内置对象从表现形式看就和别的面向对象语言中的“类”概念差不多，而正如上篇文章所属，它们实际使只是一些能被用来构造一个对应子类型的内置函数而已（不要困惑，函数也是对象，这里并不矛盾）。于是就可以回到最初的例子，`strObject` 是由内置函数/内置对象 `String` 所构造的变量，对应 `String` 子类型，所以它是一个对象，而 `strPrimitive` 则是一个原始字面值而已。

当然，上面例子中最下面我们看上去对 `strPrimitive` 调用了 `substr()` 函数，这里则是因为，JavaScript 引擎会在需要时，把原始字面量转换成对应的对象，而转换之后我们自然就可以使用属性访问对应的方法了。

## 对象属性

那么，就上方的例子而言，`String` 对象实例就会有 `substr()` 函数可以用，但根据之前的文章可以知道，这些“函数”本身并不属于某个对象，而这些函数实质是对应对象的一个属性。当然，即便我们说某种类型的对象本身具备各种属性，实际上这些属性也多是各自独立存在的，只不过以引用的形式关联在了一起而已，这和之前了解的内容也并不矛盾。这些被关联起来的东西，被称为对象的 **属性**。

### 对象的复制

插播一条快报，尽管之前的文章提到过，上方也又一次反复强调过属性只是以引用的形式关联起来的独立存在，我们有时仍然会“理所应当”的认为属性是对象的一部分，而最容易因此踩坑的地方之一就是对象的复制了。仔细思考即可知道，当我们复制对象时，由于其属性本身只是引用关联，故“复制”得到的对象所包含的属性引用指向的和原本对象的属性引用其实还是同一个位置：

``` JavaScript
var ori = { a : 1};
var ori_copy = ori;
ori.a = 61;
ori_copy.a; // 61
```

显然这很可能和我们的期望不一样，而我们想要真正的拷贝对象则没有完美适用性的方案，很多时候的常规做法则是把对象序列化一下，然后再以此反序列化得到新的对象来实现对象的拷贝（比如使用 json）。ES6 中新增了 `Object.assign()` 来进行对象的浅拷贝，做法是把对象的所有可枚举属性等号赋值到新对象中。不过仍需注意的是，等号赋值并不会赋值属性的元信息（属性描述符，后述），在需要的情况下应当特别留意。

### 属性访问和数组

访问对象所关联的属性的方式即通过 `.` 或者 `[]` 操作符进行访问，`obj.a` 和 `obj["a"]` 访问的属性实质上是一样的，而这两种访问形式的区别也只有访问的属性名称里能不能有奇怪的符号而已。`[]` 操作符内扔的是个字符串，实际上属性名也永远都是字符串。当然，这个概念可能比较意外的就是，数组的下标访问其实并不是例外，数字还是被转换成了字符串才被使用的。

``` JavaScript
// 对象的属性访问：
var tejilang = {1 : "Teji Wolf"};
tejilang instanceof Array; // false
tejilang["1"]; // "Teji Wolf"
tejilang[1]; // "Teji Wolf"

// 这回保证它是 Array
var macat = ["codingcat"];
macat instanceof Array; // true
macat.length; // 1
macat[0]; // "codingcat"
macat["0"]; // "codingcat"
macat.length = 20;
macat; // (20) ["codingcat", empty × 19]
```

数组下标既然不属例外情况，那数组对象必然有其它属性控制数组本身的行为，例如上例中，`macat` 数组的长度就是 `length` 属性所体现的，通过修改它的值也就改变了对象本身对外的表现形式。当然，由于数组本身就是对象，所以我们还是可以把数组当键值对来用，只是这种做法通常是没有意义且会让人感到困惑的。JavaScript 引擎通常都根据对象的类型做了不同程度的优化，故除了代码逻辑可读性外，合理的使用也是多少可以改善性能的。

能够通过字符访问属性还是存在一些别的好处的，比如 ES6 的可计算属性名。当然 ES6 不在本文的关注范围内，所以这里就不再讨论了。

## 属性描述符

有时我们可能不希望某个属性被随意修改，有时候我们需要额外配置一些属性的信息，自 ES5 起，所有的属性就都具备了“属性描述符”（Property Descriptor）来控制属性本身的这些元信息。

### 数据描述符

来看这个例子：

``` JavaScript
var chris = {};
Object.defineProperty(chris, "IQ", {
	value: 228,
	writable: false,
	configurable: true,
	enumerable: true
});
chris.IQ = 61; // 静默失败了，如果是严格模式则会 TypeError
chris.IQ; // 228
```

通过 `defineProperty` 可以对一个对象的属性配置其对应的属性描述符（元信息），而属性描述符则包含访问描述符和数据描述符，上面的例子中，`defineProperty` 的第三个参数就定义了数据的若干数据描述符，其中 `writable` 表示可写，`configurable` 表示属性是否可配置（注意，修改成不可配置是单向操作），`enumerable` 则表示属性是否应当出现在枚举中，比如 `for..in` 中。

显然我们可以通过属性描述符实现对属性的保护，而同时也存在一些方便函数来做近似的事。如 `Object.preventExtensions()` 会保留原有属性但禁止添加新属性，`Object.seal()` 会密封对象，在禁止添加新属性的基础上把原有属性标记为不可配置，`Object.freeze()` 会冻结对象，即在密封的基础上把数据访问属性标记为不可写。

### `[[Get]]`, `[[Put]]` 和访问描述符

在我们访问和赋值一个对象的属性时，实际上是通过 `[[Get]]` 和 `[[Put]]` 操作进行的，例如属性访问时，`[[Get]]` 会先找有没有这个属性，如果没有则会遍历对象的 `[[Prototype]]` 链（原型链，这次不谈这个概念）来找，实在找不到则返回 `undefined` 。而这个行为实际是允许我们通过设置 getter （`get()`）和 setter （`set()`）函数来改变的，它们被称为 **访问描述符**。

当我们提供访问描述符时，对应的访问操作就不再受到 value 和 writable 属性的影响了，另外需要注意的是，尽管它们也是属性描述符，但定义 getter 和 setter 并不要求一定要通过 `defineProperty` 设置：

``` JavaScript
var obj = {
	get a() { // 给 a 属性定义 getter
		return this._a_;
	},
	set a(val) { // a 属性的 setter
		this._a_ = val * 2;
	}
}

obj.a = 2;
obj.a; // 4
```

### 属性存在性

因为属性的值也可能是 `undefined`，不存在的属性直接访问得到的也是 `undefined`，所以直接通过简单的属性访问是无法区分是否存在的，这时我们即可通过 `in` 或者 `hasOwnProperty()` 检查属性是否存在对象中了:

``` JavaScript
var obj = {a : 2};
"a" in obj; // true
obj.hasOwnProperty("a"); // true
```

尽管仍没有讲到原型链的概念，这里仍然应注意，`in` 操作符会检查原型链中是否存在属性，而 `hasOwnProperty` 则不会。另外在一些情况下，有的对象会没有 `hasOwnProperty` 这个属性（此处不提原因），这时可以用过 `Object.prototype.hasOwnProperty.call(objName, propertyName)` 来实现检查。

## 最后

继上次 `this` 行为的研究后，这次进一步了解了 JavaScript 中对象属性的相关基本概念。和之前一样，如果你希望进一步了解这相关的内容，不妨去读一读《You don’t know JS - this & object prototypes》一书（这篇只覆盖了该书中 “对象” 一章的内容）。这是一本开源书，你可以在这里在线阅读这本书，或者购买这本书的电子版或实体版。这本书的中文译本涵盖在《你所不知道的 JavaScript 上卷》中，你也可以考虑看中文版。

最后，尽管我会尽可能仔细的检查文章内容是否有问题，但也不保证这篇文章中一定不会有错误，如果您发现文章哪里有问题，请在下面留言指正，或通过任何你找得到的方式联系我指正。感激不尽～
