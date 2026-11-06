// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'EarlyJobs';

  @override
  String get home => 'होम';

  @override
  String get workers => 'वर्कर';

  @override
  String get filter => 'फ़िल्टर';

  @override
  String get filters => 'फ़िल्टर';

  @override
  String get clearFilters => 'फ़िल्टर हटाएँ';

  @override
  String get applyFilters => 'लागू करें';

  @override
  String get filterAvailability => 'उपलब्धता';

  @override
  String get filterAll => 'सभी';

  @override
  String get filterAvailable => 'उपलब्ध';

  @override
  String get filterOnJob => 'काम पर';

  @override
  String get filterDisability => 'दिव्यांगता';

  @override
  String get filterWithDisability => 'दिव्यांग';

  @override
  String get filterWithoutDisability => 'बिना दिव्यांगता';

  @override
  String get filterTrade => 'मुख्य काम';

  @override
  String get filterTradeHint => 'जैसे राजमिस्त्री';

  @override
  String get filterDistrict => 'ज़िला';

  @override
  String get filterDistrictHint => 'जैसे सूरत';

  @override
  String get searchWorkers => 'नाम से खोजें';

  @override
  String get noWorkersMatchFilters => 'इन फ़िल्टर से कोई वर्कर नहीं मिला।';

  @override
  String get profile => 'खाता';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get signIn => 'साइन इन';

  @override
  String get signUp => 'साइन अप';

  @override
  String get logIn => 'लॉग इन';

  @override
  String get moreWorkers => 'और वर्कर';

  @override
  String get recentWorkers => 'आपके पास के वर्कर।';

  @override
  String workersCount(int count) {
    return 'आपकी लिस्ट में $count लोग हैं।';
  }

  @override
  String get worker => 'वर्कर';

  @override
  String get workerNotFound => 'वर्कर नहीं मिला।';

  @override
  String get addWorker => 'वर्कर जोड़ें';

  @override
  String get editWorker => 'वर्कर बदलें';

  @override
  String get saveWorker => 'वर्कर सेव करें';

  @override
  String get readyToWork => 'काम के लिए तैयार';

  @override
  String get ready => 'तैयार';

  @override
  String get busy => 'अभी काम पर';

  @override
  String get personal => 'अपनी बात';

  @override
  String get work => 'काम';

  @override
  String get address => 'पता';

  @override
  String get documents => 'दस्तावेज़';

  @override
  String get addDocument => 'दस्तावेज़ जोड़ें';

  @override
  String get noDocuments => 'अभी कोई दस्तावेज़ नहीं।';

  @override
  String get aadhaar => 'आधार कार्ड';

  @override
  String get pan => 'पैन कार्ड';

  @override
  String get bankPassbook => 'बैंक पासबुक';

  @override
  String get drivingLicence => 'ड्राइविंग लाइसेंस';

  @override
  String get photo => 'फ़ोटो';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get phone => 'फ़ोन';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get gender => 'लिंग';

  @override
  String get male => 'पुरुष';

  @override
  String get female => 'महिला';

  @override
  String get other => 'अन्य';

  @override
  String get selectGender => 'लिंग चुनें';

  @override
  String get selectIdType => 'दस्तावेज़ आईडी प्रकार चुनें';

  @override
  String get dateOfBirth => 'जन्म तारीख';

  @override
  String get hasDisability => 'दिव्यांग व्यक्ति';

  @override
  String get disabilityDetails => 'दिव्यांगता का विवरण';

  @override
  String get disabilityDetailsHint => 'दिव्यांगता का प्रकार (वैकल्पिक)';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get idType => 'दस्तावेज़ आईडी प्रकार';

  @override
  String get idNumber => 'दस्तावेज़ आईडी नंबर';

  @override
  String get invalidAadhaar => '12 अंकों का सही आधार नंबर लिखें';

  @override
  String get invalidPan => 'सही पैन लिखें (जैसे ABCDE1234F)';

  @override
  String get documentFront => 'सामने';

  @override
  String get documentBack => 'पीछे';

  @override
  String get addFrontImage => 'सामने की तस्वीर जोड़ें';

  @override
  String get addBackImage => 'पीछे की तस्वीर जोड़ें';

  @override
  String get idFront => 'सामने';

  @override
  String get idBack => 'पीछे';

  @override
  String get takePhoto => 'फोटो लें';

  @override
  String get chooseGallery => 'गैलरी से चुनें';

  @override
  String get removePhoto => 'फोटो हटाएँ';

  @override
  String get addPhotoOptional => 'फोटो जोड़ें (वैकल्पिक)';

  @override
  String get changePhoto => 'फोटो बदलें';

  @override
  String get idImagesRequired => 'आईडी की आगे और पीछे दोनों तस्वीरें जोड़ें।';

  @override
  String get idLabel => 'आईडी';

  @override
  String get primaryTrade => 'मुख्य काम';

  @override
  String get subSkills => 'और काम';

  @override
  String get subSkillsHint => 'कॉमा से अलग लिखें';

  @override
  String get experience => 'अनुभव';

  @override
  String get yearsOfExperience => 'कितने साल का काम';

  @override
  String get dailyWageExpected => 'रोज़ की मजदूरी';

  @override
  String get addressLine => 'पता';

  @override
  String get villageOrTown => 'गाँव / शहर';

  @override
  String get district => 'ज़िला';

  @override
  String get state => 'राज्य';

  @override
  String get pincode => 'पिनकोड';

  @override
  String get permanentAddress => 'स्थायी पता';

  @override
  String get currentAddress => 'अभी का पता';

  @override
  String get sameAsPermanent => 'स्थायी पते जैसा ही';

  @override
  String get workHistory => 'काम का इतिहास';

  @override
  String get company => 'कंपनी';

  @override
  String get addWork => 'काम जोड़ें';

  @override
  String get fromDate => 'से';

  @override
  String get toDate => 'तक';

  @override
  String get stillWorking => 'अभी भी यहीं काम करता है';

  @override
  String get endThisWork => 'यह काम बंद करें';

  @override
  String get noWorkHistory => 'अभी कोई काम नहीं जोड़ा।';

  @override
  String get now => 'अभी';

  @override
  String get availabilityHint => 'तैयार / अभी काम पर पर टैप करके बदलें।';

  @override
  String get leaveJobTitle => 'काम छोड़ना है?';

  @override
  String leaveJobBody(String company) {
    return 'पहले $company पर काम था। अब तैयार करें?';
  }

  @override
  String get markAvailable => 'तैयार करें';

  @override
  String get markOnJobTitle => 'अभी काम पर करें?';

  @override
  String get markOnJobBody => 'अभी कहाँ काम कर रहे हैं?';

  @override
  String get markOnJob => 'अभी काम पर करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get years => 'साल';

  @override
  String get welcomeBack => 'वापस स्वागत है';

  @override
  String get signInWithMobile => 'अपना मोबाइल नंबर डालकर साइन इन करें।';

  @override
  String get password => 'पासवर्ड';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get loginWithPasswordInstead => 'इसके बजाय पासवर्ड से लॉगिन करें';

  @override
  String get loginWithOtpInstead => 'इसके बजाय ओटीपी से लॉगिन करें';

  @override
  String get newHere => 'नए हैं?';

  @override
  String get otp => 'ओटीपी';

  @override
  String get sendOtp => 'ओटीपी भेजें';

  @override
  String get verifyOtp => 'ओटीपी सत्यापित करें';

  @override
  String get resendOtp => 'ओटीपी फिर भेजें';

  @override
  String get createAccount => 'नया खाता बनाएँ';

  @override
  String get pendingApproval => 'मंज़ूरी बाकी है';

  @override
  String get pendingApprovalBody =>
      'आपका साइनअप हो गया है। ऐप इस्तेमाल करने से पहले एडमिन को आपका पार्टनर खाता मंज़ूर करना होगा।';

  @override
  String get myProfile => 'मेरा खाता';

  @override
  String get authenticationDetails => 'प्रमाणीकरण';

  @override
  String get personalDetails => 'व्यक्तिगत विवरण';

  @override
  String get saveChanges => 'सेव करें';

  @override
  String get changesSaved => 'बदलाव सेव हो गए।';

  @override
  String get phoneCannotChange => 'फ़ोन नंबर नहीं बदला जा सकता।';

  @override
  String get preferences => 'प्राथमिकताएँ';

  @override
  String get contactSupport => 'सहायता से संपर्क करें';

  @override
  String get contactSupportBody =>
      'पार्टनर खाते में मदद चाहिए? हमें ईमेल करें, हम जल्दी जवाब देंगे।';

  @override
  String get copyEmail => 'ईमेल कॉपी करें';

  @override
  String get emailCopied => 'सहायता ईमेल कॉपी हो गया';

  @override
  String get legal => 'कानूनी';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get termsAndConditions => 'नियम और शर्तें';

  @override
  String appVersion(String version) {
    return 'संस्करण $version';
  }

  @override
  String get requiredField => 'यह भरना ज़रूरी है';

  @override
  String get systemDefault => 'फ़ोन की भाषा (डिफ़ॉल्ट)';

  @override
  String get language => 'भाषा';

  @override
  String get chooseLanguage => 'भाषा चुनें';

  @override
  String get submitForApproval => 'समीक्षा के लिए जमा करें';

  @override
  String get signupBody =>
      'सोर्सिंग पार्टनर के रूप में रजिस्टर करें। ओटीपी के बाद एडमिन आपके खाते की जाँच करेगा।';

  @override
  String enterOtpForPhone(String phone) {
    return '+91 $phone का 6 अंकों का कोड डालें।';
  }

  @override
  String get newOtpReady => 'नया ओटीपी तैयार है।';

  @override
  String get resetPassword => 'पासवर्ड बदलें';

  @override
  String get forgotPasswordTitle => 'पासवर्ड भूल गए?';

  @override
  String get forgotPasswordBody =>
      'अपना मोबाइल नंबर पक्का करें, फिर नया पासवर्ड डालें।';

  @override
  String forgotPasswordOtpBody(String phone) {
    return '+91 $phone का कोड डालें, फिर नया पासवर्ड चुनें।';
  }

  @override
  String get newPassword => 'नया पासवर्ड';

  @override
  String get confirmPassword => 'पासवर्ड पक्का करें';

  @override
  String get updatePassword => 'पासवर्ड बदलें';

  @override
  String get passwordUpdated => 'पासवर्ड बदल गया। नए पासवर्ड से साइन इन करें।';

  @override
  String get showPassword => 'पासवर्ड दिखाएँ';

  @override
  String get hidePassword => 'पासवर्ड छिपाएँ';

  @override
  String get enterMobileNumber => 'अपना मोबाइल नंबर डालें';

  @override
  String get enterValidMobile => 'सही 10 अंकों का मोबाइल नंबर डालें';

  @override
  String get enterPassword => 'अपना पासवर्ड डालें';

  @override
  String get enterOtp => 'ओटीपी डालें';

  @override
  String get enterSixDigitOtp => '6 अंकों का ओटीपी डालें';

  @override
  String get enterNewPassword => 'नया पासवर्ड डालें';

  @override
  String get useAtLeast8Characters => 'कम से कम 8 अक्षर डालें';

  @override
  String get confirmNewPassword => 'नया पासवर्ड पक्का करें';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड एक जैसे नहीं हैं';
}
