<p align="center">
  <b>English</b> ｜ <a href="quickstart.md">简体中文</a>
</p>

<h1 align="center">Three steps to get Terminal online</h1>

<p align="center">
  If you don't care how it works and just want it working, this page is enough.
</p>

---

## Step 1: Open Terminal

Press `⌘ + Space`, type `Terminal`, and press Enter.

## Step 2: Copy this line, paste it, press Enter

```bash
curl -fsSL https://raw.githubusercontent.com/October34th/terminal-proxy-guide/main/install.sh | bash
```

The script does three things: backs up your config file → writes the toggle → checks the syntax. It downloads nothing else, needs no `sudo`, and never touches system files.

## Step 3: Open a new Terminal window and run these two lines

```bash
proxy on
proxy test
```

If you see `HTTP 200` or `HTTP 301`, you're done.

> Why a new window? The config only takes effect in a **newly opened** window. If you'd rather not, run `source ~/.zshrc` in the current one.

---

## From now on, only two commands

| Command | What it does |
| --- | --- |
| `proxy on` | Sends Terminal traffic through Clash |
| `proxy off` | Goes back to a direct connection |

---

## If something looks wrong

| What you see | What it means | What to do |
| --- | --- | --- |
| `command not found: proxy` | The config isn't loaded yet | Open a new Terminal window, or run `source ~/.zshrc` |
| `❌ Clash ... not listening` | Clash isn't running, or the port isn't 7897 | Start Clash, check Settings → Mixed Port |
| `curl: (22) ... 404` | The repo path or branch name is wrong | Check `October34th` and `main` |

Still stuck? See the troubleshooting section in the [beginner edition](beginner/README.en.md).

---

## Verify it's safe before you run it

Three things you can check yourself:

```bash
# 1. See what it would do, without changing anything
curl -fsSL https://raw.githubusercontent.com/October34th/terminal-proxy-guide/main/install.sh | bash -s -- --dry-run

# 2. Download the source and read it
curl -fsSL https://raw.githubusercontent.com/October34th/terminal-proxy-guide/main/install.sh -o /tmp/tpg.sh
less /tmp/tpg.sh

# 3. Changed your mind? Uninstall (it backs up first)
bash /tmp/tpg.sh --uninstall
```

The source lives in this repo as [`install.sh`](install.sh). All of the logic is in that one file; nothing is fetched at runtime.

---

## Prefer not to use a script?

The script only saves you the manual steps. The end result is identical.

- **Manual five steps** → [Beginner edition · install](beginner/README.en.md#install-the-switch-5-steps)
- **Theory and more scenarios** → [Full guide](README.en.md)

---

## Disclaimer

This guide is for technical learning and discussion only. It does not provide any proxy service, server, or node. Follow the laws and regulations that apply to you, along with the terms of service of any network you use. Every example here targets the local address `127.0.0.1` only.

---

<p align="center">
  <sub>Last updated October 2026 · macOS 13+ · Clash Verge / Mihomo · port 7897</sub>
</p>
