import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_widgets/animated_widgets.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class ClientInfoForm extends StatefulWidget {
  @override
  _ClientInfoFormState createState() => _ClientInfoFormState();
}

class _ClientInfoFormState extends State<ClientInfoForm> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref('clients');
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController nicController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController paymentNotesController = TextEditingController();
  final TextEditingController fileNumberController = TextEditingController();
  final TextEditingController courtNameController = TextEditingController();
  final TextEditingController caseStatusController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isBlockFee = true;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
    print("Firebase initialized");
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: BoxDecoration()),
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedCardField('Full Name', FontAwesomeIcons.user, fullNameController),
                  _buildAnimatedCardField('NIC', FontAwesomeIcons.idCard, nicController),
                  _buildAnimatedCardField('Contact', FontAwesomeIcons.phone, contactController),
                  _buildAnimatedCardField('Email', FontAwesomeIcons.envelope, emailController),
                  _buildAnimatedCardField('Address', FontAwesomeIcons.mapMarkerAlt, addressController),
                  _buildChargeOptions(),
                  _buildAnimatedCardField('Payment Notes (e.g. Rs.500000 received)', FontAwesomeIcons.moneyCheck, paymentNotesController),
                  _buildAnimatedCardField('File Number', FontAwesomeIcons.folderOpen, fileNumberController),
                  _buildAnimatedCardField('Court Name', FontAwesomeIcons.balanceScale, courtNameController),
                  _buildAnimatedCardField('Status of the Case', FontAwesomeIcons.gavel, caseStatusController),
                  _buildDatePicker(),
                  _buildTimePicker(),
                  _buildAnimatedCardField('Remarks', FontAwesomeIcons.stickyNote, remarksController),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          Map<String, dynamic> clientData = {
                            'fullName': fullNameController.text,
                            'nic': nicController.text,
                            'contact': contactController.text,
                            'email': emailController.text,
                            'address': addressController.text,
                            'paymentNotes': paymentNotesController.text,
                            'fileNumber': fileNumberController.text,
                            'courtName': courtNameController.text,
                            'caseStatus': caseStatusController.text,
                            'date': selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : null,
                            'time': selectedTime != null ? selectedTime!.format(context) : null,
                            'remarks ': remarksController.text,
                            'chargeType': isBlockFee ? 'Block Fee' : 'Per Appearance',
                          };

                          try {
                            await _databaseReference.push().set(clientData);
                            _showDialog('Success', 'Data stored successfully.');
                          } catch (error) {
                            print("Error storing data: $error");
                            _showDialog('Error', 'Failed to store data: $error');
                          }
                        } else {
                          _showDialog('Error', 'Please fill correctly all the required fields.');
                        }
                      },
                      icon: FaIcon(FontAwesomeIcons.bookBookmark),
                      label: Text('Add Client'),

                      style: ElevatedButton.styleFrom(
                        iconColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        backgroundColor: const Color.fromARGB(255, 29, 183, 35),
                      
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedCardField(String label, IconData icon, TextEditingController controller) {
    return TranslationAnimatedWidget(
      enabled: true,
      values: [Offset(100, 0), Offset(0, 0)],
      duration: Duration(seconds: 1),
      child: OpacityAnimatedWidget(
        enabled: true,
        duration: Duration(seconds: 1),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 10,
          margin: const EdgeInsets.only(bottom: 16.0),
          color: Colors.white.withOpacity(0.9),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                  child: FaIcon(icon, color: const Color.fromARGB(255, 8, 189, 138)),
                ),
                 
                labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 10,
        margin: const EdgeInsets.only(bottom: 16.0),
        color: Colors.white.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              FaIcon(FontAwesomeIcons.calendarAlt, color: const Color.fromARGB(255, 8, 189, 138)),
              SizedBox(width: 16),
              Text(
                selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                    : 'Select Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () => _selectTime(context),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 10,
        margin: const EdgeInsets.only(bottom: 16.0),
        color: Colors.white.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              FaIcon(FontAwesomeIcons.clock, color: const Color.fromARGB(255, 18, 173, 49)),
              SizedBox(width: 16),
              Text(
                selectedTime != null ? selectedTime!.format(context) : 'Select Time',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChargeOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius : BorderRadius.circular(15),
            ),
            elevation: 10,
            margin: const EdgeInsets.only(bottom: 16.0),
            color: Colors.white.withOpacity(0.9),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Block Fee'),
                      leading: Radio<bool>(
                        value: true,
                        groupValue: isBlockFee,
                        onChanged: (value) {
                          setState(() {
                            isBlockFee = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Per Appearance'),
                      leading: Radio<bool>(
                        value: false,
                        groupValue: isBlockFee,
                        onChanged: (value) {
                          setState(() {
                            isBlockFee = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}