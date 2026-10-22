# ✅ Google Play Console - প্রি-লঞ্চ চেকলিস্ট (Pre-Launch Checklist)

গুগল প্লে কনসোলে **bdHousing** আপলোড ও পাবলিশ করার আগে নিচের চেকলিস্টটি মিলিয়ে নিন:

---

### ১. অ্যাকাউন্ট ও আইডেন্টিটি ভেরিফিকেশন
- [ ] \$২৫ ফি পরিশোধ করে Google Play Developer অ্যাকাউন্ট তৈরি সম্পন্ন।
- [ ] পাসপোর্ট/এনআইডি দিয়ে অ্যাকাউন্ট ভেরিফিকেশন ও ঠিকানা যাচাই সম্পন্ন।

---

### ২. টেক্সট ও মেটাডেটা সেটআপ ([docs/playstore/metadata/](file:///home/mhcybroot/Work/LandApp/docs/playstore/metadata/))
- [ ] **App Name:** `bdHousing - জমি ও ফ্ল্যাট` (২৫ অক্ষর)
- [ ] **Short Description:** `আবাসন খাতের বিশেষায়িত মার্কেটপ্লেস – জমি, ফ্ল্যাট কেনাবেচা ও প্রবাসীদের সেবা।` (৭৮ অক্ষর)
- [ ] **Full Description:** ৩,১৮০ অক্ষরের পলিসি-কমপ্লায়েন্ট বিবরণ পেস্ট করা হয়েছে।
- [ ] **Category & Tags:** House & Home / Real Estate.

---

### ৩. গ্রাফিক্স অ্যাসেট আপলোড ([docs/playstore/assets/](file:///home/mhcybroot/Work/LandApp/docs/playstore/assets/))
- [ ] **App Icon:** `assets/playstore/bdhousing_app_icon_3d_512x512.png` (৫১২x৫১২ ৩২-বিট পিএনজি) আপলোড করা হয়েছে।
- [ ] **Feature Graphic:** `assets/playstore/bdhousing_feature_graphic_1024x500.png` (১০২৪x৫০০ ২৪-বিট পিএনজি, নো-আলফা) আপলোড করা হয়েছে।
- [ ] **Phone Screenshots:** মোবাইল স্ক্রিনশট যুক্ত করা হয়েছে।

---

### ৪. পলিসি ও ডেটা সেফটি ([docs/playstore/policies/](file:///home/mhcybroot/Work/LandApp/docs/playstore/policies/))
- [ ] **Privacy Policy URL:** `https://bdhousing.com.bd/privacy-policy.html` প্রদান করা হয়েছে।
- [ ] **Account Deletion URL:** `https://bdhousing.com.bd/delete-account.html` প্রদান করা হয়েছে।
- [ ] **Data Safety:** ডেটা কালেকশন (নাম, ফোন, ছবি, আনুমানিক অবস্থান) ডিক্লেয়ার করা হয়েছে।
- [ ] **Government Apps:** "No, my app does not represent a government entity" সিলেক্ট করা হয়েছে।
- [ ] **App Access:** রিভিউয়ারদের জন্য ডেমো অ্যাকাউন্ট (`01700000000` / `admin123`) দেওয়া হয়েছে।

---

### ৫. টেকনিক্যাল বিল্ড ও আপলোড
- [ ] Application ID: `com.bdhousing.app` নিশ্চিত করা হয়েছে।
- [ ] বিল্ড ফরম্যাট: `flutter build appbundle --release` কমান্ড দিয়ে `.aab` ফাইল তৈরি করা হয়েছে।
- [ ] Closed Testing ট্র্যাকে `.aab` আপলোড করা হয়েছে।
- [ ] ১২-২০ জন টেস্টারকে ইনভাইট করে টানা ১৪ দিন টেস্টিং সম্পন্ন করার শিডিউল শুরু করা হয়েছে।
