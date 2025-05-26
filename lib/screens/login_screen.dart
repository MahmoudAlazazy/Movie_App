import 'package:flutter/material.dart';
import 'package:movies/screens/forget_password.dart';
import 'package:movies/screens/register.dart';
import 'package:movies/home_screen.dart';

// Define constants for colors and styles
const kBackgroundColor = Color(0xFF1A1A1A);
const kTextFieldColor = Color(0xFF2C2C2C);
const kButtonColor = Color(0xFFFDD835);
var kHintTextStyle = TextStyle(color: Colors.grey[600]);
final kBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: BorderSide.none,
);

class AuthWrapper extends StatelessWidget {
  static const String routeName = "AuthWrapper";

  @override
  Widget build(BuildContext context) {
    // بدون Firebase، هيبقى دايمًا LoginScreen إلا لو حددنا حالة
    return LoginScreen();
  }
}

class LoginScreen extends StatefulWidget {
  static const String routeName = "login";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // دالة تسجيل دخول بسيطة بدون Firebase
  void _signIn() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // محاكاة تسجيل الدخول (بدون Firebase)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تسجيل الدخول بنجاح! جاري التوجيه...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // الانتظار ثواني وبعدين التوجيه لـ MainScreen
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, MainScreen.routeName);
      }
    });

    setState(() => _isLoading = false); // تعطيل الـ loading بعد التوجيه
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                Image.asset('assets/images/rectangle.png', width: 100, height: 100),
                SizedBox(height: 60),
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: kTextFieldColor,
                    hintText: 'البريد الإلكتروني',
                    hintStyle: kHintTextStyle,
                    prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
                    border: kBorder,
                    focusedBorder: kBorder,
                    enabledBorder: kBorder,
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'أدخل البريد الإلكتروني' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: kTextFieldColor,
                    hintText: 'كلمة المرور',
                    hintStyle: kHintTextStyle,
                    prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey[600]),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: kBorder,
                    focusedBorder: kBorder,
                    enabledBorder: kBorder,
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  validator: (value) =>
                      (value?.isEmpty ?? true) || (value?.length ?? 0) < 6
                          ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                          : null,
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, ForgotPasswordScreen.routeName);
                    },
                    child: Text('نسيت كلمة المرور؟', style: TextStyle(color: kButtonColor)),
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.zero,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.black)
                        : Text('تسجيل الدخول',
                            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 20),
                Row(children: [
                  Expanded(child: Divider(color: Colors.grey[700])),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('أو', style: kHintTextStyle)),
                  Expanded(child: Divider(color: Colors.grey[700])),
                ]),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تسجيل الدخول بـ Google غير متاح حاليًا'), backgroundColor: Colors.grey),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.zero,
                    ),
                    icon: Text('G', style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
                    label: Text('تسجيل الدخول بـ Google',
                        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
                      child: Center(child: Text('🇺🇸', style: TextStyle(fontSize: 16))),
                    ),
                    SizedBox(width: 12),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
                      child: Center(child: Text('🇪🇬', style: TextStyle(fontSize: 16))),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ليس لديك حساب؟ ', style: TextStyle(color: Colors.white, fontSize: 16)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, RegisterScreen.routeName),
                      child: Text('إنشاء حساب', style: TextStyle(color: kButtonColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}