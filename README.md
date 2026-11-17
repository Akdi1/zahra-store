# Zahra — متجر إلكتروني مغربي

واجهة متجر عربية RTL مبنية باستخدام React + Vite، مع سلة ومفضلة وطلب بالدفع عند الاستلام، وإمكانية ربط Supabase للمنتجات والطلبات ولوحة الإدارة.

## تشغيل المشروع محلياً

1. ثبّت Node.js (نسخة LTS) من https://nodejs.org/
2. افتح مجلد المشروع في VS Code أو Terminal.
3. نفّذ:

```bash
npm install
npm run dev
```

4. افتح الرابط المحلي الذي يظهر في الطرفية.

## تخصيص بيانات المتجر

- عدّل رقم واتساب في `.env` عبر المتغير `VITE_WHATSAPP_NUMBER` (اكتب الرقم بصيغة دولية دون +، مثال يبدأ بـ 212).
- عدّل المنتجات التجريبية والصور في `src/data.js`. المنتجات الحالية بيانات عرض تجريبية وليست مخزوناً حقيقياً.
- رسوم التوصيل حالياً تظهر للعميل بأنها تحدد حسب المدينة، ولا تُضاف تلقائياً إلى الإجمالي. يجب تحديد جدول أسعار التوصيل قبل الإطلاق.

## ربط Supabase (اختياري لتفعيل قاعدة البيانات)

1. أنشئ مشروعاً على https://supabase.com/ ضمن الخطة المجانية، مع مراعاة حدودها وسياسة الاحتفاظ بالمشاريع غير النشطة.
2. من SQL Editor نفّذ محتوى `supabase/schema.sql`.
3. من Project Settings → API انسخ Project URL و anon/public key.
4. انسخ `.env.example` إلى `.env` وأدخل:

```env
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
VITE_WHATSAPP_NUMBER=2126XXXXXXXX
```

5. أنشئ مستخدم إدارة من Authentication → Users. لا تمنح دور الإدارة من الواجهة الأمامية. يجب أن يضيف مالك المشروع `app_metadata.role = "zahra_admin"` للمستخدم من جهة موثوقة/لوحة الإدارة في Supabase، وليس من كود المتصفح.
6. أعد تشغيل `npm run dev`.

ملاحظة أمنية: المفتاح anon/public مخصص للمتصفح ويظل آمناً فقط عند تفعيل RLS كما في المخطط. لا تضع service_role key أو أي سر في متغير يبدأ بـ `VITE_` أو في ملفات الواجهة.

## نشر مجاني عبر Cloudflare Pages مع GitHub

1. أنشئ مستودعاً جديداً في GitHub باسم `zahra-store` وارفع محتويات هذا المجلد.
2. سجّل الدخول إلى https://dash.cloudflare.com/ ثم Workers & Pages → Create → Pages → Connect to Git.
3. اختر مستودع `zahra-store`.
4. إعدادات البناء:
   - Framework preset: `Vite`
   - Build command: `npm run build`
   - Build output directory: `dist`
5. من Settings → Environment variables أضف `VITE_SUPABASE_URL` و`VITE_SUPABASE_ANON_KEY` و`VITE_WHATSAPP_NUMBER` إذا كنت تستخدم Supabase.
6. انشر الموقع. كل push إلى الفرع المتصل يعيد البناء والنشر تلقائياً.

## ما يعمل في النسخة الحالية وما يحتاج إعداداً

- يعمل محلياً: التصفح، التصنيفات، البحث، الفرز، صفحة المنتج، السلة، المفضلة، نموذج الطلب، رسالة واتساب.
- دون Supabase: السلة والمفضلة محليتان على جهاز العميل؛ الطلب لا يُحفظ مركزياً. يتم إنشاء مرجع محلي ثم يجب إرساله يدوياً عبر واتساب.
- مع Supabase ومخطط SQL: قراءة المنتجات النشطة، إدخال طلب COD، تسجيل دخول الإدارة، عرض الطلبات وتغيير حالتها، وإضافة المنتجات (بعد إعداد دور الإدارة).
- قبل البيع الفعلي: أضف منتجاتك وصورك وأسعارك ومخزونك الحقيقي، حدد رسوم التوصيل، أكمل سياسات الخصوصية والإرجاع، واختبر الطلب من هاتف آخر.

## هيكل الملفات

```text
zahra-store/
├── public/_redirects
├── src/data.js
├── src/main.jsx
├── src/style.css
├── src/supabase.js
├── supabase/schema.sql
├── .env.example
├── index.html
├── package.json
└── vite.config.js
```

## ملاحظات الإطلاق

- الصور الحالية من Unsplash لأغراض العرض؛ استبدلها بصور منتجات تملك حق استخدامها.
- لا تستخدم تقييمات العرض كآراء عملاء حقيقية. بيانات التقييمات الحالية تجريبية.
- لا يوجد حالياً تتبع شحن آلي أو بريد/رسائل SMS آلية أو نظام كوبونات متكامل.
- أضف معلومات التواصل والسياسات القانونية الحقيقية قبل استقبال طلبات الجمهور.

### منح صلاحية الإدارة

بعد إنشاء مستخدم الإدارة، نفّذ هذا الأمر في Supabase SQL Editor مع استبدال البريد ببريدك. نفّذه أنت فقط بصفتك مالك المشروع:

```sql
update auth.users
set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"zahra_admin"}'::jsonb
where email = 'YOUR-ADMIN-EMAIL@example.com';
```

لا تضف هذا الدور إلى بيانات المستخدم القابلة للتعديل من المتصفح.
