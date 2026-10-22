# 🏛️ Google Play Policy - সরকারি পরিচয় বিভ্রান্তি প্রতিরোধ (Government Disclaimer)

যেহেতু bdHousing জমি, ফ্ল্যাট, সাব-রেজিস্ট্রি এবং সরকারি ই-পর্চা (`eporcha.gov.bd`) রেফারেন্স নিয়ে কাজ করে, তাই গুগলের **Government Impersonation & Misleading Claims** পলিসির আওতায় যেকোনো রিজেকশন এড়াতে সুনির্দিষ্ট ডিসক্লেইমার যুক্ত করা হয়েছে।

---

## ১. সরকারি বিভ্রান্তি কেন ঘটে?
গুগল রিভিউয়ার বা এআই বট কোনো অ্যাপে সরকারি পোর্টাল লিংক (`.gov.bd`), খতিয়ান বা দলিল যাচাই সংক্রান্ত শব্দ দেখলে যাচাই করে যে অ্যাপটি সরকার অনুমোদিত কি না। অনুমোদন ছাড়া তৈরি অ্যাপগুলোতে সুস্পষ্ট অ-সরকারি ঘোষণা না থাকলে সরাসরি সাসপেন্ড বা রিজেক্ট করা হয়।

---

## ২. বাধ্যতামূলক ডিসক্লেইমার টেক্সট (বাংলা ও ইংরেজি)

### বাংলা ডিসক্লেইমার:
> *"আইনগত ঘোষণা: bdHousing একটি স্বাধীন বেসরকারি রিয়েল এস্টেট মার্কেটপ্লেস এবং এটি কোনো সরকারি দপ্তর বা বাংলাদেশ ভূমি মন্ত্রণালয়ের সাথে সরাসরি সংযুক্ত নয়। ই-পর্চা যাচাইয়ের লিংক ব্যবহারকারীর সুবিধার্থে পাবলিক রেফারেন্স হিসেবে দেওয়া হয়েছে।"*

### English Disclaimer:
> *"Disclaimer: bdHousing is an independent private real estate marketplace and is NOT affiliated with, endorsed by, or representing the Government of Bangladesh, Land Ministry, or any official land administration entity. Links to e-Porcha (eporcha.gov.bd) are provided solely for user reference."*

---

## ৩. অ্যাপের কোন কোন স্থানে এটি কার্যকর করা হয়েছে?
1. **স্টোর লিস্টিং ফুল ডেসক্রিপশন:** [store_listing_metadata.md](file:///home/mhcybroot/Work/LandApp/docs/playstore/metadata/store_listing_metadata.md)-এ স্পষ্ট আলাদা সেকশন আকারে অন্তর্ভুক্ত।
2. **হোমপেজ ও সতর্কতা কার্ড:** [safety_warning_card.dart](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/widgets/safety_warning_card.dart)-এ নোটিশ বক্স আকারে দৃশ্যমান।
3. **ই-পর্চা গাইডেন্স পপআপ:** ইউজার যখনই সরকারি ই-পর্চা বাটনে ক্লিক করবেন, ডায়ালগে এই ডিসক্লেইমার প্রদর্শন করা হয়।
4. **নিয়মাবলি স্ক্রিন:** [rules_and_fees_mobile_view.dart](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/views/mobile/rules_and_fees_mobile_view.dart) এবং ওয়েব ভিউতে স্পষ্টভাবে অন্তর্ভুক্ত।
5. **প্রাইভেসি পলিসি:** [privacy_policy_view.dart](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/views/privacy_policy_view.dart) ও এইচটিএমএল পেজে আলাদা প্যারাগ্রাফ আকারে অন্তর্ভুক্ত।
