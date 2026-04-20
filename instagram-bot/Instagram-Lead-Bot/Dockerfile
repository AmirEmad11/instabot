# ══════════════════════════════════════════════════════════════════
#  Instagram Lead Bot — Dockerfile
#  Base: Python 3.11 slim | Playwright Chromium headless
# ══════════════════════════════════════════════════════════════════

FROM python:3.11-slim

LABEL maintainer="Instagram Lead Bot"
LABEL description="SaaS Instagram Automation Panel — Streamlit + Playwright"

# ══════════════════════════════════════════════════════════════════
#  متغيرات البيئة الثابتة (القيم الحساسة في .env خارج الصورة)
# ══════════════════════════════════════════════════════════════════
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PLAYWRIGHT_BROWSERS_PATH=/home/botuser/.playwright \
    STREAMLIT_SERVER_HEADLESS=true \
    STREAMLIT_BROWSER_GATHER_USAGE_STATS=false \
    DEBIAN_FRONTEND=noninteractive

# ══════════════════════════════════════════════════════════════════
#  system dependencies لـ Playwright / Chromium (headless Linux)
# ══════════════════════════════════════════════════════════════════
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates \
    libnss3 libnss3-dev libnspr4 \
    libatk1.0-0 libatk-bridge2.0-0 \
    libcups2 libdrm2 \
    libxkbcommon0 libxcomposite1 libxdamage1 \
    libxfixes3 libxrandr2 libgbm1 \
    libasound2t64 \
    libpango-1.0-0 libpangocairo-1.0-0 libcairo2 \
    libglib2.0-0 libx11-6 libxext6 libxss1 libxtst6 \
    fonts-liberation fonts-noto \
    libxcb1 libxcb-dri3-0 libxcb-icccm4 \
    libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
    libxcb-render-util0 libxcb-shape0 libxcb-sync1 \
    libxcb-xfixes0 libxcb-xinerama0 libxcb-xkb1 \
    libxkbcommon-x11-0 \
    libvulkan1 libdbus-1-3 xvfb \
    && rm -rf /var/lib/apt/lists/*

# ══════════════════════════════════════════════════════════════════
#  مستخدم غير root للأمان
# ══════════════════════════════════════════════════════════════════
RUN groupadd --gid 1001 botuser && \
    useradd --uid 1001 --gid botuser --shell /bin/bash --create-home botuser

# ══════════════════════════════════════════════════════════════════
#  تثبيت مكتبات Python
# ══════════════════════════════════════════════════════════════════
WORKDIR /app

COPY instagram_automation/requirements.txt ./instagram_automation/requirements.txt

RUN pip install --upgrade pip --quiet && \
    pip install --no-cache-dir \
        streamlit>=1.35.0 \
        playwright>=1.44.0 \
        aiosqlite>=0.20.0 \
        openpyxl>=3.1.0 \
        python-dotenv>=1.0.0

# ══════════════════════════════════════════════════════════════════
#  تثبيت Chromium (كـ root ثم نقله لمجلد المستخدم)
# ══════════════════════════════════════════════════════════════════
RUN playwright install --with-deps chromium && \
    mkdir -p /home/botuser/.playwright && \
    if [ -d /root/.cache/ms-playwright ]; then \
        cp -r /root/.cache/ms-playwright/. /home/botuser/.playwright/; \
    fi && \
    chown -R botuser:botuser /home/botuser/.playwright

# ══════════════════════════════════════════════════════════════════
#  نسخ كود التطبيق وإعداد المجلدات
# ══════════════════════════════════════════════════════════════════
COPY instagram_automation/ ./instagram_automation/

RUN mkdir -p \
        instagram_automation/sessions \
        instagram_automation/screenshots \
        /var/log/instabot && \
    chown -R botuser:botuser /app /var/log/instabot

# ══════════════════════════════════════════════════════════════════
#  التبديل للمستخدم غير root
# ══════════════════════════════════════════════════════════════════
USER botuser

EXPOSE 8081

# نقطة الدخول الافتراضية — main.py
# لتشغيل Streamlit: docker compose up web
CMD ["python", "instagram_automation/main.py"]
