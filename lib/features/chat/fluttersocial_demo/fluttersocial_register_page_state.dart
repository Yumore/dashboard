import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_home_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_palette.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_register_page.dart';
import 'package:flutter/material.dart';

/// Port of the source sign-up screen (source `lib/views/register.dart`).
///
/// Like the source, the four fields have no `validator` and the `Form` key is
/// never validated, so CREATE ACCOUNT always continues. The gender choice is
/// the only real form state in the source and is kept working.
class FlutterSocialRegisterPageState extends State<FlutterSocialRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  int _genderRadioBtnVal = -1;

  void _handleGenderChange(int? value) {
    if (value == null) return;
    setState(() {
      _genderRadioBtnVal = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final appBar = Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ],
      ),
    );

    const pageTitle = Text(
      'Tell us about you.',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 40.0,
      ),
    );

    const formFieldSpacing = SizedBox(height: 30.0);

    final registerForm = Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _buildFormField('Name', Icons.person_outline),
            formFieldSpacing,
            _buildFormField('Email Address', Icons.mail_outline),
            formFieldSpacing,
            _buildFormField('Phone Number', Icons.phone_iphone),
            formFieldSpacing,
            _buildFormField('Password', Icons.lock_outline),
            formFieldSpacing,
          ],
        ),
      ),
    );

    final gender = RadioGroup<int>(
      groupValue: _genderRadioBtnVal,
      onChanged: _handleGenderChange,
      child: const Row(
        children: <Widget>[
          Radio<int>(value: 0),
          Text('Male'),
          Radio<int>(value: 1),
          Text('Female'),
          Radio<int>(value: 2),
          Text('Other'),
        ],
      ),
    );

    final submitBtn = Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
        margin: const EdgeInsets.only(top: 10.0, bottom: 20.0),
        height: 60.0,
        width: size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.0),
          border: Border.all(color: Colors.white),
        ),
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const FlutterSocialHomePage(),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: FlutterSocialPalette.primaryColor,
            foregroundColor: Colors.white,
            elevation: 10.0,
            shadowColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.0),
            ),
          ),
          child: const Text(
            'CREATE ACCOUNT',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 40.0),
          child: Column(
            children: <Widget>[
              appBar,
              Container(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    pageTitle,
                    registerForm,
                    gender,
                    submitBtn,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(String label, IconData icon) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: Icon(icon, color: Colors.black38),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black38),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
      keyboardType: TextInputType.text,
      style: const TextStyle(color: Colors.black),
      cursorColor: Colors.black,
    );
  }
}
