import 'package:flutter/material.dart';
import 'package:movies/screens/AvatarSelectionScreen .dart'; // تأكد من المسار الصحيح
import 'package:movies/screens/forget_password.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfileScreen extends StatefulWidget {
  static const routeName = "update";
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _currentAvatarPath = 'assets/images/avatar.png'; // الصورة الافتراضية

  @override
  void initState() {
    super.initState();
    _loadUserData(); // قم بتحميل بيانات المستخدم عند تهيئة الشاشة
  }

  // دالة لتحميل بيانات المستخدم من SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text =
          prefs.getString('user_name') ?? 'Mahmoud EL3zaZy'; // اسم افتراضي
      _phoneController.text =
          prefs.getString('user_phone') ?? '01200000000'; // رقم افتراضي
      _currentAvatarPath = prefs.getString('user_avatar') ??
          'assets/images/avatar.png'; // مسار افتراضي
    });
  }

  // دالة لحفظ بيانات المستخدم في SharedPreferences
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text);
    await prefs.setString('user_phone', _phoneController.text);
    await prefs.setString('user_avatar', _currentAvatarPath);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // لون الخلفية الداكن
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            // حفظ البيانات قبل العودة
            await _saveUserData();
            // ثم العودة مع البيانات المحدثة
            Navigator.pop(context, {
              'name': _nameController.text,
              'avatarPath': _currentAvatarPath,
            });
          },
        ),
        title: const Text(
          'Pick Avatar', // النص الموجود في الصورة
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // صورة الملف الشخصي (Avatar) القابلة للنقر
            GestureDetector(
              onTap: () async {
                final selectedAvatar = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AvatarSelectionScreen(),
                  ),
                );

                if (selectedAvatar != null) {
                  setState(() {
                    _currentAvatarPath = selectedAvatar;
                  });
                }
              },
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: Image.asset(
                    _currentAvatarPath, // استخدام المسار الحالي للأفاتار
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person,
                          size: 100, color: Colors.grey);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // حقل الاسم
            _buildTextField(
              controller: _nameController,
              hintText:
                  'Mahmoud EL3zaZy', // يمكن إزالة هذا الـ hintText الآن لأنه سيتم ملء الحقل
              icon: Icons.person,
            ),
            const SizedBox(height: 20),

            // حقل رقم الهاتف
            _buildTextField(
              controller: _phoneController,
              hintText: '01200000000', // يمكن إزالة هذا الـ hintText الآن
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 30),

            // زر Reset Password
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  print('Reset Password');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen()),
                  );
                },
                child: const Text(
                  'Reset Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Spacer(), // يدفع الأزرار إلى الأسفل

            // زر Delete Account
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  print('Delete Account');
                  // هنا يمكنك إضافة منطق حذف الحساب (قد تحتاج لتأكيد من المستخدم)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935), // أحمر
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Delete Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // زر Update Data
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // حفظ البيانات قبل العودة
                  await _saveUserData();
                  // ثم العودة مع البيانات المحدثة
                  Navigator.pop(context, {
                    'name': _nameController.text,
                    'avatarPath': _currentAvatarPath,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حفظ التغييرات بنجاح'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDD835), // أصفر
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Update Data',
                  style: TextStyle(
                    color: Colors.black, // نص أسود على زر أصفر
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF333333), // لون خلفية حقل الإدخال
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none, // إزالة الحدود الافتراضية
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
      ),
    );
  }
}
