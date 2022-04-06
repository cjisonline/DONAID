import 'dart:math';
// EXCLUDE_FROM_GALLERY_DOCS_END
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class HorizontalBarLabelChart extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool animate;
  static var f = NumberFormat("###,##0.00", "en_US");

  HorizontalBarLabelChart(this.seriesList, {this.animate = false});

  static List<charts.Series<CharityTypeDonations, String>> _arrangeData(urgentCaseDonations, beneficiaryDonations, campaignDonations) {
    final data = [
      new CharityTypeDonations('Beneficiaries', urgentCaseDonations),
      new CharityTypeDonations('Urgent Cases', beneficiaryDonations),
      new CharityTypeDonations('Campaigns', campaignDonations),
    ];

    return [
      new charts.Series<CharityTypeDonations, String>(
          id: 'Donations',
          domainFn: (CharityTypeDonations donations, _) => donations.charityType,
          measureFn: (CharityTypeDonations donations, _) => donations.donationAmount,
          data: data,
          // Set a label accessor to control the text of the bar label.
          labelAccessorFn: (CharityTypeDonations donations, _) =>
          '${donations.charityType}: \$${f.format(donations.donationAmount)}')
    ];
  }

  /// Creates a [BarChart] with sample data and no transition.
  factory HorizontalBarLabelChart.withData(urgentCaseDonations, beneficiaryDonations, campaignDonations) {
    return new HorizontalBarLabelChart(
      _arrangeData(urgentCaseDonations, beneficiaryDonations, campaignDonations),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      vertical: false,
      // Set a bar label decorator.
      // Example configuring different styles for inside/outside:
      //       barRendererDecorator: new charts.BarLabelDecorator(
      //          insideLabelStyleSpec: new charts.TextStyleSpec(...),
      //          outsideLabelStyleSpec: new charts.TextStyleSpec(...)),
      barRendererDecorator: new charts.BarLabelDecorator<String>(),
      // Hide domain axis.
      domainAxis:
      new charts.OrdinalAxisSpec(renderSpec: new charts.NoneRenderSpec()),
    );
  }
}

/// Sample ordinal data type.
class CharityTypeDonations {
  final String charityType;
  final double donationAmount;

  CharityTypeDonations(this.charityType, this.donationAmount);
}
