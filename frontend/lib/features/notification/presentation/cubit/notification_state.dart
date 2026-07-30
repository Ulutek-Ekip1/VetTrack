import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

//Ilk durum
class NotificationInitial extends NotificationState {}

//Yukleniyor durumu
class NotificationLoading extends NotificationState {}

//Basarili sekilde yuklendi
class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;

  const NotificationLoaded(this.notifications);

  @override
  List<Object> get props => [notifications];
}

//Hata durumu
class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object> get props => [message];
}

//Token basari ile kaydedildi
class DeviceTokenRegistered extends NotificationState {}
