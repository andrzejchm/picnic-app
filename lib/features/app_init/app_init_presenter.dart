import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:picnic_app/constants/constants.dart';
import 'package:picnic_app/core/domain/model/private_profile.dart';
import 'package:picnic_app/core/domain/repositories/local_storage_repository.dart';
import 'package:picnic_app/core/domain/stores/user_store.dart';
import 'package:picnic_app/core/domain/use_cases/app_init_use_case.dart';
import 'package:picnic_app/core/domain/use_cases/get_should_show_circles_selection_use_case.dart';
import 'package:picnic_app/core/utils/bloc_extensions.dart';
import 'package:picnic_app/core/utils/either_extensions.dart';
import 'package:picnic_app/core/utils/mvp_extensions.dart';
import 'package:picnic_app/features/app_init/app_init_navigator.dart';
import 'package:picnic_app/features/app_init/app_init_presentation_model.dart';
import 'package:picnic_app/features/force_update/domain/use_case/should_show_force_update_use_case.dart';
import 'package:picnic_app/features/force_update/force_update_initial_params.dart';
import 'package:picnic_app/features/main/main_initial_params.dart';
import 'package:picnic_app/features/onboarding/circles_picker/onboarding_circles_picker_initial_params.dart';
import 'package:picnic_app/features/onboarding/domain/model/onboarding_form_data.dart';
import 'package:picnic_app/features/onboarding/onboarding_initial_params.dart';
import 'package:picnic_app/features/profile/domain/use_cases/get_private_profile_use_case.dart';
import 'package:picnic_app/features/user_agreement/domain/use_cases/accept_apps_terms_use_case.dart';
import 'package:picnic_app/features/user_agreement/domain/use_cases/has_user_agreed_to_apps_terms_use_case.dart';

class AppInitPresenter extends Cubit<AppInitViewModel> with SubscriptionsMixin {
  AppInitPresenter(
    AppInitPresentationModel model,
    this.navigator,
    this.appInitUseCase,
    this.shouldShowForceUpdateUseCase,
    this.hasUserAgreedToAppsTermsUseCase,
    this.acceptAppsTermsUseCase,
    this._getPrivateProfileUseCase,
    this._getShouldShowCirclesSelectionUseCase,
    this._userStore,
    this._localStorageRepository,
  ) : super(model) {
    listenTo<PrivateProfile>(
      stream: _userStore.stream,
      subscriptionId: _userStoreSubscription,
      onChange: (user) {
        tryEmit(_model.copyWith(user: user));
      },
    );
  }

  final HasUserAgreedToAppsTermsUseCase hasUserAgreedToAppsTermsUseCase;
  final AcceptAppsTermsUseCase acceptAppsTermsUseCase;
  final ShouldShowForceUpdateUseCase shouldShowForceUpdateUseCase;
  final AppInitNavigator navigator;
  final AppInitUseCase appInitUseCase;
  final UserStore _userStore;
  final LocalStorageRepository _localStorageRepository;
  final GetPrivateProfileUseCase _getPrivateProfileUseCase;
  final GetShouldShowCirclesSelectionUseCase _getShouldShowCirclesSelectionUseCase;

  static const _userStoreSubscription = "userStoreSubscription";

  AppInitPresentationModel get _model => state as AppInitPresentationModel;

  Future<void> onInit() async {
    final shouldShowForceUpdate = await shouldShowForceUpdateUseCase.execute();
    if (shouldShowForceUpdate) {
      await navigator.openForceUpdate(
        const ForceUpdateInitialParams(),
      );
    } else {
      await _executeInitUseCase();
    }
  }

  Future<void> onLogoAnimationEnd() async {
    if (_model.appInitResult.status == FutureStatus.fulfilled) {
      await _onAppInitSuccess();
    }
  }

  Future<void> _executeInitUseCase() async {
    await appInitUseCase
        .execute() //
        .observeStatusChanges((result) => tryEmit(_model.copyWith(appInitResult: result)))
        .doOn(
          fail: (fail) => navigator.showError(
            fail.displayableFailure(),
          ),
        );
  }

  Future<void> _onAppInitSuccess() async {
    if (_model.isUserLoggedIn) {
      await _navigateBasedOnUserAgreement();
    } else {
      await navigator.openOnboarding(const OnboardingInitialParams());
    }
  }

  Future<void> _navigateBasedOnUserAgreement() async {
    final userAgreedToTerms = await hasUserAgreedToAppsTermsUseCase.execute().asyncFold(
          (fail) => false,
          (agreed) => agreed,
        );
    if (userAgreedToTerms) {
      _checkForCirclesSelection();
    } else {
      await navigator.openUserAgreementBottomSheet(
        onTapTerms: () => navigator.openUrl(Constants.termsUrl),
        onTapPolicies: () => navigator.openUrl(Constants.policiesUrl),
        onTapAccept: () {
          acceptAppsTermsUseCase.execute();
          navigator.openMain(const MainInitialParams());
        },
      );
    }
  }

  void _checkForCirclesSelection() {
    _getShouldShowCirclesSelectionUseCase.execute().doOn(
          success: (shouldShow) async {
            if (shouldShow) {
              await _navigateToOnboardingCirclesSelection();
            } else if (_model.user.agePending) {
              _checkForProfileOutdated();
            } else {
              await _navigateToMain();
            }
          },
          fail: (_) => _navigateToMain(),
        );
  }

  //check if user profile is outdated. Let's request an update from the backend and check if the age is still pending
  void _checkForProfileOutdated() {
    _getPrivateProfileUseCase.execute().doOn(
          success: (profile) async {
            await _saveUserInfo(profile);
            if (profile.agePending) {
              await navigator.openOnboarding(const OnboardingInitialParams());
            } else {
              await _navigateToMain();
            }
          },
          fail: (_) => _navigateToMain(),
        );
  }

  Future<void> _saveUserInfo(PrivateProfile user) async {
    _userStore.privateProfile = user;
    await _localStorageRepository.saveCurrentUser(user: user);
  }

  Future<void> _navigateToMain() async {
    await navigator.openMain(const MainInitialParams());
  }

  Future<void> _navigateToOnboardingCirclesSelection() async {
    await navigator.openOnBoardingCirclesPickerPage(
      OnBoardingCirclesPickerInitialParams(
        onCirclesSelected: _handleOnCirclesSelected,
        formData: const OnboardingFormData.empty(),
      ),
    );
  }

  void _handleOnCirclesSelected(circles) {
    navigator.close();
    _navigateToMain();
  }
}
