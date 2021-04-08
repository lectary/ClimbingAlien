/// Model class representing the status of data loading operations, i.e. loading remote lectures,
/// and mapping them to the corresponding UI-widgets.
class ModelState {
  Status status;
  String? message;

  ModelState.loading(this.message) : status = Status.loading;

  ModelState.completed() : status = Status.completed;

  ModelState.error(this.message) : status = Status.error;

  @override
  String toString() {
    return 'Response{status: $status, message: $message}';
  }
}

enum Status { loading, completed, error }
