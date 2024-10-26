import 'package:flutter/material.dart';
import 'package:pinq/widgets/shiny_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                child: Text(
                  'pinq',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 70,
                      ),
                ),
              ),
              Card(
                color: Color.fromARGB(255, 255, 221, 0),
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          style: Theme.of(context).textTheme.titleMedium,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(fontSize: 20),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                        ),
                        TextFormField(
                          style: Theme.of(context).textTheme.titleMedium,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(fontSize: 20),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        ShinyButton(
                          
                          onPressed: () {},
                          text: _isLogin ? 'Login' : 'Signup',
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(_isLogin
                              ? 'Create an account'
                              : 'I already have an account.'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
