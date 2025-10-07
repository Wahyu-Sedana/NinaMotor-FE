import 'package:bloc/bloc.dart';
import 'package:frontend/cores/utils/injection.dart';
import 'package:frontend/cores/utils/session.dart';
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
    on<RegisterEvent>(_onRegister);
    // on<CheckEmailEvent>(_onCheckEmail);
    on<ResendVerificationEvent>(_onResendVerificationEvent);
    on<VerifyEmailEvent>(_onVerifyEmailEvent);
    on<ForgotPasswordEvent>(_onForgotPasswordEvent);
    on<ResetPasswordEvent>(_onResetPasswordEvent);
  }

  Future<void> _onLogin(
      LoginEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoginLoading());

    final result = await authenticationUsecaseImpl.callLogin(
        event.email, event.password, event.fcmToken, event.phoneId);
    final session = locator<Session>();
    result.fold((error) => emit(AuthenticationLoginError(failure: error)),
        (data) {
      session.setIdUser = data.user.id;
      session.setEmail = data.user.email;
      session.setUsername = data.user.name;
      emit(AuthenticationLoginSuccess(authenticationModelLogin: data));
    });
  }

  Future<void> _onRegister(
      RegisterEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationRegisterLoading());

    final result = await authenticationUsecaseImpl.callRegister(
        event.name, event.email, event.password, event.cPassword);

    result.fold((error) => emit(AuthenticationRegisterError(failure: error)),
        (data) {
      emit(AuthenticationRegisterSuccess(authenticationModelRegister: data));
    });
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

  // Future<void> _onCheckEmail(
  //     CheckEmailEvent event, Emitter<AuthenticationState> emit) async {
  //   emit(AuthenticationCheckEmailLoading());

  //   final result = await authenticationUsecaseImpl.checkUserEmaill(event.email);
  //   final session = locator<Session>();
  //   result.fold((error) => emit(AuthenticationCheckEmailError(failure: error)),
  //       (data) {
  //     session.setEmail = data.user.email;
  //     emit(AuthenticationCheckEmailSuccess(authenticationModelEmail: data));
  //   });
  // }

  Future<void> _onResendVerificationEvent(
    ResendVerificationEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(ResendVerificationLoading());

    final result =
        await authenticationUsecaseImpl.resendVerification(event.email);

    result.fold(
      (failure) => emit(ResendVerificationError(failure: failure)),
      (message) => emit(ResendVerificationSuccess(message: message)),
    );
  }

  Future<void> _onVerifyEmailEvent(
    VerifyEmailEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(VerifyEmailLoading());

    final result = await authenticationUsecaseImpl.verifyEmail(event.token);

    result.fold(
      (failure) => emit(VerifyEmailError(failure: failure)),
      (message) => emit(VerifyEmailSuccess(message: message)),
    );
  }

  Future<void> _onForgotPasswordEvent(
    ForgotPasswordEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(ForgotPasswordLoading());

    final result = await authenticationUsecaseImpl.forgotPassword(event.email);

    result.fold(
      (failure) => emit(ForgotPasswordError(failure: failure)),
      (message) => emit(ForgotPasswordSuccess(message: message)),
    );
  }

  Future<void> _onResetPasswordEvent(
    ResetPasswordEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(ResetPasswordLoading());

    final result = await authenticationUsecaseImpl.resetPasswordWithToken(
      token: event.token,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
    );

    result.fold(
      (failure) => emit(ResetPasswordError(failure: failure)),
      (message) => emit(ResetPasswordSuccess(message: message)),
    );
  }
}
