// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'EarlyJobs';

  @override
  String get home => 'Home';

  @override
  String get workers => 'Workers';

  @override
  String get filter => 'Filter';

  @override
  String get filters => 'Filters';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get applyFilters => 'Apply';

  @override
  String get filterAvailability => 'Availability';

  @override
  String get filterAll => 'All';

  @override
  String get filterAvailable => 'Available';

  @override
  String get filterOnJob => 'On a job';

  @override
  String get filterDisability => 'Disability';

  @override
  String get filterWithDisability => 'With disability';

  @override
  String get filterWithoutDisability => 'Without disability';

  @override
  String get filterTrade => 'Main work';

  @override
  String get filterTradeHint => 'e.g. Mason';

  @override
  String get filterDistrict => 'District';

  @override
  String get filterDistrictHint => 'e.g. Surat';

  @override
  String get searchWorkers => 'Search by name';

  @override
  String get noWorkersMatchFilters => 'No workers match these filters.';

  @override
  String get profile => 'Account';

  @override
  String get signOut => 'Sign out';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get logIn => 'Log in';

  @override
  String get moreWorkers => 'More workers';

  @override
  String get recentWorkers => 'Workers near you.';

  @override
  String workersCount(int count) {
    return '$count people in your list.';
  }

  @override
  String get worker => 'Worker';

  @override
  String get workerNotFound => 'Worker not found.';

  @override
  String get addWorker => 'Add worker';

  @override
  String get editWorker => 'Edit worker';

  @override
  String get saveWorker => 'Save worker';

  @override
  String get readyToWork => 'Available for work';

  @override
  String get ready => 'Available';

  @override
  String get busy => 'On a job';

  @override
  String get personal => 'Personal';

  @override
  String get work => 'Work';

  @override
  String get address => 'Address';

  @override
  String get documents => 'Documents';

  @override
  String get addDocument => 'Add document';

  @override
  String get noDocuments => 'No documents yet.';

  @override
  String get aadhaar => 'Aadhaar Card';

  @override
  String get pan => 'PAN Card';

  @override
  String get bankPassbook => 'Bank passbook';

  @override
  String get drivingLicence => 'Driving licence';

  @override
  String get photo => 'Photo';

  @override
  String get fullName => 'Full name';

  @override
  String get phone => 'Phone';

  @override
  String get mobileNumber => 'Mobile number';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get selectGender => 'Select gender';

  @override
  String get selectIdType => 'Select document ID type';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get hasDisability => 'Person with disability';

  @override
  String get disabilityDetails => 'Disability details';

  @override
  String get disabilityDetailsHint => 'Type of disability (optional)';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get idType => 'Document ID Type';

  @override
  String get idNumber => 'Document ID Number';

  @override
  String get invalidAadhaar => 'Enter a valid 12-digit Aadhaar number';

  @override
  String get invalidPan => 'Enter a valid PAN (e.g. ABCDE1234F)';

  @override
  String get documentFront => 'Front';

  @override
  String get documentBack => 'Back';

  @override
  String get addFrontImage => 'Add front image';

  @override
  String get addBackImage => 'Add back image';

  @override
  String get idFront => 'Front';

  @override
  String get idBack => 'Back';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseGallery => 'Choose from gallery';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get addPhotoOptional => 'Add photo (optional)';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get idImagesRequired => 'Add front and back images of the ID.';

  @override
  String get idLabel => 'ID';

  @override
  String get primaryTrade => 'Main work';

  @override
  String get subSkills => 'Other skills';

  @override
  String get subSkillsHint => 'Separate with commas';

  @override
  String get experience => 'Experience';

  @override
  String get yearsOfExperience => 'Years of work';

  @override
  String get dailyWageExpected => 'Daily wage wanted';

  @override
  String get addressLine => 'Address';

  @override
  String get villageOrTown => 'Village / town';

  @override
  String get district => 'District';

  @override
  String get state => 'State';

  @override
  String get pincode => 'Pincode';

  @override
  String get permanentAddress => 'Permanent address';

  @override
  String get currentAddress => 'Current address';

  @override
  String get sameAsPermanent => 'Same as permanent address';

  @override
  String get workHistory => 'Work history';

  @override
  String get company => 'Company';

  @override
  String get addWork => 'Add work';

  @override
  String get fromDate => 'From';

  @override
  String get toDate => 'To';

  @override
  String get stillWorking => 'Still working here';

  @override
  String get endThisWork => 'End this work';

  @override
  String get noWorkHistory => 'No work added yet.';

  @override
  String get now => 'Now';

  @override
  String get availabilityHint => 'Toggle Available / On a job to change it.';

  @override
  String get leaveJobTitle => 'Ready to leave?';

  @override
  String leaveJobBody(String company) {
    return 'Was working at $company. Mark as Available?';
  }

  @override
  String get markAvailable => 'Mark Available';

  @override
  String get markOnJobTitle => 'Mark as on a job?';

  @override
  String get markOnJobBody => 'Where are they working now?';

  @override
  String get markOnJob => 'Mark On a job';

  @override
  String get cancel => 'Cancel';

  @override
  String get years => 'years';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInWithMobile => 'Sign in with your mobile number.';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginWithPasswordInstead => 'Login with password instead';

  @override
  String get loginWithOtpInstead => 'Login with OTP instead';

  @override
  String get newHere => 'New here?';

  @override
  String get otp => 'OTP';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get resendOtp => 'Send OTP again';

  @override
  String get createAccount => 'Create an account';

  @override
  String get pendingApproval => 'Pending approval';

  @override
  String get pendingApprovalBody =>
      'Your signup is in. An admin must approve your partner account before you can use the app.';

  @override
  String get myProfile => 'My account';

  @override
  String get authenticationDetails => 'Authentication';

  @override
  String get personalDetails => 'Personal details';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get changesSaved => 'Changes saved.';

  @override
  String get phoneCannotChange => 'Phone number cannot be changed.';

  @override
  String get preferences => 'Preferences';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get contactSupportBody =>
      'Need help with your partner account? Email us and we’ll get back to you.';

  @override
  String get copyEmail => 'Copy email';

  @override
  String get emailCopied => 'Support email copied';

  @override
  String get legal => 'Legal';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get termsAndConditions => 'Terms and conditions';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get requiredField => 'Please fill this';

  @override
  String get systemDefault => 'Phone language (Default)';

  @override
  String get language => 'Language';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get submitForApproval => 'Submit for Review';

  @override
  String get signupBody =>
      'Register as a sourcing partner. After OTP check, an admin will review your account.';

  @override
  String enterOtpForPhone(String phone) {
    return 'Enter the 6-digit code for +91 $phone.';
  }

  @override
  String get newOtpReady => 'A new OTP is ready.';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get forgotPasswordTitle => 'Forgot your password?';

  @override
  String get forgotPasswordBody =>
      'Check your mobile number, then set a new password.';

  @override
  String forgotPasswordOtpBody(String phone) {
    return 'Enter the code for +91 $phone, then choose a new password.';
  }

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get updatePassword => 'Update password';

  @override
  String get passwordUpdated =>
      'Password updated. Sign in with your new password.';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get enterMobileNumber => 'Enter your mobile number';

  @override
  String get enterValidMobile => 'Enter a valid 10-digit mobile number';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get enterOtp => 'Enter the OTP';

  @override
  String get enterSixDigitOtp => 'Enter the 6-digit OTP';

  @override
  String get enterNewPassword => 'Enter a new password';

  @override
  String get useAtLeast8Characters => 'Use at least 8 characters';

  @override
  String get confirmNewPassword => 'Confirm your new password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';
}
