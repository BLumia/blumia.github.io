---
title: 回到 GitHub Pages
layout: post
--- 

为了减少预算支出和为服务器调整做准备，打算把个人主页放回 ghpages ，或者是把一部分页面放回 ghpages ，除了不确定的~~博客~~日记是否迁移之外，别的大概都可以搬过来，能节省一部分精力去维护这些东西。

前一段写了这个 Jekyll 主题以便把东西都 port 过来，这次就是把所有除了博客文章的内容外的东西都搬过来了。接下来是否迁移博客文章过来还没想好，至于之前在我 ghpages 里的那些博客文章页面就在本次迁移中消失了，是否会 port 过来还不确定，不过反正如果真的是想找那些旧文章，我又不是 `git reset --hard` 了，所以真的想找的话又不是没办法，然而谁会那么无聊...

另外，这次迁移 Jekyll 还是有一些不满意的地方的。由于本身选择各种使用 markdown 的文章撰写平台/工具的目的就是为了尽可能保持专注于文章本身而不是标记，但 Jekyll 或者说 GitHub Pages 支持的 Jekyll 还是有一些比较蛋疼的限制。比如尽管可以使用 `parse_block_html` 和 `parse_span_html` 来控制是否把 html tag 内的内容视为 markdown 解析，但 kramdown (GitHub Pages [钦定](https://help.github.com/articles/configuring-jekyll/)的 用于 Jekyll 的 Markdown 解析引擎) 却并不总能把所有常见的 tag 正确识别区分，其中就包括 `<summary>` 。以及另一个比较奇怪的地方是，作为已经支持 front-matter 的博客引擎，不清楚为什么 Jekyll 还是一定要要求文章的文件名是 `YEAR-MONTH-DAY-title.md` 这样的格式。

总之个人主页或者博客这种性质的东西，尤其是我这种基本没人看的，应该不会有人在乎时效性吧，那什么时候迁完...就随缘吧（
