#!/usr/bin/env bash
#
# terminal-proxy-guide — installer
#
# Adds a `proxy on / off / status / test` toggle to your shell config.
# Everything it does is in this file; nothing is downloaded at runtime.
#
#   bash install.sh                 # install (auto-detects your shell)
#   bash install.sh --dry-run       # show what would change, touch nothing
#   bash install.sh --port 7890     # use a different Clash port
#   bash install.sh --shell bash    # force a shell instead of auto-detect
#   bash install.sh --uninstall     # remove the toggle
#
set -euo pipefail

MARK_BEGIN='# >>> terminal-proxy-guide >>>'
MARK_END='# <<< terminal-proxy-guide <<<'
DEFAULT_PORT=7897

PORT="${CLASH_PORT:-$DEFAULT_PORT}"
PORT_EXPLICIT=0
MODE=install
DRY_RUN=0
FORCE_SHELL=""

# ---------------------------------------------------------------- i18n
if [[ "${LC_ALL:-${LANG:-}}" == zh* ]]; then ZH=1; else ZH=0; fi

say() { if [[ $ZH -eq 1 ]]; then printf '%s\n' "$1"; else printf '%s\n' "$2"; fi; }
say_raw() { printf '%s\n' "$1"; }
die() {
  if [[ $ZH -eq 1 ]]; then printf '✖ %s\n' "$1" >&2; else printf '✖ %s\n' "$2" >&2; fi
  exit 1
}

usage() {
  cat <<'EOF'
terminal-proxy-guide installer

  bash install.sh                install
  bash install.sh --dry-run      preview only
  bash install.sh --port 7890    set Clash port (default 7897)
  bash install.sh --shell bash   force zsh or bash
  bash install.sh --uninstall    remove
  bash install.sh --help         this text

Environment: CLASH_PORT overrides the default port.
EOF
}

# ---------------------------------------------------------------- args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --uninstall) MODE=uninstall ;;
    --dry-run)   DRY_RUN=1 ;;
    --port)
      [[ $# -ge 2 ]] || die "--port 后面要跟端口号" "--port needs a value"
      PORT="$2"; PORT_EXPLICIT=1; shift ;;
    --shell)
      [[ $# -ge 2 ]] || die "--shell 后面要跟 zsh 或 bash" "--shell needs zsh or bash"
      FORCE_SHELL="$2"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "不认识的参数：$1" "unknown option: $1" ;;
  esac
  shift
done

[[ "$PORT" =~ ^[0-9]+$ ]] || die "端口必须是数字：$PORT" "port must be a number: $PORT"

# ---------------------------------------------------------------- target
detect_rc() {
  case "$1" in
    zsh)  printf '%s\n' "$HOME/.zshrc" ;;
    bash) printf '%s\n' "$HOME/.bash_profile" ;;
    *)    return 1 ;;
  esac
}

SHELL_NAME="${FORCE_SHELL:-$(basename "${SHELL:-/bin/zsh}")}"
RC="$(detect_rc "$SHELL_NAME")" || \
  die "只支持 zsh 和 bash，检测到：$SHELL_NAME" "only zsh and bash are supported (got $SHELL_NAME)"

# ---------------------------------------------------------------- port hint
port_open() { nc -z 127.0.0.1 "$1" 2>/dev/null; }

if [[ $PORT_EXPLICIT -eq 0 && "$PORT" == "$DEFAULT_PORT" ]] && ! port_open "$PORT" && port_open 7890; then
  PORT=7890
fi

# ---------------------------------------------------------------- block
block() {
  cat <<'BLOCK_EOF'
# >>> terminal-proxy-guide >>>
# Clash 代理开关 / Clash proxy toggle
# 用法 / usage: proxy on | proxy off | proxy status | proxy test
# 端口 / port: 改下面这行的数字即可 / change the number below
export CLASH_PORT="${CLASH_PORT:-__PORT__}"

proxy() {
  local port="${2:-$CLASH_PORT}"

  case "$1" in
    on)
      # 先确认 Clash 真的在监听 / make sure something is listening
      if ! nc -z 127.0.0.1 "$port" 2>/dev/null; then
        echo "❌ Clash 没有在 127.0.0.1:${port} 监听 / not listening"
        echo "   请先打开 Clash Verge / start Clash, or check Settings → Mixed Port"
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
      echo "✅ proxy OFF（直连 / direct）"
      ;;

    status)
      if [ -z "${http_proxy}${https_proxy}${all_proxy}" ]; then
        echo "当前：无代理变量（直连）/ no proxy variables (direct)"
      else
        echo "当前代理 / current proxy:"
        env | grep -iE '^(http|https|all|no)_proxy=' | sort
      fi
      ;;

    test)
      echo "出口测试 / egress test:"
      curl -sS --max-time 15 -o /dev/null \
        -w "  HTTP %{http_code}  耗时/took %{time_total}s\n" \
        https://www.google.com || echo "  ❌ 失败 / failed"
      ;;

    *)
      echo "用法 / usage:"
      echo "  proxy on                开启代理 / turn on  (default port ${CLASH_PORT})"
      echo "  proxy on 7899           指定端口 / specific port"
      echo "  proxy off               关闭代理 / turn off (direct)"
      echo "  proxy status            查看状态 / show state"
      echo "  proxy test              测试联网 / test connectivity"
      ;;
  esac
}

