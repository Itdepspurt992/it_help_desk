# IT Help Desk — البرنامج الكامل

## التثبيت على Windows 10/11
1. فك الضغط في مجلد ثابت، مثلاً `C:\IT_Help_Desk`.
2. شغّل `START_HERE.bat`.
3. اختر **1 - تثبيت وبناء برنامج EXE تلقائيا**.
4. بعد نجاح العملية ستجد البرنامج داخل `dist\IT_Help_Desk\IT_Help_Desk.exe` وسيتم إنشاء اختصار على سطح المكتب.

### المتطلبات
- Windows 10/11 64-bit.
- Python 3.11 أو 3.12 موصى به.
- اتصال إنترنت أثناء أول عملية بناء لتثبيت المكتبات وPyInstaller.
- عند استخدام SQL Server: Microsoft ODBC Driver 18 for SQL Server.

## SQL Server
يمكنك اختيار:
- الخيار 2 لإعداد ملف الاتصال.
- الخيار 3 لإنشاء قاعدة البيانات وتهيئة الجداول باستخدام `sqlcmd`.

أو تنفيذ `sqlserver_schema.sql` من SQL Server Management Studio.

## التشغيل داخل الشبكة
البرنامج يعمل على `0.0.0.0:5000` عند ضبط HOST بذلك. من أجهزة الموظفين افتح:
`http://IP-جهاز-الخادم:5000`

اسمح بالمنفذ TCP 5000 في Windows Firewall على جهاز الخادم.

## الحسابات التجريبية
- admin / Admin@123
- obada / Obada@123
- manager / Manager@123
- ahmed / Ahmed@123
- accounting_mgr / Account@123
- executive / Executive@123

**غيّر كلمات المرور فوراً قبل الاستخدام الفعلي.**

## ملاحظة مهمة
هذه الحزمة تحتوي مشروع البرنامج وملفات البناء والتثبيت الخاصة بـ Windows. ملف EXE النهائي يتم بناؤه على جهاز Windows نفسه؛ بيئة التطوير الحالية ليست Windows، لذلك لا يتم الادعاء بوجود EXE مُسبق البناء داخل الحزمة.

## بناء ملف Setup EXE عبر GitHub
يوجد ملف `GITHUB_BUILD_AR.md` وWorkflow داخل `.github/workflows/build-windows.yml` لبناء `IT_Help_Desk_Setup.exe` على Windows Runner في GitHub Actions، دون الحاجة إلى تثبيت Python أو PyInstaller على جهاز المستخدم.
