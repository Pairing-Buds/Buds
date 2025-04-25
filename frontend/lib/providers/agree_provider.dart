import 'package:flutter/material.dart';

class AgreementProvider extends ChangeNotifier {
  bool _allAgreed = false;
  bool _serviceAgreed = false;
  bool _privacyAgreed = false;
  bool _thirdPartyAgreed = false;
  bool _locationAgreed = false;

  bool get allAgreed => _allAgreed;
  bool get serviceAgreed => _serviceAgreed;
  bool get privacyAgreed => _privacyAgreed;
  bool get thirdPartyAgreed => _thirdPartyAgreed;
  bool get locationAgreed => _locationAgreed;

  bool get isAllRequiredAgreed =>
      _serviceAgreed && _privacyAgreed && _thirdPartyAgreed && _locationAgreed;

  void setAllAgreements(bool value) {
    _allAgreed = value;
    _serviceAgreed = value;
    _privacyAgreed = value;
    _thirdPartyAgreed = value;
    _locationAgreed = value;
    notifyListeners();
  }

  void setServiceAgreement(bool value) {
    _serviceAgreed = value;
    _updateAllAgreementState();
    notifyListeners();
  }

  void setPrivacyAgreement(bool value) {
    _privacyAgreed = value;
    _updateAllAgreementState();
    notifyListeners();
  }

  void setThirdPartyAgreement(bool value) {
    _thirdPartyAgreed = value;
    _updateAllAgreementState();
    notifyListeners();
  }

  void setLocationAgreement(bool value) {
    _locationAgreed = value;
    _updateAllAgreementState();
    notifyListeners();
  }

  void _updateAllAgreementState() {
    _allAgreed =
        _serviceAgreed &&
        _privacyAgreed &&
        _thirdPartyAgreed &&
        _locationAgreed;
  }

  void setAgreement(bool value) {
    _allAgreed = value;
    notifyListeners();
  }

  void resetAllAgreements() {
    _allAgreed = false;
    _serviceAgreed = false;
    _privacyAgreed = false;
    _thirdPartyAgreed = false;
    _locationAgreed = false;
    notifyListeners();
  }
}
