bool validateEmail(String email) {
  String pattern = r'^[^@]+@[^@]+\.[^@]+$';
  RegExp regex = RegExp(pattern);
  return regex.hasMatch(email);
}

bool validatePassword(String password) {
  return password.length >= 6;
}
