// activity_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/forms/activity_form_data.dart';
import '../../domain/models/activitys/activitys_model.dart';
import '../../domain/services/activitys_services/activitys_services.dart';

class ActivityProvider extends StateNotifier<ActivityState> {
  final ActivityService _activityService;

  ActivityProvider(this._activityService) : super(ActivityState());

  Future<void> loadActivities(int cropId) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final activities = await _activityService.getActivitiesByCrop(cropId);
      state = state.copyWith(
        activities: activities,
        isLoading: false,
        errorMessage: '',
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
        activities: [],
      );
    }
  }

  Future<bool> registerActivity(int cropId, ActivityFormData formData) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      final activity = formData.toActivity(cropId: cropId);
      final inputs = formData.inputs
          .map((inputForm) => inputForm.toInputUsed())
          .toList();

      final response = await _activityService.registerActivity(
        cropId,
        activity,
        inputs,
      );

      if (response.success) {
        await loadActivities(cropId);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message,
        );
        return false;
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: '');
  }
}

class ActivityState {
  final List<Activity> activities;
  final bool isLoading;
  final String errorMessage;

  ActivityState({
    this.activities = const [],
    this.isLoading = false,
    this.errorMessage = '',
  });

  ActivityState copyWith({
    List<Activity>? activities,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ActivityState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Provider global
final activityProvider = StateNotifierProvider<ActivityProvider, ActivityState>(
      (ref) {
    final activityService = ActivityService();
    return ActivityProvider(activityService);
  },
);