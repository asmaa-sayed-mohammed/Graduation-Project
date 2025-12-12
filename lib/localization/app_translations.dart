import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {

    // ============================================================
    // ========================== Arabic ===========================
    // ============================================================
    'ar_EG': {

      /// OnBoarding
      'title1': 'مرحبا بك',
      'subtitle1': 'ابدأ رحلتك معنا',
      'title2': 'تعلّم بسهولة',
      'subtitle2': 'الوصول لكل المعلومات بسهولة',
      'title3': 'ابدأ الآن',
      'subtitle3': 'انطلق مع تطبيقنا',
      'Skip': 'تخطي',
      'go to home page': 'اذهب للصفحة الرئيسية',

      /// HomeScreen
      'Homescreen': 'الصفحة الرئيسية',
      'Login': 'تسجيل الدخول',
      'calculate once': 'احسب مرة واحدة',
      'appliance tips': 'نصائح عامة',

      /// Login Page
      'Login1': 'يرجي ملء جميع الحقول',
      'title dialog': 'خطأ في تسجيل الدخول',
      'middleText dialog': 'يرجى التحقق من بريدك الإلكتروني وكلمة السر مرة اخرى.',
      'ok': 'حسنا',
      'email': 'الإيميل',
      'hint email': 'email@gmail.com',
      'password': 'كلمة السر',
      'hint password': 'كلمة السر لا تقل عن 6 حروف',
      'login2': 'تسجيل',
      'not found email': 'ليس لديك حساب؟',
      'create account': 'أنشئ حساب',
      'or': 'أو',
      'go to homepage': 'اذهب للصفحة الرئيسية',

      /// Sign up
      'complete profile': 'أكمل بياناتك',
      'error': 'خطأ',
      'name': 'الاسم',
      'address': 'العنوان',
      'company name': 'اسم الشركة',
      'save': 'حفظ البيانات',
      'confirm': 'تأكيد',
      'save data': 'هل تريد حفظ البيانات؟',
      'cancel': 'إلغاء',
      'return': 'العودة',

      /// Reading Screen
      'reading': 'إدخال القراءة',
      'old reading': 'القراءة القديمة',
      'new reading': 'القراءة الجديدة',
      'user not login': 'المستخدم غير مسجل الدخول',
      'calculate': 'احسب',
      'reading2': 'ادخل القراءة',

      /// Start Screen
      'electric usage': 'استهلاك الكهرباء',
      'slide': 'الشريحة :',
      'save2': 'تم الحفظ',
      'local':' في السحابة والتخزين المحلي',
      'saved local': 'تم حفظ القراءة محليا',
      'success saved': 'تم حفظ القراءة بنجاح',
      'save reading': 'حفظ القراءة',
      'monthly cost': 'التكلفة الشهرية',
      'EGP': '  جنية ',
      'read old reading': 'شاهد قراءاتك السابقة',
      'alert monthly cost': 'تجاوزت الميزانية الشهرية! التكلفة ',
      'alert cost1': 'قريب من تجاوز الميزانية! التكلفة ',
      'alert cost2': 'تنبيه الميزانية',
      'Budget': 'الميزانية',
      'residual': 'المتبقي',

      /// Tips Screen
      'General advice': 'نصائح عامة',
      'advice': 'استهلاك أقل .. توفير أكبر',
      'advice1': 'افصل الأجهزة بعد الاستخدام',
      'title advice1': 'بعض الأجهزة تستهلك كهرباء حتى وهي مغلقة. افصلها بعد الاستخدام',
      'advice2': 'اضبط التكييف على 25 درجة',
      'title advice2': 'كل درجة أقل من 25 تزيد استهلاك الكهرباء بشكل كبير',
      'advice3': 'استخدم اللمبات الموفّرة LED',
      'title advice3': 'استهلاكها أقل بنسبة 70% من اللمبات العادية',
      'advice4': 'نظّف جوانب الثلاجة',
      'title advice4': 'اتساخ الملفات الخلفية يزيد استهلاك الكهرباء',
      'advice5': 'قلّل من استخدام السخان',
      'title advice5': 'استخدمه وقت الحاجة فقط وبدرجة حرارة متوسطة',
      'advice6': 'استخدم Timer للأجهزة',
      'title advice6': 'لتحديد وقت تشغيل الأجهزة وتقليل الاستهلاك',

      /// Recommendations Screen
      'recommendations': 'اقتراحات للتوفير',
      'review consumption': 'راجع استهلاكك واقتراحات التوفير',
      'refresh': 'تحديث',
      'recalculate recommendations': 'تم إعادة حساب التوصيات',
      'budget exceeded': 'تجاوزت الميزانية الشهرية!',
      'cost': 'التكلفة',
      'budget': 'الميزانية',
      'near budget': 'اقتربت من تجاوز الميزانية',
      'remaining': 'المتبقي',
      'good budget': 'وضع الميزانية ممتاز',
      'keep it': 'استمر على هذا المعدل',
      'manage budget and devices': 'إدارة الميزانية والأجهزة',
      'monthly prediction': 'التوقع الشهري',
      'total expected': 'الإجمالي المتوقع',
      'device suggestions': 'اقتراحات مخصصة للأجهزة',
      'reduce': 'قلل',
      'hour per day': 'ساعة / يوم',
      'my devices': 'أجهزتي المضافة',
      'no devices yet': 'لم تضف أي جهاز حتى الآن',
      'add devices to get recommendations': 'أضف أجهزة لتحصل على توصيات مخصصة',
      'add device now': 'أضف جهاز الآن',
      'more tips': 'المزيد من النصائح',
      'amount': 'كمية',

      /// Appliance Screen
      'add_appliance': 'أضف جهاز جديد',
      'all_devices': 'كل الأجهزة',
      'edit_devices_data': 'أضف أو حدّث بيانات أجهزتك',
      'no_devices': 'لا توجد اجهزة',
      'hours_per_day': 'ساعات/يوم',
      'quantity': 'الكمية',
      'priority': 'الأولوية',
      'important': 'مهم',
      'not_important': 'غير مهم',
      'show_more': 'عرض المزيد',
      'update': 'تحديث',
      'add': 'أضف',
      'updated': 'تم التحديث',
      'updated_success': 'تم تحديث الجهاز بنجاح',
      'added': 'تم الإضافة',
      'added_success': 'تم إضافة الجهاز بنجاح',
      'fill_fields_correct': 'يرجى ملء جميع الحقول بشكل صحيح',
      'add_new_appliance': 'أضف جهاز جديد',
      'device_name': 'اسم الجهاز',
      'brand': 'النوع/الماركة',
      'watt': 'الوات',
      'daily_hours': 'ساعات/يوم',
      'device_quantity': 'الكمية',

      /// Budget & Devices
      "manage devices and budget": "إدارة الميزانية والأجهزة",
      "review budget and devices": "مراجعة الميزانية والأجهزة",
      "login first": "سجل الدخول أولاً",
      "current monthly budget": "الميزانية الشهرية الحالية",
      "enter new budget": "أدخل ميزانية جديدة",
      "save budget": "حفظ الميزانية",
      "budget updated": "تم تحديث الميزانية",
      "enter valid number": "أدخل رقمًا صحيحًا",
      "my added appliances": "أجهزتي المضافة",
      "add new device": "إضافة جهاز جديد",
      "no devices added": "لا توجد أجهزة",
      "(custom)": "(مخصص)",
      "hours/day": "ساعات/يوم",
      "device updated": "تم تحديث الجهاز",

      /// Calculation Once
      "enter_reading": "إدخال القراءة",
      "enter_old_reading": "ادخل القراءة القديمة",
      "enter_new_reading": "ادخل القراءة الجديدة",
      "location": "الموقع",

      /// Result
      'reading result': 'نتيجة الحساب',
      'consumption kwh': 'الاستهلاك ',
      'tier': 'الشريحة',
      'total price': 'السعر النهائي (جنيه)',

      /// Company Screen
      'electricity company': 'شركة الكهرباء',
      'enter area or city': 'أدخل المنطقة أو المحافظة',
      'search company': 'ابحث عن الشركة',
      'no company found': 'لم يتم العثور على شركة',
      'map': 'الخريطة',
      'location search': 'بحث بالموقع',
      'searching': 'جاري البحث...',
      'not found': 'غير موجود',

      /// History Screen
      'history': 'السجل',
      'no history': 'لا يوجد سجل',
      'price': 'السعر : ',
      'pound': 'جنيه',
      'kwh': 'ك.و',
      'date': 'التاريخ',
      'update': 'تحديث',

      /// Bottom Nav
      'home': 'الرئيسية',
      'scan': 'قراءة',
      'budget': 'الميزانية',
      'company location': 'موقع الشركة',
      'tips': 'النصائح',

      /// Profile
      "profile": "الملف الشخصي",
      "created_at": "تاريخ الإنشاء",
      "no_data": "لا توجد بيانات للعرض",
      "address": "العنوان",
      "company_name": "اسم الشركة",
      "no_value": "لا يوجد",
      "logout": "تسجيل الخروج",
      "language": "اللغة",
      "convert": "English",

      "none": "لا يوجد",
      "created at": "تاريخ الإنشاء",


      "first_tier": "الأولى",
      "second_tier": "الثانية",
      "third_tier": "الثالثة",
      "fourth_tier": "الرابعة",
      "fifth_tier": "الخامسة",
      "sixth_tier": "السادسة",
      "seventh_tier": "السابعة",
      'Error saving to Supabase':'فشل الحفظ في الكلاود',

      'history':'السجل',
      'no history': 'لا يوجد سجل حتى الآن',
     'load more': 'عرض المزيد',
  'refresh history': 'تحديث السجل',
  'consumption kwh': 'الاستهلاك',
  'date': 'التاريخ',
      'refresh history':'تم تحديث السجل',
      'refresh':'تحديث',
          'budget_exceeded':'تجاوزت الميزانية'



},

    // ============================================================
    // ========================== English ==========================
    // ============================================================

    'en_US': {

      /// OnBoarding
      'title1': 'Welcome',
      'subtitle1': 'Start your journey with us',
      'title2': 'Learn Easily',
      'subtitle2': 'Access all information easily',
      'title3': 'Get Started',
      'subtitle3': 'Start with our app',
      'Skip': 'Skip',
      'go to home page': 'Go to home page',

      /// HomeScreen
      'Homescreen': 'Home',
      'Login': 'Login',
      'calculate once': 'Calculate Once',
      'appliance tips': 'General Tips',

      /// Login
      'Login1': 'Please fill all fields',
      'title dialog': 'Login Error',
      'middleText dialog': 'Please check your email and password again.',
      'ok': 'OK',
      'email': 'Email',
      'hint email': 'email@gmail.com',
      'password': 'Password',
      'hint password': 'Password must be at least 6 characters',
      'login2': 'Login',
      'not found email': "Don't have an account?",
      'create account': 'Create Account',
      'or': 'or',
      'go to homepage': 'Go to home page',

      /// Signup
      'complete profile': 'Complete your profile',
      'error': 'Error',
      'name': 'Name',
      'address': 'Address',
      'company name': 'Company',
      'save': 'Save Data',
      'confirm': 'Confirm',
      'save data': 'Do you want to save data?',
      'cancel': 'Cancel',
      'return': 'Return',

      /// Reading
      'reading': 'Reading Input',
      'old reading': 'Old Reading',
      'new reading': 'New Reading',
      'user not login': 'User not logged in',
      'calculate': 'Calculate',
      'reading2': 'Enter reading',

      /// Start Screen
      'electric usage': 'Electric Usage',
      'slide': 'Tier : ',
      'save2': 'Saved',
      'saved local': 'Reading saved locally',
      'save reading': 'Save Reading',
      'monthly cost': 'Monthly Cost',
      'EGP': ' EGP ',
      'read old reading': 'View previous readings',
      'alert monthly cost': 'Monthly budget exceeded! Cost: ',
      'alert cost1': 'Close to exceeding your budget! Cost: ',
      'alert cost2': 'Budget Alert',
      'Budget': 'Budget',
      'residual': 'Remaining',

      /// Tips
      'General advice': 'General Advice',
      'advice': 'Less consumption .. More saving',
      'advice1': 'Unplug devices after use',
      'title advice1': 'Some devices consume electricity even when turned off',
      'advice2': 'Set AC to 25°C',
      'title advice2': 'Every degree below 25 increases consumption',
      'advice3': 'Use LED bulbs',
      'title advice3': 'They use 70% less energy than regular bulbs',
      'advice4': 'Clean refrigerator coils',
      'title advice4': 'Dirty coils increase electricity usage',
      'advice5': 'Reduce water heater usage',
      'title advice5': 'Use it only when needed and at medium temperature',
      'advice6': 'Use Timer for appliances',
      'title advice6': 'Set timer to reduce usage',

      /// Recommendations
      'recommendations': 'Save & Tips',
      'review consumption': 'Review your usage and saving suggestions',
      'refresh': 'Refresh',
      'recalculate recommendations': 'Recommendations recalculated',
      'budget exceeded': 'Monthly budget exceeded!',
      'cost': 'Cost',
      'budget': 'Budget',
      'near budget': 'Near budget limit',
      'remaining': 'Remaining',
      'good budget': 'Budget is excellent',
      'keep it': 'Keep it up',
      'manage budget and devices': 'Devices & Budget',
      'monthly prediction': 'Monthly Prediction',
      'total expected': 'Total Expected',
      'device suggestions': 'Device suggestions',
      'reduce': 'Reduce',
      'hour per day': 'Hour per day',
      'my devices': 'My Devices',
      'no devices yet': 'No devices yet',
      'add devices to get recommendations': 'Add devices for personalized suggestions',
      'add device now': 'Add Device Now',
      'more tips': 'More Tips',
      'amount': 'Amount',

      /// Appliances
      'add_appliance': 'Add New Appliance',
      'all_devices': 'All Devices',
      'edit_devices_data': 'Add or Update Your Devices',
      'no_devices': 'No devices',
      'hours_per_day': 'Hours/day',
      'quantity': 'Quantity',
      'priority': 'Priority',
      'important': 'Important',
      'not_important': 'Not Important',
      'show_more': 'Show More',
      'update': 'Update',
      'add': 'Add',
      'updated': 'Updated',
      'updated_success': 'Device updated successfully',
      'added': 'Added',
      'added_success': 'Device added successfully',
      'fill_fields_correct': 'Please fill all fields correctly',
      'add_new_appliance': 'Add New Appliance',
      'device_name': 'Device Name',
      'brand': 'Brand',
      'watt': 'Watt',
      'daily_hours': 'Daily Hours',
      'device_quantity': 'Quantity',

      /// Budget
      "manage devices and budget": "Manage devices and budget",
      "review budget and devices": "Review budget and devices",
      "login first": "Login first",
      "current monthly budget": "Current monthly budget",
      "enter new budget": "Enter new budget",
      "save budget": "Save budget",
      "budget updated": "Budget updated",
      "enter valid number": "Enter a valid number",
      "my added appliances": "My added devices",
      "add new device": "Add new device",
      "no devices added": "No devices added",
      "(custom)": "(custom)",
      "hours/day": "Hours/day",
      "device updated": "Device updated",

      /// Calculation Once
      "enter_reading": "Enter reading",
      "enter_old_reading": "Enter old reading",
      "enter_new_reading": "Enter new reading",
      "location": "Location",

      /// Result
      'reading result': 'Reading Result',
      'consumption kwh': 'Consumption (kWh) :',
      'tier': 'Tier',
      'total price': 'Total Price (EGP)',

      /// Company
      'electricity company': 'Electricity Company',
      'enter area or city': 'Enter area or city',
      'search company': 'Search Company',
      'no company found': 'No company found',
      'map': 'Map',
      'location search': 'Location Search',
      'searching': 'Searching...',
      'not found': 'Not found',

      /// History
      'history': 'History',
      'no history': 'No history available',
      'price': 'Price : ',
      'pound': 'EGP',
      'date': 'Date',
      'update': 'Update',

      /// Bottom Nav
      'home': 'Home',
      'scan': 'Scan',
      'budget': 'Budget',
      'company location': 'Company Location',
      'tips': 'Tips',

      /// Profile
      "profile": "Profile",
      "created_at": "Created At",
      "no_data": "No data available",
      "address": "Address",
      "company_name": "Company Name",
      "no_value": "Not available",
      "logout": "Logout",
      "language": "Language",
      "convert": "عربي",

      "none": "None",
      "created at": "Created At",

      "first_tier": "First ",
      "second_tier": "Second ",
      "third_tier": "Third ",
      "fourth_tier": "Fourth ",
      "fifth_tier": "Fifth ",
      "sixth_tier": "Sixth ",
      "seventh_tier": "Seventh ",

      'local':'in Local Storage',
      'Error saving to Supabase':'Error saving to Supabase',
          'success saved': 'succeed saved',

      'history': 'History',
      'no history': 'No history available',
      'load more': 'Load More',
      'refresh history': 'Refresh History',
      'consumption kwh': 'Consumption (kWh) : ',
      'date': 'Date',
      'refresh history':'refresh history',
          'refresh':'refresh',
      'budget_exceeded':'budget_exceeded'

}
  };
}
