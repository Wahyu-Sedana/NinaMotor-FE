import 'package:bloc/bloc.dart';
import 'package:frontend/features/authentication/domain/usecases/authentication_usecase.dart';
import 'package:frontend/features/authentication/presentations/bloc/event/authentication_event.dart';
import 'package:frontend/features/authentication/presentations/bloc/state/authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationUsecaseImpl authenticationUsecaseImpl;

  AuthenticationBloc({required this.authenticationUsecaseImpl})
      : super(AuthenticationLoginInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(
      LoginEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoginLoading());

    final result =
        await authenticationUsecaseImpl.callLogin(event.email, event.password);

    result.fold(
      (error) => emit(AuthenticationLoginError(failure: error)),
      (data) =>
          emit(AuthenticationLoginSuccess(authenticationModelLogin: data)),
    );
  }

  Future<void> _onLogout(
      LogoutEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLogoutLoading());

    final result = await authenticationUsecaseImpl.callLogout();

    result.fold(
      (error) => emit(AuthenticationLogoutError(failure: error)),
      (data) => emit(AuthenticationLogoutSuccess()),
    );
  }
}
