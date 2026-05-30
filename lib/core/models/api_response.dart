enum LoadingState {
  initial,
  loading,
  success,
  error,
}

extension LoadingStateExtension on LoadingState {
  bool get isInitial => this == LoadingState.initial;
  bool get isLoading => this == LoadingState.loading;
  bool get isSuccess => this == LoadingState.success;
  bool get isError => this == LoadingState.error;
}

class ApiResponse<T> {
  final T? data;
  final String? error;
  final LoadingState state;

  ApiResponse({
    this.data,
    this.error,
    required this.state,
  });

  factory ApiResponse.initial() {
    return ApiResponse(state: LoadingState.initial);
  }

  factory ApiResponse.loading() {
    return ApiResponse(state: LoadingState.loading);
  }

  factory ApiResponse.success(T data) {
    return ApiResponse(data: data, state: LoadingState.success);
  }

  factory ApiResponse.error(String error) {
    return ApiResponse(error: error, state: LoadingState.error);
  }
}


