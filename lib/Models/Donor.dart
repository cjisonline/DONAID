class Donor {
  String email;
  String firstName;
  String lastName;
  String phoneNumber;
  String id;

  Donor({required this.email, required this.firstName, required this.lastName, required this.phoneNumber, required this.id});
  Donor.c1()
      :email="",
      firstName="",
  lastName="",
  phoneNumber="",
  id="";

}