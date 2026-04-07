import '../providers/language_provider.dart';

class AppStrings {
  AppStrings(this.language);

  final AppLanguage language;

  bool get isEnglish => language == AppLanguage.en;

  String get languageEnglish => isEnglish ? 'English' : 'Англиски';
  String get languageMacedonian => isEnglish ? 'Macedonian' : 'Македонски';

  String get loginTitle => isEnglish ? 'Login' : 'Најава';
  String get createAccountTitle => isEnglish ? 'Create Account' : 'Креирај сметка';
  String get emailLabel => isEnglish ? 'Email' : 'Е-пошта';
  String get passwordLabel => isEnglish ? 'Password' : 'Лозинка';
  String get confirmPasswordLabel => isEnglish ? 'Confirm Password' : 'Потврди лозинка';
  String get appTitle => isEnglish ? 'MDT Inventory' : 'MDT Инвентар';
  String get addDeviceTitle => isEnglish ? 'Add device' : 'Додај уред';
  String get addDeviceButton => isEnglish ? 'Add Device' : 'Додај уред';
  String get addNewDeviceTitle => isEnglish ? 'Add New Device' : 'Додај нов уред';
  String get editDeviceTitle => isEnglish ? 'Edit Device' : 'Измени уред';
  String get deleteDeviceTitle => isEnglish ? 'Delete Device' : 'Избриши уред';
  String get deleteDeviceConfirm => isEnglish
      ? 'Are you sure you want to delete this device?'
      : 'Дали сте сигурни дека сакате да го избришете овој уред?';
  String get cancel => isEnglish ? 'Cancel' : 'Откажи';
  String get continueLabel => isEnglish ? 'Continue' : 'Продолжи';
  String get confirm => isEnglish ? 'Confirm' : 'Потврди';
  String get scanQr => isEnglish ? 'Scan QR' : 'Скенирај QR';
  String get scanQrTitle => isEnglish ? 'Scan QR Code' : 'Скенирај QR код';
  String get reports => isEnglish ? 'Reports' : 'Извештаи';
  String get reportsAndStats => isEnglish ? 'Reports & Stats' : 'Извештаи и статистики';
  String get notifications => isEnglish ? 'Notifications' : 'Известувања';
  String get adminLogs => isEnglish ? 'Admin Logs' : 'Админ логови';
  String get userRoles => isEnglish ? 'User Roles' : 'Улоги на корисници';
  String get deviceIdLabel => isEnglish ? 'Device ID' : 'ID на уред';
  String get deviceIdHint => isEnglish ? 'e.g. LAP-101' : 'пр. LAP-101';
  String get deviceIdRequired =>
      isEnglish ? 'Device ID is required' : 'Потребен е ID на уред';
  String get noDevicesFound => isEnglish
      ? 'No devices found. Scan a QR code or add one manually.'
      : 'Нема пронајдени уреди. Скенирајте QR код или додадете рачно.';
  String get noDevicesFoundShort =>
      isEnglish ? 'No devices found.' : 'Нема пронајдени уреди.';
  String get errorPrefix => isEnglish ? 'Error' : 'Грешка';
  String get adminAccessRequired =>
      isEnglish ? 'Admin access required.' : 'Потребен е админ пристап.';
  String get helpAssistantTitle =>
      isEnglish ? 'AI Assistant' : 'AI Помошник';
  String get aiAssistantTitle =>
      isEnglish ? 'AI Assistant' : 'AI Помошник';
  String get aiAssistantButton =>
      isEnglish ? 'Ask AI' : 'Прашај AI';
  String get aiAssistantInputHint => isEnglish
      ? 'Describe your problem...'
      : 'Опишете го проблемот...';
  String get aiAssistantEmptyState => isEnglish
      ? 'Ask a question about device issues and get quick tips.'
      : 'Поставете прашање за проблем со уреди и добијте брзи совети.';
  String get aiAssistantThinking =>
      isEnglish ? 'Thinking...' : 'Размислувам...';
  String get aiAssistantErrorPrefix => isEnglish
      ? 'AI request failed'
      : 'AI барањето не успеа';
  String get aiAssistantMissingKey => isEnglish
      ? 'Add your Gemini API key in the app code to use AI.'
      : 'Додадете го Gemini API клучот во кодот за да користите AI.';
  String get onlyStaffCanReport =>
      isEnglish ? 'Only staff can report issues.' : 'Само вработени можат да пријават проблеми.';
  String get reportIssue => isEnglish ? 'Report Issue' : 'Пријави проблем';
  String get issuesTitle => isEnglish ? 'Issues' : 'Проблеми';
  String get issueDescriptionLabel =>
      isEnglish ? 'Issue Description' : 'Опис на проблем';
  String get issueDescriptionHint =>
      isEnglish ? 'Describe the problem...' : 'Опишете го проблемот...';
  String get locationLabel => isEnglish ? 'Location' : 'Локација';
  String get locationHint => isEnglish ? 'Device location' : 'Локација на уред';
  String get submitReport => isEnglish ? 'Submit Report' : 'Поднеси пријава';
  String get reportDescriptionRequired =>
      isEnglish ? 'Please enter a description' : 'Внесете опис';
  String get reportLocationRequired =>
      isEnglish ? 'Please confirm the location' : 'Потврдете ја локацијата';
  String get reportSuccess =>
      isEnglish ? 'Issue reported successfully!' : 'Проблемот е пријавен успешно!';
  String get reportFailedPrefix =>
      isEnglish ? 'Failed to report issue' : 'Неуспешно пријавување на проблем';
  String get signInRequiredNotifications => isEnglish
      ? 'Please sign in to view notifications.'
      : 'Најавете се за да ги видите известувањата.';
  String get noNotificationsYet =>
      isEnglish ? 'No notifications yet.' : 'Нема известувања.';
  String get noLogsYet => isEnglish ? 'No logs yet.' : 'Нема логови.';
  String get noUsersFound => isEnglish ? 'No users found.' : 'Нема корисници.';
  String get unknown => isEnglish ? 'Unknown' : 'Непознато';
  String get changeRoleTitle => isEnglish ? 'Change role' : 'Промени улога';
  String get setRolePrompt => isEnglish ? 'Set' : 'Постави';
  String get saveDevice => isEnglish ? 'Save Device' : 'Зачувај уред';
  String get updateDevice => isEnglish ? 'Update Device' : 'Ажурирај уред';
  String get deviceSavedSuccess => isEnglish
      ? 'Device saved successfully!'
      : 'Уредот е успешно зачуван!';
  String get deviceSaveFailedPrefix =>
      isEnglish ? 'Failed to save device' : 'Неуспешно зачувување на уред';
  String get nameDescriptionLabel =>
      isEnglish ? 'Name / Description' : 'Име / Опис';
  String get typeCategoryLabel =>
      isEnglish ? 'Type / Category' : 'Тип / Категорија';
  String get brandLabel => isEnglish ? 'Brand' : 'Бренд';
  String get modelLabel => isEnglish ? 'Model' : 'Модел';
  String get locationOfficeLabel =>
      isEnglish ? 'Location / Office' : 'Локација / Канцеларија';
  String get assignedToLabel => isEnglish ? 'Assigned To' : 'Доделено на';
  String get conditionLabel => isEnglish ? 'Condition' : 'Состојба';
  String get notesLabel => isEnglish ? 'Notes' : 'Забелешки';
  String get requiredField => isEnglish ? 'Required' : 'Задолжително';
  String get readOnlyNote => isEnglish ? '(Read-only)' : '(Само за читање)';
  String get exportBy => isEnglish ? 'Export by:' : 'Извези по:';
  String get exportAll => isEnglish ? 'All' : 'Сите';
  String get exportFieldStatus => isEnglish ? 'Status' : 'Состојба';
  String get exportFieldLocation => isEnglish ? 'Location' : 'Локација';
  String get exportFieldType => isEnglish ? 'Type' : 'Тип';
  String get tabByStatus => isEnglish ? 'By Status' : 'По состојба';
  String get tabByLocation => isEnglish ? 'By Location' : 'По локација';
  String get tabByType => isEnglish ? 'By Type' : 'По тип';
  String get unspecified => isEnglish ? 'Unspecified' : 'Ненаведено';
  String get inventoryReport => isEnglish ? 'Inventory report' : 'Извештај за инвентар';
  String get scanInstruction => isEnglish
      ? 'Scan a QR code containing the device ID (e.g. LAP-101).'
      : 'Скенирајте QR код со ID на уред (пр. LAP-101).';
  String get invalidQrCode => isEnglish
      ? 'Invalid QR code. Use a device ID like LAP-101 (no /).'
      : 'Невалиден QR код. Користете ID како LAP-101 (без /).';
  String get lookupFailedPrefix =>
      isEnglish ? 'Lookup failed' : 'Неуспешно пребарување';
  String get cameraPermissionDenied => isEnglish
      ? 'Camera permission denied. Enable it in Settings > mdt > Camera, then reopen the scanner.'
      : 'Нема дозвола за камера. Вклучете ја во Settings > mdt > Camera, па повторно отворете скенерот.';
  String cameraError(String detail) =>
      isEnglish ? 'Camera error: $detail' : 'Грешка со камера: $detail';
  String get addDeviceToIssue =>
      isEnglish ? 'Add New Device' : 'Додај нов уред';
  String get deviceDetailsTitle => isEnglish ? 'Device Details' : 'Детали за уред';
  String get deviceNotFound => isEnglish ? 'Device Not Found' : 'Уредот не е пронајден';
  String get idLabel => isEnglish ? 'ID' : 'ID';
  String get typeLabel => isEnglish ? 'Type' : 'Тип';
  String get brandModelLabel => isEnglish ? 'Brand/Model' : 'Бренд/Модел';
  String get statusLabel => isEnglish ? 'Status' : 'Состојба';
  String get delete => isEnglish ? 'Delete' : 'Избриши';
  String get reportIssueButton => isEnglish ? 'Report Issue' : 'Пријави проблем';
  String get assignToTechnician => isEnglish ? 'Assign to Technician' : 'Додели техничар';
  String get technicianLabel =>
      isEnglish ? 'Technician Name/Email' : 'Име/е-пошта на техничар';
  String get technicianHint => isEnglish ? 'Enter technician name' : 'Внесете име на техничар';
  String get assign => isEnglish ? 'Assign' : 'Додели';
  String get adminAccessReport => isEnglish ? 'Admin access required.' : 'Потребен е админ пристап.';
  String get addDeviceReportTitle => isEnglish ? 'Add device' : 'Додај уред';
  String get addDeviceReportContinue => isEnglish ? 'Continue' : 'Продолжи';
  String get addDeviceReportCancel => isEnglish ? 'Cancel' : 'Откажи';
  String get issuesEmpty => isEnglish ? 'No issues reported.' : 'Нема пријавени проблеми.';
  String get issueReportedTitle =>
      isEnglish ? 'New issue reported' : 'Пријавен нов проблем';
  String issueReportedMessage(String deviceId, String description) => isEnglish
      ? 'Device $deviceId reported: $description'
      : 'Уред $deviceId пријавен: $description';
  String get issueUpdatedTitle =>
      isEnglish ? 'Issue updated' : 'Проблемот е ажуриран';
  String issueUpdatedMessage(String deviceId, String status) => isEnglish
      ? 'Issue for device $deviceId is now $status.'
      : 'Проблемот за уред $deviceId е сега $status.';
  String get issueAssignedTitle =>
      isEnglish ? 'Issue assigned' : 'Проблемот е доделен';
  String issueAssignedMessage(String issueId, String deviceId) => isEnglish
      ? 'You have been assigned issue $issueId for device $deviceId.'
      : 'Ви е доделен проблем $issueId за уред $deviceId.';

