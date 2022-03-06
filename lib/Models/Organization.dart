
class Organization {
  String? organizationEmail;
  String organizationName;
  String? phoneNumber;
  String uid;
  String? organizationDescription;
  String? country;
  String? gatewayLink;
  String? id;
  String? profilePictureDownloadURL;

  Organization({
    this.organizationEmail,
    required this.organizationName,
    this.phoneNumber,
    required this.uid,
    this.organizationDescription,
    this.country,
    this.gatewayLink,
    this.id,
    this.profilePictureDownloadURL
  });
  Organization.c1()
      :organizationEmail="",
        organizationName="",
        phoneNumber="",
        uid="",
        organizationDescription="",
        country="",
        gatewayLink="",
        id="",
        profilePictureDownloadURL=""
  ;
}