class Donor {
  String email;
  String firstName;
  String lastName;
  String phoneNumber;
  String id;

  Donor(this.email, this.firstName, this.lastName, this.phoneNumber, this.id);
  Donor.c1()
      :email="",
      firstName="",
  lastName="",
  phoneNumber="",
  id="";

}