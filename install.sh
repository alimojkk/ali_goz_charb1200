#!/usr/bin/env bash
# ============================================================
#  ManixShop VPS — One-command installer / نصب با یک دستور
#  Usage / استفاده:   bash install.sh
#  Creates the GitHub repo, pushes the files, opens Railway.
# ============================================================
set -euo pipefail

G='\033[1;32m'; R='\033[1;31m'; Y='\033[1;33m'; C='\033[1;36m'; B='\033[1m'; N='\033[0m'
say(){ echo -e "${C}▸${N} $1"; }
ok(){  echo -e "${G}✔${N} $1"; }
err(){ echo -e "${R}✘${N} $1"; }
warn(){ echo -e "${Y}!${N} $1"; }

clear 2>/dev/null || true
cat <<'BANNER'
==============================================
   __  __             _       ____  _
  |  \/  | __ _ _ __ (_)_  __/ ___|| |__   ___  _ __
  | |\/| |/ _` | '_ \| \ \/ /\___ \| '_ \ / _ \| '_ \
  | |  | | (_| | | | | |>  <  ___) | | | | (_) | |_) |
  |_|  |_|\__,_|_| |_|_/_/\_\|____/|_| |_|\___/| .__/
        ManixShop VPS  •  Installer / نصاب
==============================================
BANNER
echo ""

cd "$(dirname "${BASH_SOURCE[0]}")"

# ---------- 1. sanity check ----------
say "بررسی فایل‌ها / Checking files ..."
missing=0
for f in Dockerfile start.sh railway.json; do
  [ -f "$f" ] || { err "فایل $f پیدا نشد / $f missing"; missing=1; }
done
[ "$missing" -eq 0 ] || { err "نصب متوقف شد / aborted."; exit 1; }
bash -n start.sh || { err "start.sh خطای سینتکس دارد"; exit 1; }
ok "همه فایل‌ها سالم‌اند / all files OK"
echo ""

# ---------- 2. tools ----------
if ! command -v git >/dev/null 2>&1; then
  err "git نصب نیست / git not installed."
  echo "   Linux:  sudo apt install git"
  echo "   macOS:  brew install git"
  echo "   Win:    https://git-scm.com/download/win"
  exit 1
fi
ok "git موجود است"

HAS_GH=0
command -v gh >/dev/null 2>&1 && HAS_GH=1
[ "$HAS_GH" -eq 1 ] && ok "GitHub CLI موجود است (ریپو خودکار ساخته می‌شود)" \
                    || warn "GitHub CLI نصب نیست — ریپو را دستی می‌سازی"
echo ""

# ---------- 3. repo name ----------
read -rp "$(echo -e "${B}نام ریپو / Repo name${N} [manixshop-vps]: ")" REPO
REPO="${REPO:-manixshop-vps}"

# ---------- 4. git init & commit ----------
say "آماده‌سازی گیت / Preparing git ..."
[ -d .git ] || git init -q
git add -A
git -c user.email="setup@manixshop.local" -c user.name="ManixShop Setup" \
    commit -qm "ManixShop VPS on Railway" 2>/dev/null || say "تغییر جدیدی نبود / nothing new to commit"
git branch -M main 2>/dev/null || true
ok "کامیت آماده است"
echo ""

# ---------- 5. push ----------
if [ "$HAS_GH" -eq 1 ]; then
  if ! gh auth status >/dev/null 2>&1; then
    say "ورود به GitHub / Logging in ..."
    gh auth login
  fi
  USER_NAME="$(gh api user --jq .login)"
  if gh repo view "$USER_NAME/$REPO" >/dev/null 2>&1; then
    warn "ریپو از قبل وجود دارد / repo exists — pushing to it"
    git remote remove origin 2>/dev/null || true
    git remote add origin "https://github.com/$USER_NAME/$REPO.git"
    git push -u origin main --force
  else
    say "ساخت ریپوی خصوصی / Creating private repo ..."
    gh repo create "$REPO" --private --source=. --remote=origin --push
  fi
  REPO_URL="https://github.com/$USER_NAME/$REPO"
  ok "کد روی گیت‌هاب رفت / pushed: $REPO_URL"
else
  echo ""
  warn "GitHub CLI نداری. این دو کار را دستی انجام بده:"
  echo -e "  ${B}1)${N} یک ریپوی خالی بساز: ${C}https://github.com/new${N}  (نام: $REPO)"
  echo ""
  read -rp "$(echo -e "${B}نام کاربری گیت‌هاب / GitHub username: ${N}")" USER_NAME
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/$USER_NAME/$REPO.git"
  echo -e "  ${B}2)${N} الان پوش می‌کنیم ..."
  git push -u origin main
  REPO_URL="https://github.com/$USER_NAME/$REPO"
  ok "کد روی گیت‌هاب رفت / pushed: $REPO_URL"
fi

# ---------- 6. next steps ----------
echo ""
echo -e "${G}==============================================${N}"
echo -e "${G}  ✅  مرحله گیت‌هاب تمام شد / GitHub done     ${N}"
echo -e "${G}==============================================${N}"
echo ""
echo -e "${B}حالا فقط ۳ کلیک در Railway / Now just 3 clicks:${N}"
echo ""
echo -e "  ${C}1.${N} باز کن / Open:  ${B}https://railway.com/new${N}"
echo -e "     → Deploy from GitHub repo → ${B}$REPO${N}"
echo ""
echo -e "  ${C}2.${N} Settings → Networking → ${B}Generate Domain${N}"
echo ""
echo -e "  ${C}3.${N} + New → ${B}Volume${N} → Mount path: ${B}/data${N}"
echo ""
echo -e "${Y}هیچ متغیری لازم نیست!${N} رمز خودکار ساخته و در Deploy Logs چاپ می‌شود."
echo -e "${Y}No variables needed!${N} A password is generated and printed in the deploy logs."
echo ""
echo -e "برای رمز دلخواه / for a custom password: Variables → ${B}ROOT_PASSWORD${N}"
echo ""

# try to open the browser
for opener in xdg-open open start; do
  if command -v "$opener" >/dev/null 2>&1; then
    "$opener" "https://railway.com/new" >/dev/null 2>&1 && ok "مرورگر باز شد / browser opened" && break
  fi
done
echo ""
ok "تمام شد / Done. 🎉"
