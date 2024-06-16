import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hats/constants/routes.dart';
import 'package:hats/helper_loading/loading_screen.dart';
import 'package:hats/services/auth/auth_service.dart';
import 'package:hats/services/auth/bloc/auth_bloc.dart';
import 'package:hats/services/auth/bloc/auth_event.dart';
import 'package:hats/services/auth/bloc/auth_state.dart';
import 'package:hats/services/auth/firebase_auth_provider.dart';
import 'package:hats/view/forgot_password_view.dart';
import 'package:hats/view/loginview.dart';
import 'package:hats/view/registerview.dart';
import 'package:hats/view/note/notes_view.dart';
import 'package:hats/view/note/create_update_notes_view.dart';
import 'dart:developer' as dev;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        debugShowCheckedModeBanner: false,
        title: 'Hats',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BlocProvider<AuthBloc>(
          create: (context)=>AuthBloc(FirebaseAuthProvider()),
          child: const HomePage(),
        ),
        routes: {
          loginRoute: (context)=> const LoginView(),
          registerRoute: (context)=> const RegisterView(),
          homeRoute: (context)=> const HomePage(),
          emailveriRoute: (context)=> const EmailVerification(),
          notesRoute: (context)=> const NotesView(),
          UpdateNoteRoute: (context)=> const CreateUpdateNoteView(),
        },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(AuthEventInitialize());
    return BlocConsumer<AuthBloc,AuthState>(
      listener: (context,state){
        if(state.isLoading){
          LoadingScreen().show(context: context, text: state.loadingText ?? 'Please wait a moment');
        }else{
          LoadingScreen().hide();
        }
      },
      builder: (context,state){
      if(state is AuthStateLoggedIn){
        return const NotesView();
      }else if(state is AuthStateRegistering) {
        return const RegisterView();
      } else if(state is AuthStateForgotPassword){
        return const ForgotPasswordView();
      }else if(state is AuthStateNeedsVerification){
        return const EmailVerification();
      }else if(state is AuthStateLoggedOut){
        return const LoginView();
      }else{
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              strokeWidth: 3, // Adjust the thickness as needed
            ),
          ),
        );
      }
    },);

  }
}