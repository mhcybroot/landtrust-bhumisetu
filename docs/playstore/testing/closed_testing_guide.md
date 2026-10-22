# 🧪 Google Play Console - ১৪ দিনের ক্লোজড টেস্টিং গাইডলাইন (Closed Testing)

ব্যক্তিগত গুগল প্লে ডেভেলপার অ্যাকাউন্টে নতুন অ্যাপ সরাসরি প্রোডাকশনে পাবলিশ করা যায় না। গুগল বাধ্যতামূলক করেছে যে প্রোডাকশন অনুমোদনের আগে ক্লোজড ট্র্যাকে অ্যাপটি সফলভাবে টেস্ট করাতে হবে।

---

## 📌 মূল নিয়মাবলী (The Rules)
1. **১২–২০ জন টেস্টার:** প্লে কনসোলে ন্যূনতম ১২ থেকে ২০ জন ইউজারের জিমেইল যোগ করতে হবে।
2. **টানা ১৪ দিন ইনস্টল রাখা:** টেস্টাররা প্লে স্টোর লিংক থেকে অ্যাপে "Opt-in" করে ডিভাইসে ইনস্টল করবেন এবং টানা ১৪ দিন আনইনস্টল করবেন না।
3. **নিয়মিত ইন্টার‍্যাকশন:** টেস্টাররা মাঝে মাঝে অ্যাপে ঢুকে প্রোপার্টি ব্রাউজ করা, সার্চ ফিল্টার ব্যবহার বা ডেমো অ্যাকাউন্টে লগইন করবেন। (গুগল ইউজারের ক্র্যাশ ও টেলিমেট্রি লগ পর্যবেক্ষণ করে)।

---

## 📝 ১৪ দিন পর প্রোডাকশন অ্যাক্সেস আবেদন (Apply for Production Q&A)

১৪ দিন পূর্ণ হওয়ার পর গুগল ৪টি সুনির্দিষ্ট প্রশ্ন করবে। সেগুলোর জন্য প্রস্তুতকৃত পেশাদার উত্তর নিচে দেওয়া হলো:

### প্রশ্ন ১: How did you recruit testers for your closed test? (কীভাবে টেস্টার সংগ্রহ করেছেন?)
> **নমুনা উত্তর:**  
> "We recruited 20 testers comprising real estate enthusiasts, property buyers, sellers, and field agents from our target regions (Noakhali, Feni, and Cumilla). We distributed closed testing opt-in links via internal email lists and a dedicated private WhatsApp testing group."

---

### প্রশ্ন ২: What feedback did you receive from testers during the closed test? (কী কী ফিডব্যাক পেয়েছেন?)
> **নমুনা উত্তর:**  
> "Testers appreciated the clean UI, district-upazila location filtering, and verified safety warnings. They provided valuable suggestions, including clarifying the offline P2P nature of property transactions, adding in-app account deletion controls, refining Pourashava and Union filters, and improving login speed with 1-click demo accounts."

---

### প্রশ্ন ৩: What changes did you make based on this feedback? (ফিডব্যাকের ভিত্তিতে কী কী পরিবর্তন করেছেন?)
> **নমুনা উত্তর:**  
> "Based on tester feedback, we made several improvements:  
> 1. Implemented a prominent Safety Warning Card clarifying offline P2P financial settlement.  
> 2. Added comprehensive In-App and Web-based Account Deletion options.  
> 3. Embedded an in-app Privacy Policy screen and Government Impersonation disclaimer regarding e-Porcha reference.  
> 4. Optimized network performance and enforced secure TLS/HTTPS configurations."

---

### প্রশ্ন ৪: Why do you believe your app is ready for production? (অ্যাপটি কেন প্রোডাকশনের জন্য প্রস্তুত?)
> **নমুনা উত্তর:**  
> "Our application has been thoroughly tested for 14 consecutive days with zero crashes. All core features—including property search, inquiry submission, seller workspace, and officer referral portal—are fully functional, secure, and compliant with all Google Play developer policies."
