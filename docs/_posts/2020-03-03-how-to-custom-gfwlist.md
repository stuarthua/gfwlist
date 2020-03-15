---
layout: post
title: 如何自定义 gfwlist ？
categories: [gfwlist]
tags: gfwlist
---

### 前言

不可否认，[gfwlist/gfwlist](https://github.com/gfwlist/gfwlist) 是一个非常优秀的公益项目，涵盖了众多网友整理的一些黑名单网址。但实际使用过程中，由于 gfwlist 更新慢，用户总是会碰到一些没有覆盖的网址、或者使用了一些老旧的网址，体验上差强人意。再者，每一个人的浏览习惯都不尽相同，使用公共版的 list 并不能满足个人的自定义需求。有这种困扰的同学，不妨尝试以原版 gfwlist 为基础自定义符合个人浏览习惯的网址清单。

* 了解 gfwlist
* 了解 gfwlist PAC 规则
* 自定义 gfwlist

### 了解 gfwlist

官方：[Github - gfwlist/gfwlist](https://github.com/gfwlist/gfwlist)

在原版 gfwlist 中，其最终提供的名单通过 `Base 64` 加密，形成文本文档。

Mac 中 `base64` 命令使用示例：

```
//1. 把 demo.json 文件 base64 加密
$ base64 demo.json -o abc.txt //加密, -o 后面跟着是输出目录
$ base64 -b 64 -i demo.json -o abc.txt //加密, -b 64 每64个字符换行, -i 后面跟要加密的文件, -o 后面跟着是输出目录
$ base64 -D abc.txt -o 123.json //解密, -o 后面跟着是输出目录

//2. 把 "Man" 字符串进行 base64 加密，并回显输出
$ echo -n "Man" | base64
TWFu

//3. 把 "TWFu" 字符串通过 base64 解密，并回显输出
$ echo -n "TWFu" | base64 -D
Man%
```

使用 `base64` 解密 [github - gfwlist.txt](https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt) 文件，得到解密后的文件：

```
$ base64 -D gfwlist.txt -o list.txt
```

现在，我们得到了一份看起来正常的网址列表清单，面对这众多的网址，熟悉一下 PAC 过滤规则便显得十分有必要了。

### 了解 gfwlist PAC 规则

`PAC` 全称 Proxy Auto Config File，用于根据 URL 选择不同代理服务器或是不代理直接访问，相比于传统代理可以加快速度，也减少代理服务器的流量。

#### PAC 规则描述

PAC 最早是 `Ad Block` 使用的一种规则，用于屏蔽网页各种广告，所以参数除了 URL 外还支持各种 DOM 元素，详细参数可以查看 [Adblock Plus filters explained](https://adblockplus.org/en/filter-cheatsheet)。

基本过滤规则：

```
# 要匹配的 url 地址，如：

http://example.com
or
http://example.com*
```

基本的过滤器 `/`：

```
# 匹配整站，如：

http://example.com/

# 匹配站点部分地址，如：

http://example.com/ads/

# 匹配站点部分资源，如：

http://example.com/ads/banner*.gif
```

使用 `!` 行注释符进行注释：

```
# 使用！作为注释的开始，可以在注释中书写任何想些的文案，如：

! Comment
! Here is comment.
! 我是注释
```

使用 `|` 管线符号来表示地址的最前端或最末端，用于精确控制匹配的开始或结束：

```
# PAC 默认会认为每个规则前后都有通配符，所以，ad 和 *ad* 没有任何区别。为了明确前后，可以加 |。
# gif| 说明在 gif 后没有任何东西了。 |http://xxx 说明在前面没有了。
# 示例：匹配以 http://www.example.com 开头的网址

|http://www.example.com
or
|http://www.abc.com*
```

使用 `||` 子域通配符匹配主域名下的所有子域：

```
# 示例：匹配网址中包含 example.com 的全部站点，如：

||example.com
```

定义例外规则 `@@`：

```
# 可以使用 @@ 表示后面的是例外，不会拦截；也可以配合 | 精确匹配。如：

@@|http://example.com
```

分隔符 `^`，匹配任何单个字符，同样用于精确匹配：

```
# http://example.com/ 和 http://example.com:8000/ 已经能帮助我们匹配到这两个网址，
# 但却不能匹配 http://example.com.ar/ 使用 http://example.com^ 即可实现我们的需求
# 分隔符可以是除了字母、数字或者 _ - . % 之外的任何字符。地址的结尾默认也是一个分隔符。
```

排除标识符 `~`，来修正匹配的地址

字符通配符 `*`，匹配0长度或任意长度的字符串

#### gfwlist PAC 规则格式

了解了 PAC 的规则，我们看一下在 gfwlist 中的应用。目前在 gfwlist 中，有如下的规则格式：

* ```
  example.com
  ```
  
  - 匹配：http://www.example.com/foo
  - 匹配：http://www.google.com/search?q=www.example.com
  - 匹配：http://fakeexample.com/
  - 不匹配：https://www.example.com/

  **说明**：用于表明字符串 `example.com` 为 URL 关键词。任何含关键词的 http 连接（不包括 https）皆会使用代理。
<br>
* ```
  .example.com
  ```
  
  - 匹配：http://www.example.com/foo
  - 匹配：http://www.google.com/search?q=www.example.com
  - 不匹配：http://fakeexample.com/
  - 不匹配：https://www.example.com/

  **说明**：用于表明字符串 `.example.com` 为 URL 关键词。任何含关键词的 http 连接（不包括 https）皆会使用代理。
<br>
* ```
  ||example.com
  ```
  - 匹配：http://example.com/foo
  - 匹配：https://subdomain.example.com/bar
  - 不匹配：http://www.google.com/search?q=example.com
  
  **说明**：匹配整个域名（含子域名）（不论是 http 还是 https），一般用于该站点的 IP 被封锁的情况。
<br>
* ```
  @@||example.com
  ```
  
  **说明**：这种规则的优先级最高，表示所有匹配 `||example.com` 规则的网址均 **禁止代理**。一般用于特殊情况，比如禁止对国内的网站误用代理。
<br>
* ```
  |https://ssl.example.com
  ```

  **说明**：这种规则匹配的是所有以 `https://ssl.example.com` 开头的地址。一般用于某些 IP 的 HTTPS 访问被定点封锁的情况。
<br>
* ```
  |http://example.com
  ```

  **说明**：这种规则匹配的是所有以 `http://example.com` 开头的地址。一般用于某些域名较短的网站，例如短网址服务，可以防止出现慢规则。
<br>
* ```
  /^https?:\/\/[^\/]+example\.com/
  ```
  
  **说明**：这种规则匹配的是域名中含有 `example.com` 这个字符串的，是正则表达式，较不常见。一般用于该字符串被 DNS 污染的情况。
<br>
* ```
  !Foo bar
  ```
  
  **说明**：注释，以英文感叹号开头，解释说明，不起实际作用，可以在注释中书写任何想些的文案。

### 自定义 gfwlist

在了解上述规则后，便可以根据自己的浏览习惯自定义 gfwlist

### Thanks

* [gfwlist/gfwlist](https://github.com/gfwlist/gfwlist)
* [How to write filters](https://help.eyeo.com/en/adblockplus/how-to-write-filters)
* [查找冗余的过滤规则](https://adblockplus.org/zh_CN/redundancy_check)
