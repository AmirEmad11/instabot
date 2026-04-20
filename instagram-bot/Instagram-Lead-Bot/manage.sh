#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════
#  manage.sh — Instagram Lead Bot | Maintenance Script
#  الاستخدام:  ./manage.sh [COMMAND]
# ══════════════════════════════════════════════════════════════════

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${CYAN}▶${NC} $*"; }
success() { echo -e "${GREEN}✔${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $*"; }
error()   { echo -e "${RED}✖${NC}  $*"; exit 1; }
header()  { echo -e "\n${BOLD}${CYAN}══ $* ══${NC}\n"; }

# ── التحقق من وجود docker compose ──
_dc() {
    if command -v "docker" &>/dev/null && docker compose version &>/dev/null 2>&1; then
        docker compose "$@"
    elif command -v "docker-compose" &>/dev/null; then
        docker-compose "$@"
    else
        error "لم أجد docker compose — تأكد من تثبيت Docker"
    fi
}

# ── التحقق من وجود .env ──
_check_env() {
    if [[ ! -f ".env" ]]; then
        warn "ملف .env غير موجود!"
        info "جارٍ إنشاء .env من .env.example..."
        cp .env.example .env
        echo ""
        warn "عدّل ملف .env وأدخل بياناتك قبل التشغيل:"
        echo "  nano .env"
        echo ""
        exit 1
    fi
}

# ── إنشاء مجلدات البيانات ──
_init_dirs() {
    mkdir -p data/sessions data/screenshots data/logs data/db
    success "تم إنشاء مجلدات البيانات: ./data/"
}

# ══════════════════════════════════════════════════════════════════

cmd_start() {
    header "تشغيل Instagram Lead Bot"
    _check_env
    _init_dirs
    info "بناء الصورة وتشغيل السيرفر..."
    _dc up -d --build web
    echo ""
    success "الخدمة تعمل!"
    info "الرابط:  http://$(hostname -I | awk '{print $1}'):${PORT:-8081}"
    info "لمتابعة السجل:  ./manage.sh logs"
}

cmd_stop() {
    header "إيقاف الخدمة"
    _dc down
    success "تم إيقاف الخدمة"
}

cmd_restart() {
    header "إعادة تشغيل الخدمة"
    _dc restart web
    success "تمت إعادة التشغيل"
}

cmd_logs() {
    header "السجل المباشر (Ctrl+C للخروج)"
    _dc logs -f --tail=100 web
}

cmd_status() {
    header "حالة الخدمة"
    _dc ps
    echo ""
    info "فحص الصحة..."
    PORT_VAL="${PORT:-8081}"
    if curl -sf "http://localhost:${PORT_VAL}/_stcore/health" &>/dev/null; then
        success "الخدمة تستجيب على البورت ${PORT_VAL} ✅"
    else
        warn "الخدمة لا تستجيب بعد أو لا تزال تبدأ..."
    fi
}

cmd_run_bot() {
    header "تشغيل main.py (one-shot automation)"
    _check_env
    info "تشغيل البوت بنفس السشنات الخاصة بـ web..."
    _dc run --rm bot
    success "اكتمل تشغيل البوت"
}

cmd_rebuild() {
    header "إعادة بناء الصورة من الصفر"
    warn "هذا سيوقف الخدمة مؤقتاً!"
    _dc down
    _dc build --no-cache web
    _dc up -d web
    success "تمت إعادة البناء والتشغيل"
}

cmd_update() {
    header "تحديث الكود وإعادة التشغيل"
    info "سحب آخر تحديثات..."
    git pull --ff-only 2>/dev/null || warn "git pull فشل — تأكد من الاتصال أو وجود مستودع git"
    info "إعادة بناء الصورة..."
    _dc build web
    _dc up -d web
    success "تم التحديث بنجاح!"
}

cmd_clean() {
    header "تنظيف مساحة VPS"

    info "حجم المجلدات قبل التنظيف:"
    du -sh data/ 2>/dev/null || true
    du -sh data/screenshots/ 2>/dev/null || true

    # حذف لقطات الشاشة القديمة (أكتر من 7 أيام)
    info "حذف لقطات الشاشة الأقدم من 7 أيام..."
    find data/screenshots/ -name "*.png" -mtime +7 -delete 2>/dev/null || true
    find data/screenshots/ -name "*.jpg" -mtime +7 -delete 2>/dev/null || true

    # حذف ملفات السجل القديمة (أكتر من 14 يوم)
    info "حذف ملفات السجل الأقدم من 14 يوم..."
    find data/logs/ -name "*.log" -mtime +14 -delete 2>/dev/null || true

    # تنظيف Docker
    info "تنظيف صور وكونتينرات Docker غير المستخدمة..."
    docker image prune -f --filter "label!=instabot" 2>/dev/null || true
    docker container prune -f 2>/dev/null || true

    # تنظيف __pycache__
    info "حذف ملفات __pycache__..."
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

    echo ""
    info "حجم المجلدات بعد التنظيف:"
    du -sh data/ 2>/dev/null || true

    success "تم التنظيف ✅"
}

cmd_backup() {
    header "نسخ احتياطي للبيانات"
    BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    info "إنشاء: $BACKUP_FILE"
    tar -czf "$BACKUP_FILE" data/
    success "تم حفظ النسخة الاحتياطية: $BACKUP_FILE"
    info "الحجم: $(du -sh "$BACKUP_FILE" | cut -f1)"
}

cmd_help() {
    echo -e "${BOLD}Instagram Lead Bot — manage.sh${NC}"
    echo ""
    echo -e "الاستخدام:  ${CYAN}./manage.sh [COMMAND]${NC}"
    echo ""
    echo "الأوامر:"
    echo -e "  ${GREEN}start${NC}      بناء الصورة وتشغيل الخدمة"
    echo -e "  ${GREEN}stop${NC}       إيقاف الخدمة"
    echo -e "  ${GREEN}restart${NC}    إعادة تشغيل الخدمة"
    echo -e "  ${GREEN}status${NC}     حالة الخدمة وفحص الصحة"
    echo -e "  ${GREEN}logs${NC}       متابعة السجل المباشر"
    echo -e "  ${GREEN}run-bot${NC}    تشغيل main.py يدوياً (one-shot)"
    echo -e "  ${GREEN}rebuild${NC}    إعادة بناء الصورة من الصفر"
    echo -e "  ${GREEN}update${NC}     سحب آخر كود وإعادة التشغيل"
    echo -e "  ${GREEN}clean${NC}      تنظيف الملفات المؤقتة وتوفير المساحة"
    echo -e "  ${GREEN}backup${NC}     نسخ احتياطي لقواعد البيانات والسشنات"
    echo -e "  ${GREEN}help${NC}       عرض هذه المساعدة"
    echo ""
}

# ══════════════════════════════════════════════════════════════════
#  نقطة الدخول
# ══════════════════════════════════════════════════════════════════
COMMAND="${1:-help}"

case "$COMMAND" in
    start)     cmd_start ;;
    stop)      cmd_stop ;;
    restart)   cmd_restart ;;
    status)    cmd_status ;;
    logs)      cmd_logs ;;
    run-bot)   cmd_run_bot ;;
    rebuild)   cmd_rebuild ;;
    update)    cmd_update ;;
    clean)     cmd_clean ;;
    backup)    cmd_backup ;;
    help|--help|-h) cmd_help ;;
    *) error "أمر غير معروف: $COMMAND — جرّب: ./manage.sh help" ;;
esac
