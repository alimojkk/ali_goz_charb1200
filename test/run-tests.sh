#!/usr/bin/env bash
# ============================================================
#  ManixShop VPS — Test Suite / مجموعه تست
#  Runs start.sh in a sandbox with mocked system commands
#  and verifies every behaviour without needing Docker.
# ============================================================
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0; FAIL=0
G='\033[1;32m'; R='\033[1;31m'; Y='\033[1;33m'; C='\033[1;36m'; N='\033[0m'

t_ok()   { echo -e "  ${G}✔${N} $1"; PASS=$((PASS+1)); }
t_bad()  { echo -e "  ${R}✘${N} $1"; FAIL=$((FAIL+1)); }
check()  { if eval "$2" >/dev/null 2>&1; then t_ok "$1"; else t_bad "$1"; fi; }
grep_ok(){ if grep -q -- "$2" "$3" 2>/dev/null; then t_ok "$1"; else t_bad "$1  (missing: $2)"; fi; }
grep_no(){ if grep -q -- "$2" "$3" 2>/dev/null; then t_bad "$1  (found: $2)"; else t_ok "$1"; fi; }

section(){ echo -e "\n${C}▸ $1${N}"; }

# ------------------------------------------------------------
# Build a mock bin dir so start.sh can run on any machine
# ------------------------------------------------------------
MOCK="$(mktemp -d)"; trap 'rm -rf "$MOCK"' EXIT
mkdir -p "$MOCK/bin" "$MOCK/etc" "$MOCK/root/.ssh"

mk() { printf '#!/usr/bin/env bash\n%s\n' "$2" > "$MOCK/bin/$1"; chmod +x "$MOCK/bin/$1"; }

mk chpasswd      'cat > "$MOCKDIR/chpasswd.in"; exit 0'
mk ssh-keygen    'echo "ssh-keygen $*" >> "$MOCKDIR/calls.log"; exit 0'
mk sshd          'echo "sshd $*" >> "$MOCKDIR/calls.log"; exit 0'
mk hostname      'echo "hostname $*" >> "$MOCKDIR/calls.log"; exit 0'
mk free          'echo "              total used"; echo "Mem:           4096  512"'
mk nproc         'echo 4'
mk ttyd          'echo "TTYD_ARGS: $*" > "$MOCKDIR/ttyd.args"; exit 0'
mk chmod_noop    'exit 0'

# fake /usr/sbin/sshd path used by the script
mkdir -p "$MOCK/usr/sbin"; cp "$MOCK/bin/sshd" "$MOCK/usr/sbin/sshd"

run_start() {   # run_start <extra env assignments...>
  rm -f "$MOCK/calls.log" "$MOCK/ttyd.args" "$MOCK/chpasswd.in"
  : > "$MOCK/etc/hosts"
  env -i \
    PATH="$MOCK/bin:/usr/bin:/bin" \
    HOME="$MOCK/root" \
    MOCKDIR="$MOCK" \
    TERM=xterm \
    "$@" \
    bash -c "
      cd '$MOCK'
      # redirect absolute paths the script touches into the sandbox
      exec 2>&1
      sed -e 's#/usr/sbin/sshd#sshd#g' \
          -e 's#/etc/hostname#$MOCK/etc/hostname#g' \
          -e 's#/etc/hosts#$MOCK/etc/hosts#g' \
          -e 's#/etc/motd#$MOCK/etc/motd#g' \
          -e 's#/root/.ssh#$MOCK/root/.ssh#g' \
          -e 's#^cd /root\$#cd $MOCK/root#' \
          '$ROOT/start.sh' > '$MOCK/start.patched.sh'
      bash '$MOCK/start.patched.sh'
    " > "$MOCK/out.log" 2>&1
  return 0
}

echo -e "${C}╔════════════════════════════════════════════════╗${N}"
echo -e "${C}║   ManixShop VPS — Test Suite / تست کامل پنل   ║${N}"
echo -e "${C}╚════════════════════════════════════════════════╝${N}"

# ------------------------------------------------------------
section "1. Files present / وجود فایل‌ها"
for f in Dockerfile start.sh railway.json README.md INSTALL.md .dockerignore; do
  check "$f exists" "[ -f '$ROOT/$f' ]"
done

# ------------------------------------------------------------
section "2. Syntax / سینتکس"
check "start.sh is valid bash"   "bash -n '$ROOT/start.sh'"
check "railway.json is valid JSON" "python3 -c \"import json;json.load(open('$ROOT/railway.json'))\""
check "start.sh has shebang"     "head -1 '$ROOT/start.sh' | grep -q '^#!/'"
check "start.sh uses 'set -e'"   "grep -q '^set -e' '$ROOT/start.sh'"

