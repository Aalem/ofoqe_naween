import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ofoqe_naween/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginUser(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
      // Navigate to main app screen
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (error) {
      // Handle errors (e.g., invalid credentials)
      _showError('error.message');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(FirebaseAuth.instance.currentUser);
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Management'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20.0),
          constraints: BoxConstraints(maxWidth: 300.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 2)],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter your email' : null,
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter your password' : null,
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    if (_formKey.currentState!.validate()) {
                      _loginUser(_emailController.text, _passwordController.text);
                    }
                  },
                  child: Text(_isLoading ? 'Logging In...' : 'Login'),
                ),
                TextButton(
                  onPressed: () {
                    // Handle forgot password logic (navigate to reset flow)
                  },
                  child: Text('Forgot Password?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
