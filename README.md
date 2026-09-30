# ManixShop VPS 🚀 — Ubuntu on Railway

**EN:** A full Ubuntu 24.04 container on [Railway](https://railway.com) with a browser-based terminal and SSH access.
**FA:** یک کانتینر کامل اوبونتو ۲۴.۰۴ روی ریلوی، با ترمینال تحت وب و دسترسی SSH.

---

## ✨ Features / امکانات

| EN | FA |
|---|---|
| Ubuntu 24.04 LTS + common tools (git, curl, python3, vim, htop, tmux…) | اوبونتو ۲۴.۰۴ + ابزارهای پرکاربرد |
| Web terminal (ttyd) behind one HTTPS link | ترمینال تحت وب با یک لینک HTTPS |
| SSH access via Railway TCP Proxy | دسترسی SSH از طریق TCP Proxy ریلوی |
| Bilingual **manixshop** deploy logs | لاگ‌های دو زبانه با برند **manixshop** |
| Password + optional public-key login | ورود با رمز یا کلید عمومی |

---

## 📁 Files / فایل‌ها

| File | EN | FA |
|---|---|---|
| `Dockerfile` | Ubuntu image + sshd + ttyd | ایمیج اوبونتو + sshd + ttyd |
| `start.sh` | Boot script, logs, services | اسکریپت راه‌اندازی، لاگ‌ها و سرویس‌ها |
| `railway.json` | Railway build config | تنظیمات بیلد ریلوی |
| `.dockerignore` | Build exclusions | فایل‌های نادیده‌گرفته‌شده |

---

## ⚡ Fastest install / سریع‌ترین نصب

```bash
bash install.sh
```
**EN:** Creates the GitHub repo, pushes everything, opens Railway. Then: Generate Domain + a Volume on `/data`. **No variables required** — a password is generated and shown in the deploy logs.
**FA:** ریپو را می‌سازد، کد را پوش می‌کند و ریلوی را باز می‌کند. بعدش فقط Generate Domain و یک Volume روی `/data`. **هیچ متغیری لازم نیست** — رمز خودکار ساخته و در لاگ نشان داده می‌شود.

👉 See `QUICKSTART.md` (3 min) or `INSTALL.md` (full guide).
👉 راهنمای سریع: `QUICKSTART.md` • راهنمای کامل: `INSTALL.md`

---

## 🛠 Installation (manual / دستی) / نصب

### 1. Push to GitHub / آپلود روی گیت‌هاب
**EN:** Unzip the archive, then push the folder to a new GitHub repo.
**FA:** فایل زیپ را باز کن و پوشه را روی یک ریپوی جدید گیت‌هاب پوش کن.

```bash
cd manixshop-vps
git init
git add .
git commit -m "ManixShop VPS on Railway"
git branch -M main
git remote add origin https://github.com/USERNAME/REPO.git
git push -u origin main
```

### 2. Deploy on Railway / دیپلوی روی ریلوی
**EN:** Railway → **New Project** → **Deploy from GitHub repo** → pick your repo. It auto-detects the Dockerfile.
**FA:** در ریلوی → **New Project** → **Deploy from GitHub repo** → ریپو را انتخاب کن. Dockerfile خودکار شناسایی می‌شود.

### 3. Variables / متغیرها
Railway → **Variables**:

| Variable | EN | FA | Required |
|---|---|---|---|
| `ROOT_PASSWORD` | root & terminal password | رمز root و ترمینال | recommended / پیشنهادی |
| `TERMINAL_USER` | web terminal username (default `manixshop`) | یوزرنیم ترمینال وب (پیش‌فرض `manixshop`) | optional |
| `TERMINAL_PASSWORD` | web terminal password | رمز ترمینال وب | optional |
| `SSH_PUBLIC_KEY` | contents of `id_rsa.pub` | محتوای `id_rsa.pub` | optional |
| `TZ` | timezone (default `Asia/Tehran`) | منطقه زمانی | optional |

> **EN:** If `ROOT_PASSWORD` is empty, a random one is generated and printed in the logs.
> **FA:** اگر `ROOT_PASSWORD` را نگذاری، یک رمز تصادفی ساخته و در لاگ چاپ می‌شود.

### 4. Generate a domain / ساخت دامنه
**EN:** Settings → **Networking** → **Generate Domain** (target port `7681` or `$PORT`).
**FA:** در Settings → **Networking** → **Generate Domain** (پورت `7681` یا `PORT`).

### 5. Read the logs / خواندن لاگ‌ها
Deploy Logs:

```
==============================================
   __  __             _       ____  _
  |  \/  | __ _ _ __ (_)_  __/ ___|| |__   ___  _ __
  | |\/| |/ _` | '_ \| \ \/ /\___ \| '_ \ / _ \| '_ \
  | |  | | (_| | | | | |>  <  ___) | | | | (_) | |_) |
  |_|  |_|\__,_|_| |_|_/_/\_\|____/|_| |_|\___/| .__/
        ManixShop VPS  •  Ubuntu on Railway
==============================================

[ manixshop ] در حال راه‌اندازی سرور manixshop ... / Booting manixshop server ...
[ manixshop ] سیستم‌عامل / OS: Ubuntu 24.04 LTS
[ manixshop ✔ ] رمز root تنظیم شد / root password set.
[ manixshop ✔ ] SSH روی پورت 22 فعال است / SSH is up.

  سرور manixshop با موفقیت بالا آمد ✅
  manixshop server is up and running ✅

🖥  ترمینال تحت وب / Web terminal: https://manixshop.up.railway.app
👤  یوزرنیم / Username: manixshop
🔑  رمز / Password: ********
```

### 6. Open the terminal / باز کردن ترمینال
**EN:** Click the link, enter username + password, and you get a full bash shell in your browser.
**FA:** روی لینک بزن، یوزرنیم و رمز را وارد کن، یک شل کامل bash در مرورگر باز می‌شود.

---

## 🔌 SSH (optional / اختیاری)

**EN:** Settings → Networking → **TCP Proxy** → internal port `22`. Railway gives you a host and a public port:
**FA:** در Settings → Networking → **TCP Proxy** پورت داخلی `22` را بزن. ریلوی یک هاست و پورت عمومی می‌دهد:

```bash
ssh root@containers-us-west-x.railway.app -p 12345
```

---

## 💾 Persistent data / داده‌های ماندگار

**EN:** The container filesystem is ephemeral — everything is wiped on redeploy. Create a **Volume** in Railway and mount it on `/data`, then store your files there.
**FA:** فایل‌سیستم کانتینر موقتی است و با هر ری‌دیپلوی پاک می‌شود. در ریلوی یک **Volume** بساز و روی `/data` مانت کن و فایل‌های مهم را همان‌جا نگه دار.

---

## ⚠️ Limitations / محدودیت‌ها

- **EN:** This is a container, not a real VPS — `systemd`, Docker-in-Docker, and kernel modules don't work.
  **FA:** این یک کانتینر است نه VPS واقعی — `systemd`، داکر داخلی و ماژول کرنل کار نمی‌کند.
- **EN:** The web terminal link is public; always set a strong `ROOT_PASSWORD`.
  **FA:** لینک ترمینال عمومی است؛ حتماً `ROOT_PASSWORD` قوی بگذار.
- **EN:** Railway bills by usage and forbids mining / mass proxying — your account can be banned.
  **FA:** ریلوی بر اساس مصرف صورتحساب می‌دهد و ماینینگ یا پروکسی انبوه ممنوع است — اکانت بن می‌شود.

---

## 🧰 Troubleshooting / رفع اشکال

| Problem / مشکل | Fix / راه‌حل |
|---|---|
| No link in logs / لینکی در لاگ نیست | Generate Domain را بزن / generate a domain |
| 502 error | Target port باید `7681` یا `$PORT` باشد |
| Login rejected / رمز قبول نمی‌شود | `ROOT_PASSWORD` را در Variables ست کن و Redeploy بزن |
| SSH timeout | TCP Proxy روی پورت `22` فعال نیست |

---

**ManixShop** — made for Railway ☁️