# ------------------------------------------------------------
section "3. Dockerfile sanity / بررسی داکرفایل"
D="$ROOT/Dockerfile"
grep_ok "base image is ubuntu"        "FROM ubuntu" "$D"
grep_ok "installs openssh-server"     "openssh-server" "$D"
grep_ok "downloads ttyd"              "ttyd" "$D"
grep_ok "copies start.sh"             "COPY start.sh" "$D"
grep_ok "start.sh made executable"    "chmod +x /start.sh" "$D"
grep_ok "CMD runs start.sh"           'CMD \["/start.sh"\]' "$D"
grep_ok "DEBIAN_FRONTEND set"         "DEBIAN_FRONTEND=noninteractive" "$D"
grep_ok "cleans apt lists"            "rm -rf /var/lib/apt/lists" "$D"
grep_ok "creates /data"               "/data" "$D"

# ------------------------------------------------------------
section "4. Boot with defaults / اجرا با تنظیمات پیش‌فرض"
run_start
O="$MOCK/out.log"
grep_ok "banner printed"                 "ManixShop VPS" "$O"
grep_ok "persian boot message"           "در حال راه‌اندازی سرور manixshop" "$O"
grep_ok "english boot message"           "Booting manixshop server" "$O"
grep_ok "reports CPU/RAM"                "RAM" "$O"
grep_ok "auto password warning"          "auto-generated password" "$O"
grep_ok "no-public-key warning"          "no public key" "$O"
grep_ok "host keys generated"            "host keys ready" "$O"
grep_ok "sshd started"                   "SSH is up" "$O"
grep_ok "success banner"                 "manixshop server is up and running" "$O"
grep_ok "web terminal label"             "Web terminal" "$O"
grep_ok "ephemeral fs warning"           "reset on every redeploy" "$O"
grep_ok "no-domain hint shown"           "Generate Domain" "$O"

# ------------------------------------------------------------
section "5. Mocked system calls / فراخوانی‌های سیستمی"
grep_ok "root password was set"          "root:" "$MOCK/chpasswd.in"
grep_ok "ssh-keygen -A called"           "ssh-keygen -A" "$MOCK/calls.log"
grep_ok "sshd started on port 22"        "sshd -e -p 22" "$MOCK/calls.log"
grep_ok "hostname set to manixshop"      "hostname manixshop" "$MOCK/calls.log"
grep_ok "/etc/hosts updated"             "manixshop" "$MOCK/etc/hosts"
check   "MOTD written"                   "[ -s '$MOCK/etc/motd' ]"
grep_ok "MOTD mentions manixshop"        "manixshop" "$MOCK/etc/motd"

# ------------------------------------------------------------
section "6. ttyd arguments / آرگومان‌های ttyd"
A="$MOCK/ttyd.args"
grep_ok "binds 0.0.0.0"                  "interface 0.0.0.0" "$A"
grep_ok "default port 7681"              "port 7681" "$A"
grep_ok "credential flag present"        "credential" "$A"
grep_ok "writable enabled"               "writable" "$A"
grep_ok "titleFixed as client-option"    "titleFixed" "$A"
grep_ok "launches bash -l"               "bash -l" "$A"
grep_no "no bad --title-fixed flag"      "\-\-title-fixed" "$A"
# command must be the LAST argument
if [ -f "$A" ] && [[ "$(cat "$A")" == *"bash -l" ]]; then
  t_ok "shell command is last arg (not swallowed by a flag)"
else
  t_bad "shell command is last arg"
fi

# ------------------------------------------------------------
section "7. Custom env vars / متغیرهای سفارشی"
run_start ROOT_PASSWORD='Str0ng!Pass' TERMINAL_USER='admin' \
          SSH_PUBLIC_KEY='ssh-ed25519 AAAAFAKEKEY test' \
          PORT=8080 SSH_PORT=2222 RAILWAY_PUBLIC_DOMAIN='demo.up.railway.app'
O="$MOCK/out.log"
grep_ok "custom password used"           "root:Str0ng!Pass" "$MOCK/chpasswd.in"
grep_no "no auto-password warning"      "auto-generated password" "$O"
grep_ok "public key installed msg"       "public key installed" "$O"
check   "authorized_keys written"        "[ -s '$MOCK/root/.ssh/authorized_keys' ]"
grep_ok "authorized_keys content ok"     "AAAAFAKEKEY" "$MOCK/root/.ssh/authorized_keys"
grep_ok "custom SSH port honoured"       "sshd -e -p 2222" "$MOCK/calls.log"
grep_ok "PORT honoured by ttyd"          "port 8080" "$MOCK/ttyd.args"
grep_ok "https link built from domain"   "https://demo.up.railway.app" "$O"
grep_ok "custom terminal user shown"     "admin" "$O"
grep_ok "credential uses admin"          "admin:Str0ng!Pass" "$MOCK/ttyd.args"

# ------------------------------------------------------------
section "8. Separate terminal password / رمز جدای ترمینال"
run_start ROOT_PASSWORD='RootPw1' TERMINAL_PASSWORD='TermPw2' TERMINAL_USER='manixshop'
grep_ok "root keeps its own password"    "root:RootPw1" "$MOCK/chpasswd.in"
grep_ok "ttyd uses terminal password"    "manixshop:TermPw2" "$MOCK/ttyd.args"

