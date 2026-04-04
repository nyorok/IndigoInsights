import 'dart:js_interop';

@JS('pwaInstallAvailable')
external bool pwaInstallAvailable();

@JS('pwaIsInstalled')
external bool pwaIsInstalled();

@JS('pwaTriggerInstall')
external void pwaTriggerInstall();
