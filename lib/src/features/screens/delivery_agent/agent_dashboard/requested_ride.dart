import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logistics_express/src/custom_widgets/custom_loader.dart';
import 'package:logistics_express/src/utils/theme.dart';

class RequestedRide extends StatefulWidget {
  final Map<String, dynamic> delivery;

  const RequestedRide({
    super.key,
    required this.delivery,
  });

  @override
  State<RequestedRide> createState() => _RequestedRideState();
}

class _RequestedRideState extends State<RequestedRide> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Requested Delivery"),
          ),
          backgroundColor: theme.cardColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(4.0),
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
                        CustomSectionTitle(
                          title: "Delivery Details",
                        ),
                        CustomInfoRow(
                          icon: FontAwesomeIcons.locationDot,
                          text: "From: ${widget.delivery['Source']}",
                        ),
                        CustomInfoRow(
                          icon: FontAwesomeIcons.mapPin,
                          text: "To: ${widget.delivery['Destination']}",
                        ),
                        CustomInfoRow(
                          icon: FontAwesomeIcons.calendarDays,
                          text: "Date: ${widget.delivery['Date']}",
                        ),
                        const Divider(thickness: 1, height: 20),
                        CustomSectionTitle(
                          title: "Customer Info",
                        ),
                        CustomInfoRow(
                          icon: FontAwesomeIcons.user,
                          text: "Name: ${widget.delivery['Name']}",
                        ),
                        CustomInfoRow(
                          icon: FontAwesomeIcons.phone,
                          text: "Phone: ${widget.delivery['Phone']}",
                        ),
                        const Divider(thickness: 1, height: 20),
                        CustomSectionTitle(
                          title: "Cargo Information",
                        ),
                        CustomInfoRow(
                          icon: FontAwesomeIcons.box,
                          text: "Type: ${widget.delivery['ItemType']}",
                        ),
                        CustomInfoRow(
                          icon: FontAwesomeIcons.weightHanging,
                          text: "Weight: ${widget.delivery['Weight']} kg",
                        ),
                        CustomInfoRow(
                          icon: FontAwesomeIcons.cube,
                          text: "Volume: ${widget.delivery['Volume']} cm³",
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Accept Delivery'),
                  ),
                )
              ],
            ),
          ),
        ),
        if (isLoading)
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

class CustomSectionTitle extends StatelessWidget {
  final String title;

  const CustomSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: theme.textTheme.headlineMedium
            ?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}

class CustomInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const CustomInfoRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Increased padding
      child: Row(
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