# ------------------------------------------------------------
section "9. Domain with https:// prefix / دامنه با پیشوند"
run_start RAILWAY_PUBLIC_DOMAIN='https://x.up.railway.app' ROOT_PASSWORD=p
grep_ok "no double https://"             "https://x.up.railway.app" "$MOCK/out.log"
if grep -q "https://https://" "$MOCK/out.log"; then t_bad "double prefix bug"; else t_ok "no double prefix bug"; fi

# ------------------------------------------------------------
section "10. Docs quality / کیفیت مستندات"
grep_ok "README has install steps"       "Installation" "$ROOT/README.md"
grep_ok "INSTALL has troubleshooting"    "Troubleshooting" "$ROOT/INSTALL.md"
grep_ok "docs mention /data volume"      "/data" "$ROOT/INSTALL.md"
grep_ok "docs mention TCP Proxy"         "TCP Proxy" "$ROOT/INSTALL.md"
grep_ok "docs are bilingual"             "FA:" "$ROOT/INSTALL.md"

# ------------------------------------------------------------
section "11. Easy-install assets / فایل‌های نصب آسان"
check "install.sh exists"        "[ -f '$ROOT/install.sh' ]"
check "QUICKSTART.md exists"     "[ -f '$ROOT/QUICKSTART.md' ]"
check "install.sh valid bash"    "bash -n '$ROOT/install.sh'"
grep_ok "installer creates repo"     "gh repo create" "$ROOT/install.sh"
grep_ok "installer has manual path"  "github.com/new" "$ROOT/install.sh"
grep_ok "installer validates files"  "bash -n start.sh" "$ROOT/install.sh"
grep_ok "quickstart says no vars"    "No variables needed\|هیچ متغیری لازم نیست" "$ROOT/QUICKSTART.md"
grep_ok "quickstart mentions volume" "/data" "$ROOT/QUICKSTART.md"

# ------------------------------------------------------------
section "12. Zero-config defaults / پیش‌فرض بدون تنظیمات"
grep_ok "Dockerfile sets default PORT" "ENV PORT=7681" "$ROOT/Dockerfile"
if [ "$(grep -c '^EXPOSE' "$ROOT/Dockerfile")" = "1" ] && grep -q '^EXPOSE 7681' "$ROOT/Dockerfile"; then
  t_ok "single EXPOSE 7681 (Railway auto-detects the port)"
else
  t_bad "single EXPOSE 7681"
fi
run_start
grep_ok "friendly generated password"  "auto-generated password" "$MOCK/out.log"
if grep -qE 'root:[A-Z][a-z]+-[A-Z][a-z]+-[0-9]{4}' "$MOCK/chpasswd.in"; then
  t_ok "password is memorable Word-Word-1234 format"
else
  t_bad "password format ($(cat "$MOCK/chpasswd.in" 2>/dev/null))"
fi
grep_ok "warns when no volume"         "No volume" "$MOCK/out.log"
grep_ok "shows ONE STEP LEFT hint"     "ONE STEP LEFT" "$MOCK/out.log"

# ------------------------------------------------------------
section "13. Password persistence / ماندگاری رمز"
PWDIR="$MOCK/persist"; mkdir -p "$PWDIR"
echo "Saved-Pass-9999" > "$PWDIR/.manixshop_password"
sed "s#/data/.manixshop_password#$PWDIR/.manixshop_password#g" "$ROOT/start.sh" > "$MOCK/persist_start.sh"
ROOT_SAVE="$ROOT"; cp "$MOCK/persist_start.sh" "$MOCK/tmp_start.sh"
(
  cd "$MOCK"
  env -i PATH="$MOCK/bin:/usr/bin:/bin" HOME="$MOCK/root" MOCKDIR="$MOCK" TERM=xterm \
  bash -c "sed -e 's#/usr/sbin/sshd#sshd#g' -e 's#/etc/hostname#$MOCK/etc/hostname#g' \
    -e 's#/etc/hosts#$MOCK/etc/hosts#g' -e 's#/etc/motd#$MOCK/etc/motd#g' \
    -e 's#/root/.ssh#$MOCK/root/.ssh#g' '$MOCK/tmp_start.sh' > '$MOCK/p2.sh'; bash '$MOCK/p2.sh'" \
    > "$MOCK/out2.log" 2>&1
)
grep_ok "restores password from volume" "Saved-Pass-9999" "$MOCK/chpasswd.in"
grep_ok "logs the restore"              "restored from volume" "$MOCK/out2.log"

# ------------------------------------------------------------
echo ""
echo -e "${C}════════════════════════════════════════════════${N}"
TOTAL=$((PASS+FAIL))
if [ "$FAIL" -eq 0 ]; then
  echo -e "${G}  ✅  ALL $TOTAL TESTS PASSED / همه تست‌ها موفق${N}"
else
  echo -e "${R}  ❌  $FAIL of $TOTAL failed${N} ${G}($PASS passed)${N}"
fi
echo -e "${C}════════════════════════════════════════════════${N}"
exit $([ "$FAIL" -eq 0 ] && echo 0 || echo 1)
