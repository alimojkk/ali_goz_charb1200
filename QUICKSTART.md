# ⚡ QUICKSTART — نصب ۳ دقیقه‌ای / 3-Minute Setup

**EN:** No variables to configure. No passwords to invent. Three clicks.
**FA:** هیچ متغیری لازم نیست. هیچ رمزی نباید بسازی. سه کلیک.

---

## 🅰️ روش خودکار / Automatic (recommended)

**EN:** Extract the zip, open a terminal in the folder and run:
**FA:** زیپ را باز کن، در همان پوشه ترمینال باز کن و بزن:

```bash
bash install.sh
```

**EN:** It checks the files, creates a private GitHub repo, pushes everything, and opens Railway for you.
**FA:** فایل‌ها را چک می‌کند، ریپوی خصوصی می‌سازد، کد را پوش می‌کند و ریلوی را برایت باز می‌کند.

---

## 🅱️ روش دستی / Manual (no terminal)

### 1. Railway
**EN:** https://railway.com/new → **Deploy from GitHub repo** → pick the repo. Wait 3–5 min.
**FA:** به https://railway.com/new برو → **Deploy from GitHub repo** → ریپو را انتخاب کن. ۳ تا ۵ دقیقه صبر کن.

### 2. Domain / دامنه
**EN:** Settings → Networking → **Generate Domain** (port `7681` is auto-detected).
**FA:** Settings → Networking → **Generate Domain** (پورت `7681` خودکار شناسایی می‌شود).

### 3. Volume (mهم / important)
**EN:** + New → **Volume** → mount path `/data`. Without it, everything resets on redeploy.
**FA:** + New → **Volume** → مسیر `/data`. بدون این، همه‌چیز با ری‌دیپلوی پاک می‌شود.

---

## 🔑 Login / ورود

**EN:** Open **Deploy Logs**. Read the box:
**FA:** تب **Deploy Logs** را باز کن. این کادر را بخوان:

```
🖥  ترمینال تحت وب / Web terminal: https://your-app.up.railway.app
👤  یوزرنیم / Username: manixshop
🔑  رمز / Password: Manix-Falcon-4821
```

**EN:** Click the link, type the username + password → you're in a full Ubuntu shell.
**FA:** روی لینک بزن، یوزرنیم و رمز را وارد کن → داخل یک شل کامل اوبونتو هستی.

> 💡 **EN:** With a volume mounted, the password **stays the same** across redeploys and is also saved to `/data/manixshop-credentials.txt`.
> 💡 **FA:** اگر Volume وصل باشد، رمز بعد از ری‌دیپلوی **ثابت می‌ماند** و در `/data/manixshop-credentials.txt` هم ذخیره می‌شود.

---

## 🎛 Optional variables / متغیرهای اختیاری

**EN:** Only if you want to override the defaults — Railway → Variables:
**FA:** فقط اگر خواستی پیش‌فرض‌ها را عوض کنی — Variables:

| Variable | Default | EN / FA |
|---|---|---|
| `ROOT_PASSWORD` | auto | your own password / رمز دلخواه |
| `TERMINAL_USER` | `manixshop` | web login username / یوزرنیم |
| `SSH_PUBLIC_KEY` | — | key-based SSH / ورود با کلید |
| `TZ` | `Asia/Tehran` | timezone / منطقه زمانی |

---

## 🆘 If something breaks / اگر مشکلی بود

| Problem | Fix |
|---|---|
| No link in logs | Generate Domain را بزن |
| 502 Bad Gateway | ۶۰ ثانیه صبر کن و رفرش کن |
| Password rejected | رمز را از آخرین Deploy Log بردار |
| Files vanish | Volume روی `/data` وصل کن |

**EN:** Full guide → `INSTALL.md` **FA:** راهنمای کامل → `INSTALL.md`
