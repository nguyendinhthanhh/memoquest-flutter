class Validators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value, 'Email');
    if (requiredError != null) {
      return requiredError;
    }

    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(value!.trim())) {
      return 'Email format is invalid';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = requiredField(value, 'Password');
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? noteTitle(String? value) {
    final requiredError = requiredField(value, 'Title');
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    return null;
  }

  static String? noteContent(String? value) {
    final requiredError = requiredField(value, 'Content');
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.trim().length < 10) {
      return 'Content must be at least 10 characters';
    }
    return null;
  }

  static String? subject(String? value) {
    return requiredField(value, 'Subject');
  }

  static String? flashcardQuestion(String? value) {
    final requiredError = requiredField(value, 'Question');
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.trim().length < 3) {
      return 'Question must be at least 3 characters';
    }
    return null;
  }

  static String? flashcardAnswer(String? value) {
    return requiredField(value, 'Answer');
  }

  static String? difficulty(String? value) {
    final requiredError = requiredField(value, 'Difficulty');
    if (requiredError != null) {
      return requiredError;
    }
    const allowed = {'hard', 'medium', 'easy'};
    if (!allowed.contains(value!.trim().toLowerCase())) {
      return 'Difficulty must be Hard, Medium, or Easy';
    }
    return null;
  }
}
