class Donor {
  String email;
  String firstName;
  String lastName;
  String password;
  String phoneNumber;

  Donor(this.email, this.firstName, this.lastName, this.password, this.phoneNumber);
  Donor.c1()
      :email="",
      firstName="",
  lastName="",
  password="",
  phoneNumber=""
    ;

}