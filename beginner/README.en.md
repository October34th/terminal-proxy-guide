<p align="center">
  <b>English</b> ｜ <a href="README.md">简体中文</a>
</p>

<h1 align="center">Terminal Proxy Toggle · Beginner Edition</h1>

<p align="center">
  No networking knowledge needed. Follow along and in 10 minutes <code>brew</code>, <code>git</code>, and <code>curl</code> will work in Terminal.
</p>

> Want the theory, more scenarios, and deeper troubleshooting? See the [full guide](../README.en.md). Just need commands? There's a [cheat sheet](#cheat-sheet) at the end.

---

## Who this is for

- You've never opened the Terminal app before.
- Someone sent you a wall of commands and it made your head hurt.
- You just want to know "which lines do I type?"

No programming background required. You only need to **copy**, **paste**, and **press Enter**.

---

## In plain words: what is a proxy?

Here's an analogy.

You want to mail a letter abroad, but you can't send it yourself. So you use a relay office: you hand the letter over, they send it out for you, and the reply comes back through them too.

Clash is that relay office, running on your Mac. It opens a "door" — door number **7897**.

Here's the catch: browsers and most everyday apps are happy to use the relay. They actively look for the door. But `brew`, `git`, and `curl` don't look. They just push their requests straight out and fail.

Your job is to tell them, explicitly: "use door 7897."

Technically that means setting an environment variable. This guide turns that into a switch you can flip on and off.

```text
your command  →  Clash (door 7897)  →  the internet
```

---

## Five words you need

| Word | One-line meaning | Analogy |
| --- | --- | --- |
| Terminal | A window where you type to control your Mac | Texting your computer |
| Command | One line you type in Terminal | An instruction |
| Port | A door number a program listens on | A room number in a building |
| Environment variable | A note stuck on the window that programs read | "Use door 7897" |
| Config file | A small text file that stores settings | A notebook the window reads at startup |

Two things you'll see everywhere:

- **`~`** means "your home folder" — the house icon in Finder. So `~/.zshrc` is "the file `.zshrc` in your home folder."
- **`127.0.0.1`** means "this computer itself." It's not an internet address; it never leaves your Mac.

Two more words for later:

- **System proxy**: a Clash switch. Browsers obey it; command-line tools **don't**.
- **TUN**: another Clash switch. **Everything** obeys it, including the command line.

---

## Three checks before you start

Two minutes here saves you an hour later.

### 1. Open Terminal

Press `⌘ + Space`, type `Terminal`, and press Enter.

You'll get a window with a `%` or `$` sign. That sign means "ready for typing."

> [!TIP]
> Paste in Terminal with **`⌘ + V`**, not `Ctrl + V`. Getting this wrong can cost you ten minutes of confusion.

### 2. Find out which shell you use

Type this line and press Enter:

```bash
echo $SHELL
```

Read the output:

| You see | You use | Your config file |
| --- | --- | --- |
| `/bin/zsh` | zsh (most Macs) | `~/.zshrc` |
| `/bin/bash` | bash | `~/.bash_profile` |
| something else (e.g. fish) | rare | not covered here, see [Q7](#q7-im-not-on-zsh-or-bash-what-now) |

**Write down your config file.** You'll need it in Steps 1 and 3.

### 3. Find your Clash port

Open Clash Verge, click `Settings`, find **Mixed Port**.

The default is **`7897`**. Check whether yours matches, and note the number.

> [!IMPORTANT]
> Get this wrong and every step after it fails. It's worth a second look.

---

## Install the switch: 5 steps

Every step follows the same pattern: **what to do → what to type → what you should see**.

### Step 1: Open your config file

Pick the pair that matches the shell you found in check 2.

If you use **zsh**:

```bash
nano ~/.zshrc
```

If you use **bash**:

```bash
nano ~/.bash_profile
```

**You should see:** a blank editing screen (if the file is new), or its existing contents, with a row of shortcuts at the bottom.

That's correct. `nano` is a text editor built into macOS, and you'll use it to edit the config file.

### Step 2: Paste this in

You don't need to understand this block; just paste it. It does one thing: it gives you four commands — `proxy on`, `proxy off`, `proxy status`, and `proxy test`.

Paste it into the file with `⌘ + V`. Top or bottom both work; just don't drop it in the middle of an existing line:

```bash
# ==========================================================
#  Clash proxy toggle
#  Usage: proxy on | proxy off | proxy status | proxy test
#  Port:  Clash Verge defaults to 7897; change the line below if yours differs
# ==========================================================
export CLASH_PORT="${CLASH_PORT:-7897}"

proxy() {
  local port="${2:-$CLASH_PORT}"

  case "$1" in
    on)
      # Make sure Clash is actually listening before setting anything
      if ! nc -z 127.0.0.1 "$port" 2>/dev/null; then
        echo "❌ Nothing is listening on 127.0.0.1:${port}"
        echo "   Start Clash Verge, or check Settings → Mixed Port"
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
      echo "✅ proxy OFF (Terminal is direct again)"
      ;;

    status)
      if [ -z "${http_proxy}${https_proxy}${all_proxy}" ]; then
        echo "Current: no proxy variables (direct)"
      else
        echo "Current proxy:"
        env | grep -iE '^(http|https|all|no)_proxy=' | sort
      fi
      ;;

    test)
      echo "Egress test (using current environment variables):"
      curl -sS --max-time 15 -o /dev/null \
        -w "  HTTP %{http_code}  took %{time_total}s\n" \
        https://www.google.com || echo "  ❌ failed"
      ;;

    *)
      echo "Usage:"
      echo "  proxy on                turn the proxy on (default port ${CLASH_PORT})"
      echo "  proxy on 7899           turn it on with a specific port"
      echo "  proxy off               turn it off (back to direct)"
      echo "  proxy status            show the current state"
      echo "  proxy test              test whether you can reach the internet"
      ;;
  esac
}

# Shortcuts (functions rather than aliases, so they also work in scripts and subshells)
proxy_on()  { proxy on "$@"; }
proxy_off() { proxy off; }
```

Then:

- Save: press `Ctrl + O`, then **Enter**
- Exit: press `Ctrl + X`

**You should see:** you're back at the normal Terminal prompt.

### Step 3: Load it

```bash
source ~/.zshrc
```

(bash users: `source ~/.bash_profile`)

**You should see:** nothing at all.

That's success. This command stays silent when it works — no news is good news.

### Step 4: Turn the switch on

Make sure Clash is running, then:

```bash
proxy on
```

**You should see:**

```text
✅ proxy ON  ->  http://127.0.0.1:7897
```

Now test whether traffic actually flows:

```bash
proxy test
```

**You should see:**

```text
  HTTP 200  took 0.83s
```

`200` or `301` both mean it works.

If you instead see `❌ Nothing is listening on 127.0.0.1:7897`, Clash isn't running, or your port isn't 7897. Go back to check 3.

If you see `command not found: proxy`, the paste in Step 2 didn't make it. Go back to Step 2, paste again, and run `source` once more.

### Step 5: Turn it off

```bash
proxy off
```

**You should see:**

```text
✅ proxy OFF (Terminal is direct again)
```

That's the whole setup, and you only do it once. From now on it's just `proxy on` and `proxy off`.

---

## Day to day: 4 situations

### Situation 1: In China, using Clash normally

The most common case.

1. Turn on **System Proxy** in Clash.
2. Type `proxy on` in Terminal.
3. Do your work with `brew`, `git`, `curl`.
4. Type `proxy off` when you're done.

**Why you must type it:** Clash's system proxy only covers browsers. The command line ignores it. Without `proxy on`, your commands go direct, and direct access to GitHub from mainland China is slow.

### Situation 2: In China, using TUN mode

**Do nothing.**

TUN takes over below the app layer, so the command line follows automatically. Running `proxy on` on top of it adds a pointless extra hop and makes things slower.

How to confirm: `proxy status` says no variables, yet `proxy test` returns `200`. That's TUN at work.

### Situation 3: Abroad, on local Wi-Fi

**First thing after you land: run `proxy off`.**

A lot of "the internet doesn't work abroad either" cases happen because the proxy variables are still there, pointing at a Clash you already quit. Every request goes to a door nobody is answering.

The safe sequence:

```bash
proxy off
proxy test
```

If `proxy test` returns `200`, you're fine. Also turn off System Proxy and TUN inside Clash.

### Situation 4: Hotel Wi-Fi connected, but the login page won't load

Hotel and airport Wi-Fi usually make you open a web page and sign in first, and **your proxy can block that page**.

The order matters:

```text
1. Turn off TUN and System Proxy in Clash
2. In Terminal: proxy off
3. Join the Wi-Fi and finish the login page in a browser
4. Once you're online, turn Clash back on
5. In Terminal: proxy on (if you're using system proxy)
```

---

## Something broke: do these 3 things first

Don't start editing configs. Run these three checks in order; they tell you where the problem is in 30 seconds.

```bash
# 1. Are proxy variables set right now?
proxy status

# 2. Is the Clash door open? (use your own port)
nc -z 127.0.0.1 7897 && echo "door open" || echo "door closed"

# 3. Can you reach the internet?
curl -sS --max-time 10 -o /dev/null -w "%{http_code}\n" https://www.google.com
```

Reading the results:

| Check 1 | Check 2 | Check 3 | What it means | What to do |
| --- | --- | --- | --- | --- |
| variables set | door open | `200` | All good | Nothing |
| variables set | door closed | error | You're pointing at a closed door | `proxy off`, or start Clash |
| none | door open | fails | Door is open but Terminal doesn't know | `proxy on` |
| none | door closed | fails | Clash is off, or the port is wrong | Start Clash, check the port |

### Still stuck?

1. **Open a new Terminal window** and try again (the old one may hold stale settings).
2. Open Clash → `Settings` and confirm the port really is `7897`.
3. Restart Clash.
4. Still broken? Read the troubleshooting section of the [full guide](../README.en.md#4-when-it-breaks-verify-and-troubleshoot).

---

## Six mistakes beginners make

| What you might do | What the screen says | Do this instead |
| --- | --- | --- |
| Copy the leading `$` too | `zsh: command not found: $` | Copy only what follows the `$` |
| Paste with `Ctrl + V` | Nothing, or odd characters | Use `⌘ + V` on a Mac |
| Forget `source` after editing | `proxy: command not found` | Run `source ~/.zshrc` |
| Run both the zsh and bash sets | No error, but nothing takes effect | Use only your own set |
| Type Terminal commands while in `nano` | The text gets written into the file | Press `Ctrl + X` first |
| A command hangs forever | Cursor sits there, no output | Press `Ctrl + C`, then `proxy off` |

> [!WARNING]
> You never need `sudo`, and you should not modify system files. If a tutorial asks you to add `sudo`, pause and think.

---

## Cheat sheet

| I want to | Type this |
| --- | --- |
| See the current state | `proxy status` |
| Turn the proxy on | `proxy on` |
| Turn the proxy off | `proxy off` |
| Test connectivity | `proxy test` |
| Check whether the port is open | `nc -z 127.0.0.1 7897 && echo open` |

Four lines to remember everything:

```text
In China, system proxy  →  proxy on
In China, TUN mode      →  do nothing
Abroad on local Wi-Fi   →  proxy off
Hotel login page        →  off first, on after you sign in
```

---

## FAQ

### Q1: Why 7897 and not 7890?

`7890` is the old default of a different client, Clash for Windows. Clash Verge uses `7897`. Use whatever your Clash settings show.

### Q2: Does `proxy on` affect my browser?

No. It only changes **the current Terminal window**. It never touches system settings. Whether your browser uses a proxy depends only on the switches inside Clash.

### Q3: If I close the Terminal window, is the proxy gone?

Yes, and that's a good thing. Each window keeps its own settings; closing it discards them, and nothing is left behind on the system.

### Q4: Why check the port first?

It's necessary. If Clash is off and you set the proxy anyway, every command tries to knock on a door nobody answers, so it hangs or fails with `Connection refused`. That's worse than no proxy at all. So the script knocks once and only sets variables if someone answers.

### Q5: Should I delete all this when I travel abroad?

No. The setup sets nothing by default; it does nothing until you type `proxy on`. Run `proxy off` once after you land and you're back to a direct connection.

### Q6: Why do commands with `sudo` ignore the proxy?

`sudo` clears the environment for security, so the settings disappear. For the rare case where you need it:

```bash
# replace "brew update" with the command you actually need
sudo env http_proxy=http://127.0.0.1:7897 https_proxy=http://127.0.0.1:7897 brew update
```

Don't edit `/etc/sudoers` for this.

### Q7: I'm not on zsh or bash. What now?

The script is bash syntax, so shells like fish can't use it as-is and would need a rewrite. Windows PowerShell and CMD are a different world entirely; look for a guide for your system.

### Q8: Is this safe?

The script only sets a few variables inside your own Terminal window. It doesn't go online, doesn't upload anything, doesn't change system files, and doesn't affect other programs. All it does is tell your commands which door to use.

---

## Appendix A: Use it just once

If you don't want to edit any file, do it by hand in the current window:

```bash
# on
export http_proxy=http://127.0.0.1:7897
export https_proxy=http://127.0.0.1:7897
export all_proxy=socks5://127.0.0.1:7897

# work
brew update

# off (or just close the window)
unset http_proxy https_proxy all_proxy
```

The catch: it disappears when you close the window, and you'll retype it next time. If you'll do this more than twice, install the switch above.

---

## Appendix B: Remove it completely

1. Open your config file, delete everything from `# ===== Clash proxy toggle =====` through the last line `proxy_off() { proxy off; }`, and save.
2. In Terminal, run:

```bash
unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY no_proxy
unset -f proxy proxy_on proxy_off 2>/dev/null
```

3. Open a new window and type `proxy`. `command not found` means it's clean.

---

## Disclaimer

This guide is for technical learning and discussion only. It explains how to turn proxy environment variables on and off in the terminal, and it does not provide any proxy service, server, or node. Follow the laws and regulations that apply to you, along with the terms of service of any network you use. Every example here targets the local address `127.0.0.1` only.

---

<p align="center">
  <sub>Last updated October 2026 · macOS 13+ · Clash Verge / Mihomo · port 7897</sub>
</p>
