#!/bin/bash
# ------------------------------------------------------------
#  ManixShop VPS on Railway — startup script / اسکریپت راه‌اندازی
# ------------------------------------------------------------
set -e

GREEN='\033[1;32m'; CYAN='\033[1;36m'; YELLOW='\033[1;33m'; NC='\033[0m'

say()  { echo -e "${CYAN}[ manixshop ]${NC} $1"; }
ok()   { echo -e "${GREEN}[ manixshop ✔ ]${NC} $1"; }
warn() { echo -e "${YELLOW}[ manixshop ! ]${NC} $1"; }

echo ""
echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   __  __             _       ____  _                 ${NC}"
echo -e "${GREEN}  |  \/  | __ _ _ __ (_)_  __/ ___|| |__   ___  _ __  ${NC}"
echo -e "${GREEN}  | |\/| |/ _\` | '_ \| \ \/ /\___ \| '_ \ / _ \| '_ \ ${NC}"
echo -e "${GREEN}  | |  | | (_| | | | | |>  <  ___) | | | | (_) | |_) |${NC}"
echo -e "${GREEN}  |_|  |_|\__,_|_| |_|_/_/\_\|____/|_| |_|\___/| .__/ ${NC}"
echo -e "${GREEN}                                               |_|    ${NC}"
echo -e "${GREEN}        ManixShop VPS  •  Ubuntu on Railway            ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""

say "در حال راه‌اندازی سرور manixshop ... / Booting manixshop server ..."
say "سیستم‌عامل / OS: $(. /etc/os-release && echo "$PRETTY_NAME")"
say "معماری / Arch: $(uname -m)  |  هسته / CPU: $(nproc)"
say "حافظه / RAM: $(free -m | awk '/Mem:/{print $2}') MB"
say "زمان / Time: $(date '+%Y-%m-%d %H:%M:%S')  (${TZ:-UTC})"
echo ""

# ---------- hostname ----------
hostname manixshop 2>/dev/null || true
echo "manixshop" > /etc/hostname 2>/dev/null || true
grep -q manixshop /etc/hosts 2>/dev/null || echo "127.0.0.1 manixshop" >> /etc/hosts

# ---------- ports / پورت‌ها ----------
WEB_PORT="${PORT:-7681}"
SSH_PORT="${SSH_PORT:-22}"
say "پورت وب‌ترمینال / Web port: ${WEB_PORT} | پورت SSH: ${SSH_PORT}"

# ---------- password / رمز عبور ----------
say "تنظیم رمز کاربر root / Setting root password ..."
PW_FILE="/data/.manixshop_password"
if [ -n "${ROOT_PASSWORD:-}" ]; then
  ok "رمز از متغیر محیطی خوانده شد / password taken from ROOT_PASSWORD."
elif [ -f "$PW_FILE" ]; then
  ROOT_PASSWORD="$(cat "$PW_FILE")"
  ok "رمز قبلی از Volume بازیابی شد / password restored from volume."
else
  W1=(manix shop cyber ubuntu railway nova delta orbit pixel turbo)
  W2=(tiger falcon dragon panda comet rocket shadow thunder viper eagle)
  ROOT_PASSWORD="${W1[$((RANDOM%10))]^}-${W2[$((RANDOM%10))]^}-$((RANDOM%9000+1000))"
  warn "رمزی تنظیم نشده بود؛ رمز خودکار ساخته شد / auto-generated password."
  mkdir -p /data 2>/dev/null && echo "$ROOT_PASSWORD" > "$PW_FILE" 2>/dev/null \
    && chmod 600 "$PW_FILE" 2>/dev/null \
    && say "رمز در /data ذخیره شد تا بعد از ری‌دیپلوی عوض نشود." \
    || warn "Volume وصل نیست؛ رمز بعد از هر ری‌دیپلوی عوض می‌شود."
fi
echo "root:${ROOT_PASSWORD}" | chpasswd
ok "رمز root تنظیم شد / root password set."

