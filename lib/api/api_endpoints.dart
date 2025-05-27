class APIEndPoints {

  //application dev api base Url
  static String baseUrl = 'https://dev.planetcombo.com/';

  // //application Production api base Url
  // static String baseUrl = 'https://planetcombo.com/';

  ///Social Login
  static String socialLogin = '${baseUrl}api/Profile/login';

  ///Get horoscopes
  static String getHoroscope = '${baseUrl}api/horoscope/get?userId=';

  ///Get pendingPayments
  static String getPendingPayments = '${baseUrl}api/Payments/pending-payments/';

  ///Get horoscopes
  static String checkRequest = '${baseUrl}api/request/ChekckDuplicateRequest?USERID=';

  ///Get horoscopes
  static String getDailyCharge = '${baseUrl}api/Charge/GetDailyChargeHTMLink?TypeRequest=';

  ///Add offline Money
  static String addOfflineMoney = '${baseUrl}api/Invoice/Pay';

  ///Reply Special Prediction
  static String replyPredictionMessage = '${baseUrl}api/Prediction/addMessage';


  ///Pay Payment by Paypal
  static String payByPaypal = '${baseUrl}api/Payments/create-paypal-payment';

  ///endpoint changed to stripe
  static String payByStripe = '${baseUrl}api/Payments/create-stripPay-payment';

  // ///Pay Payment by Upi
  // static String payByUpi = '${baseUrl}api/Payments/create-UpiPay-payment';

  ///Pay Payment by Upi
  static String payByUpi = '${baseUrl}api/Payments/create-payu-payment';

  ///update Message
  static String updateMessage = '${baseUrl}api/messages/updateMessages';

  ///add Message
  static String addMessage = '${baseUrl}api/messages/addMessages';

  ///update Prediction Flag
  static String updateFlag = '${baseUrl}api/Prediction/updatePredictionFLag/';

  ///delete Message
  static String deleteMessages = '${baseUrl}api/messages/deleteMessages?userId=';

  ///delete Profile
  static String deleteProfile = '${baseUrl}api/profile/deleteAppUser?userId=';

  ///get Special Predictions
  static String specialPredictions = '${baseUrl}api/Prediction/GetPredictions/';

  ///get Daily Prediction dates
  static String getDailyPredictionDates = '${baseUrl}api/Prediction/GetPredictionDates/';

  ///get Daily Prediction date details
  static String getDailyPredictionDateDetails = '${baseUrl}api/Prediction/GetPredictionDates/';

  ///get Special Prediction Messages
  static String specialPredictionMessages  = '${baseUrl}api/Prediction/getMessages?PredictionId=';

  ///Get terms and conditions
  static String getTermsAndConditions = '${baseUrl}api/termCondition/TCLinkandCharCharges?userId=';

  ///Get invoice List
  static String getInvoiceList = '${baseUrl}api/Payments/invoice-records?userId=';

  ///Get user wallet balance
  static String getUserWalletBalance = '${baseUrl}api/account/getStatements?userId=';

  ///Get User Messages
  static String getUserMessages = '${baseUrl}api/messages/getMessages?userId=';


  ///Get User All Predictions
  static String getUserAllPredictions = '${baseUrl}api/prediction/GetPredictions/';

  ///Get User Predictions
  static String getUserPredictions = '${baseUrl}api/request/getRequests?userId=';

  ///Delete horoscopes
  static String deleteHoroscope = '${baseUrl}api/horoscope/deleteHoroscope?userId=';


  ///get Promise
  static String getPromises = '${baseUrl}api/promise/getPromises?userId=';

  ///get Planet
  static String getPlanetTransit = '${baseUrl}api/transit/getComment?planet=';

  ///View horoscope chart
  static String viewChart = '${baseUrl}api/horoscope/GetPDFChart?userId=';

  ///Add horoscopes
  static String addNewHoroscope = '${baseUrl}api/horoscope/addNew';

  ///update Profile
  static String updateProfile = '${baseUrl}api/profile/updateProfile';

  ///update Horoscope Profile
  static String updateHoroscopeImage = '${baseUrl}api/Horoscope/updateHoroscopeImage/';


  ///Add New Profile
  static String addProfile = '${baseUrl}api/profile/addProfile';

  ///Payment Status Check
  static String paymentStatusCheck = '${baseUrl}api/Payments/pending-payments-ref-id/';

  ///Update horoscopes
  static String updateHoroscope = '${baseUrl}api/horoscope/updateHoroscope';


  ///Update horoscopes
  static String updatePrediction = '${baseUrl}api/prediction/updatePrediction';


  ///Email Horoscope Chart
  static String emailChart = '${baseUrl}api/hcom/requestHoroPDF';

  ///Add Daily Request
  static String addDailyRequest = '${baseUrl}api/request/addDailyRequest';

  ///Add Special Request
  static String addSpecialRequest = '${baseUrl}api/request/addRequest';

  ///View Count Shop
  static String viewShopCount = '${baseUrl}api/User/ViewShop';


  ///View Promotion
  static String viewPromotionCount = '${baseUrl}api/Promotion/ViewPromotion';


  ///Vendor Register
  static String vendorRegister = '${baseUrl}api/User/RegisterUser';
  ///Vendor Login
  static String vendorLogin = '${baseUrl}api/Authentication/CheckAuthentication?';
  ///Get Vendor Profile
  static String vendorProfile = '${baseUrl}api/User/GetUserById?UserId=';
  ///Get Popular Vendor
  static String popularVendors = '${baseUrl}api/User/GetPopularVendor';
  ///Get Popular Vendor
  static String trendingVendors = '${baseUrl}api/User/GetTrendingVendor';
  ///Get Advertisement
  static String getAdvertisement = '${baseUrl}api/Promotion/GetAdvertisement';
  ///Get Vendor Coupons
  static String vendorCoupons = '${baseUrl}api/Coupon/GetCoupon?UserId=';
  ///Get Vendor Social Media
  static String vendorSocialMedia = '${baseUrl}api/SocialMedia/GetSocialMedia?UserId=';
  ///Get Vendor By Location
  static String vendorByLocation = '${baseUrl}api/User/GetVendorByLocation?Location=';
  ///Get Vendor Counts
  static String vendorCounts = '${baseUrl}api/User/GetDashboard?vendorId=';
  ///Get Vendor Promotion
  static String getVendorPromotion = '${baseUrl}api/Promotion/GetPromotion?UserId=';
  ///Delete Vendor Coupons
  static String deleteVendorCoupon = '${baseUrl}api/Coupon/DeleteCoupon?couponId=';
  ///Get Vendor Membership
  static String getVendorMembership = '${baseUrl}api/User/GetMembership';
  ///Update membership
  static String updateMembership = '${baseUrl}api/User/UpdateMembership';
  ///Update Vendor profile
  static String updateVendorProfile = '${baseUrl}api/User/UpdateUser';
  ///Vendor add coupon
  static String vendorAddCoupon = '${baseUrl}api/Coupon/AddCoupon';
  ///Vendor add social Media
  static String vendorAddSocialMedia = '${baseUrl}api/SocialMedia/AddSocialMedia';
  ///Vendor Show all vendors
  static String showVendorsList = '${baseUrl}api/User/ViewShopDashboardVisitor';
  ///Vendor Show ads vendors
  static String showAdsVendorsList = '${baseUrl}api/Promotion/ViewPromotionDashboardVisitor';
  ///Update add social Media
  static String vendorUpdateSocialMedia = '${baseUrl}api/SocialMedia/UpdateSocialMedia';
  ///Vendor add promotion
  static String vendorAddPromotion = '${baseUrl}api/Promotion/AddPromotion';
  ///Vendor update promotion
  static String vendorUpdatePromotion = '${baseUrl}api/Promotion/UpdatePromotion';
}