# 🚀 دليل النشر الكامل على Hostinger VPS
## للمبتدئين — خطوة بخطوة من الصفر حتى التشغيل

---

> ✅ **يدعم Ubuntu 22.04 و Ubuntu 24.04** — الدليل ده شغال على الإتنين.
> الفرق الوحيد بينهم بيتم التعامل معاه تلقائياً في سكريبتات التثبيت.

---

## 📌 المتطلبات قبل البداية

| المطلوب | التفاصيل |
|---------|---------|
| VPS من Hostinger | خطة KVM 1 على الأقل (1 CPU / 4GB RAM / 50GB SSD) |
| نظام التشغيل | **Ubuntu 22.04** أو **Ubuntu 24.04** LTS (كلاهما مدعوم) |
| جهاز كمبيوتر | Windows أو Mac أو Linux |
| ملفات المشروع | محفوظة على جهازك أو على GitHub |

---

## الجزء الأول: إعداد VPS على Hostinger

### الخطوة 1 — شراء وإنشاء VPS

1. ادخل على [hostinger.com](https://hostinger.com)
2. اختار **VPS Hosting** من القائمة
3. اختار خطة **KVM 1** أو أعلى
4. في صفحة الإعداد:
   - **Operating System**: اختار `Ubuntu 22.04`
   - **Password**: اكتب كلمة مرور قوية للـ root (**احفظها**)
   - **Server Location**: اختار الأقرب لعملائك
5. اضغط **Create Server** وانتظر 2-5 دقائق

### الخطوة 2 — الحصول على IP السيرفر

1. ادخل على **hPanel** (لوحة تحكم Hostinger)
2. اضغط على **VPS** من القائمة
3. ستجد **IP Address** — انسخه، هتحتاجه كتير

---

## الجزء الثاني: الاتصال بالسيرفر

### على Windows

1. حمّل برنامج **MobaXterm** من: [mobaxterm.mobatek.net](https://mobaxterm.mobatek.net) (مجاناً)
2. افتح MobaXterm
3. اضغط **Session** → **SSH**
4. في **Remote host**: حط IP السيرفر
5. في **Username**: اكتب `root`
6. اضغط **OK**
7. هيطلب منك كلمة المرور — اكتبها (مش هتشوفها وهي بتتكتب، ده طبيعي)

### على Mac أو Linux

افتح Terminal واكتب:

```bash
ssh root@YOUR_SERVER_IP
```

استبدل `YOUR_SERVER_IP` بـ IP السيرفر الحقيقي، مثال:
```bash
ssh root@185.123.45.67
```

ثم اكتب كلمة المرور.

---

## الجزء الثالث: إعداد السيرفر لأول مرة

### الخطوة 3 — تحديث النظام

بعد الدخول للسيرفر، اكتب هذه الأوامر **واحدة واحدة** واضغط Enter بعد كل سطر:

```bash
apt update
```

انتظر حتى ينتهي، ثم:

```bash
apt upgrade -y
```

انتظر حتى ينتهي (قد يستغرق دقيقتين).

### الخطوة 4 — تثبيت Docker

```bash
curl -fsSL https://get.docker.com | bash
```

انتظر حتى ينتهي التثبيت، ثم تحقق:

```bash
docker --version
```

يجب أن ترى شيئاً مثل: `Docker version 24.x.x`

### الخطوة 5 — تثبيت Docker Compose

```bash
apt install docker-compose-plugin -y
```

تحقق:

```bash
docker compose version
```

يجب أن ترى: `Docker Compose version v2.x.x`

### الخطوة 6 — تثبيت أدوات مساعدة

```bash
apt install -y git nano unzip wget curl
```

---

## الجزء الرابع: رفع ملفات المشروع

### الطريقة A — من GitHub (الأسهل لو عندك repo)

```bash
cd /opt
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git instabot
cd instabot/Instagram-Lead-Bot
```

استبدل `YOUR_USERNAME` و `YOUR_REPO_NAME` ببياناتك الحقيقية.

---

### الطريقة B — رفع الملفات من جهازك مباشرة

**على Windows (باستخدام MobaXterm):**

1. في MobaXterm، في الشريط الجانبي الأيسر، ستجد **File Browser**
2. انتقل في السيرفر إلى `/opt`
3. اضغط بالزر الأيمن → **Upload files**
4. اختار مجلد `Instagram-Lead-Bot` من جهازك
5. انتظر رفع الملفات

ثم في السيرفر:
```bash
mkdir -p /opt/instabot
mv /opt/Instagram-Lead-Bot /opt/instabot/
cd /opt/instabot/Instagram-Lead-Bot
```

**على Mac/Linux (من Terminal):**

```bash
scp -r /path/to/Instagram-Lead-Bot root@YOUR_SERVER_IP:/opt/instabot/
ssh root@YOUR_SERVER_IP
cd /opt/instabot/Instagram-Lead-Bot
```

استبدل `/path/to/Instagram-Lead-Bot` بالمسار الحقيقي للمجلد على جهازك.

---

## الجزء الخامس: إعداد ملف البيئة (.env)

### الخطوة 7 — إنشاء ملف .env

تأكد إنك داخل مجلد المشروع:

```bash
cd /opt/instabot/Instagram-Lead-Bot
```

انسخ ملف القالب:

```bash
cp .env.example .env
```

افتح الملف للتعديل:

```bash
nano .env
```

ستظهر لك شاشة تعديل. غيّر هذه الأسطر:

```
IG_USERNAME=اسم_حساب_انستجرام
IG_PASSWORD=كلمة_مرور_انستجرام
PORT=8081
DEBUG_MODE=false
```

للحفظ والخروج من nano:
- اضغط `Ctrl + X`
- اضغط `Y`
- اضغط `Enter`

---

## الجزء السادس: التشغيل

### الخطوة 8 — إنشاء مجلدات البيانات

```bash
mkdir -p data/sessions data/screenshots data/logs data/db
```

### الخطوة 9 — إعطاء صلاحية التشغيل لـ manage.sh

```bash
chmod +x manage.sh
```

### الخطوة 10 — بناء الصورة وتشغيل البوت 🚀

```bash
./manage.sh start
```

هذا الأمر سيقوم بـ:
1. بناء صورة Docker (قد يستغرق 5-10 دقائق في أول مرة)
2. تثبيت Chromium داخل الصورة
3. تشغيل الخدمة على البورت 8081

انتظر حتى تظهر رسالة:
```
✔ الخدمة تعمل!
▶ الرابط: http://185.xxx.xxx.xxx:8081
```

---

## الجزء السابع: الوصول للتطبيق

### الخطوة 11 — فتح التطبيق في المتصفح

افتح أي متصفح على جهازك وادخل:

```
http://YOUR_SERVER_IP:8081
```

مثال:
```
http://185.123.45.67:8081
```

يجب أن تظهر لك شاشة تسجيل الدخول للبوت.

### بيانات الدخول الافتراضية للأدمن:

```
Username: admin
Password: admin1234
```

> ⚠️ **غيّر كلمة مرور الأدمن فوراً** من لوحة الإدارة بعد أول دخول!

---

## الجزء الثامن: فتح البورت في Hostinger

إذا لم يفتح الرابط، تحتاج فتح البورت:

1. ادخل **hPanel** على Hostinger
2. اختار VPS الخاص بك
3. اضغط **Firewall** أو **Security**
4. أضف Rule جديد:
   - **Port**: `8081`
   - **Protocol**: `TCP`
   - **Action**: `Allow`
5. احفظ

---

## أوامر مهمة للإدارة اليومية

```bash
# حالة الخدمة — هل شغالة؟
./manage.sh status

# متابعة السجل المباشر (اضغط Ctrl+C للخروج)
./manage.sh logs

# إعادة التشغيل بعد أي تعديل
./manage.sh restart

# إيقاف كل شيء
./manage.sh stop

# تشغيل main.py يدوياً (البوت الأتوماتيك)
./manage.sh run-bot

# تنظيف المساحة
./manage.sh clean

# نسخ احتياطي للبيانات
./manage.sh backup
```

---

## استكشاف الأخطاء الشائعة

### مشكلة: الرابط لا يفتح في المتصفح

```bash
# تحقق أن الخدمة شغالة
./manage.sh status

# تحقق أن البورت مفتوح
curl http://localhost:8081
```

إذا ظهر رد = الخدمة شغالة والمشكلة في الـ Firewall → ارجع لـ hPanel وافتح البورت.

---

### مشكلة: خطأ أثناء بناء الصورة

```bash
# شوف تفاصيل الخطأ
docker compose build --no-cache 2>&1 | tail -30

# تأكد من مساحة القرص
df -h
```

---

### مشكلة: الخدمة تتوقف وحدها

```bash
# شوف سجل الأخطاء
./manage.sh logs

# أو شوف ملف الأخطاء مباشرة
tail -50 data/logs/server_errors.log
```

---

### مشكلة: نسيت كلمة مرور الأدمن

```bash
# ادخل للكونتينر مباشرة
docker exec -it instabot_web python3 -c "
import sys; sys.path.insert(0, '/app/instagram_automation')
import site_database as sdb
sdb.update_password('admin', 'NewPassword123')
print('تم تغيير كلمة المرور')
"
```

---

## نصائح مهمة للأمان

1. **لا ترفع ملف `.env` على GitHub أبداً** — فيه كلمات المرور
2. **غيّر كلمة مرور admin** فور الدخول الأول
3. **احتفظ بنسخ احتياطية** بانتظام: `./manage.sh backup`
4. **راجع ملف الأخطاء** أسبوعياً: `tail -20 data/logs/server_errors.log`

---

## هيكل الملفات على السيرفر بعد التثبيت

```
/opt/instabot/Instagram-Lead-Bot/
├── .env                    ← بياناتك السرية (لا ترفعه)
├── docker-compose.yml
├── Dockerfile
├── manage.sh
└── data/                   ← بياناتك (محفوظة دائماً)
    ├── sessions/            ← جلسات Instagram
    ├── screenshots/         ← صور الأخطاء
    ├── logs/                ← ملفات السجل
    └── db/                  ← قواعد البيانات
```

---

*تم إنشاء هذا الدليل خصيصاً لـ VPS من Hostinger بنظام Ubuntu 22.04*
