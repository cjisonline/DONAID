class Organization {
  String? organizationEmail;
  String organizationName;
  String? password;
  String? phoneNumber;
  String uid;
  String? organizationDescription;
  String? country;
  String? gatewayLink;

  Organization({
    this.organizationEmail,
    required this.organizationName,
    this.password,
    this.phoneNumber,
    required this.uid,
    this.organizationDescription,
    this.country,
    this.gatewayLink
  });
}