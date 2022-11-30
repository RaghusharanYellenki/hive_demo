import 'package:hive/hive.dart';

part 'person.g.dart';

@HiveType(typeId: 1)
class Person {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String phonenumber;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String dob;

  @HiveField(4)
  final String id;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final String imageUrl;


  Person({
    required this.name,
    required this.phonenumber,
    required this.email,
    required this.dob,
    required this.id,
    required this.status,
    required this.imageUrl,
  });
}
