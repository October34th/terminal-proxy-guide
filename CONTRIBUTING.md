<p align="center">
  <b>简体中文</b> ｜ <a href="CONTRIBUTING.en.md">English</a>
</p>

# 参与贡献

感谢你愿意帮忙改进这份教程。下面四件事，先说清楚。

## 一、报告问题

先查这两处，大多数问题已经写过答案：

- [故障排查](README.md#四出问题了验证与排错)：按你看到的现象查表
- [常见问题](README.md#七常见问题)：端口、`sudo`、TUN 之类的疑问

还是没解决，就[开一个 Issue](../../issues/new/choose)，请附上下表内容：

| 项目 | 怎么拿到 |
| --- | --- |
| macOS 版本 | `sw_vers -productVersion` |
| 你用的 shell | `echo $SHELL` |
| 客户端与版本 | 例如 Clash Verge Rev 1.7.7 |
| 混合端口 | Clash 设置里显示的那个数字 |
| 报错原文 | 直接贴文字，不要只发截图 |
| 已尝试的步骤 | 做过什么、结果如何 |

## 二、修改文档

教程分成几层，按你要改的内容找对文件：

| 文件 | 放什么 |
| --- | --- |
| `README.md` / `README.en.md` | 完整版：原理、六个场景、排错 |
| `beginner/README.md` / `beginner/README.en.md` | 新手版：逐步骤，含"你会看到" |
| `quickstart.md` / `quickstart.en.md` | 三步搞定 |
| `install.sh` | 一行安装脚本 |

1. Fork 仓库，在对应文件里改。**中英文要同步改**，不要只改一边。
2. 动过 bash 脚本（`install.sh` 或文档里的代码块），先自测：

   ```bash
   bash -n install.sh          # 语法检查
   zsh  -n install.sh          # 兼容性检查
   bash install.sh --dry-run   # 空跑一遍，不改任何文件
   ```

   最好再实际执行一次 `proxy status`、`proxy on`、`proxy off`，确认行为没有变化。

3. 提 PR 时说明两件事：**改了哪一节**、**为什么改**。

## 三、写作原则

- **写给新手**：命令能直接复制，每一步都写清"你应该看到什么"。
- **只写验证过的**：没实测的内容标注「未验证」，不要写成结论。
- **不留隐私**：不出现真实 IP、SSH 端口、主机名、密钥、订阅链接、个人路径。
- **截图打码**：节点名、机场名、订阅地址一律模糊处理。

## 四、沟通方式

就事论事。讨论技术，不评价提问的人。
