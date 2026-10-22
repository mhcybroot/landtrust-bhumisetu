# 🗑️ Google Play Console - অ্যাকাউন্ট ও ডেটা ডিলিটেশন পলিসি (Account Deletion)

২০২৪ সাল থেকে গুগল প্লে স্টোরে যেসব অ্যাপে অ্যাকাউন্ট খোলার সুবিধা রয়েছে, তাদের জন্য **ইন-অ্যাপ এবং পাবলিক ওয়েব লিংক**—উভয় মাধ্যমে অ্যাকাউন্ট ও ডেটা ডিলিটেশনের বিকল্প থাকা বাধ্যতামূলক।

---

## ১. প্লে কনসোলে প্রদানযোগ্য ওয়েব ইউআরএল (Web Deletion URL)
Data Safety ফর্মে **"Account deletion URL"** হিসেবে নিচের লিংকটি সাবমিট করুন:
```text
https://bdhousing.com.bd/delete-account.html
```
*(প্রজেক্টের ফাইল: `frontend/web/delete-account.html` এবং `backend/src/main/resources/static/delete-account.html`)*

---

## ২. কীভাবে এটি বাস্তবায়ন করা হয়েছে?

### ক. ইন-অ্যাপ অ্যাকাউন্ট ডিলিটেশন (In-App)
* **ইউআই কম্পোনেন্ট:** [profile_and_security_dialogs.dart](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/member_portal/widgets/profile_and_security_dialogs.dart)
* **সুবিধা:** ব্যবহারকারী তার প্রোফাইল সেটিংসে গিয়ে সরাসরি **"অ্যাকাউন্ট ডিলিট করুন"** (Danger Zone) বোতামে চাপ দিয়ে কনফার্মেশন সহ অ্যাকাউন্ট মুছে ফেলতে পারেন।
* **এপিআই কল:** `DELETE /api/portal/account`

### খ. ওয়েবভিত্তিক রিকোয়েস্ট পেজ (Web Form)
* **এইচটিএমএল পেজ:** `delete-account.html`
* **সুবিধা:** কোনো ব্যবহারকারী অ্যাপ আনইনস্টল করে ফেললেও ওয়েবসাইট থেকে তার মোবাইল নম্বর ও কারণ নির্বাচন করে ডেটা মোছার আবেদন জমা দিতে পারেন।
* **এপিআই কল:** `POST /api/public/request-account-deletion`

---

## ৩. ডেটা মোছার প্রক্রিয়া ও সময়সীমা
* আবেদন প্রাপ্তির পর ব্যাকএন্ডে ইউজারের ফোন নম্বর ও নাম অ্যানোনিমাইজ করা হয় (`DELETED_timestamp`), নোটিফিকেশন হিস্ট্রি মুছে ফেলা হয় এবং অ্যাকাউন্ট স্ট্যাটাস `DELETED` করা হয়।
* পলিসি বিবরণ অনুযায়ী ৪৮ ঘণ্টার মধ্যে স্থায়ী অপসারণ সম্পন্ন হয়।
