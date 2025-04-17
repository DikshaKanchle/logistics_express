import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logistics_express/src/custom_widgets/custom_dialog.dart';
import 'package:logistics_express/src/custom_widgets/custom_dropdown.dart';
import 'package:logistics_express/src/custom_widgets/custom_loader.dart';
import 'package:logistics_express/src/features/screens/delivery_agent/agent_dashboard/requested_ride.dart';
import 'package:logistics_express/src/models/specific_request_model.dart';
import 'package:logistics_express/src/models/specific_ride_model.dart';
import 'package:logistics_express/src/services/user_services.dart';
import 'package:logistics_express/src/utils/firebase_exceptions.dart';
import 'package:logistics_express/src/utils/theme.dart';
import 'package:logistics_express/src/utils/validators.dart';
import '../../../../utils/new_text_field.dart';

class RideInformationSR extends ConsumerStatefulWidget {
  final Map<String, dynamic> ride;
  final String source;
  final String destination;

  const RideInformationSR({
    super.key,
    required this.ride,
    required this.source,
    required this.destination,
  });

  @override
  ConsumerState<RideInformationSR> createState() => _RideInformationSRState();
}

class _RideInformationSRState extends ConsumerState<RideInformationSR> {
  String? _selectedType;
  TextEditingController weightController = TextEditingController();
  TextEditingController volumeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> sendRequest() async {
    setState(() => _isLoading = true);
    try {
      SpecificRequestModel delivery = SpecificRequestModel(
        agentName: widget.ride['Name'],
        agentPhoneNo: widget.ride['Phone'],
        source: widget.source,
        destination: widget.destination,
        startDate: widget.ride['StartDate'],
        endDate: widget.ride['EndDate'],
        weight: weightController.text.trim(),
        volume: volumeController.text.trim(),
        itemType: _selectedType!,
        vehicleType: widget.ride['VehicleType'],
      );

      User? user = FirebaseAuth.instance.currentUser;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(user!.uid)
          .get();

      String name = '', phone = '';
      if (userDoc.exists) {
        name = userDoc['Name'] ?? '';
        phone = userDoc['Phone'] ?? '';
      }

      SpecificRideModel newRide = SpecificRideModel(
        customerName: name,
        customerPhoneNo: phone,
        source: widget.source,
        destination: widget.destination,
        startDate: widget.ride['StartDate'],
        endDate: widget.ride['EndDate'],
        weight: weightController.text.trim(),
        volume: volumeController.text.trim(),
        itemType: _selectedType!,
      );

      final userServices = UserServices();
      await userServices.specificRequestedDelivery(delivery);
      await userServices.publishSpecificRide(newRide, widget.ride["AgentId"]);

      if (mounted) {
        showSuccessSnackBar(context, "Request sent successfully!");
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        showErrorSnackBar(context, 'Error: ${error.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Are you sure?',
          message: 'Do you want to send the request?',
          onConfirm: () {
            Navigator.pop(context);
            sendRequest();
          },
        );
      },
    );
  }

  void showRequestBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Text("Enter Package Details",
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 15),
                NewTextField(
                  label: 'Weight',
                  hintText: 'Enter weight in Kg',
                  keyboardType: TextInputType.number,
                  controller: weightController,
                  validator: (val) => Validators.quantityValidator(val),
                ),
                const SizedBox(height: 10),
                NewTextField(
                  label: 'Volume',
                  hintText: 'Enter volume in cm\u00B3',
                  keyboardType: TextInputType.number,
                  controller: volumeController,
                  validator: (val) => Validators.quantityValidator(val),
                ),
                const SizedBox(height: 10),
                CustomDropdown(
                  label: "Item Type",
                  items: [
                    'Furniture',
                    'Electronics',
                    'Clothes & Accessories',
                    'Glass & Fragile Items',
                    'Food & Medicine'
                  ],
                  value: _selectedType,
                  onChanged: (value) => setState(() => _selectedType = value),
                  validator: (val) => Validators.commonValidator(val),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      showConfirmationDialog();
                    }
                  },
                  child: const Text("Submit"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text("Ride Details")),
          backgroundColor: theme.cardColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(4.0),
            child: AbsorbPointer(
              absorbing: _isLoading,
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: theme.colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomSectionTitle(title: "Current Ride Details"),
                          CustomInfoRow(
                            icon: FontAwesomeIcons.locationDot,
                            text: "From: ${widget.ride['Source']}",
                          ),
                          CustomInfoRow(
                            icon: FontAwesomeIcons.mapPin,
                            text: "To: ${widget.ride['Destination']}",
                          ),
                          CustomInfoRow(
                            icon: FontAwesomeIcons.calendarDays,
                            text: "Start Date: ${widget.ride['StartDate']}",
                          ),
                          CustomInfoRow(
                            icon: FontAwesomeIcons.calendarDays,
                            text: "End Date: ${widget.ride['EndDate']}",
                          ),
                          const Divider(thickness: 1, height: 20),
                          CustomSectionTitle(title: "Delivery Agent Details"),
                          CustomInfoRow(
                            icon: FontAwesomeIcons.user,
                            text: "Name: ${widget.ride['Name']}",
                          ),
                          CustomInfoRow(
                            icon: FontAwesomeIcons.phone,
                            text: "Phone: ${widget.ride['Phone']}",
                          ),
                          CustomInfoRow(
                            icon: FontAwesomeIcons.truck,
                            text: "Vehicle Type: ${widget.ride['VehicleType']}",
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: showRequestBottomSheet,
                      child: const Text('Send request'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CustomLoader(),
              ),
            ),
          ),
      ],
    );
  }
}
