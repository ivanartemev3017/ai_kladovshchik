import 'package:flutter/material.dart';
import '../widgets/background_wrapper.dart'; // не забудь создать этот файл
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // если хочешь переводы

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent, // обязательно!
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.appTitle),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/storages');
            },
            child: Text(AppLocalizations.of(context)!.goToStorages),
          ),
        ),
      ),
    );
  }
}
