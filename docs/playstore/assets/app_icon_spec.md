# 📱 Google Play Console - অ্যাপ আইকন স্পেসিফিকেশন (App Icon)

গুগল প্লে কনসোলে আপলোড করার জন্য নির্ধারিত শর্তাবলী অনুযায়ী bdHousing-এর অ্যাপ আইকন তৈরি করা হয়েছে।

---

## ১. অফিসিয়াল স্পেসিফিকেশন
* **রেজোলিউশন:** `512 x 512 px`
* **কালার ডেপথ:** `32-bit PNG (8-bit per color RGBA with Alpha Channel)`
* **কালার স্পেস:** sRGB
* **আকার সীমা:** সর্বোচ্চ ১,০২৪ KB (১ MB)
* **আকৃতি:** ফুল স্কয়ার (প্লে স্টোর স্বয়ংক্রিয়ভাবে ডিভাইসে স্কুইর্কল মাস্কিং প্রয়োগ করে)

---

## ২. ফাইল লোকেশনসমূহ (Ready to Upload)

### ভ্যারিয়েন্ট ১: ৩ডি আর্কিটেকচারাল এডিশন (সুপারিশকৃত / Recommended)
* **ফাইল পাথ:** [bdhousing_app_icon_3d_512x512.png](file:///home/mhcybroot/Work/LandApp/assets/playstore/bdhousing_app_icon_3d_512x512.png)
* **সাইজ:** ৩০২ KB
* **স্টাইল:** ৩ডি আধুনিক আইসোমেট্রিক ভিলা ও বহুতল ফ্ল্যাট ভবন, গোল্ডেন ট্রাস্ট লোকেশন পিন এবং গভীর এমারেল্ড গ্রিন ব্যাকগ্রাউন্ড।

### ভ্যারিয়েন্ট ২: মিনিমালিস্ট ট্রাস্ট শিল্ড এডিশন
* **ফাইল পাথ:** [bdhousing_app_icon_v2_512x512.png](file:///home/mhcybroot/Work/LandApp/assets/playstore/bdhousing_app_icon_v2_512x512.png)
* **সাইজ:** ১০১ KB
* **স্টাইল:** হেরাল্ডিক গোল্ডেন ট্রাস্ট শিল্ড, আর্কিটেকচারাল উইন্ডোজ ও ট্রাস্ট ভেরিফিকেশন রিবন।

### ভ্যারিয়েন্ট ৩: ব্র্যান্ড টাইপোগ্রাফি ও ব্যাজ এডিশন
* **ফাইল পাথ:** [bdhousing_app_icon_512x512.png](file:///home/mhcybroot/Work/LandApp/assets/playstore/bdhousing_app_icon_512x512.png)
* **সাইজ:** ১১১ KB
* **স্টাইল:** ভিলা-টাওয়ার সিলুয়েট, সাথে স্পষ্ট "bdHousing" লোগোটাইপ ও ট্যাগলাইন।

---

## ৩. অ্যাপে ইনস্টল হওয়া লঞ্চার আইকন তালিকা
ডিভাইসে ইনস্টল করার সময় স্বয়ংক্রিয়ভাবে এই আইকন প্রদর্শিত হওয়ার জন্য নিচের ফাইলগুলোও আপডেট করা রয়েছে:
* `frontend/android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
* `frontend/android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
* `frontend/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
* `frontend/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
* `frontend/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)
* `frontend/web/icons/Icon-192.png` ও `Icon-512.png`
