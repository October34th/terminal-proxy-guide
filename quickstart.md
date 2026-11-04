<p align="center">
  <b>简体中文</b> ｜ <a href="quickstart.en.md">English</a>
</p>

<h1 align="center">三步搞定：让终端也能上网</h1>

<p align="center">
  不对原理感兴趣、只想快点用上的人，看这一页就够了。
</p>

---

## 第 1 步：打开终端

按 `⌘ + 空格`，输入 `Terminal`，回车。

中文系统里这个 App 叫「**终端**」，黑底白字，图标上有个 `>_`。

## 第 2 步：复制这一行，粘贴，回车

```bash
curl -fsSL https://raw.githubusercontent.com/October34th/terminal-proxy-guide/main/install.sh | bash
```

脚本会做三件事：备份你的配置文件 → 写入开关 → 自动检查语法。它不下载别的东西，不需要 `sudo`，也不碰系统文件。

## 第 3 步：新开一个终端窗口，敲这两行

```bash
proxy on
proxy test
```

看到 `HTTP 200` 或 `HTTP 301`，就成了。

> 为什么要新开窗口？配置只在**新开的**窗口里才会生效。嫌麻烦也可以在当前窗口敲 `source ~/.zshrc`。

---

## 以后每天只用两个命令

| 命令 | 作用 |
| --- | --- |
| `proxy on` | 打开代理，让终端走 Clash |
| `proxy off` | 关闭代理，回到直连 |

---

## 万一不对

| 你看到 | 意思 | 怎么办 |
| --- | --- | --- |
| `command not found: proxy` | 配置还没生效 | 新开一个终端窗口，或 `source ~/.zshrc` |
| `❌ Clash 没有在 127.0.0.1:7897 监听` | Clash 没开，或端口不是 7897 | 打开 Clash，看「设置 → 混合端口」 |
| `curl: (22) ... 404` | 仓库地址或分支名写错 | 核对 `October34th` 和 `main` 是否拼对 |

还是不行，去看[新手版](beginner/README.md)的排错部分。

---

## 想先确认它安全

三件事你可以自己验证：

```bash
# 1. 只看它打算做什么，不动任何文件
curl -fsSL https://raw.githubusercontent.com/October34th/terminal-proxy-guide/main/install.sh | bash -s -- --dry-run

# 2. 把源码下载下来读一遍
curl -fsSL https://raw.githubusercontent.com/October34th/terminal-proxy-guide/main/install.sh -o /tmp/tpg.sh
less /tmp/tpg.sh

# 3. 后悔了就卸载（会先备份）
bash /tmp/tpg.sh --uninstall
```

脚本源码就在本仓库的 [`install.sh`](install.sh)，全部逻辑都在一个文件里，没有远程加载。

---

## 不想用脚本？

脚本只是省掉手动步骤，两种方式效果完全一样。

- **手动五步** → [新手版 · 装开关](beginner/README.md#装开关5-步)
- **想看原理和更多场景** → [完整版](README.md)

---

## 免责声明

本文档仅供技术学习与交流，不提供任何代理服务、服务器或节点。请遵守你所在国家或地区的法律法规，以及所使用网络服务的条款。文中所有示例只指向本机地址 `127.0.0.1`。

---

<p align="center">
  <sub>最后更新 2026-10 · 适用 macOS 13+ · Clash Verge / Mihomo · 端口 7897</sub>
</p>
