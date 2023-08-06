class user_model {
  int? id;
  String? salary_per_day;
  String? Name;
  String? email;
  String? phone_with_code;
  String? country;
  String? phone;
  String? city;
  int? ctc;
  int? salary;
  int? employee_id;
  int? company_id;
  int? department;
  int? present_days;
  int? status;
  int? working_days;
  String? image;
  String? working_start_time;
  List<MediaFiles>? mediaFiles;

  user_model({
    this.id,
    this.Name,
    this.email,
    this.phone_with_code,
    this.country,
    this.phone,
    this.city,
    this.ctc,
    this.salary,
    this.present_days,
    this.employee_id,
    this.company_id,
    this.department,
    this.status,
    this.working_days,
    this.image,
    this.working_start_time,
    this.salary_per_day,
    this.mediaFiles,
  });

  user_model.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    Name = json['name'];
    email = json['email'];
    phone_with_code = json['phone_with_code'];
    country = json['country'];
    phone = json['phone'];
    city = json['city'];
    ctc = json['ctc'];
    salary = json['salary'];
    employee_id = json['employee_id'];
    company_id = json['company_id'];
    department = json['department'];
    status = json['status'];
    working_days = json['working_days'];
    image = json['image'];
    working_start_time = json['working_start_time'];
    present_days = json['present_days'];
    salary_per_day = json['salary_per_day'].toString();
    if (json['media_files'] != null) {
      mediaFiles = <MediaFiles>[];
      json['media_files'].forEach((v) {
        mediaFiles!.add(new MediaFiles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['f_name'] = this.Name;
    data['email'] = this.email;
    data['phone_with_code'] = this.phone_with_code;
    data['country'] = this.country;
    data['phone'] = this.phone;
    data['city'] = this.city;
    data['ctc'] = this.ctc;
    data['salary'] = this.salary;
    data['employee_id'] = this.employee_id;
    data['company_id'] = this.company_id;
    data['department'] = this.department;
    data['status'] = this.status;
    data['working_days'] = this.working_days;
    data['image'] = this.image;
    data['working_start_time'] = this.working_start_time;
    data['present_days'] = this.present_days;
    data['salary_per_day'] = this.salary_per_day;
    if (this.mediaFiles != null) {
      data['media_files'] = this.mediaFiles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MediaFiles {
  int? id;
  int? companyId;
  int? employeeId;
  String? media;
  String? createdAt;
  String? updatedAt;

  MediaFiles(
      {this.id,
      this.companyId,
      this.employeeId,
      this.media,
      this.createdAt,
      this.updatedAt});

  MediaFiles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyId = json['company_id'];
    employeeId = json['employee_id'];
    media = json['media'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['company_id'] = this.companyId;
    data['employee_id'] = this.employeeId;
    data['media'] = this.media;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