  String statusValueLabel(String status) {
    switch (status) {
      case 'New':
        return isEnglish ? 'New' : 'Ново';
      case 'Good':
        return isEnglish ? 'Good' : 'Добро';
      case 'Broken':
        return isEnglish ? 'Broken' : 'Расипано';
      case 'In Repair':
        return isEnglish ? 'In Repair' : 'Во поправка';
      default:
        return status;
    }
  }

  String issueStatusLabel(String status) {
    switch (status) {
      case 'Pending':
        return isEnglish ? 'Pending' : 'Во чекање';
      case 'In Progress':
        return isEnglish ? 'In Progress' : 'Во тек';
      case 'Fixed':
        return isEnglish ? 'Fixed' : 'Поправено';
      default:
        return status;
    }
  }

  String typeValueLabel(String type) {
    switch (type) {
      case 'Laptop':
        return isEnglish ? 'Laptop' : 'Лаптоп';
      case 'Printer':
        return isEnglish ? 'Printer' : 'Печатач';
      case 'Monitor':
        return isEnglish ? 'Monitor' : 'Монитор';
      case 'Tool':
        return isEnglish ? 'Tool' : 'Алат';
      case 'Phone':
        return isEnglish ? 'Phone' : 'Телефон';
      case 'Tablet':
        return isEnglish ? 'Tablet' : 'Таблет';
      case 'Other':
        return isEnglish ? 'Other' : 'Друго';
      default:
        return type;
    }
  }