# ---------- ssh key / کلید عمومی ----------
if [ -n "$SSH_PUBLIC_KEY" ]; then
  mkdir -p /root/.ssh && echo "$SSH_PUBLIC_KEY" > /root/.ssh/authorized_keys
  chmod 600 /root/.ssh/authorized_keys
  ok "کلید عمومی نصب شد / public key installed."
else
  warn "کلید عمومی ثبت نشده / no public key — password login only."
fi

say "ساخت کلیدهای میزبان / Generating host keys ..."
ssh-keygen -A >/dev/null 2>&1
ok "کلیدهای میزبان آماده شد / host keys ready."

say "اجرای سرویس SSH / Starting sshd ..."
/usr/sbin/sshd -e -p "${SSH_PORT}" || warn "sshd اجرا نشد / sshd failed to start."
sleep 1
ok "SSH روی پورت ${SSH_PORT} فعال است / SSH is up."

# ---------- MOTD ----------
cat > /etc/motd <<'EOF'

  ManixShop VPS  •  Ubuntu on Railway
  ------------------------------------
  خوش آمدی! این سرور manixshop است.
  Welcome! You are on the manixshop server.
  داده‌های مهم را در /data نگه دار / Keep persistent data in /data
EOF

# ---------- public link / لینک عمومی ----------
DOMAIN="${RAILWAY_PUBLIC_DOMAIN:-${RAILWAY_STATIC_URL:-}}"
if [ -n "$DOMAIN" ]; then
  LINK="https://${DOMAIN#https://}"
else
  LINK="(دامنه ساخته نشده / no domain yet — Railway → Settings → Networking → Generate Domain)"
fi

TTYD_USER="${TERMINAL_USER:-manixshop}"
TTYD_PASS="${TERMINAL_PASSWORD:-$ROOT_PASSWORD}"

echo ""
echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}  سرور manixshop با موفقیت بالا آمد ✅         ${NC}"
echo -e "${GREEN}  manixshop server is up and running ✅        ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${CYAN}🖥  ترمینال تحت وب / Web terminal:${NC} ${LINK}"
echo -e "${CYAN}👤  یوزرنیم / Username:${NC} ${TTYD_USER}"
echo -e "${CYAN}🔑  رمز / Password:${NC} ${TTYD_PASS}"
echo ""

if [ -z "$DOMAIN" ]; then
  echo -e "${YELLOW}━━━ یک قدم مانده / ONE STEP LEFT ━━━${NC}"
  echo -e "${YELLOW}  Settings → Networking → Generate Domain${NC}"
  echo -e "${YELLOW}  سپس لینک در همین لاگ ظاهر می‌شود / then the link appears here.${NC}"
  echo ""
fi

if [ -d /data ] && mountpoint -q /data 2>/dev/null; then
  ok "Volume روی /data وصل است / persistent volume mounted."
else
  echo -e "${YELLOW}⚠️  Volume وصل نیست: با هر ری‌دیپلوی همه‌چیز پاک می‌شود.${NC}"
  echo -e "${YELLOW}⚠️  No volume: data (and the password) reset on every redeploy.${NC}"
  echo -e "${YELLOW}    Railway → + New → Volume → Mount path: /data${NC}"
fi

# credentials file for convenience
{ echo "ManixShop VPS"
  echo "url:      ${LINK}"
  echo "user:     ${TTYD_USER}"
  echo "password: ${TTYD_PASS}"
} > /data/manixshop-credentials.txt 2>/dev/null || true

echo ""
echo -e "${CYAN}🔌  SSH (اختیاری): Settings → Networking → TCP Proxy → 22${NC}"
echo -e "${CYAN}    ssh root@<tcp-proxy-host> -p <public-port>${NC}"
echo ""
say "لاگ‌های وب‌ترمینال manixshop / manixshop web terminal logs:"
echo ""

cd /root
exec ttyd \
  --port "${WEB_PORT}" \
  --interface 0.0.0.0 \
  --credential "${TTYD_USER}:${TTYD_PASS}" \
  --writable \
  --client-option titleFixed="ManixShop VPS" \
  --client-option fontSize=15 \
  --client-option 'theme={"background":"#0b0e14","foreground":"#d7dae0"}' \
  bash -l
