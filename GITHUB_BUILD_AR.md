# بناء ملف التثبيت EXE عبر GitHub Actions

1. أنشئ مستودع GitHub خاص.
2. ارفع **محتويات** مجلد المشروع إلى المستودع، بما فيها `.github/workflows/build-windows.yml`.
3. افتح تبويب **Actions**.
4. اختر **Build IT Help Desk Windows Installer**.
5. اضغط **Run workflow**.
6. بعد نجاح البناء افتح العملية الأخيرة وانزل إلى **Artifacts**.
7. حمّل `IT_Help_Desk_Setup_Windows`.

النتيجة: `IT_Help_Desk_Setup.exe` جاهز للتثبيت على Windows 10/11.

## بيانات الدخول الأولى
- المستخدم: `admin`
- كلمة المرور: `Admin@123`

غيّر كلمة المرور فوراً بعد أول تسجيل دخول.

## SQL Server
بعد تثبيت البرنامج يمكن وضع ملف `.env` بجانب `IT_Help_Desk.exe` وتحديد `DATABASE_URL`، ثم تشغيل البرنامج. لا يتم نقل بيانات SQLite تلقائياً إلى SQL Server.