  String roleValueLabel(String role) {
    switch (role) {
      case 'admin':
        return isEnglish ? 'Admin' : 'Админ';
      case 'staff':
        return isEnglish ? 'Staff' : 'Вработен';
      case 'viewer':
        return isEnglish ? 'Viewer' : 'Преглед';
      default:
        return role;
    }
  }

  String logActionLabel(String action) {
    switch (action) {
      case 'device_created':
        return isEnglish ? 'device created' : 'уред креиран';
      case 'device_updated':
        return isEnglish ? 'device updated' : 'уред ажуриран';
      case 'device_deleted':
        return isEnglish ? 'device deleted' : 'уред избришан';
      case 'issue_reported':
        return isEnglish ? 'issue reported' : 'пријавен проблем';
      case 'issue_status_updated':
        return isEnglish ? 'issue status updated' : 'ажурирана состојба на проблем';
      case 'user_role_updated':
        return isEnglish ? 'user role updated' : 'ажурирана улога на корисник';
      default:
        return action.replaceAll('_', ' ');
    }
  }

  String entityLabel(String entityType) {
    switch (entityType) {
      case 'device':
        return isEnglish ? 'Device' : 'Уред';
      case 'issue':
        return isEnglish ? 'Issue' : 'Проблем';
      case 'user':
        return isEnglish ? 'User' : 'Корисник';
      default:
        return entityType;
    }
  }

