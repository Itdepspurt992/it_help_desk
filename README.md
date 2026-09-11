# IT Help Desk Management System — Production V3

نظام داخلي عملي لإدارة الدعم الفني، مبني بـ Python/Flask + SQLAlchemy، مع SQLite للتطوير وإمكانية الانتقال إلى Microsoft SQL Server عبر `DATABASE_URL`.

## هيكل المشروع

```text
IT_Help_Desk/
├── backend/        # Flask + SQLAlchemy + seed
├── frontend/       # مساحة مخصصة لتطوير SPA لاحقاً
├── templates/      # واجهة RTL الحالية
├── static/         # CSS responsive
├── database/       # SQLite runtime
├── uploads/        # مرفقات التذاكر
├── backups/        # نسخ SQLite
├── reports/
├── tests/
├── requirements.txt
├── run.bat
├── run.sh
└── sqlserver_schema.sql
```

## المزايا
- Login/Logout، Remember Me، Password Hashing عبر Werkzeug.
- RBAC حقيقي من خلال `Roles → Permissions → RolePermissions` والتحقق من الصلاحيات في Backend.
- تذاكر: إنشاء، تصنيف، أولوية، تعيين فني، Workflow، Comments، Resolution، Rating.
- Ticket History وAudit Log.
- Assets وربط الجهاز بالتذكرة وتاريخ الأعطال.
- SLA: Critical 30m، High 2h، Medium 8h، Low 24h، مع Warning/Overdue.
- Notifications داخلية.
- بحث وتصفية شاملة للتذاكر.
- Dashboard وتقارير حسب القسم والتصنيف والفني وتصدير CSV.
- إدارة المستخدمين والأقسام والتصنيفات والحالات وSLA والصلاحيات.
- Attachments بحد أقصى 10MB وبأنواع ملفات محددة.
- Backup لـ SQLite.
- REST API مع CSRF token endpoint.
- SQL Server reference schema.
- صفحات 403/404/413/500.
- Responsive RTL بدون اعتماد على CDN في الواجهة الأساسية.

## التشغيل على Windows
1. افتح مجلد المشروع.
2. شغل `run.bat`.
3. سيُنشئ Virtual Environment، يثبت Dependencies، يجهز Database وSample Data ثم يشغل الخادم.
4. افتح `http://127.0.0.1:5000`.

إذا كان الجهاز خلف Proxy أو بدون Internet، استخدم PyPI mirror داخلي أو جهز wheelhouse داخلياً قبل تشغيل `run.bat`.

## بيانات تجريبية
- `admin / Admin@123` — IT Administrator
- `manager / Manager@123` — IT Manager
- `obada / Obada@123` — IT Technician
- `ahmed / Ahmed@123` — Department Member
- `accounting_mgr / Account@123` — Department Manager
- `executive / Executive@123` — Executive Manager
- `user1..user5 / User@123` — Department Members

**غيّر جميع كلمات المرور الافتراضية فوراً.**

## Network Mode
الخادم يستمع افتراضياً على `0.0.0.0:5000`. مثال:

`http://192.168.1.100:5000`

في Windows Firewall (PowerShell كمسؤول):

```powershell
New-NetFirewallRule -DisplayName "IT Help Desk 5000" -Direction Inbound -Protocol TCP -LocalPort 5000 -Action Allow
```

يفضل في الإنتاج استخدام Reverse Proxy/HTTPS وعدم نشر منفذ Flask مباشرة على الإنترنت.

## Database
SQLite الافتراضية:

`sqlite:///database/helpdesk.db`

SQL Server مثال:

`mssql+pyodbc://USER:PASSWORD@SERVER/DATABASE?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes`

يمكن ضبطها في `.env` عبر `DATABASE_URL`.

## API
- `GET /api/csrf-token`
- `GET /api/tickets`
- `POST /api/tickets`
- `GET /api/tickets/{id}`
- `PUT /api/tickets/{id}`
- `POST /api/tickets/{id}/assign`
- `POST /api/tickets/{id}/status`
- `POST /api/tickets/{id}/comments`
- `POST /api/tickets/{id}/resolve`
- `POST /api/tickets/{id}/rate`
- `GET/POST /api/assets`
- `GET /api/reports/dashboard`
- `GET /api/reports/daily`
- `GET /api/reports/monthly`
- `GET /api/reports/monthly/{year}/{month}`
- `GET /api/reports/technicians`
- `GET /api/notifications`

طلبات POST/PUT عبر API تستخدم Session Authentication وCSRF؛ احصل على token من `/api/csrf-token` وأرسله في `X-CSRFToken`.

## Testing
بعد تثبيت المتطلبات:

```bash
pytest -q
```

الاختبارات تغطي Login، Unauthorized Access، Ticket creation/number، Assignment، Workflow، Comments، Resolution، Rating، RBAC، Audit Log، SLA وAPI.

## Backup
من Settings → Backup يمكن إنشاء نسخة SQLite في:

`backups/helpdesk_YYYY-MM-DD_HHMMSS.db`

لـ SQL Server استخدم SQL Server native backup/maintenance jobs.

## Security / production notes
- Executive Manager is restricted to the read-only executive dashboard; ticket browsing and detailed reports are blocked server-side.
- API endpoints return JSON errors for 400/403/404/413/500 responses.
- Login redirects reject external `next` URLs to prevent open redirects.
- Deactivated users are rejected by the session user loader on subsequent requests.
- SQLite backups use the SQLite online backup API instead of copying a live database file.
- Attachment files are removed if ticket creation fails after files were written.

## Production notes
- غيّر `SECRET_KEY` إلى قيمة عشوائية طويلة.
- استخدم SQL Server أو PostgreSQL عند الحاجة إلى تشغيل مؤسسي أكبر.
- فعّل HTTPS و`SESSION_COOKIE_SECURE=1` خلف Reverse Proxy.
- ضع `uploads` و`backups` على Storage محمي مع صلاحيات نظام الملفات.
- لا تستخدم كلمات المرور التجريبية في الإنتاج.
