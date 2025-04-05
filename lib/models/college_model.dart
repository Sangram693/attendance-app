class CollegeModel {
  College college;

  CollegeModel({required this.college});

  factory CollegeModel.fromJson(Map<String, dynamic> json) {
    return CollegeModel(
      college: College.fromJson(json['college']),
    );
  }
}

class College {
  String id;
  String code;
  String name;
  List<CourseStream> streams;
  String collegeId;
  int addedAt;
  int v;

  College({
    required this.id,
    required this.code,
    required this.name,
    required this.streams,
    required this.collegeId,
    required this.addedAt,
    required this.v,
  });

  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      id: json['_id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      streams: (json['streams'] as List?)?.map((e) => CourseStream.fromJson(e)).toList() ?? [],
      collegeId: json['college_id'] ?? '',
      addedAt: json['added_at'] ?? 0,
      v: json['__v'] ?? 0,
    );
  }
}

class CourseStream {
  String streamId;
  String name;
  List<Department> departments;
  String id;

  CourseStream({
    required this.streamId,
    required this.name,
    required this.departments,
    required this.id,
  });

  factory CourseStream.fromJson(Map<String, dynamic> json) {
    return CourseStream(
      streamId: json['stream_id'] ?? '',
      name: json['name'] ?? '',
      departments: (json['departments'] as List?)?.map((e) => Department.fromJson(e)).toList() ?? [],
      id: json['_id'] ?? '',
    );
  }
}

class Department {
  String deptId;
  String name;
  String id;
  List<Semester> semesters;

  Department({
    required this.deptId,
    required this.name,
    required this.id,
    required this.semesters,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      deptId: json['dept_id'] ?? '',
      name: json['name'] ?? '',
      id: json['_id'] ?? '',
      semesters: (json['semesters'] as List?)?.map((e) => Semester.fromJson(e)).toList() ?? [],
    );
  }
}

class Semester {
  String semId;
  String name;
  String id;

  Semester({
    required this.semId,
    required this.name,
    required this.id,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      semId: json['sem_id'] ?? '',
      name: json['name'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}
