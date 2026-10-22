# 🚀 bdHousing - Google Play Console পাবলিশিং মাস্টার গাইড

এই ডিরেক্টরিতে **bdHousing** (`com.bdhousing.app`) অ্যাপটি গুগল প্লে স্টোরে কোনো ধরনের রিজেকশন ছাড়া সফলভাবে পাবলিশ করার সমস্ত নথিপত্র, পলিসি, মেটাডেটা, গ্রাফিক্স অ্যাসেট এবং টেস্টিং নির্দেশিকা ফোল্ডার অনুসারে সাজানো রয়েছে।

---

## 📁 ফোল্ডার স্ট্রাকচার ওভারভিউ (Directory Map)

```text
docs/playstore/
├── README.md                              # মূল ইনডেক্স ও সার্বিক নির্দেশিকা (বর্তমান ফাইল)
│
├── metadata/                              # স্টোর লিস্টিং মেটাডেটা ও রিভিউয়ার ক্রেডেনশিয়াল
│   ├── store_listing_metadata.md          # নাম, শর্ট ডেসক্রিপশন, ফুল ডেসক্রিপশন (কপি-পেস্ট রেডি)
│   └── app_access_credentials.md          # গুগল রিভিউয়ারদের জন্য ১-ক্লিক টেস্ট লগইন তথ্য
│
├── assets/                                # গ্রাফিক্যাল অ্যাসেটস ও টেকনিক্যাল স্পেসিফিকেশন
│   ├── README.md                          # গ্রাফিক্স গাইডলাইন ও স্টোর রিকোয়ারমেন্ট
│   ├── app_icon_spec.md                   # ৫১২x৫১২ ৩২-বিট পিএনজি আইকন স্পেসিফিকেশন ও পাথ
│   └── feature_graphic_spec.md            # ১০২৪x৫০০ জেপিজি/পিএনজি ব্যানার স্পেসিফিকেশন
│
├── policies/                              # গুগল প্লে পলিসি ও রিজেকশন প্রতিরোধ ডকুমেন্টেশন
│   ├── privacy_policy.md                  # পূর্ণাঙ্গ প্রাইভেসি পলিসি (ইন-অ্যাপ ও ওয়েব)
│   ├── account_deletion_policy.md         # ইন-অ্যাপ ও ওয়েবভিত্তিক অ্যাকাউন্ট ডিলিটেশন পলিসি
│   ├── government_disclaimer.md           # সরকারি বিভ্রান্তি প্রতিরোধ (ই-পর্চা ডিসক্লেইমার)
│   └── p2p_and_fees_policy.md             # পি২পি লেনদেন ও বাস্তব সার্ভিস ফি ব্যাখ্যা
│
└── testing/                               # ক্লোজড টেস্টিং ও প্রোডাকশন প্রিপারেশন
    ├── closed_testing_guide.md            # ১২-২০ টেস্টার, টানা ১৪ দিন নিয়ম ও প্রশ্নোত্তর গাইড
    └── pre_launch_checklist.md            # পাবলিশ করার চূড়ান্ত চেকলিস্ট
```

---

## ⚡ কুইক অ্যাকশন ন্যাভিগেশন (Quick Links)

1. **স্টোর লিস্টিং টেক্সট কপি করতে:** [store_listing_metadata.md](file:///home/mhcybroot/Work/LandApp/docs/playstore/metadata/store_listing_metadata.md)
2. **আইকন ফাইল দেখতে ও পেতে:** [app_icon_spec.md](file:///home/mhcybroot/Work/LandApp/docs/playstore/assets/app_icon_spec.md)
3. **ফিচার গ্রাফিক দেখতে ও পেতে:** [feature_graphic_spec.md](file:///home/mhcybroot/Work/LandApp/docs/playstore/assets/feature_graphic_spec.md)
4. **গুগল রিভিউয়ার অ্যাকাউন্ট দিতে:** [app_access_credentials.md](file:///home/mhcybroot/Work/LandApp/docs/playstore/metadata/app_access_credentials.md)
5. **১৪ দিনের টেস্টিং পাস করার কৌশল:** [closed_testing_guide.md](file:///home/mhcybroot/Work/LandApp/docs/playstore/testing/closed_testing_guide.md)
6. **চূড়ান্ত চেকলিস্ট:** [pre_launch_checklist.md](file:///home/mhcybroot/Work/LandApp/docs/playstore/testing/pre_launch_checklist.md)

---

## 📱 অ্যাপ ইনফরমেশন সামারি
* **App Name:** bdHousing - জমি ও ফ্ল্যাট
* **Package Name (Application ID):** `com.bdhousing.app`
* **Target SDK:** Android 14/15 (API 34/35/36)
* **Category:** House & Home / Business
* **Support Email:** `support@bdhousing.com.bd`