# 便捷写法 / shortcuts
proxy_on()  { proxy on "$@"; }
proxy_off() { proxy off; }
# <<< terminal-proxy-guide <<<
BLOCK_EOF
}

BLOCK="$(block | sed "s/__PORT__/$PORT/")"

# ---------------------------------------------------------------- checks
[[ -d "$HOME" ]] || die "找不到用户目录 \$HOME" "cannot find \$HOME"

if [[ "$MODE" == install && $DRY_RUN -eq 0 && ! -w "$HOME" ]]; then
  die "没有写入 $HOME 的权限" "no write permission in $HOME"
fi

if [[ "$MODE" == install && $DRY_RUN -eq 0 && -e "$RC" && ! -w "$RC" ]]; then
  die "$RC 不可写，请先检查文件权限" "$RC is not writable; check its permissions"
fi

exists=0
[[ -f "$RC" ]] && grep -qF "$MARK_BEGIN" "$RC" && exists=1

# ---------------------------------------------------------------- plan
if [[ $DRY_RUN -eq 1 ]]; then
  say "（预览模式，不会修改任何文件）" "(dry run, nothing will be written)"
  say_raw "  shell : $SHELL_NAME"
  say_raw "  file  : $RC"
  say_raw "  port  : $PORT"
  if [[ "$MODE" == uninstall ]]; then
    if [[ $exists -eq 1 ]]; then
      say "  动作  : 删除已有的开关（先备份）" "  action: remove the existing block (backup first)"
    else
      say "  动作  : 没有找到开关，无需删除" "  action: no block found, nothing to remove"
    fi
  else
    if [[ $exists -eq 1 ]]; then
      say "  动作  : 替换已有的开关（先备份）" "  action: replace the existing block (backup first)"
    else
      say "  动作  : 写入开关（先备份）" "  action: add the block (backup first)"
    fi
  fi
  exit 0
fi

# ---------------------------------------------------------------- uninstall
if [[ "$MODE" == uninstall ]]; then
  if [[ ! -f "$RC" || $exists -eq 0 ]]; then
    say "没有找到需要删除的开关，什么都没做。" "No block found, nothing to remove."
    exit 0
  fi
  backup="$RC.bak.$(date +%Y%m%d%H%M%S)"
  cp "$RC" "$backup"
  tmp="$(mktemp)"
  awk -v b="$MARK_BEGIN" -v e="$MARK_END" '
    $0 == b { skip = 1; next }
    $0 == e { skip = 0; next }
    !skip   { print }
  ' "$RC" > "$tmp"
  cat "$tmp" > "$RC"
  rm -f "$tmp"
  say "✔ 已移除：$RC" "✔ removed from $RC"
  say "  备份 / backup: $backup" "  backup: $backup"
  say "  新开一个终端窗口即生效 / open a new terminal window" "  open a new terminal window to finish"
  exit 0
fi

# ---------------------------------------------------------------- install
backup=""
if [[ -f "$RC" ]]; then
  backup="$RC.bak.$(date +%Y%m%d%H%M%S)"
  cp "$RC" "$backup"
else
  : > "$RC"
fi

tmp="$(mktemp)"
if [[ $exists -eq 1 ]]; then
  awk -v b="$MARK_BEGIN" -v e="$MARK_END" '
    $0 == b { skip = 1; next }
    $0 == e { skip = 0; next }
    !skip   { print }
  ' "$RC" > "$tmp"
  printf '%s\n' "$BLOCK" >> "$tmp"
else
  cat "$RC" > "$tmp"
  printf '\n%s\n' "$BLOCK" >> "$tmp"
fi

# 语法自检：只检查我们插入的这一段
check="$(mktemp)"
printf '%s\n' "$BLOCK" > "$check"
bash -n "$check" || { rm -f "$check" "$tmp"; die "脚本语法检查失败，已放弃写入" "syntax check failed, aborting"; }
if command -v zsh >/dev/null 2>&1; then
  zsh -n "$check" || { rm -f "$check" "$tmp"; die "zsh 语法检查失败，已放弃写入" "zsh syntax check failed, aborting"; }
fi
rm -f "$check"

cat "$tmp" > "$RC"      # 保留原文件的权限与所有者
rm -f "$tmp"

# ---------------------------------------------------------------- done
say "✔ 装好了 / installed" "✔ installed"
say_raw "  shell : $SHELL_NAME"
say_raw "  file  : $RC"
say_raw "  port  : $PORT"
if [[ -n "$backup" ]]; then say_raw "  backup: $backup"; fi
printf '\n'
say "下一步：" "Next:"
say "  1. 新开一个终端窗口（或执行 source $RC）" "  1. open a new terminal window (or run: source $RC)"
say "  2. 打开 Clash，然后敲 proxy on" "  2. start Clash, then run: proxy on"
say "  3. 敲 proxy test 验证" "  3. verify with: proxy test"
printf '\n'
say "卸载：bash install.sh --uninstall" "Uninstall: bash install.sh --uninstall"
