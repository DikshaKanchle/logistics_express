import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logistics_express/src/custom_widgets/custom_dialog.dart';
import 'package:logistics_express/src/features/subscreens/address_field/address_filled.dart';
import 'package:logistics_express/src/utils/estimate_price.dart';
import '../../../../custom_widgets/custom_dropdown.dart';
import '../../../../custom_widgets/custom_loader.dart';
import '../../../../custom_widgets/date_picker.dart';
import '../../../../models/requested_delivery_model.dart';
import '../../../../services/authentication/auth_controller.dart';
import '../../../../services/user_services.dart';
import '../../../../utils/firebase_exceptions.dart';
import '../../../../utils/new_text_field.dart';
import '../../../../utils/validators.dart';

class MakeRequest extends ConsumerStatefulWidget {
  const MakeRequest({super.key});

  @override
  ConsumerState<MakeRequest> createState() => _MakeRequestState();
}

class _MakeRequestState extends ConsumerState<MakeRequest> {
  String? _selectedType;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  late RequestedDeliveryModel delivery;

  @override
  Widget build(BuildContext context) {
    final authController = ref.read(authControllerProvider);

    Future<void> sendRequestToDb() async {
      setState(() => _isLoading = true);
      try {
        final userServices = UserServices();
        await userServices.requestedDelivery(delivery);

        authController.clearAll();

        if (context.mounted) {
          showSuccessSnackBar(context, "Request sent successfully!");
          Navigator.of(context).pop();
        }
      } catch (error) {
        if (context.mounted) {
          showErrorSnackBar(context, 'Error: ${error.toString()}');
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

    Future<void> prepareRequestAndShowDialog() async {
      setState(() => _isLoading = true);

      try {
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

        delivery = RequestedDeliveryModel(
          name: name,
          phoneNo: phone,
          source: authController.sourceAddressController.text.trim(),
          destination: authController.destinationAddressController.text.trim(),
          startDate: authController.startDateController.text.trim(),
          weight: authController.weightController.text.trim(),
          volume: authController.volumeController.text.trim(),
          itemType: _selectedType!,
          amount: '', 
          uId: user.uid,
        );

        double estimatedAmount = await estimatePrice(ref);
        delivery.amount = estimatedAmount.toString();

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialog(
                title: 'Estimated Price: $estimatedAmount',
                message: 'Do you want to send the request?',
                onConfirm: () => sendRequestToDb(),
              );
            },
          );
        }
      } catch (e) {
        if (context.mounted) {
          showErrorSnackBar(context, 'Something went wrong. Try again.');
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text('Make Request'),
            ),
            backgroundColor: Theme.of(context).cardColor,
            body: AbsorbPointer(
              absorbing: _isLoading,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AddressFilled(),
                        const SizedBox(height: 10),
                        NewTextField(
                          hintText: "DD/MM/YYYY",
                          label: 'Date',
                          controller: authController.startDateController,
                          keyboardType: TextInputType.number,
                          readOnly: true,
                          onTap: () async {
                            String selectedDate =
                                await DatePicker.pickDate(context, ref);
                            setState(() {
                              authController.startDateController.text =
                                  selectedDate;
                            });
                          },
                          suffixIcon: const Icon(FontAwesomeIcons.calendarDays),
                          validator: (val) => Validators.validateDate(val),
                        ),
                        const SizedBox(height: 10),
                        NewTextField(
                          label: 'Weight',
                          hintText: 'Enter weight in Kg',
                          keyboardType: TextInputType.number,
                          controller: authController.weightController,
                          validator: (val) => Validators.quantityValidator(val),
                        ),
                        const SizedBox(height: 10),
                        NewTextField(
                          label: 'Volume',
                          hintText: 'Enter volume in cm\u00B3',
                          keyboardType: TextInputType.number,
                          controller: authController.volumeController,
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
                          onChanged: (value) =>
                              setState(() => _selectedType = value),
                          validator: (val) => Validators.commonValidator(val),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await prepareRequestAndShowDialog();
                            } else {
                              showErrorSnackBar(
                                context,
                                'Please fill all required fields.',
                              );
                            }
                          },
                          child: const Text('Send Request'),
                        ),
                      ],
                    ),
                  ),
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
      ),
    );
  }
}
