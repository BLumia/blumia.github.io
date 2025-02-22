---
date: "2018-08-12T18:39:08Z"
title: Main 通常是一个函数。那什么时候不是呢？
aliases:
  - /2018/08/12/main-is-usually-a-function.html
---

[原文链接](https://jroweboy.github.io/c/asm/2015/01/26/when-is-main-not-a-function.html), 由于翻译需要和译者所使用的环境不同，对文章的部分内容有修改，相关原因请参见脚注和原文最后附加的内容。

---------

事情得从我的一个同事说起，尽管他已经知道怎么编写程序了，并且曾在大学内开设了入门级别的计算机科学的课程。我们拿他开涮说，他的课程内容需要把一个程序跑起来，但是他的助教却压根搞不清楚程序到底是 _怎么_ 跑起来的。所以挑战来了，我们可以搞一个能正常工作的程序，还得让这种不熟悉工作原理的人认为这程序不应该跑起来。因此，我开始在脑子里翻我曾经见过或用过的 C 语言奇技淫巧，其中一个点子尤为符合这个要求。这个点子来自一个叫 [main 通常是一个函数](http://mainisusuallyafunction.blogspot.com/) 的博客名字，于是我就开始想，那 main 什么时候能够**不是**一个函数呢？让我们搞清楚吧！

（请留意，我是在 64 位 Linux 下编写的这些例子，并且不同发行版的 gcc 所用的默认参数很可能是不同的，你很可能需要根据情况调整代码）

我解决这个问题的方式和大多数码农差不多。第一步：谷歌这个问题。第二步：把看上去相关的链接挨个点进去看，如果没，就换个关键词接着搜。幸运的是，这个问题答案就在搜索结果很靠前的 [这篇 Stackoverflow 回答中](https://stackoverflow.com/a/2252429/745719) 。实际上在 1984 年，一个奇怪的程序拿下了 IOCCC （国际C语言混乱代码大赛）的第一名，而它的 main 则是一个 `short main[] = {...}` （ short 数组），并且这个程序最终还能把东西输出到屏幕上！不过由于当时编写那个程序所用的编译器和架构都不清楚，于是想搞清楚那个程序到底输出了啥已经不是那么容易了，但通过那个程序的源码来看，由于就是一堆数字，那我猜那堆数字肯定就是某个函数的编译好的二进制内容，而当链接器试图寻找 main 函数的时候则使它作为要找的内容来使用。

那么该程序的源码就仅仅是把 main 函数编译好的机器码作为数组形式呈现了出来——有了这个假说，那就让我们来看一下我们能不能写个小程序来验证这种做法的可行性。

``` c
char main[] = "你好, 世界!";
```

``` shell
$ cat main_char.c 
char main[] = "你好, 世界!";
$ gcc -Wall main_char.c -o first
main_char.c:1:6: warning: ‘main’ is usually a function [-Wmain]
 char main[] = "你好, 世界!";
      ^~~~
$ ./first 
段错误 (核心已转储)
```

好！它好使了！算是好使了...所以我们的下一个目标就是让这个程序实际能在屏幕上输出点东西。根据我有限的汇编经验，我想起编译后的内容会被划分到不同的段（section）下存储。和我们所要做的事情最相关的就是 `.text` 段和 `.data` 段了。其中 `.text` 这个只读段包含了所有可执行的代码而 `.data` 则包含了可以被读写但不可执行的数据。对于我们的情况，我们需要想个办法把字符串 `"你好, 世界!"` 搞进 main 函数并且能引用到它。

于是我开始看怎么能用尽可能少的代码把东西输出到屏幕。由于咱们的目标系统确定是 64 位 Linux 系统，于是我发现可以使用 `write()` 系统调用 [^1] 来把东西输出到屏幕上。现在来看我其实不用为了这个写汇编，不过我觉得我写这些汇编的同时也学到了一些东西，还是划得来的。刚开始写行内 GCC ASM 汇编是最难的部分，而找到窍门之后，事情就会变得简单了。

入门起来其实并没有那么简单，现在谷歌到的最多的汇编知识都是那些：古董的，英特尔语法的，适用于 32 位系统的东西。而鉴于我们要做的是在 64 位机的 gcc 上不修改任何编译参数的编译代码完成我们的目标，所以我们就不能指望能通过指定编译参数来使用 AT&T 语法的行内汇编了，而我的大部分时间都花在了找关于关于如何编写能在 64 位机上跑的现代化汇编上面了！也许我的谷歌功夫不到家吧 :) 这部分我做了诸多尝试，我的目标也就是使用 gcc 行内汇编来通过系统调用把 "你好, 世界!" 输出到屏幕上，为什么就这么难呢？对于想要了解相关内容的人们，我推荐看看这些网站：[Linux 系统调用清单](https://filippo.io/linux-syscall-table/) ，[行内汇编简介](https://wiki.osdev.org/Inline_Assembly) 和 [Intel 和 AT&T 语法的区别](http://asm.sourceforge.net/articles/linasm.html#Syntax) 。

最终我的汇编代码憋出来了并且好像好使！记住我们的目标是生成一个包含了一堆内容是能输出 “你好, 世界!” 的汇编的数组 main [^2]。

``` c
void main() {
    __asm__ (
        // 输出: 你好, 世界!
        "movl $1, %eax;\n"  // 在 64 位机上 1 是系统调用 write 的编号
        "movl $1, %ebx;\n"  // 这里的 1 表示 stdout 标准输出，是 write 的第一个参数
        "movl $message, %esi;\n" // 把字符串的地址作为第二个参数传入
        "movl $16, %edx;\n"  // 第三个参数是字符串的长度
        "syscall;\n"
        // 调用 exit (所以就不会试图运行那个字符串了)
        // 或许我可以直接使用 ret ?
        "movl $60, %eax;\n"
        "xorl %ebx, %ebx; \n"
        "syscall;\n"
        // 在 main 函数中存储 你好, 世界! 字符串
        "message: .ascii \"你好, 世界!\\n\";"
    );
}
```

``` shell
$ gcc -no-pie -Wall asm_main.c -o second
asm_main.c:1:6: warning: return type of ‘main’ is not ‘int’ [-Wmain]
 void main() {
      ^~~~
$ ./second 
你好, 世界!
```

塔哒！它输出了！让我们看看编译后的代码的十六进制吧，它应该和我们手写的代码行行对应。我另外加了点注释。

``` plain
$ gdb ./second
... 略去一段输出 ...
(gdb) disass main
Dump of assembler code for function main:
   0x0000000000400497 <+0>:	push   %rbp                  ; 编译器插入的
   0x0000000000400498 <+1>:	mov    %rsp,%rbp
   0x000000000040049b <+4>:	mov    $0x1,%eax             ; 这是我们的代码！
   0x00000000004004a0 <+9>:	mov    $0x1,%ebx
   0x00000000004004a5 <+14>:	mov    $0x4004ba,%esi
   0x00000000004004aa <+19>:	mov    $0x10,%edx
   0x00000000004004af <+24>:	syscall 
   0x00000000004004b1 <+26>:	mov    $0x3c,%eax
   0x00000000004004b6 <+31>:	xor    %ebx,%ebx
   0x00000000004004b8 <+33>:	syscall 
   0x00000000004004ba <+35>:	in     $0xbd,%al             ; 我们的哈喽沃德字符串
   0x00000000004004bc <+37>:	movabs 0x96b8e4202cbda5e5,%al; 这里并不是真正的汇编
   0x00000000004004c5 <+46>:	out    %eax,$0x95            ; gdb 把我们的字符串强行反汇编了
   0x00000000004004c7 <+48>:	mov    %fs,(%rcx)
   0x00000000004004c9 <+50>:	or     0x1f0fc35d(%rax),%dl
End of assembler dump.
```

这个 main 看上去很科学！所以现在让我们把这些内容的以十六进制的形式的内容搞到手，然后再处理成字符串看看好不好使吧。把这些内容转成十六进制我们依然可以使用 gdb 来做。我觉得可能有更好的办法来做这件事，如果你有更好的方法的话，欢迎在评论区留言告诉我 :) 我的做法是像下面这样用 gdb 载入程序并输出十六进制。上次我们反汇编 main 的时候我们看到了 56 字节长（注：or 指令一行长度为 6），我们可以使用 `dump` 命令把这些东西存成文件：

``` shell
# 这是如何以十六进制形式输出的示例：
(gdb) x/56xb main
0x400497 <main>:	0x55	0x48	0x89	0xe5	0xb8	0x01	0x00	0x00
0x40049f <main+8>:	0x00	0xbb	0x01	0x00	0x00	0x00	0xbe	0xba
0x4004a7 <main+16>:	0x04	0x40	0x00	0xba	0x10	0x00	0x00	0x00
0x4004af <main+24>:	0x0f	0x05	0xb8	0x3c	0x00	0x00	0x00	0x31
0x4004b7 <main+32>:	0xdb	0x0f	0x05	0xe4	0xbd	0xa0	0xe5	0xa5
0x4004bf <main+40>:	0xbd	0x2c	0x20	0xe4	0xb8	0x96	0xe7	0x95
0x4004c7 <main+48>:	0x8c	0x21	0x0a	0x90	0x5d	0xc3	0x0f	0x1f
# 这是如何把它保存到文件的示例：
(gdb) dump memory hex.out main main+56
```

现在我们有了十六进制的内容数据 [^3] ，我们可以用最简单的方式把它转成数字——使用 python 。在 python 2.6 和 2.7 中 [^4] 你可以使用下面的方式简单的把它们转成 int 数组以备使用。

``` python
>>> import array
>>> hex_string = "554889e5b801000000bb01000000beba044000ba100000000f05b83c00000031db0f05e4bda0e5a5bd2c20e4b896e7958c210a905dc30f1f".decode("hex")
>>> array.array('B', hex_string)
array('B', [85, 72, 137, 229, 184, 1, 0, 0, 0, 187, 1, 0, 0, 0, 190, 186, 4, 64, 0, 186, 16, 0, 0, 0, 15, 5, 184, 60, 0, 0, 0, 49, 219, 15, 5, 228, 189, 160, 229, 165, 189, 44, 32, 228, 184, 150, 231, 149, 140, 33])
```

我觉得如果我能提高我的 bash 和 unix 知识水平的话估计我会有更好的办法来做这件事，但是谷歌搜 “hex dump of compiled function” 得到的结果却是如何用哪种哪种语言输出十六进制。不过还好我们现在已经得到了我们想要的 main 数组，那就让我们试试建个新文件看看好不好使吧！下面的段落也附带了注释表示每个数字分别是啥意思。

``` c
char main[] = {
    85,                 // push   %rbp
    72, 137, 229,       // mov    %rsp,%rbp
    184, 1, 0, 0, 0,    // mov    $0x1,%eax
    187, 1, 0, 0, 0,    // mov    $0x1,%ebx
    190, 186, 4, 64, 0, // mov    $0x4004ba,%esi
    186, 16, 0, 0, 0,   // mov    $0x10,%edx
    15, 5,              // syscall
    184, 60, 0, 0, 0,   // mov    $0x3c,%eax
    49, 219,            // xor    %ebx,%ebx
    15, 5,              // syscall
    // ？？？？？？？？？？？
    228, 189, 160, 229, 165, 189, 44, 32, 228, 184, 150, 231, 149, 140, 33, 10, 144, 93, 195, 15, 31
};
```

``` shell
$ gcc -no-pie -Wall compiled_array_main.c -o third
compiled_array_main.c:1:6: warning: ‘main’ is usually a function [-Wmain]
 char main[] = {
      ^
$ ./third
段错误 (核心已转储)
```

段错误？哪里搞炸了？ gdb 伺候！由于 main 现在已经不是个函数了，于是我们没办法使用 `break main` 打断点。不过，我们可以用 `break _start` 来在 libc 运行时跑起来的位置（接下来就会调用 main ）打断点然后来看看什么地址被传给了 `__libc_start_main` ：

``` shell
$ gdb ./third
(gdb) break _start
(gdb) run
(gdb) layout asm
   ┌─────────────────────────────────────────────────────────────────┐
B+>│0x5555555544f0 <_start>                 xor    %ebp,%ebp                                                    │
   │0x5555555544f2 <_start+2>               mov    %rdx,%r9                                                     │
   │0x5555555544f5 <_start+5>               pop    %rsi                                                         │
   │0x5555555544f6 <_start+6>               mov    %rsp,%rdx                                                    │
   │0x5555555544f9 <_start+9>               and    $0xfffffffffffffff0,%rsp                                     │
   │0x5555555544fd <_start+13>              push   %rax                                                         │
   │0x5555555544fe <_start+14>              push   %rsp                                                         │
   │0x5555555544ff <_start+15>              lea    0x16a(%rip),%r8        # 0x555555554670 <__libc_csu_fini>    │
   │0x555555554506 <_start+22>              lea    0xf3(%rip),%rcx        # 0x555555554600 <__libc_csu_init>    │
   │0x55555555450d <_start+29>              lea    0x200b2c(%rip),%rdi        # 0x555555755040 <main>           │
   │0x555555554514 <_start+36>              callq  *0x200ac6(%rip)        # 0x555555754fe0                      │
   │0x55555555451a <_start+42>              hlt                                                                 │
   │0x55555555451b                          nopl   0x0(%rax,%rax,1)                                             │
   │0x555555554520 <deregister_tm_clones>   lea    0x200b51(%rip),%rdi        # 0x555555755078                  │
   │0x555555554527 <deregister_tm_clones+7> push   %rbp                                                         │
   └─────────────────────────────────────────────────────────────────┘
native process 26086 In: _start                                                         L??   PC: 0x5555555544f0 |
```

通过测试，我发现被压入 `%rdi` 的就是 main 的位置，但是这回看上去不太对劲。等会儿， main 被放到了 `.data` 段！上面我们提到 `.text` 是只读的可执行代码所在的段落而 `.data` 是不可执行的可读写变量区域！等于说这段代码试图在运行被标记不可执行的段落于是就炸了。那我们怎么才能把 main 放到 `.text` 段呢？好了搜索引擎也罢工了，似乎真的穷途末路了。还是洗洗睡吧。

但是想不到答案实在是睡不着，我就接着搜啊搜直到在 Stack Overflow 搜到了一个看起来巨简单明了的方案，链接我忘了，不过方法就是把 main 定义成 `const` 的。我们要做的就只是把它改成 `const char main[] = {` 就行了。所以咱们再来试试吧。

``` shell
$ gcc -no-pie -Wall const_array_main.c -o fourth
const_array_main.c:1:12: warning: ‘main’ is usually a function [-Wmain]
 const char main[] = {
            ^
$ ./fourth
SA��I��L)�H�H�
```

！什么飞机！来 gdb 走起：

``` shell
gdb ./fourth
(gdb) break _start
(gdb) run
(gdb) layout asm
```

然后从这坨汇编里可以看到在我机器上 main 的地址是 `0x5555555546a0` 。于是就可以 `break *0x5555555546a0` 用这个地址打个断点然后按 `c` 接着跑。

``` shell
(gdb) break *0x5555555546a0
(gdb) c
(gdb) x/56i $pc     # $pc is the current executing instruction
...
   0x4005a4 <main+4>:   mov    $0x1,%eax
   0x4005a9 <main+9>:   mov    $0x1,%ebx
   0x4005ae <main+14>:  mov    $0x4004ba,%esi
   0x4005b3 <main+19>:  mov    $0xd,%edx
   0x4005b8 <main+24>:  syscall
...
```

不重要的汇编我省略了，如果你还没看出来毛病在哪，用来输出的字符串的地址（0x4004ba）并不是我们存 “你好, 世界!\n” 的地址（???）！它还在使用原来的可执行之前计算后的位置而不是一个相对的内存位置。这就意味着我们需要修改汇编代码使得字符串的位置使用一个相对当前指令位置的位置。这对于 32 位机汇编来说很难，但还好我们再用 64 位机汇编，所以我们就可以使用 `lea` 指令来搞事了。

``` c
void main() {
    __asm__ (
        // 输出: 你好, 世界!
        "movl $1, %eax;\n"  // 在 64 位机上 1 是系统调用 write 的编号
        "movl $1, %ebx;\n"  // 这里的 1 表示 stdout 标准输出，是 write 的第一个参数
        // "movl $message, %esi;\n" // 把字符串的地址作为第二个参数传入
        // 距离当前指令 16 字节的位置
        "leal 16(%eip), %esi;\n"
        "movl $16, %edx;\n"  // 第三个参数是字符串的长度
        "syscall;\n"
        // 调用 exit (所以就不会试图运行那个字符串了)
        // 或许我可以直接使用 ret ?
        "movl $60, %eax;\n"
        "xorl %ebx, %ebx; \n"
        "syscall;\n"
        // 在 main 函数中存储 你好, 世界! 字符串
        "message: .ascii \"你好, 世界!\\n\";"
    );
}
```

然后我们来编译一下看看好不好使：

```
$ gcc -no-pie -Wall relative_str_asm.c -o fifth
relative_str_asm.c:1:6: warning: return type of ‘main’ is not ‘int’ [-Wmain]
 void main() {
      ^
$ ./fifth
你好, 世界!
```

现在我们该像之前做过的一样把十六进制值搞出来再转成字符串了。不过这回我想通过使用 4 字节宽的 int 类型而不是之前的 char 来让它变得更有意思。我们可以直接 gdb 得到所需的东西并复制粘贴到我们的代码里。

```
gdb ./fifth
(gdb) x/15dw main
0x400497 <main>:	-443987883	440	113408	-1922629632
0x4004a7 <main+16>:	4149	1096192	84869120	15544
0x4004b7 <main+32>:	266023168	-1598168059	750626277	-1766267872
0x4004c7 <main+48>:	562861543	-1017278454	1096237456
```

现在指令长度是 58 ，除以 4 并保险起见向上取整得到 15 。由于我们的程序返回了所以额外的长度不会有什么影响。


``` c
const int main[] = {
    -443987883, 440, 113408, -1922629632,
    4149, 1096192, 84869120, 15544,
    266023168, -1598168059, 750626277, -1766267872,
    562861543, -1017278454, 1096237456
};
```

``` shell
$ gcc -no-pie -Wall final_array.c -o sixth
final_array.c:1:11: warning: ‘main’ is usually a function [-Wmain]
 const int main[] = {
           ^
$ ./sixth
你好, 世界!
```

你看，好使！而整个过程中我们也一直在无视编译器给我们的警告：“Main 通常是一个函数” :)

我估计我那同事看到之后会涨一点写辣鸡代码的习惯然后剩下的内容“闷声发大财”了。

[图片]

-------------

最初继德让我写写给 DDE 做新音效主题的过程，但想来一我并不是在 Linux 下制作的音效主题 [^5] ，二那套主题并不会包含在接下来即将发布的版本中，故就没有写这件事。翻译这篇文章的起因是我高中时维护的 [在线判题平台](https://oj.blumia.cn/) 中的题目 A + B 由于偷懒只放了一组测试数据（故实际想 AC 该题目只需要 `puts(“*在这里 hardcode 答案*”)` 就行了。而由于题目都有对应一个单题榜单，就有人打趣要写 “最短的 AC 代码”，而试图使用的则是该文章所提及的内容。这篇文章是蛮有趣的文章，就按照步骤翻译过来给大家分享。

在翻译过程中必然要试着自己复现整个过程，而这个过程还是遇到了一些问题，比如如果你看过原文可能会发现我在几乎所有编译指令都追加了 `-no-pie` 参数 [^6] 。由于不同的发行版下 gcc 的默认参数是不同的（可以使用 `gcc -Q -v` 查看你当前的默认参数），这可能就会影响到具体的编译生成的结果。由于文章在涉及访问我们的哈喽沃德字符串时多次涉及了位置相关的内容，我们显然不需要 gcc 提供的 [位置无关可执行](https://en.wikipedia.org/wiki/Position-independent_code#Position-independent_executables) 特性。另外，由于编译结果可能各不相同，为了能提供正确的上下文，我在这里提供的代码均为我实际复现环境下的情况。另外还补充了一些原文可能缺少的或者可能对有兴趣复现的读者有帮助的内容。例如如果你使用 python3 并需要转换 hex 到 char 数组，可以使用这种方式：

``` python
>>> import binascii, array
>>> hex_string = binascii.unhexlify("554889e5b801000000bb01000000beba044000ba100000000f05b83c00000031db0f05e4bda0e5a5bd2c20e4b896e7958c210a905dc30f1f")
>>> array.array('B', hex_string)
```

如果你对代码怎样生成汇编感兴趣，也可以访问[这个网站](https://gcc.godbolt.org)玩玩。


[^1]: 通过 auditd 包提供的 `ausyscall` 工具可以方便的通过系统调用编号查到对应的系统调用名称。
[^2]: 这段汇编涉及到的字符串长度值 `16` 可以尝试使用 `python3` 执行 `len("你好, 世界!\n".encode('utf-8'))` 得到。
[^3]: 以 hex 来 "cat" ： `xxd -p hex.out | tr -d '\n'` 。
[^4]: 对于 python3 ，可以使用文末附带的方式达到同样的目的。
[^5]: 整个过程是在 Windows 下使用 SONAR Platinum 和 FL Studio Fruity Edition 制作的。没在 Linux 下制作的原因是没有使用起来比较顺手的 DAW 。
[^6]: 感谢 [chris](https://github.com/chirs241097/) 协助发现了问题。





