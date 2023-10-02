import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//global variable
final _firebase = FirebaseAuth.instance; // firebase nesnesine erişim saglar

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  final _formKey = GlobalKey<FormState>();
 

  var _isLogin = true;

  var enteredEmail = "";
  var enteredPassword = "";

  File? _selectedImage;
  var _isAuthenticating = false;

  var enteredUsername = "";

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || !_isLogin ) {
      return;
    }
    _formKey.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
      
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
        
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child("${userCredentials.user!.uid}.jpg");

        await storageRef.putFile(_selectedImage!);
        final imageURl = await storageRef.getDownloadURL();

        //vt
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredentials.user!.uid)
            .set({
          "username": enteredUsername,
          "email": enteredEmail,
          "password": enteredPassword,
          "image_url": imageURl,
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == "Bu eposta adresi zaten kayıtlı.") {
        //...
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).clearSnackBars();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? "Authentication failed."),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).colorScheme.primary, //sayfanın ana rengi
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
                width: 200,
                child: Image.asset("assets/images/chat.png"),
              ), //alt alta widgetlar
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),
                          TextFormField(
                            decoration:
                                const InputDecoration(hintText: "Email"),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !value.contains("@")) {
                                return "Geçersiz email adresi.";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enteredEmail = value!;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(hintText: "Şifre"),
                            obscureText: true, // sifreyi gizlemek icin
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return "Şifre en az 6 karakter olmalıdır.";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enteredPassword = value!;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                  hintText: "Kullanıcı Adı"),
                              enableSuggestions: false,
                              //store the username
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length < 4) {
                                  return "Lütfen geçerli bir kullanıcı adı girin (En az 4 karakter)";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                enteredUsername = value!;
                              },
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              child: Text(_isLogin ? "Giriş Yap" : "Kayıt Ol"),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? "Yeni Hesap Oluştur"
                                  : "Zaten bir hesabım var. Giriş Yap"),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ), //inputlar tutulacak
        ),
      ),
    );
  }
}
