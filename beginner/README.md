<p align="center">
  <b>简体中文</b> ｜ <a href="README.en.md">English</a>
</p>

<h1 align="center">终端代理开关 · 新手版</h1>

<p align="center">
  不用懂网络。照着做，10 分钟让 <code>brew</code>、<code>git</code>、<code>curl</code> 在终端里正常上网。
</p>

> 想看原理、更多场景和排错细节？去[完整版](../README.md)。只想查命令？本文最后有[速查表](#一页速查)。

---

## 这份文档适合谁

- 第一次打开「终端」这个 App；
- 看到别人发来的一串命令就头疼；
- 只想知道"我到底该敲哪几行"。

不需要编程基础。你只要会**复制**、**粘贴**、**回车**。

---

## 先说人话：代理是什么

打个比方。

你要寄一封信到国外，自己寄不过去，于是找了一个中转站：你把信交给它，它替你寄出去；回信也先到它那里，再由它转给你。

Clash 就是你 Mac 上的这个中转站。它开了一扇"门"，门牌号是 **7897**。

问题来了：浏览器和大多数日常 App 愿意把请求交给中转站，因为它们会主动看门牌。但 `brew`、`git`、`curl` 这些命令行程序不看门牌，它们只会闷头自己往外发。

你要做的，就是明确告诉它们一句："请走 7897 号门。"

这句话，在技术上叫"设置环境变量"。这份文档做的事，是把它变成一个能开能关的开关。

```text
你的命令  →  Clash（7897 号门）  →  互联网
```

---

## 你要认识的 5 个词

| 词 | 一句话解释 | 打个比方 |
| --- | --- | --- |
| 终端 Terminal | 一个用打字指挥电脑的窗口 | 打字版的 Siri |
| 命令 | 你在终端里敲的一行字 | 一句指令 |
| 端口 | 程序在电脑上开的门牌号 | 大楼里的房间号 |
| 环境变量 | 贴在窗口上的一张便条，程序会读 | "出门请走 7897 号门" |
| 配置文件 | 一个存着设置的小文本文件 | 记事本，每次开窗口自动读一遍 |

还有两个你一定会看到的东西：

- **`~`** 表示"你的个人文件夹"，就是 Finder 左边那个房子图标。所以 `~/.zshrc` 指的是"你个人文件夹里的 `.zshrc` 文件"。
- **`127.0.0.1`** 表示"这台电脑自己"。它不是外网地址，只在你自己电脑里用。

再记两个词，后面会用：

- **系统代理**：Clash 里的一个开关，打开后浏览器之类的 App 会走代理，但命令行**不会**。
- **TUN**：Clash 里的另一个开关，打开后**所有**程序都走代理，包括命令行。

---

## 开始前的 3 项检查

花两分钟，把这三件事弄明白，后面就不会卡住。

### ① 打开终端

按 `⌘ + 空格`，输入 `Terminal`，回车。

中文系统里这个 App 叫「**终端**」，图标是一个黑底白字的 `>_`。

打开后你会看到一个窗口，里面有 `%` 或 `$` 符号——那是"可以打字了"的意思。

> [!TIP]
> 在终端里粘贴用 **`⌘ + V`**，不是 `Ctrl + V`。这个搞错会浪费你十分钟。

### ② 搞清楚自己用的是哪种 shell

在终端里输入这一行，然后回车：

```bash
echo $SHELL
```

看输出：

| 你看到 | 你是 | 你的配置文件 |
| --- | --- | --- |
| `/bin/zsh` | zsh（大部分 Mac 都是这个） | `~/.zshrc` |
| `/bin/bash` | bash | `~/.bash_profile` |
| 其他（比如 fish） | 少见 | 本文不适用，见 [Q7](#q7我用的不是-zsh-也不是-bash怎么办) |

**记下你的配置文件**，第 1 步和第 3 步都要用到。

### ③ 找到 Clash 的端口

打开 Clash Verge → 点 `设置` → 找到 **混合端口**（Mixed Port）。

默认是 **`7897`**。看一眼你的是不是这个数字，记下来。

> [!IMPORTANT]
> 如果这里填错，后面每一步都会失败。宁可多看一眼。

---

## 装开关：5 步

每一步都是同一个套路：**做什么 → 敲什么 → 看到什么才算成功**。

### 第 1 步：打开配置文件

按「开始前的 3 项检查」里第 ② 项查到的结果，选一组执行。

如果你用 **zsh**：

```bash
nano ~/.zshrc
```

如果你用 **bash**：

```bash
nano ~/.bash_profile
```

**你会看到**：一个全是空白的编辑界面（如果文件是新建的），或者原来文件的内容，下方有一排快捷键提示。

**这就对了**。`nano` 是 Mac 自带的文本编辑器，我们用它改配置文件。

### 第 2 步：把下面这段贴进去

这段脚本**不用看懂**，照贴即可。它只做一件事：给你造四个命令——`proxy on`、`proxy off`、`proxy status`、`proxy test`。

用 `⌘ + V` 粘贴到文件里。放开头或末尾都可以，只要别插进已有内容的某一行中间：

```bash
# ==========================================================
#  Clash 代理开关
#  用法：proxy on | proxy off | proxy status | proxy test
#  端口：Clash Verge 默认 7897，不是这个就改下面这行
# ==========================================================
export CLASH_PORT="${CLASH_PORT:-7897}"

proxy() {
  local port="${2:-$CLASH_PORT}"

  case "$1" in
    on)
      # 先确认 Clash 真的在监听，避免设了变量却连不上
      if ! nc -z 127.0.0.1 "$port" 2>/dev/null; then
        echo "❌ Clash 没有在 127.0.0.1:${port} 监听"
        echo "   请先打开 Clash Verge，或检查「设置 → 混合端口」"
        return 1
      fi

      export http_proxy="http://127.0.0.1:${port}"
      export https_proxy="$http_proxy"
      export all_proxy="socks5://127.0.0.1:${port}"
      export HTTP_PROXY="$http_proxy"
      export HTTPS_PROXY="$https_proxy"
      export ALL_PROXY="$all_proxy"
      export NO_PROXY="localhost,127.0.0.1,::1"
      export no_proxy="$NO_PROXY"

      echo "✅ proxy ON  ->  ${http_proxy}"
      ;;

    off)
      unset http_proxy https_proxy all_proxy
      unset HTTP_PROXY HTTPS_PROXY ALL_PROXY
      unset NO_PROXY no_proxy
      echo "✅ proxy OFF（Terminal 直连）"
      ;;

    status)
      if [ -z "${http_proxy}${https_proxy}${all_proxy}" ]; then
        echo "当前：无代理变量（直连）"
      else
        echo "当前代理："
        env | grep -iE '^(http|https|all|no)_proxy=' | sort
      fi
      ;;

    test)
      echo "出口测试（走当前环境变量）："
      curl -sS --max-time 15 -o /dev/null \
        -w "  HTTP %{http_code}  耗时 %{time_total}s\n" \
        https://www.google.com || echo "  ❌ 失败"
      ;;

    *)
      echo "用法："
      echo "  proxy on                开启代理（默认端口 ${CLASH_PORT}）"
      echo "  proxy on 7899           开启代理（临时指定端口）"
      echo "  proxy off               关闭代理（回到直连）"
      echo "  proxy status            查看当前状态"
      echo "  proxy test              测试能不能上网"
      ;;
  esac
}

# 便捷写法（用函数而非 alias，在脚本、子 shell 里也有效）
proxy_on()  { proxy on "$@"; }
proxy_off() { proxy off; }
```

然后：

- 保存：按 `Ctrl + O`，再按**回车**
- 退出：按 `Ctrl + X`

**你会看到**：回到普通的终端界面（`%` 或 `$` 提示符又出现了）。

### 第 3 步：让它生效

```bash
source ~/.zshrc
```

（bash 用户改成 `source ~/.bash_profile`）

**你会看到**：什么都不显示。

**这就是成功**。这条命令的特点就是成功了也不说话——没有消息就是好消息。

### 第 4 步：试着打开开关

先确认 Clash 已经打开，然后在终端里：

```bash
proxy on
```

**你会看到**：

```text
✅ proxy ON  ->  http://127.0.0.1:7897
```

然后测一下能不能上网：

```bash
proxy test
```

**你会看到**：

```text
  HTTP 200  耗时 0.83s
```

只要出现 `200` 或 `301`，就说明通了。

如果看到红色的 `❌ Clash 没有在 127.0.0.1:7897 监听`，说明 Clash 没开，或者端口不是 7897。回到「开始前的 3 项检查」第 ③ 项重新确认。

如果看到 `command not found: proxy`，说明第 2 步的脚本没贴进去。回到第 2 步重新贴一次，再执行一次 `source`。

### 第 5 步：关掉它

```bash
proxy off
```

**你会看到**：

```text
✅ proxy OFF（Terminal 直连）
```

到这里就装完了，一共只做这一次。以后每天只需要 `proxy on` 和 `proxy off`。

---

## 每天怎么用：4 种情况

### 情况 1：在国内，平时用 Clash 上网

这是最常见的用法。

1. Clash 里打开「系统代理」；
2. 终端里敲 `proxy on`；
3. 干活（`brew`、`git`、`curl` 都行）；
4. 干完敲 `proxy off`。

**为什么必须敲**：Clash 的「系统代理」只管浏览器，命令行不认。不敲这一下，命令行还是直连，国内直连 GitHub 会很慢。

### 情况 2：在国内，Clash 开了 TUN

**什么都不用做**。

TUN 会在更底层接管所有程序，命令行也会自动走代理。这时候再敲 `proxy on`，反而多绕一层，会更慢。

验证方法：`proxy status` 显示"无代理变量"，但 `proxy test` 能返回 200 —— 这就是 TUN 在工作。

### 情况 3：出国了，用当地的 Wi-Fi

**落地第一件事，先敲 `proxy off`。**

很多人到了国外发现"网也上不了"，其实是因为代理变量还留在那里，指向一个已经关掉的 Clash，所有请求都被送进一个没人接的门。

稳妥的做法：

```bash
proxy off
proxy test
```

`proxy test` 返回 `200` 就正常了。同时把 Clash 里的「系统代理」和「TUN」都关掉。

### 情况 4：连上酒店 Wi-Fi，但打不开登录页

酒店、机场的 Wi-Fi 要先打开一个网页登录，而**代理会把这个登录页挡住**。

顺序是：

```text
1. 关掉 Clash 的 TUN 和系统代理
2. 终端里 proxy off
3. 连 Wi-Fi，用浏览器完成登录页
4. 登录成功后，再打开 Clash
5. 终端里 proxy on（如果你用的是系统代理）
```

---

## 出错了：先做这 3 件事

别急着改配置，先按顺序做三件事，30 秒就能知道问题在哪。

```bash
# 1. 现在有没有代理变量？
proxy status

# 2. Clash 的门开着吗？（把 7897 换成你的端口）
nc -z 127.0.0.1 7897 && echo "门开着" || echo "门关着"

# 3. 能上网吗？
curl -sS --max-time 10 -o /dev/null -w "%{http_code}\n" https://www.google.com
```

对照结果：

| 第 1 条 | 第 2 条 | 第 3 条 | 什么意思 | 怎么办 |
| --- | --- | --- | --- | --- |
| 有变量 | 门开着 | `200` | 一切正常 | 不用管 |
| 有变量 | 门关着 | 报错 | 门关着却让人走，当然走不通 | `proxy off`，或先打开 Clash |
| 无变量 | 门开着 | 打不开 | 门开着，但命令行不知道 | `proxy on` |
| 无变量 | 门关着 | 打不开 | Clash 没开，或端口不对 | 打开 Clash，核对端口 |

### 还是不行？

1. **新开一个终端窗口**再试（旧窗口里可能还留着旧的设置）；
2. 打开 Clash 的 `设置`，确认端口真的是 `7897`；
3. 重启一次 Clash；
4. 还没好，就去看[完整版的排错章节](../README.md#四出问题了验证与排错)。

---

## 新手最常犯的 6 个错

| 你可能做了 | 屏幕上会显示 | 正确做法 |
| --- | --- | --- |
| 把命令开头的 `$` 也复制进去 | `zsh: command not found: $` | 只复制 `$` 后面的部分 |
| 用 `Ctrl + V` 粘贴 | 没反应，或出现奇怪的字符 | Mac 上用 `⌘ + V` |
| 改完文件没执行 `source` | 敲 `proxy` 没反应，提示找不到命令 | 执行 `source ~/.zshrc` |
| zsh 和 bash 两组命令都执行了 | 看着没报错，但配置不生效 | 只用你那一组 |
| 在 `nano` 里敲终端命令 | 命令被当成文字写进了文件 | 先 `Ctrl + X` 退出，再敲 |
| 命令卡住不动 | 光标停着，什么也不输出 | 按 `Ctrl + C` 中断，再 `proxy off` |

> [!WARNING]
> 全程**不需要** `sudo`，也**不要**改系统文件。看到教程让你加 `sudo` 再仔细想想。

---

## 一页速查

| 我想做什么 | 敲这个 |
| --- | --- |
| 看看现在是什么状态 | `proxy status` |
| 打开代理 | `proxy on` |
| 关闭代理 | `proxy off` |
| 试试能不能上网 | `proxy test` |
| 看端口通不通 | `nc -z 127.0.0.1 7897 && echo 通` |

四句话记住全部：

```text
国内用系统代理  →  proxy on
国内用 TUN      →  不用管
出国用当地网    →  proxy off
酒店登录页      →  先 off，登录后再 on
```

---

## 常见问题

### Q1：为什么端口是 7897，不是 7890？

`7890` 是另一个客户端 Clash for Windows 的旧默认端口。Clash Verge 用的是 `7897`。以你 Clash 设置里显示的为准。

### Q2：`proxy on` 之后，浏览器会不会受影响？

不会。`proxy on` 只影响**当前这个终端窗口**，不碰系统设置。浏览器走不走代理，只取决于 Clash 里的开关。

### Q3：关掉终端窗口，代理就没了吗？

是的，而且这是好事。每个终端窗口的设置有自己的一份，关掉窗口、设置就没了，不会留在系统里。

### Q4：为什么要先检查端口？

这是必要的。如果 Clash 没开却硬设了代理，之后每条命令都会去敲一扇没人开的门，结果是卡住或者报 `Connection refused`——比不设还糟。所以脚本会先敲一下门，有人应才设。

### Q5：出国后要把这些删掉吗？

不用。这套配置默认什么都不设，不敲 `proxy on` 就不会生效。落地后敲一次 `proxy off` 就行。

### Q6：为什么 `sudo` 开头的命令不走代理？

`sudo` 出于安全会把环境变量清空，所以代理"丢"了。偶尔需要时，可以这样写：

```bash
# 末尾的 brew update 换成你真正要执行的那条命令
sudo env http_proxy=http://127.0.0.1:7897 https_proxy=http://127.0.0.1:7897 brew update
```

不建议为此去改 `/etc/sudoers`。

### Q7：我用的不是 zsh 也不是 bash，怎么办？

本文的脚本是 bash 语法，fish 之类的 shell 不能直接用，需要改写。Windows 的 PowerShell 和 CMD 更不适用，请找对应系统的教程。

### Q8：这样设置安全吗？

脚本只是在你自己的终端窗口里设置几个变量：不联网、不上传、不修改系统文件，也不会影响别的程序。它做的事情就是告诉命令"走哪个门"。

---

## 附录 A：只想临时用一次

不想改任何文件，就在当前窗口里手动来一次：

```bash
# 打开
export http_proxy=http://127.0.0.1:7897
export https_proxy=http://127.0.0.1:7897
export all_proxy=socks5://127.0.0.1:7897

# 用
brew update

# 关掉（或者直接关窗口）
unset http_proxy https_proxy all_proxy
```

缺点：关掉窗口就没了，下次还得重新敲。用超过两次，建议装上面那个开关。

---

## 附录 B：彻底删掉

1. 打开配置文件，删掉从 `# ===== Clash 代理开关 =====` 到最后一行 `proxy_off() { proxy off; }` 的内容，保存退出。
2. 在终端里执行：

```bash
unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY no_proxy
unset -f proxy proxy_on proxy_off 2>/dev/null
```

3. 新开一个窗口，敲 `proxy`，提示 `command not found` 就干净了。

---

## 免责声明

本文档仅供技术学习与交流，讲解终端里代理环境变量的开启与关闭，不提供任何代理服务、服务器或节点。请遵守你所在国家或地区的法律法规，以及所使用网络服务的条款。文中所有示例只指向本机地址 `127.0.0.1`。

---

<p align="center">
  <sub>最后更新 2026-10 · 适用 macOS 13+ · Clash Verge / Mihomo · 端口 7897</sub>
</p>
