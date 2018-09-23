---
title: 使用 TUN 设备实现一个简单的 UDP 代理隧道
date: 2017-09-28 17:05:31
tags: [网络编程]
---

若要实现在 Linux 下的代理程序，方法有很多，比如看着 [RFC 1928](https://www.ietf.org/rfc/rfc1928.txt) 来实现一个 socks5 代理并自行设置程序经过 socks5 代理等方式，下文是使用 Linux 提供的 `tun/tap` 设备来实现 UDP 代理隧道的大体思路和过程讲解。

<!-- more -->

## TUN 设备

tun / tap 是由 Linux （可能还有其他 *NIX 系统提供支持）提供的，可以用来实现用户态的网络路由等处理的虚拟网络接口。也就是说，它们允许用户态的程序直接管理这个网络接口，而不是让内核协议栈来处理网络包。

那么很明显，如果我们要实现一个代理隧道程序，那么我们第一步就要解决包从哪里来的问题，这很好解决，我们知道我们可以通过路由表来指定包到底应该流向哪个网络设备，等数据包进入我们能够控制的网络接口后，我们自行处理网络包的转发就好了。而这里，tun / tap 就是我们所需要的，能够为所欲为的自行处理包状态的虚拟网络接口。

TUN 和 TAP 分别是虚拟的三层和二层网络设备，也就是说，我们可以从 TUN 拿到的就是 IP 层的网络数据包了，而 TAP 则是二层网络包，比如以太网包。因为我只打算对 IP 层的包进行处理（其实只打算处理 TCP 和 UDP），故接下来就只讨论 TUN 设备了。

要想使用 ~~臀~~ TUN 设备，首先需要启用这个内核模块，在我的系统（ Arch linux ）上，只需 `insmod` 一下就行了。

```shell
find /lib/modules/ -iname 'tun.ko.gz' # 找到在哪儿
sudo insmod /lib/modules/4.12.12-1-ARCH/kernel/drivers/net/tun.ko.gz # 插入该模块
modprobe tun # 加载该内核模块，当然你也可以选择 the Windows way: 重启一下
modinfo tun # 可以检查一下了
lsmod | grep tun # 也可以这样检查
```

为了方便，我选择重启...

TUN 设备可以由程序创建和销毁（这种情况下即便程序没有主动的销毁创建的 TUN 设备，程序退出时 TUN 设备也会自行销毁），也可以使用 cli 工具创建和销毁，比如 `ip tuntap` ，`tunctl` ，或是 `openvpn --mktun`。在我们用程序实现之前，我们先使用 `ip tuntap` 来创建一个 TUN 设备来进行简易的测试。

### 简易测试

建立一个 tun 设备（网络接口），然后设置路由表把数据包路由到 tun 设备里。

```shell
sudo ip tuntap add dev dummytun mode tun # 添加一个叫 dummytun 的 tun 设备
sudo ip link set dummytun up # 把设备 dummytun 开起来
sudo route add 123.123.123.123 dummytun # 把 123.123.123.123 路由到 dummytun
ip route get 123.123.123.123 # 试试看是否搞成了
```

如上并没有给这个 tun 设备 IP （但 `ioctl()` 打开这个 tun 设备后就会有一个 IPv6 地址了），当然也可以给它一个 IP ：

```shell
sudo ip addr add 192.168.61.0/24 dev dummytun
```

由于 tun 设备需要我们编写用户态的程序来操作数据包，所以需要写个东西来处理包数据的 IO 。tun 是三层设备，故能拿到的都是三层（ IP 层）的包了。下面是一个非常简单的代码片段，仅仅简单的把东西从 `dummytun` 中读出来而已。

```c
// 此处省略了 tun_open() 的原型。
// 作用仅仅是 `open()` 该设备，`ioctl()` 连接到该设备最终返回文件描述符
int fd = tun_open("dummytun");
// 我们假设是按照刚刚的步骤，在运行程序之前就已经创建并 `up` 了设备 dummytun
// 如果你希望通过代码创建 tun 设备，别忘了把创建的设备 `up` 起来
printf("Device dummytun opened\n");

while(1) {
	int nbytes = read(fd, buf, sizeof(buf));  // FYI: char buf[1600];
	printf("Read %d bytes from dummytun\n", nbytes);
}
```

另外额外需要注意的事是，在写过路由表规则以及给设备绑 IP 之后，最好还是刷一下缓存比较好，以免出现测了半天才发现压根没经过自己的 tun 设备的情况。

```shell
sudo ip route flush cache
```

当开始处理包时，我们就可以在 wireshark 或其他类似软件中看到流经该 tun 的网络包了。值得一提的是，即便事先没有给 tun 设备分配任何 IP 地址的情况下，在使用 `ioctl()` 打开 tun 设备后， tun 设备也将自动分得一个 IPv6 地址，所以在 wireshark 中是可以看到 ICMPv6 包存在的。

## TUN 设备的使用

根据上面的简单测试，我们可以发现，实际上我们的程序本身就是完全接管所创建的虚拟网络设备的，我们程序所处于的职责就是，不断的 `read` 看看哪些网络包需要处理，然后程序进行处理并 `write` 就是了。

作为最简单的实践，我们可以写一个无脑的程序去伪装远程端响应我们网络设备中出现的 ICMP 包，首先本地拦截 `123.123.123.123` 到我们的 TUN 网络设备，然后我们在 ping 的时候，就可以从 TUN 中 `read` 到 ICMP 包了，那么接下来，我们只需要互换 IP 包的源地址和目的地址，并修改 ICMP 包中的标志位为 `ECHO_REPLY` ，（别忘了重算包的checksum）然后写回 TUN 设备，就可以让 ping 程序认为远程端服务器正确的做了响应了。

我在编写时使用了一个叫 `libtins` 的第三方库来做包的拼装和解析，下面则是对上面描述的步骤的一个简单的例子。

``` c++
while(1) {
	nbytes = read(fd, buf, sizeof(buf)); // 假设 fd 为所创建的 tun 设备的文件描述符
	printf("Read %d bytes from dummytun\n", nbytes);
	RawPDU p((uint8_t *)buf, nbytes);
	try {
		IP ip(p.to<IP>());
		cout << "IP Packet: " << ip.src_addr() << " -> " << ip.dst_addr() << std::endl;
		Tins::IPv4Address srcaddr = ip.src_addr();
		ip.src_addr(ip.dst_addr());
		ip.dst_addr(srcaddr);
		ICMP &icmp = ip.rfind_pdu<ICMP>();
		icmp.type(ICMP::ECHO_REPLY);
		write(fd, ip.serialize().data(),ip.serialize().size()); // 其实不建议 serialize 调用两次，这里无所谓了
	} catch (...) {
		continue;
	}
}
```

现在就可以看出我们的程序到底是干嘛的了吧？所以，当我们要实现隧道程序时，我们实际只是需要从我们创建的网络接口上读取数据包，并把数据包通过我们自己的方式发给代理隧道服务端，并等待代理隧道服务端的回复并写回我们创建的的网络接口就好了。也就是说，我们的客户端程序做的事情就是：

- 从 TUN 设备读取数据包
- 将数据包发送给代理隧道服务端（本篇所用的是 UDP 发送未做任何加密处理的数据包）
- 读取代理隧道服务端发回的数据包
- 把发回的数据包写回 TUN 设备

于是接下来我们可以试着把上面的程序改成两部分，客户端仅发送和接收，服务端则仅仅把源地址和目的地址交换并修改 ICMP 头的标志为 `ECHO_REPLY`。示例代码这里就不贴了，有兴趣的读者可以自己试着写一写，很简单的内容。

## 所以，服务端呢？

实际上，客户端的工作就是简单的监听 UDP socket 和 TUN 设备的文件描述符，然后读写就是了，那么服务端怎么把客户端发来的包写到网卡中，又怎么把远程端服务器返回的数据包捕获到程序中呢？

为了让我们的数据包发出去后远程端返回的数据包依然能回到我们的代理隧道服务端程序所处的服务器上，我们自然要对数据包进行一次 sNAT。而假如我们把源地址改成了服务器的 IP，返回的数据包就会进入服务器的默认网络接口。一旦数据包进入由内核控制的网络接口，内核协议栈就会处理 SYN 包并自动做出响应，如果我们隧道中的 TCP 数据包发出去，结果远程端服务器与我们的服务器建立的连接，这就很糟糕了，于是我们需要让我们的数据包不经过协议栈处理而由我们控制。

我们能控制什么？当然是 TUN 设备啦！还记得我们可以给 TUN 设备指定网络地址吗？我们可以在服务端也建立一个 TUN 设备，并指定一个内网网络地址（我假设指定的是`192.168.61.123`），我们把要发的数据包写入该 TUN ，数据包就发出去了。接下来呢？我们当然是写一条 iptables 规则来把数据包导到我们的 TUN 设备了。大概是这样的：

``` shell
iptables -t nat -A POSTROUTING -s 192.168.61.0/24 -o eth0 -j MASQUERADE # 这样写
iptables -t nat -A POSTROUTING -s 192.168.61.0/24 -o eth0 -j SNAT --to-source xxx.xxx.xxx.xxx # 或这样，xx是服务器 IP
```

哦对了。别忘了打开服务器的路由转发功能：

``` shell
echo "1" > /proc/sys/net/ipv4/ip_forward
```

这样的话，我们做 sNAT 的时候把源地址改为 tun 设备的地址就是了，而数据包回来时，网络数据包就会进入我们的能为所欲为控制的 TUN 设备啦！此时我们只需要做一次 dNAT 然后把数据包发回客户端，就大功告成了。

整个过程并不复杂，我的一份简单实现可以见 [GitHub: BLumia/udptun](https://github.com/BLumia/udptun) 。上述内容可能有遗漏和错误，如果你发现了任何错误，都欢迎在下面评论指正，感激不尽！

### 附加内容

其实这篇本身是因为看了 oing 的 TUN 相关博客，发现其中有部分错误，问其得到的答复是我也可以写一篇来讲这个东西。我觉得写一篇如果能帮上他来理解一些内容的话，也算有所帮助吧，但最终并没有帮上忙，有点失望。

由于 oing 的博客内容有误且他不打算更正，这里就不给出链接了。下面是一些可能有用的链接：

 - [tuntap网络接口教程](http://backreference.org/2010/03/26/tuntap-interface-tutorial/) 这一篇在谷歌的第一页其实..
 - [kernel.org 对于 tuntap 的描述文档](https://www.kernel.org/doc/Documentation/networking/tuntap.txt) 毕竟官方文档，看看的好
 - [理解 tuntap 网络接口](http://www.naturalborncoder.com/virtualization/2014/10/17/understanding-tun-tap-interfaces/)
 - [libtins](https://libtins.github.io/) 包拼装和网络嗅探库，尽管我只用它的包拼装..
 - [dblank 的关于同样主题的博客](http://www.littleblank.net/archives/1067/) 以及[他的程序](https://github.com/DMLfor/dbvpn)

关于 iptables 和路由表之类的链接就不贴了，毕竟这篇主要不是写那些的，虽然他们也很重要。顺便这篇博客被博客园从首页推荐中拿掉了，原因是...你懂得...不过没办法...互相理解嘛。

难得我这日记博客的地方能放一片正经的资料...可喜可贺，可喜可贺。
