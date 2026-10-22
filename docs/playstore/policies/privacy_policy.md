# 📜 Google Play Console - প্রাইভেসি পলিসি ও ডেটা সেফটি (Privacy Policy)

গুগল প্লে স্টোরে ব্যবহারকারীর ডেটা সংগ্রহ ও গোপনীয়তা সম্পর্কিত নীতিমালা মেনে bdHousing-এর প্রাইভেসি পলিসি ইন-অ্যাপ এবং পাবলিক ওয়েব—উভয় মাধ্যমেই সংযুক্ত করা হয়েছে।

---

## ১. লাইভ প্রাইভেসি পলিসি ইউআরএল (Live Web URL)
প্লে কনসোলের **Policy > App content > Privacy policy** ফর্মে নিচের লিংকটি প্রদান করুন:
```text
https://bdhousing.com.bd/privacy-policy.html
```
*(বিকল্প/লোকাল টেস্ট পাথ: `backend/src/main/resources/static/privacy-policy.html` এবং `frontend/web/privacy-policy.html`)*

---

## ২. ইন-অ্যাপ প্রাইভেসি পলিসি স্ক্রিন (In-App Screen)
অ্যাপে ব্যবহারকারী যেকোনো সময় অফলাইন বা অনলাইনে গোপনীয়তা নীতি পড়তে পারবেন:
* **ফাইল পাথ:** [privacy_policy_view.dart](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/views/privacy_policy_view.dart)
* **এক্সেস পয়েন্ট:** অ্যাপের সাইড ড্রয়ার ([shell_drawer.dart](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/shell/widgets/shell_drawer.dart)), লগইন কার্ড এবং রেজিস্ট্রেশন কার্ডে লিংক দেওয়া রয়েছে।

---

## ৩. ডেটা সেফটি ফর্মের উত্তরমালা (Data Safety Form Answers)

প্লে কনসোলে Data Safety ফর্ম পূরণের সময় নিচের মতো উত্তর দিন:

| প্রশ্ন | উত্তর | ব্যাখ্যা |
| :--- | :--- | :--- |
| **Does your app collect or share any of the required user data types?** | **Yes** | নাম, ফোন নম্বর, ছবি ও এলাকা সংগ্রহ করা হয়। |
| **Is all of the user data collected by your app encrypted in transit?** | **Yes** | সকল ডেটা TLS/HTTPS এনক্রিপশনের মাধ্যমে আদান-প্রদান করা হয়। |
| **Do you provide a way for users to request that their data be deleted?** | **Yes** | ইন-অ্যাপ ও ওয়েব উভয় মাধ্যমেই ডিলিটেশনের ব্যবস্থা রয়েছে। |

### সংগৃহীত ডেটা সেকশন:
1. **Personal info > Name:** App functionality, Account management.
2. **Personal info > Phone number:** Account management, Fraud prevention, Customer communication.
3. **Photos and videos > Photos:** App functionality (জমির ছবি আপলোড).
4. **Location > Approximate location:** App functionality (জেলা/উপজেলা অনুযায়ী ফিল্টারিং).
