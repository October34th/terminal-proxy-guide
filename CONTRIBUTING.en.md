<p align="center">
  <b>English</b> ｜ <a href="CONTRIBUTING.md">简体中文</a>
</p>

# Contributing

Thanks for helping improve this guide. Four things worth knowing up front.

## 1. Reporting a problem

Check these two places first; they answer most questions:

- [Troubleshooting](README.en.md#4-when-it-breaks-verify-and-troubleshoot): look up the symptom you see
- [FAQ](README.en.md#7-faq): ports, `sudo`, TUN, and similar

Still stuck? [Open an issue](../../issues/new/choose) and include:

| What | How to get it |
| --- | --- |
| macOS version | `sw_vers -productVersion` |
| Your shell | `echo $SHELL` |
| Client and version | e.g. Clash Verge Rev 1.7.7 |
| Mixed port | the number shown in Clash settings |
| The exact error | paste the text, not just a screenshot |
| What you already tried | which steps, and what happened |

## 2. Editing the docs

The guide has several layers. Pick the right file:

| File | What it holds |
| --- | --- |
| `README.md` / `README.en.md` | Full guide: concepts, six scenarios, troubleshooting |
| `beginner/README.md` / `beginner/README.en.md` | Beginner edition: step by step, with "you should see" |
| `quickstart.md` / `quickstart.en.md` | Three-step setup |
| `install.sh` | The one-line installer |

1. Fork the repo and edit the matching file. **Keep both languages in sync**; don't change only one side.
2. If you touched a bash script (`install.sh` or a code block), test it first:

   ```bash
   bash -n install.sh          # syntax check
   zsh  -n install.sh          # compatibility check
   bash install.sh --dry-run   # dry run, changes nothing
   ```

   Then run `proxy status`, `proxy on`, and `proxy off` once to confirm nothing broke.

3. In the PR, say two things: **which section you changed** and **why**.

## 3. Writing principles

- **Write for beginners**: commands paste cleanly, and every step says what you should see.
- **Only claim what you tested**: mark anything unverified as "untested" instead of stating it as fact.
- **No private data**: no real IPs, SSH ports, hostnames, keys, subscription URLs, or personal paths.
- **Redact screenshots**: blur node names, provider names, and subscription addresses.

## 4. Tone

Keep it about the work. Discuss the technical claim, not the person who made it.
