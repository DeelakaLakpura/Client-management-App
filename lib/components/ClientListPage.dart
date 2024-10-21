import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClientListPage extends StatefulWidget {
  @override
  _ClientListPageState createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage>
    with SingleTickerProviderStateMixin {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('clients');
  List<Map<dynamic, dynamic>> clientsList = [];
  List<Map<dynamic, dynamic>> filteredClientsList = [];

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchClientData();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Listen for changes in the search input
    _searchController.addListener(_filterClients);
  }

  void _fetchClientData() {
    _databaseReference.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          clientsList = data.values
              .map((client) => client as Map<dynamic, dynamic>)
              .toList();
          filteredClientsList = clientsList; // Initialize filtered list
        });

        _controller.forward();
      }
    });
  }

  void _filterClients() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredClientsList = clientsList
          .where((client) =>
              (client['fullName'] as String).toLowerCase().contains(query))
          .toList();
    });
  }

  void _deleteClient(String clientId) {
    _databaseReference.child(clientId).remove().then((_) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Client deleted successfully')),
      );
      _fetchClientData();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete client: $error')),
      );
    });
  }

  Future<void> _showDeleteConfirmationDialog(String clientId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this client?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes, Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteClient(clientId); // Call the delete function
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 8, 189, 138),
                  ),
                ),
                prefixIcon: Icon(Icons.search,
                    color: const Color.fromARGB(255, 8, 189, 138)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
              ),
            ),
          ),
          Expanded(
            child: filteredClientsList.isEmpty
                ? _searchController.text.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : Center(
                        child:
                            Text('No clients found. Please check your search.'))
                : ListView.builder(
                    itemCount: filteredClientsList.length,
                    itemBuilder: (context, index) {
                      return SlideTransition(
                        position: _offsetAnimation,
                        child: _buildClientCard(filteredClientsList[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(Map<dynamic, dynamic> client) {
    // Assuming each client has a unique 'id' field for identification
    String clientId =
        client['id'] ?? ''; // Modify based on your actual ID field

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 12,
      margin: const EdgeInsets.all(12.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClientHeader(client),
            const SizedBox(height: 15),
            _buildClientInfoGrid(client),
            const SizedBox(height: 20),
            _buildActionButtons(clientId), // Pass the client ID here
          ],
        ),
      ),
    );
  }

  Widget _buildClientHeader(Map<dynamic, dynamic> client) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            FaIcon(
              FontAwesomeIcons.userCircle,
              size: 40,
              color: const Color.fromARGB(255, 8, 189, 138),
            ),
            const SizedBox(width: 12),
            Text(
              client['fullName'] ?? 'Unknown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Row(
          children: [
            FaIcon(FontAwesomeIcons.calendarAlt,
                color: const Color.fromARGB(255, 8, 189, 138)),
            const SizedBox(width: 5),
            Text(client['date'] ?? 'N/A'),
          ],
        ),
      ],
    );
  }

  Widget _buildClientInfoGrid(Map<dynamic, dynamic> client) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // Disable scrolling for grid
      crossAxisCount: 2,
      childAspectRatio: 2, // Adjust aspect ratio for a better layout
      children: [
        _buildGridTile(FontAwesomeIcons.idCard, "NIC: ${client['nic']}"),
        _buildGridTile(FontAwesomeIcons.phone, "Contact: ${client['contact']}"),
        _buildGridTile(FontAwesomeIcons.envelope, "Email: ${client['email']}"),
        _buildGridTile(
            FontAwesomeIcons.mapMarkerAlt, "Address: ${client['address']}"),
        _buildGridTile(FontAwesomeIcons.balanceScale,
            "Court Name: ${client['courtName']}"),
        _buildGridTile(
            FontAwesomeIcons.gavel, "Case Status: ${client['caseStatus']}"),
        _buildGridTile(FontAwesomeIcons.moneyCheck,
            "Payment Notes: ${client['paymentNotes']}"),
        _buildGridTile(FontAwesomeIcons.folderOpen,
            "File Number: ${client['fileNumber']}"),
        _buildGridTile(
            FontAwesomeIcons.stickyNote, "Remarks: ${client['remarks']}"),
      ],
    );
  }

  Widget _buildGridTile(IconData icon, String info) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon,
                size: 24, color: const Color.fromARGB(255, 8, 189, 138)),
            const SizedBox(height: 5),
            Text(
              info,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildActionButtons(String clientId) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      // Edit Button
      Container(
        width: 40, // Set the width of the button
        height: 40, // Set the height of the button
        decoration: BoxDecoration(
          color: Colors.blue, // Background color for Edit button
          shape: BoxShape.circle, // Make the button circular
        ),
        child: TextButton(
          onPressed: () {
            // Navigate to the edit client page
          },
          child: Icon(FontAwesomeIcons.edit, size: 20, color: Colors.white), // Edit icon
        ),
      ),
      SizedBox(width: 8), // Spacing between buttons
      // Delete Button
      Container(
        width: 40, // Set the width of the button
        height: 40, // Set the height of the button
        decoration: BoxDecoration(
          color: Colors.red, // Background color for Delete button
          shape: BoxShape.circle, // Make the button circular
        ),
        child: TextButton(
          onPressed: () {
            _showDeleteConfirmationDialog(clientId);
          },
          child: Icon(FontAwesomeIcons.trash, size: 20, color: Colors.white), // Delete icon
        ),
      ),
      SizedBox(width: 8), // Spacing between buttons
      // Set Alarm Button
      Container(
        width: 40, // Set the width of the button
        height: 40, // Set the height of the button
        decoration: BoxDecoration(
          color: Colors.green, // Background color for Set Alarm button
          shape: BoxShape.circle, // Make the button circular
        ),
        child: TextButton(
          onPressed: () {
            // Navigate to the set alarm page
          },
          child: Icon(FontAwesomeIcons.clock, size: 20, color: Colors.white), // Set Alarm icon
        ),
      ),
    ],
  );
}
}