  String get logEntityLabel => isEnglish ? 'Entity' : 'Ентитет';
  String get logActorLabel => isEnglish ? 'Actor' : 'Извршител';
  String get onlyMdtEmailNote => isEnglish
      ? 'Only @mdt.gov.mk emails can create an account.'
      : 'Само е-пошта со @mdt.gov.mk може да креира сметка.';
  String get passwordsDoNotMatch =>
      isEnglish ? 'Passwords do not match' : 'Лозинките не се совпаѓаат';
  String get loginFailedUnknown =>
      isEnglish ? 'Login failed: unknown error' : 'Најавата не успеа: непозната грешка';
  String get signInCta =>
      isEnglish ? 'Have an account? Sign in' : 'Имате сметка? Најавете се';
  String get signUpCta =>
      isEnglish ? 'Create an account' : 'Креирај сметка';
  String get forgotPassword =>
      isEnglish ? 'Forgot password?' : 'Ја заборавивте лозинката?';
  String get resetPassword =>
      isEnglish ? 'Reset password' : 'Ресетирај лозинка';
  String get resetPasswordHint => isEnglish
      ? 'Enter your email to receive a reset link.'
      : 'Внесете ја е-поштата за да добиете линк за ресет.';
  String get resetPasswordSent => isEnglish
      ? 'Password reset email sent.'
      : 'Испратена е е-пошта за ресет.';
  String get resetPasswordFailedPrefix => isEnglish
      ? 'Password reset failed'
      : 'Ресетирањето не успеа';

  String loginFailed(String detail) => isEnglish
      ? 'Login failed: $detail'
      : 'Најавата не успеа: $detail';
}
