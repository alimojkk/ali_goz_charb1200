# 📘 ManixShop VPS — Complete Installation Guide / راهنمای کامل نصب

**EN:** Step-by-step guide to turn a GitHub repo into an Ubuntu server with a web terminal on Railway.
**FA:** راهنمای قدم‌به‌قدم برای تبدیل یک ریپوی گیت‌هاب به سرور اوبونتو با ترمینال تحت وب روی ریلوی.

⏱ **Time / زمان:** ~10 min  •  💳 **Cost / هزینه:** Railway usage-based (~$5 trial credit)

---

## 📑 Table of Contents / فهرست

1. [Prerequisites / پیش‌نیازها](#1)
2. [Get the files / دریافت فایل‌ها](#2)
3. [Create GitHub repo / ساخت ریپو](#3)
4. [Upload the files / آپلود فایل‌ها](#4)
5. [Create Railway project / ساخت پروژه ریلوی](#5)
6. [Environment variables / متغیرهای محیطی](#6)
7. [Generate domain / ساخت دامنه](#7)
8. [Check the logs / بررسی لاگ](#8)
9. [Open the web terminal / باز کردن ترمینال](#9)
10. [Enable SSH / فعال‌سازی SSH](#10)
11. [Persistent storage / فضای ماندگار](#11)
12. [Daily usage / استفاده روزمره](#12)
13. [Updating / به‌روزرسانی](#13)
14. [Troubleshooting / رفع اشکال](#14)
15. [Security / امنیت](#15)
16. [FAQ / سوالات متداول](#16)

---

<a id="1"></a>
## 1️⃣ Prerequisites / پیش‌نیازها

**EN:** You need:
- A **GitHub** account — https://github.com
- A **Railway** account — https://railway.com (sign up with GitHub, easiest)
- A browser. Git on your PC is optional (you can upload files through the web UI).

**FA:** نیاز داری به:
- حساب **گیت‌هاب** — https://github.com
- حساب **ریلوی** — https://railway.com (با گیت‌هاب ثبت‌نام کن، ساده‌تر است)
- یک مرورگر. نصب Git روی کامپیوتر اختیاری است (می‌توانی از طریق وب آپلود کنی).

---

<a id="2"></a>
## 2️⃣ Get the files / دریافت فایل‌ها

**EN:** Download `manixshop-vps.zip` and extract it. You should see:
**FA:** فایل `manixshop-vps.zip` را دانلود و استخراج کن. باید این‌ها را ببینی:

```
manixshop-vps/
├── Dockerfile        ← Ubuntu + sshd + ttyd image
├── start.sh          ← boot script (Persian/English logs)
├── railway.json      ← Railway build settings
├── .dockerignore
├── README.md
└── INSTALL.md        ← this file
```

> ⚠️ **EN:** Keep the file names exactly as they are. **FA:** اسم فایل‌ها را عوض نکن.

---

<a id="3"></a>
## 3️⃣ Create a GitHub repository / ساخت ریپوی گیت‌هاب

**EN:**
1. Go to https://github.com/new
2. **Repository name:** `manixshop-vps`
3. Choose **Private** (recommended — the repo has no secrets, but keep it private anyway)
4. Do **NOT** check "Add a README file"
5. Click **Create repository**

**FA:**
1. برو به https://github.com/new
2. **نام ریپو:** `manixshop-vps`
3. گزینه **Private** را انتخاب کن (پیشنهادی)
4. تیک "Add a README file" را **نزن**
5. روی **Create repository** بزن

---

<a id="4"></a>
## 4️⃣ Upload the files / آپلود فایل‌ها

### Option A — Web upload (no Git needed) / روش آسان بدون گیت

**EN:**
1. On the empty repo page click **uploading an existing file**
2. Drag **the files inside** `manixshop-vps/` (not the folder itself)
3. Commit message: `initial commit` → **Commit changes**

**FA:**
1. در صفحه ریپوی خالی روی **uploading an existing file** کلیک کن
2. **فایل‌های داخل** پوشه `manixshop-vps/` را بکش و رها کن (نه خود پوشه)
3. پیام کامیت: `initial commit` → **Commit changes**

### Option B — Git CLI / روش گیت

```bash
cd manixshop-vps
git init
git add .
git commit -m "ManixShop VPS on Railway"
git branch -M main
git remote add origin https://github.com/USERNAME/manixshop-vps.git
git push -u origin main
```

> **EN:** Replace `USERNAME` with your GitHub username.
> **FA:** به‌جای `USERNAME` نام کاربری گیت‌هاب خودت را بگذار.

✅ **EN:** The repo root must contain `Dockerfile` directly. **FA:** فایل `Dockerfile` باید مستقیم در ریشه ریپو باشد.

---

<a id="5"></a>
## 5️⃣ Create the Railway project / ساخت پروژه ریلوی

**EN:**
1. Go to https://railway.com/new
2. Click **Deploy from GitHub repo**
3. If asked, click **Configure GitHub App** and give Railway access to `manixshop-vps`
4. Select the repo → Railway starts building automatically
5. Building the image takes **3–6 minutes** the first time

**FA:**
1. برو به https://railway.com/new
2. روی **Deploy from GitHub repo** بزن
3. اگر خواست، **Configure GitHub App** را بزن و به ریلوی دسترسی ریپو را بده
4. ریپو را انتخاب کن → ریلوی خودکار شروع به بیلد می‌کند
5. بیلد اولیه **۳ تا ۶ دقیقه** طول می‌کشد

> **EN:** Railway auto-detects the `Dockerfile` — no extra config needed.
> **FA:** ریلوی خودش `Dockerfile` را تشخیص می‌دهد؛ تنظیم اضافه لازم نیست.

---

<a id="6"></a>
## 6️⃣ Environment variables / متغیرهای محیطی

**EN:** Open your service → **Variables** tab → **New Variable**.
**FA:** سرویس را باز کن → تب **Variables** → **New Variable**.

| Variable / متغیر | Example / نمونه | EN | FA |
|---|---|---|---|
| `ROOT_PASSWORD` | `MyStr0ng!Pass2026` | root + terminal password | رمز root و ترمینال |
| `TERMINAL_USER` | `manixshop` | web terminal username | یوزرنیم ترمینال وب |
| `TERMINAL_PASSWORD` | `AnotherPass!` | separate terminal password | رمز جدای ترمینال |
| `SSH_PUBLIC_KEY` | `ssh-rsa AAAA...` | key-based SSH login | ورود SSH با کلید |
| `TZ` | `Asia/Tehran` | timezone | منطقه زمانی |
| `SSH_PORT` | `22` | internal SSH port | پورت داخلی SSH |

**EN:** Only `ROOT_PASSWORD` really matters. If you leave it empty a random password is generated and printed in the deploy logs.
**FA:** فقط `ROOT_PASSWORD` مهم است. اگر خالی بگذاری یک رمز تصادفی ساخته و در لاگ دیپلوی چاپ می‌شود.

**Getting your SSH public key / گرفتن کلید عمومی:**
```bash
# Linux / macOS
cat ~/.ssh/id_rsa.pub
# Windows PowerShell
type $env:USERPROFILE\.ssh\id_rsa.pub
# Don't have one? / نداری؟
ssh-keygen -t ed25519 -C "manixshop"
```

> 🔄 **EN:** After adding variables, Railway redeploys automatically. **FA:** بعد از افزودن متغیرها، ریلوی خودکار ری‌دیپلوی می‌کند.

---

<a id="7"></a>
## 7️⃣ Generate a public domain / ساخت دامنه عمومی

**EN:**
1. Service → **Settings** → scroll to **Networking**
2. Click **Generate Domain**
3. If it asks for a port, enter **`7681`**
4. You get something like `manixshop-vps-production.up.railway.app`

**FA:**
1. سرویس → **Settings** → بخش **Networking**
2. روی **Generate Domain** بزن
3. اگر پورت خواست، **`7681`** را وارد کن
4. آدرسی مثل `manixshop-vps-production.up.railway.app` می‌گیری

> ❗ **EN:** Without this step there is **no link** to the terminal.
> **FA:** بدون این مرحله **هیچ لینکی** به ترمینال وجود ندارد.

---

<a id="8"></a>
## 8️⃣ Check the deploy logs / بررسی لاگ دیپلوی

**EN:** Service → **Deployments** → click the latest → **Deploy Logs**. You should see:
**FA:** سرویس → **Deployments** → آخرین مورد → **Deploy Logs**. باید این را ببینی:

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
[ manixshop ] معماری / Arch: x86_64  |  هسته / CPU: 8
[ manixshop ] حافظه / RAM: 8192 MB
[ manixshop ] پورت وب‌ترمینال / Web port: 7681 | پورت SSH: 22
[ manixshop ✔ ] رمز root تنظیم شد / root password set.
[ manixshop ✔ ] کلیدهای میزبان آماده شد / host keys ready.
[ manixshop ✔ ] SSH روی پورت 22 فعال است / SSH is up.

  سرور manixshop با موفقیت بالا آمد ✅
  manixshop server is up and running ✅

🖥  ترمینال تحت وب / Web terminal: https://manixshop-vps-production.up.railway.app
👤  یوزرنیم / Username: manixshop
🔑  رمز / Password: MyStr0ng!Pass2026
🔌  SSH: ssh root@<tcp-proxy-host> -p <public-port>
```

---

<a id="9"></a>
## 9️⃣ Open the web terminal / باز کردن ترمینال

**EN:**
1. Click the link from the logs (or the domain in Settings)
2. Browser asks for username + password → enter `TERMINAL_USER` and `ROOT_PASSWORD`
3. A dark-themed bash shell opens: `root@manixshop:~#`

**FA:**
1. روی لینک داخل لاگ کلیک کن
2. مرورگر یوزرنیم و رمز می‌خواهد → `TERMINAL_USER` و `ROOT_PASSWORD` را وارد کن
3. یک شل bash با تم تیره باز می‌شود: `root@manixshop:~#`

**Test it / تستش کن:**
```bash
neofetch || (apt update && apt install -y neofetch && neofetch)
df -h
free -m
```

---

<a id="10"></a>
## 🔟 Enable SSH / فعال‌سازی SSH

**EN:**
1. Settings → **Networking** → **TCP Proxy**
2. Internal port: **`22`** → Add
3. Railway shows e.g. `containers-us-west-42.railway.app:31337`

```bash
ssh root@containers-us-west-42.railway.app -p 31337
```

**FA:**
1. Settings → **Networking** → **TCP Proxy**
2. پورت داخلی: **`22`** → Add
3. ریلوی چیزی مثل `containers-us-west-42.railway.app:31337` می‌دهد، بعد دستور بالا را بزن

**File transfer / انتقال فایل:**
```bash
scp -P 31337 myfile.zip root@containers-us-west-42.railway.app:/data/
```

---

<a id="11"></a>
## 1️⃣1️⃣ Persistent storage / فضای ماندگار

> 🚨 **EN:** Without a Volume, **everything you install or create is deleted on every redeploy.**
> **FA:** بدون Volume، **هر چیزی نصب یا ساخته باشی با هر ری‌دیپلوی پاک می‌شود.**

**EN:**
1. Project canvas → **+ New** → **Volume**
2. Attach it to your service
3. Mount path: **`/data`**
4. Redeploy. Now keep all important files in `/data`.

**FA:**
1. صفحه پروژه → **+ New** → **Volume**
2. به سرویست وصلش کن
3. مسیر مانت: **`/data`**
4. ری‌دیپلوی کن. از این به بعد فایل‌های مهم را در `/data` نگه دار.

```bash
cd /data          # کار اینجا انجام بده / work here
mkdir -p /data/projects
```

---

<a id="12"></a>
## 1️⃣2️⃣ Daily usage / استفاده روزمره

```bash
# update / بروزرسانی
apt update && apt upgrade -y

# install packages / نصب پکیج
apt install -y nodejs npm ffmpeg

# keep a process alive after closing the tab / ادامه اجرا بعد بستن تب
tmux new -s work
#   detach: Ctrl+B سپس D
tmux attach -t work

# resources / منابع
htop
df -h /data
```

---

<a id="13"></a>
## 1️⃣3️⃣ Updating / به‌روزرسانی

**EN:** Edit a file on GitHub → commit → Railway rebuilds and redeploys automatically. You can also press **Redeploy** in the Deployments tab.
**FA:** فایل را در گیت‌هاب ویرایش و کامیت کن → ریلوی خودکار دوباره بیلد و دیپلوی می‌کند. یا در تب Deployments دکمه **Redeploy** را بزن.

---

<a id="14"></a>
## 1️⃣4️⃣ Troubleshooting / رفع اشکال

| Symptom / نشانه | Cause / علت | Fix / راه‌حل |
|---|---|---|
| No link in logs | domain not generated | Settings → Networking → Generate Domain |
| `502 Bad Gateway` | wrong target port | set domain target port to `7681` |
| `Application failed to respond` | still booting | wait ~60s, refresh / کمی صبر کن |
| Login popup keeps returning | wrong credentials | check `TERMINAL_USER` / `ROOT_PASSWORD`, redeploy |
| Build fails at `ttyd` download | GitHub rate limit | Redeploy again / دوباره ری‌دیپلوی کن |
| SSH `connection refused` | TCP Proxy off | add TCP Proxy on port `22` |
| Files disappear | no Volume | mount a Volume on `/data` |
| Service sleeps / stops | out of credit | check Railway usage / اعتبار را چک کن |
| `systemctl` not working | it's a container | use direct commands, not systemd |

---

<a id="15"></a>
## 1️⃣5️⃣ Security / امنیت

**EN:**
- Use a **strong** `ROOT_PASSWORD` (16+ chars) — the terminal URL is public.
- Prefer `SSH_PUBLIC_KEY` over passwords for SSH.
- Never commit passwords into the repo; keep them in Railway Variables only.
- Don't share the terminal link — anyone with URL + password owns the box.
- Rotate the password: change the variable → redeploy.

**FA:**
- رمز `ROOT_PASSWORD` **قوی** (۱۶ کاراکتر به بالا) بگذار — آدرس ترمینال عمومی است.
- برای SSH ترجیحاً از `SSH_PUBLIC_KEY` استفاده کن.
- هرگز رمز را داخل ریپو کامیت نکن؛ فقط در Variables ریلوی بگذار.
- لینک ترمینال را با کسی به اشتراک نگذار.
- برای تعویض رمز: متغیر را عوض کن و ری‌دیپلوی بزن.

---

<a id="16"></a>
## 1️⃣6️⃣ FAQ / سوالات متداول

**Is it a real VPS? / آیا VPS واقعی است؟**
EN: No — it's a Docker container. No `systemd`, no Docker-in-Docker, no kernel modules, no custom iptables.
FA: نه — یک کانتینر داکر است. `systemd`، داکر داخلی، ماژول کرنل و iptables سفارشی کار نمی‌کند.

**Is it free? / رایگان است؟**
EN: Railway gives trial credit, then bills by RAM/CPU/hours. A 24/7 idle container costs a few dollars a month.
FA: ریلوی اعتبار آزمایشی می‌دهد و بعد بر اساس رم/سی‌پی‌یو/ساعت حساب می‌کند. یک کانتینر ۲۴ساعته چند دلار در ماه هزینه دارد.

**Can I host a website on it? / می‌توانم سایت میزبانی کنم؟**
EN: The public domain is used by the terminal. For a site, add a second Railway service or change the domain's target port to your app's port.
FA: دامنه عمومی برای ترمینال است. برای سایت، یک سرویس دوم بساز یا پورت هدف دامنه را به پورت اپت تغییر بده.

**Can I use a VPN/proxy on it? / برای وی‌پی‌ان استفاده کنم؟**
EN: Mass proxying and mining violate Railway's ToS and will get your account banned.
FA: پروکسی انبوه و ماینینگ خلاف قوانین ریلوی است و باعث بن شدن اکانت می‌شود.

**How do I delete it? / چطور حذفش کنم؟**
EN: Railway → Project Settings → **Delete Project**.
FA: ریلوی → Project Settings → **Delete Project**.

---

## ✅ Checklist / چک‌لیست نهایی

- [ ] GitHub repo created with `Dockerfile` in root / ریپو ساخته شد
- [ ] Railway project deployed from repo / پروژه دیپلوی شد
- [ ] `ROOT_PASSWORD` set / رمز ست شد
- [ ] Domain generated (port `7681`) / دامنه ساخته شد
- [ ] Logs show "manixshop server is up" / لاگ موفق است
- [ ] Web terminal opens / ترمینال باز می‌شود
- [ ] Volume mounted on `/data` / ولوم وصل شد
- [ ] TCP Proxy on `22` (optional) / SSH فعال شد

---

**ManixShop VPS** — Ubuntu on Railway ☁️
