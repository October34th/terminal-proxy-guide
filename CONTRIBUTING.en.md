<p align="center">
  <b>English</b> ｜ <a href="CONTRIBUTING.md">简体中文</a>
</p>

# Contributing

Thanks for taking the time to improve this guide. Three short rules below.

## 1. Reporting a problem

First, check [Section 4, "When It Breaks"](README.en.md#4-when-it-breaks-verify-and-troubleshoot). Most issues are answered there.

If that doesn't help, [open an issue](../../issues/new/choose) and include:

- macOS version: `sw_vers -productVersion`
- Shell: `echo $SHELL`
- Proxy client name and version, plus the mixed port number
- **The exact error output** (paste the text, don't just send a screenshot)
- Which steps you already tried and what happened

## 2. Improving the docs

1. Fork this repository and edit `README.en.md` (or `README.md` for the Chinese version).
2. If you touched the bash script inside, **test it before opening a PR**:

   ```bash
   # Save the edited script as test.sh, then
   bash -n test.sh     # syntax check
   zsh  -n test.sh     # compatibility check
   ```

   Ideally also run `proxy status`, `proxy on`, and `proxy off` for real.

3. In the PR, state two things: **which section you changed** and **why**.

## 3. Content principles

- **Written for beginners**: every command copy-pastes cleanly, and every step lets readers check the result themselves ("you should see...").
- **Only claim what you've verified**: if you haven't tested something, label it "untested" rather than stating it as fact.
- **No private data**: no real IPs, SSH ports, hostnames, keys, subscription URLs, or personal paths (`/Users/yourname/`).
- **Redact screenshots**: blur node names, provider names, and subscription addresses.

## 4. Code of conduct

Keep it about the work. Critique the technical claim, not the person who made it.
