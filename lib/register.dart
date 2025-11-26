import 'package:automaticmb/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

final Dio _dio = Dio();
const String baseurl = "http://192.168.1.144:5000"; // 🔹 Update this

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _classList = [];
int? _selectedClass; // Stores dropdown value
bool _loadingClasses = true;

  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _admissionController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _loading = false;


  Future<void> _fetchClasses() async {
  try {
    final response = await _dio.get("$baseurl/ViewClassrooms");
    print(response.data);
    if (response.statusCode == 200) {
      setState(() {
        _classList = List<Map<String, dynamic>>.from(response.data);
        _loadingClasses = false;
      });
    } else {
      throw Exception("Failed to load class list");
    }
  } catch (e) {
    setState(() => _loadingClasses = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error loading classes: $e")),
    );
  }
}
 Future<void> _fetchDepartment() async {
  try {
    final response = await _dio.get("$baseurl/ViewDepartment");
    print(response.data);
    if (response.statusCode == 200) {
      setState(() {
        _classList = List<Map<String, dynamic>>.from(response.data);
        _loadingClasses = false;
      });
    } else {
      throw Exception("Failed to load class list");
    }
  } catch (e) {
    setState(() => _loadingClasses = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error loading classes: $e")),
    );
  }
}
@override
void initState() {
  super.initState();
  _fetchClasses();
  _fetchDepartment();
  
}

  Future<void> _registerStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final Map<String, dynamic> data = {
      "username": _usernameController.text.trim(),
      "password": _passwordController.text.trim(),
      "name": _nameController.text.trim(),
      "admission_no": _admissionController.text.trim(),
      "department": _departmentController.text.trim(),
      "class_name": _selectedClass,
      "semester": _semesterController.text.trim(),
      "email_id": _emailController.text.trim(),
      "phone_no": _phoneController.text.trim(),
    };

    try {
      final response = await _dio.post("$baseurl/studentreg_api/", data: data);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Registration successful!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Loginscreen()),
        );
        _clearFields();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error: ${response.statusMessage}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on DioError catch (e) {
      final message = e.response?.data.toString() ?? e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Failed: $message"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _clearFields() {
    _usernameController.clear();
    _passwordController.clear();
    _nameController.clear();
    _admissionController.clear();
    _departmentController.clear();
    _classController.clear();
    _semesterController.clear();
    _emailController.clear();
    _phoneController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          'Student Registration',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Create Student Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 25),

                  _buildTextField(
                    _usernameController,
                    "Username",
                    Icons.person,
                    "Enter username",
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    _passwordController,
                    "Password",
                    Icons.lock,
                    "Enter password",
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    _nameController,
                    "Name",
                    Icons.badge,
                    "Enter full name",
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    _admissionController,
                    "Admission No",
                    Icons.school,
                    "Enter admission no",
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    _departmentController,
                    "Department",
                    Icons.apartment,
                    "Enter department",
                  ),
                  const SizedBox(height: 15),
                  _loadingClasses
    ? const Center(child: CircularProgressIndicator())
    : DropdownButtonFormField<int>(
  value: _selectedClass,
  items: _classList.map((classItem) {
    return DropdownMenuItem<int>(
      value: classItem["id"] as int,
      child: Text(classItem["ClassName"]),
    );
  }).toList(),
  decoration: InputDecoration(
    labelText: "Class",
    prefixIcon: const Icon(Icons.class_),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  validator: (value) => value == null ? "Please select a class" : null,
  onChanged: (value) {
    setState(() {
      _selectedClass = value;
    });
  },
),


                  const SizedBox(height: 15),
                  _buildTextField(
                    _semesterController,
                    "Semester",
                    Icons.schedule,
                    "Enter semester",
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    _emailController,
                    "Email",
                    Icons.email,
                    "Enter email",
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    _phoneController,
                    "Phone No",
                    Icons.phone,
                    "Enter phone number",
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _registerStudent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    String hint, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }
}
