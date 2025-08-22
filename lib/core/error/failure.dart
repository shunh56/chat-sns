abstract class Failure {
  final String message;
  final String code;
  final StackTrace? stackTrace;

  const Failure({
    required this.message,
    required this.code,
    this.stackTrace,
  });

  List<Object?> get props => [message, code];
}

class PopupFailure extends Failure {
  const PopupFailure({
    required super.message,
    required super.code,
    super.stackTrace,
  });

  factory PopupFailure.unknown(
      {required String message, StackTrace? stackTrace}) {
    return PopupFailure(
      message: message,
      code: 'POPUP_UNKNOWN_ERROR',
      stackTrace: stackTrace,
    );
  }

  factory PopupFailure.retrievalError(
      {required String message, StackTrace? stackTrace}) {
    return PopupFailure(
      message: message,
      code: 'POPUP_RETRIEVAL_ERROR',
      stackTrace: stackTrace,
    );
  }

  factory PopupFailure.displayError(
      {required String message, StackTrace? stackTrace}) {
    return PopupFailure(
      message: message,
      code: 'POPUP_DISPLAY_ERROR',
      stackTrace: stackTrace,
    );
  }

  factory PopupFailure.storageError(
      {required String message, StackTrace? stackTrace}) {
    return PopupFailure(
      message: message,
      code: 'POPUP_STORAGE_ERROR',
      stackTrace: stackTrace,
    );
  }

  factory PopupFailure.userDataError(
      {required String message, StackTrace? stackTrace}) {
    return PopupFailure(
      message: message,
      code: 'POPUP_USER_DATA_ERROR',
      stackTrace: stackTrace,
    );
  }

  factory PopupFailure.firestoreError(
      {required String message, StackTrace? stackTrace}) {
    return PopupFailure(
      message: message,
      code: 'POPUP_FIRESTORE_ERROR',
      stackTrace: stackTrace,
    );
  }
}
