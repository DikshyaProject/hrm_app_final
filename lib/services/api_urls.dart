class ApiUrls {
  static const baseUrl =
      'https://developer.bluediamondresearch.com/beamorg/api/';

  static const String login_with_phone = baseUrl + 'get-otp';
  static const String verify_otp = baseUrl + 'verify-otp';
  static const String get_user_data = baseUrl + 'get-employee';
  static const String login_with_email = baseUrl + 'login';
  static const String forget_password = baseUrl + 'forget-password';
  static const String get_company_policy = baseUrl + 'company-policy';
  static const String edit_profile = baseUrl + 'edit-profile';
  static const String get_holidays_list = baseUrl + 'get-holidays-list';
  static const String get_all_my_leaves = baseUrl + 'get-all-my-leaves';
  static const String get_leaves_count = baseUrl + 'get-leaves-count';
  static const String add_leave_request = baseUrl + 'add-leave-request';
  static const String edit_leave_request = baseUrl + 'edit-leave-request';
  static const String delete_my_leave = baseUrl + 'delete-my-leave';
  static const String get_notification = baseUrl + 'get-notification';
  static const String interval = baseUrl + 'interval';
  static const String get_my_task = baseUrl + 'get-my-task';
  static const String get_completed_task = baseUrl + 'get-completed-task';
  static const String get_punchin_out_eligible =
      baseUrl + 'get-punchin-out-eligible';
  static const String punch = baseUrl + 'punch';
  static const String start_end_task = baseUrl + 'start-end-task';
  static const String get_my_attendance = baseUrl + 'get-my-attendance';
  static const String get_employee_list = baseUrl + 'get-employee-list';
  static const String add_new_task = baseUrl + 'add-new-task';
  static const String get_task_detail = baseUrl + 'get-task-by-id';
  static const String get_announcement_detail =
      baseUrl + 'get-announcement-by-id';
  static const String get_all_projects = baseUrl + 'get-all-projects';
  static const String get_project_by_id = baseUrl + 'get-project-by-id';
}
