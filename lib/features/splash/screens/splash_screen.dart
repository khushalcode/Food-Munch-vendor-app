import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart_store/features/rental_module/chat/screens/taxi_chat_screen.dart';
import 'package:sixam_mart_store/features/rental_module/profile/controllers/taxi_profile_controller.dart';
import 'package:sixam_mart_store/features/rental_module/trips/screens/trip_details_screen.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/app_constants.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  const SplashScreen({super.key, required this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isConnected = result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile);

      if(!firstTime) {
        isConnected ? ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar() : const SizedBox();
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6000),
          content: Text(isConnected ? 'connected'.tr : 'no_connection'.tr, textAlign: TextAlign.center),
        ));
        if(isConnected) {
          _route();
        }
      }

      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    _route();

  }

  @override
  void dispose() {
    super.dispose();

    _onConnectivityChanged?.cancel();
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((isSuccess) async {
      if (isSuccess) {
        Timer(const Duration(seconds: 1), () async {
          double? minimumVersion = _getMinimumVersion();
          bool isMaintenanceMode = Get.find<SplashController>().configModel!.maintenanceMode!;
          bool needsUpdate = AppConstants.appVersion < minimumVersion!;
          bool inMaintenanceForApp = isMaintenanceMode && Get.find<SplashController>().configModel!.maintenanceModeData!.maintenanceSystemSetup!.contains('vendor_app');

          if (needsUpdate || inMaintenanceForApp) {
            Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
            return;
          }

          if(widget.body != null) {
            await _handleNotificationRouting(widget.body);
          }else{
            await _handleDefaultRouting();
          }
        });
      }
    });
  }

  double? _getMinimumVersion() {
    if (GetPlatform.isAndroid) {
      return Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
    } else if (GetPlatform.isIOS) {
      return Get.find<SplashController>().configModel!.appMinimumVersionIos;
    }
    return 0;
  }

  Future<void> _handleNotificationRouting(NotificationBodyModel? notificationBody) async {
    final notificationType = notificationBody?.notificationType;
    
    final Map<NotificationType, Function> notificationActions = {
      NotificationType.order: () {
        if(Get.find<AuthController>().getModuleType() == 'rental'){
          Get.to(()=> TripDetailsScreen(tripId: notificationBody!.orderId!, fromNotification: true));
        }else{
          Get.toNamed(RouteHelper.getOrderDetailsRoute(notificationBody?.orderId, fromNotification: true));
        }
      },
      NotificationType.advertisement: () => Get.toNamed(RouteHelper.getAdvertisementDetailsScreen(advertisementId: notificationBody?.advertisementId, fromNotification: true)),
      NotificationType.block: () => Get.offAllNamed(RouteHelper.getSignInRoute()),
      NotificationType.unblock: () => Get.offAllNamed(RouteHelper.getSignInRoute()),
      NotificationType.withdraw: () => Get.to(const DashboardScreen(pageIndex: 3)),
      NotificationType.campaign: () => Get.toNamed(RouteHelper.getCampaignDetailsRoute(id: notificationBody?.campaignId, fromNotification: true)),
      NotificationType.message: () {
        if(Get.find<AuthController>().getModuleType() == 'rental'){
          Get.to(()=> TaxiChatScreen(notificationBody: notificationBody, conversationId: notificationBody?.conversationId, fromNotification: true));
        }else{
          Get.toNamed(RouteHelper.getChatRoute(notificationBody: notificationBody, conversationId: notificationBody?.conversationId, fromNotification: true));
        }
      },
      NotificationType.subscription: () async{
        if (Get.find<SplashController>().configModel == null) {
          await Get.find<SplashController>().getConfigData(closeRoute: true);
        }
        if (Get.find<ProfileController>().profileModel == null) {
          await Get.find<ProfileController>().getProfile();
        }
        return Get.toNamed(RouteHelper.getMySubscriptionRoute(fromNotification: true));
      },
      NotificationType.product_approve: () => Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
      NotificationType.product_rejected: () => Get.toNamed(RouteHelper.getPendingItemRoute(fromNotification: true)),
      NotificationType.general: () => Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true)),
    };

    notificationActions[notificationType]?.call();
  }

  Future<void> _handleDefaultRouting() async {
    if (Get.find<AuthController>().isLoggedIn()) {
      await Get.find<AuthController>().updateToken();
      Get.find<AuthController>().getModuleType() == 'rental' ? await Get.find<TaxiProfileController>().getProfile() : await Get.find<ProfileController>().getProfile();
      Get.offNamed(RouteHelper.getInitialRoute());
    } else {
      final bool showIntro = Get.find<SplashController>().showIntro();
      if(AppConstants.languages.length > 1 && showIntro) {
        Get.offNamed(RouteHelper.getLanguageRoute('splash'));
      }else {
        Get.offNamed(RouteHelper.getSignInRoute());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: GetBuilder<SplashController>(builder: (splashController) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF5F7F8), Color(0xFFEFF4F1)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.85, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                    child: Container(
                      width: 130, height: 130,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(65),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1F2937).withValues(alpha: 0.30),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.restaurant_menu, color: Color(0xFF7ED321), size: 64),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('FOOD MUNCH',
                    style: TextStyle(fontFamily: 'Roboto', fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1F2937), letterSpacing: 2.0)),
                  const SizedBox(height: 8),
                  const Text('RESTAURANT PARTNER',
                    style: TextStyle(fontFamily: 'Roboto', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF5BB819), letterSpacing: 3.0)),
                  const SizedBox(height: 64),
                  const SizedBox(width: 28, height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5BB819)))),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
