import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage operation failed']);
}

class GameplayFailure extends Failure {
  const GameplayFailure([super.message = 'Gameplay state error occurred']);
}
