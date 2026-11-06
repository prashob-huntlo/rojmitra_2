import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'EarlyJobs'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @workers.
  ///
  /// In en, this message translates to:
  /// **'Workers'**
  String get workers;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyFilters;

  /// No description provided for @filterAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get filterAvailability;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get filterAvailable;

  /// No description provided for @filterOnJob.
  ///
  /// In en, this message translates to:
  /// **'On a job'**
  String get filterOnJob;

  /// No description provided for @filterDisability.
  ///
  /// In en, this message translates to:
  /// **'Disability'**
  String get filterDisability;

  /// No description provided for @filterWithDisability.
  ///
  /// In en, this message translates to:
  /// **'With disability'**
  String get filterWithDisability;

  /// No description provided for @filterWithoutDisability.
  ///
  /// In en, this message translates to:
  /// **'Without disability'**
  String get filterWithoutDisability;

  /// No description provided for @filterTrade.
  ///
  /// In en, this message translates to:
  /// **'Main work'**
  String get filterTrade;

  /// No description provided for @filterTradeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mason'**
  String get filterTradeHint;

  /// No description provided for @filterDistrict.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get filterDistrict;

  /// No description provided for @filterDistrictHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Surat'**
  String get filterDistrictHint;

  /// No description provided for @searchWorkers.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchWorkers;

  /// No description provided for @noWorkersMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No workers match these filters.'**
  String get noWorkersMatchFilters;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profile;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @moreWorkers.
  ///
  /// In en, this message translates to:
  /// **'More workers'**
  String get moreWorkers;

  /// No description provided for @recentWorkers.
  ///
  /// In en, this message translates to:
  /// **'Workers near you.'**
  String get recentWorkers;

  /// No description provided for @workersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} people in your list.'**
  String workersCount(int count);

  /// No description provided for @worker.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get worker;

  /// No description provided for @workerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Worker not found.'**
  String get workerNotFound;

  /// No description provided for @addWorker.
  ///
  /// In en, this message translates to:
  /// **'Add worker'**
  String get addWorker;

  /// No description provided for @editWorker.
  ///
  /// In en, this message translates to:
  /// **'Edit worker'**
  String get editWorker;

  /// No description provided for @saveWorker.
  ///
  /// In en, this message translates to:
  /// **'Save worker'**
  String get saveWorker;

  /// No description provided for @readyToWork.
  ///
  /// In en, this message translates to:
  /// **'Available for work'**
  String get readyToWork;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get ready;

  /// No description provided for @busy.
  ///
  /// In en, this message translates to:
  /// **'On a job'**
  String get busy;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @addDocument.
  ///
  /// In en, this message translates to:
  /// **'Add document'**
  String get addDocument;

  /// No description provided for @noDocuments.
  ///
  /// In en, this message translates to:
  /// **'No documents yet.'**
  String get noDocuments;

  /// No description provided for @aadhaar.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar Card'**
  String get aadhaar;

  /// No description provided for @pan.
  ///
  /// In en, this message translates to:
  /// **'PAN Card'**
  String get pan;

  /// No description provided for @bankPassbook.
  ///
  /// In en, this message translates to:
  /// **'Bank passbook'**
  String get bankPassbook;

  /// No description provided for @drivingLicence.
  ///
  /// In en, this message translates to:
  /// **'Driving licence'**
  String get drivingLicence;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumber;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get selectGender;

  /// No description provided for @selectIdType.
  ///
  /// In en, this message translates to:
  /// **'Select document ID type'**
  String get selectIdType;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @hasDisability.
  ///
  /// In en, this message translates to:
  /// **'Person with disability'**
  String get hasDisability;

  /// No description provided for @disabilityDetails.
  ///
  /// In en, this message translates to:
  /// **'Disability details'**
  String get disabilityDetails;

  /// No description provided for @disabilityDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Type of disability (optional)'**
  String get disabilityDetailsHint;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @idType.
  ///
  /// In en, this message translates to:
  /// **'Document ID Type'**
  String get idType;

  /// No description provided for @idNumber.
  ///
  /// In en, this message translates to:
  /// **'Document ID Number'**
  String get idNumber;

  /// No description provided for @invalidAadhaar.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 12-digit Aadhaar number'**
  String get invalidAadhaar;

  /// No description provided for @invalidPan.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid PAN (e.g. ABCDE1234F)'**
  String get invalidPan;

  /// No description provided for @documentFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get documentFront;

  /// No description provided for @documentBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get documentBack;

  /// No description provided for @addFrontImage.
  ///
  /// In en, this message translates to:
  /// **'Add front image'**
  String get addFrontImage;

  /// No description provided for @addBackImage.
  ///
  /// In en, this message translates to:
  /// **'Add back image'**
  String get addBackImage;

  /// No description provided for @idFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get idFront;

  /// No description provided for @idBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get idBack;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @addPhotoOptional.
  ///
  /// In en, this message translates to:
  /// **'Add photo (optional)'**
  String get addPhotoOptional;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @idImagesRequired.
  ///
  /// In en, this message translates to:
  /// **'Add front and back images of the ID.'**
  String get idImagesRequired;

  /// No description provided for @idLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get idLabel;

  /// No description provided for @primaryTrade.
  ///
  /// In en, this message translates to:
  /// **'Main work'**
  String get primaryTrade;

  /// No description provided for @subSkills.
  ///
  /// In en, this message translates to:
  /// **'Other skills'**
  String get subSkills;

  /// No description provided for @subSkillsHint.
  ///
  /// In en, this message translates to:
  /// **'Separate with commas'**
  String get subSkillsHint;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @yearsOfExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of work'**
  String get yearsOfExperience;

  /// No description provided for @dailyWageExpected.
  ///
  /// In en, this message translates to:
  /// **'Daily wage wanted'**
  String get dailyWageExpected;

  /// No description provided for @addressLine.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLine;

  /// No description provided for @villageOrTown.
  ///
  /// In en, this message translates to:
  /// **'Village / town'**
  String get villageOrTown;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @pincode.
  ///
  /// In en, this message translates to:
  /// **'Pincode'**
  String get pincode;

  /// No description provided for @permanentAddress.
  ///
  /// In en, this message translates to:
  /// **'Permanent address'**
  String get permanentAddress;

  /// No description provided for @currentAddress.
  ///
  /// In en, this message translates to:
  /// **'Current address'**
  String get currentAddress;

  /// No description provided for @sameAsPermanent.
  ///
  /// In en, this message translates to:
  /// **'Same as permanent address'**
  String get sameAsPermanent;

  /// No description provided for @workHistory.
  ///
  /// In en, this message translates to:
  /// **'Work history'**
  String get workHistory;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @addWork.
  ///
  /// In en, this message translates to:
  /// **'Add work'**
  String get addWork;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toDate;

  /// No description provided for @stillWorking.
  ///
  /// In en, this message translates to:
  /// **'Still working here'**
  String get stillWorking;

  /// No description provided for @endThisWork.
  ///
  /// In en, this message translates to:
  /// **'End this work'**
  String get endThisWork;

  /// No description provided for @noWorkHistory.
  ///
  /// In en, this message translates to:
  /// **'No work added yet.'**
  String get noWorkHistory;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @availabilityHint.
  ///
  /// In en, this message translates to:
  /// **'Toggle Available / On a job to change it.'**
  String get availabilityHint;

  /// No description provided for @leaveJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to leave?'**
  String get leaveJobTitle;

  /// No description provided for @leaveJobBody.
  ///
  /// In en, this message translates to:
  /// **'Was working at {company}. Mark as Available?'**
  String leaveJobBody(String company);

  /// No description provided for @markAvailable.
  ///
  /// In en, this message translates to:
  /// **'Mark Available'**
  String get markAvailable;

  /// No description provided for @markOnJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as on a job?'**
  String get markOnJobTitle;

  /// No description provided for @markOnJobBody.
  ///
  /// In en, this message translates to:
  /// **'Where are they working now?'**
  String get markOnJobBody;

  /// No description provided for @markOnJob.
  ///
  /// In en, this message translates to:
  /// **'Mark On a job'**
  String get markOnJob;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInWithMobile.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your mobile number.'**
  String get signInWithMobile;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @loginWithPasswordInstead.
  ///
  /// In en, this message translates to:
  /// **'Login with password instead'**
  String get loginWithPasswordInstead;

  /// No description provided for @loginWithOtpInstead.
  ///
  /// In en, this message translates to:
  /// **'Login with OTP instead'**
  String get loginWithOtpInstead;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get newHere;

  /// No description provided for @otp.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otp;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP again'**
  String get resendOtp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @pendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get pendingApproval;

  /// No description provided for @pendingApprovalBody.
  ///
  /// In en, this message translates to:
  /// **'Your signup is in. An admin must approve your partner account before you can use the app.'**
  String get pendingApprovalBody;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get myProfile;

  /// No description provided for @authenticationDetails.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authenticationDetails;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get personalDetails;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved.'**
  String get changesSaved;

  /// No description provided for @phoneCannotChange.
  ///
  /// In en, this message translates to:
  /// **'Phone number cannot be changed.'**
  String get phoneCannotChange;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @contactSupportBody.
  ///
  /// In en, this message translates to:
  /// **'Need help with your partner account? Email us and we’ll get back to you.'**
  String get contactSupportBody;

  /// No description provided for @copyEmail.
  ///
  /// In en, this message translates to:
  /// **'Copy email'**
  String get copyEmail;

  /// No description provided for @emailCopied.
  ///
  /// In en, this message translates to:
  /// **'Support email copied'**
  String get emailCopied;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and conditions'**
  String get termsAndConditions;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Please fill this'**
  String get requiredField;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'Phone language (Default)'**
  String get systemDefault;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @submitForApproval.
  ///
  /// In en, this message translates to:
  /// **'Submit for Review'**
  String get submitForApproval;

  /// No description provided for @signupBody.
  ///
  /// In en, this message translates to:
  /// **'Register as a sourcing partner. After OTP check, an admin will review your account.'**
  String get signupBody;

  /// No description provided for @enterOtpForPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code for +91 {phone}.'**
  String enterOtpForPhone(String phone);

  /// No description provided for @newOtpReady.
  ///
  /// In en, this message translates to:
  /// **'A new OTP is ready.'**
  String get newOtpReady;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Check your mobile number, then set a new password.'**
  String get forgotPasswordBody;

  /// No description provided for @forgotPasswordOtpBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the code for +91 {phone}, then choose a new password.'**
  String forgotPasswordOtpBody(String phone);

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Sign in with your new password.'**
  String get passwordUpdated;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number'**
  String get enterMobileNumber;

  /// No description provided for @enterValidMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number'**
  String get enterValidMobile;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP'**
  String get enterOtp;

  /// No description provided for @enterSixDigitOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit OTP'**
  String get enterSixDigitOtp;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get enterNewPassword;

  /// No description provided for @useAtLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get useAtLeast8Characters;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your new password'**
  String get confirmNewPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
