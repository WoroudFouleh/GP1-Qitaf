import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_page/screens/groupChat.dart';

class CreateGroupScreen extends StatefulWidget {
  final String userId;

  const CreateGroupScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final List<String> _selectedMembers = [];
  String searchQuery = '';

// البحث عن المستخدمين مع استثناء المستخدم الحالي
  Future<List<DocumentSnapshot>> _searchUsers(String query) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    // تصفية النتائج لاستبعاد المستخدم الحالي
    return snapshot.docs.where((doc) => doc.id != widget.userId).toList();
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.isEmpty || _selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى ملء اسم الجروب واختيار الأعضاء.")),
      );
      return;
    }

    try {
      // بيانات الجروب
      final groupData = {
        'name': _groupNameController.text,
        'members': _selectedMembers,
        'createdBy': widget.userId,
        'createdAt': Timestamp.now(),
      };

      // إضافة الجروب إلى Firestore
      DocumentReference groupDoc =
          await FirebaseFirestore.instance.collection('groups').add(groupData);

      // الحصول على الـ groupId
      final groupId = groupDoc.id;

      // الانتقال إلى شاشة الدردشة الخاصة بالجروب
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChatScreen(
            currentUserId: widget.userId, // معرّف المستخدم الحالي
            groupId: groupId, // معرّف الجروب
            groupName: _groupNameController.text, // اسم الجروب
            members: _selectedMembers, // قائمة معرفات الأعضاء
            createdBy: widget.userId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء إنشاء الجروب: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إنشاء جروب',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(15, 99, 43, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _createGroup,
          ),
        ],
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _groupNameController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'اسم الجروب',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'البحث عن الأعضاء',
                  prefixIcon: const Icon(Icons.search,
                      color: const Color.fromRGBO(15, 99, 43, 1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<DocumentSnapshot>>(
                  future: _searchUsers(searchQuery),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'لا توجد نتائج.',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var user = snapshot.data![index];
                        var name = user['name'];
                        var familyName = user['familyName'];
                        var userId = user.id;

                        return CheckboxListTile(
                          title: Text(
                            '$name $familyName',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 16),
                          ),
                          value: _selectedMembers.contains(userId),
                          onChanged: (bool? isSelected) {
                            setState(() {
                              if (isSelected == true) {
                                _selectedMembers.add(userId);
                              } else {
                                _selectedMembers.remove(userId);
                              }
                            });
                          },
                          activeColor: const Color.fromRGBO(15, 99, 43, 1),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
