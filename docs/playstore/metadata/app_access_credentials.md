# 🔑 Google Play Console - রিভিউয়ার অ্যাপ অ্যাক্সেস ক্রেডেনশিয়াল (App Access)

গুগল প্লে স্টোরে অ্যাপ সাবমিট করার সময় **App content > App access** সেকশনে রিভিউয়ারদের জন্য টেস্ট একাউন্ট প্রদান করা বাধ্যতামূলক, যাতে তারা কোনো বাধা বা ওটিপি জটিলতা ছাড়া অ্যাপের সমস্ত অংশ পরীক্ষা করতে পারেন।

---

## ১. প্লে কনসোলে কী সিলেক্ট করবেন?
* অপশন সিলেক্ট করুন: **"All or some functionality in my app is restricted"**
* এরপর **"Add instructions"** বাটনে ক্লিক করুন।

---

## ২. রিভিউয়ারদের জন্য লগইন নির্দেশিকা (Copy-Paste Instructions)

### Credential Set 1: Super Admin Access
* **Credential Name:** Google Reviewer - Admin Account
* **Phone Number / Username:** `01700000000`
* **Password:** `admin123`
* **Instructions / Notes for Reviewer:**
  > "Use phone number `01700000000` and password `admin123` to log in as Super Admin. This account has full access to the Admin Dashboard, Property Verification, User Management, and Location Management. Alternatively, tap the '⚡ ডেমো অ্যাকাউন্ট পরীক্ষা / Reviewer Quick Access (1-Click)' button on the login screen to enter with a single tap without needing SMS OTP."

---

### Credential Set 2: Verified Member (Buyer / Seller / Officer)
* **Buyer Account:**
  * Phone: `01600000003` | Password: `123456`
  * Role: Buyer (Browsing, search, filter, submitting property demand)
* **Seller Account:**
  * Phone: `01900000002` | Password: `123456`
  * Role: Seller (Adding property listing, uploading photos, receiving inquiries)
* **Marketing Officer Account:**
  * Phone: `01800000001` | Password: `123456`
  * Role: Marketing Officer (Referral code `LT-NOA-1001`, earning commission)

---

## ৩. গুরুত্বপূর্ণ নোট (Why this guarantees review pass)
1. **ওটিপি বাইপাস:** রিভিউয়ারদের আন্তর্জাতিক ফোনে কোনো বাংলাদেশি ওটিপি কোডের প্রয়োজন হবে না।
2. **১-ক্লিক ডেমো বার:** অ্যাপের লগইন পেজে [demo_accounts_bar.dart](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/auth/widgets/demo_accounts_bar.dart)-এ ইংরেজি ও বাংলায় বোতাম রয়েছে, যার ফলে ১-ক্লিকেই ক্রেডেনশিয়াল স্বয়ংক্রিয়ভাবে বসে যায়।
3. **গেস্ট মোড:** কোনো রেজিস্ট্রেশন বা লগইন না করেও অতিথি (Guest) হিসেবে হোমপেজ ও ফিল্টারিং ব্রাউজ করা যায়।
