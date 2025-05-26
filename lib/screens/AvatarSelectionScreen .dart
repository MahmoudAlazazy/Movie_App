import 'package:flutter/material.dart';

class AvatarSelectionScreen extends StatelessWidget {
  // قائمة بمسارات صور الأفاتار المتاحة
  final List<String> avatars = const [
    'assets/images/gamer(1).png', // أضف مسارات صور الأفاتار هنا
    'assets/images/gamer2.png',
    'assets/images/gamer3.png',
    'assets/images/gamer4.png',
    'assets/images/gamer5.png',
    'assets/images/gamer6.png',
    'assets/images/gamer7.png', // الصورة الجديدة المضافة
    'assets/images/gamer8.png', // الصورة الجديدة المضافة
    'assets/images/gamer9.png', // الصورة الجديدة المضافة
    // أضف المزيد من المسارات هنا حسب عدد صور الأفاتار لديك
  ];

  const AvatarSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // نفس لون الخلفية الداكن
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // للعودة بدون اختيار
          },
        ),
        title: const Text(
          'Pick Avatar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 أعمدة
            crossAxisSpacing: 16.0, // المسافة الأفقية بين العناصر
            mainAxisSpacing: 16.0, // المسافة الرأسية بين العناصر
            childAspectRatio: 1.0, // نسبة العرض إلى الارتفاع لكل عنصر (مربع)
          ),
          itemCount: avatars.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // عند النقر على الصورة، نرجع مسارها إلى الشاشة السابقة
                Navigator.pop(context, avatars[index]);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF333333), // خلفية خفيفة لكل أيقونة
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDD835), width: 2), // حدود صفراء
                ),
                child: ClipOval( // لجعل الصورة دائرية
                  child: Image.asset(
                    avatars[index],
                    fit: BoxFit.cover, // الصورة تملأ المربع وتتجاوز الحدود إذا لزم الأمر
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, size: 50, color: Colors.grey);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}