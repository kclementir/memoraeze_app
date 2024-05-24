import 'package:flutter/material.dart';
import 'login.dart';
import 'package:memoraeze_flashcard_app/classes/user.dart'; // Import User class

class ProfileScreen extends StatefulWidget {
  User? user;

  ProfileScreen({super.key, this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.user == null) {
        _scaffoldKey.currentState?.openEndDrawer();
      } else {
        // Update the username if the user has logged in
        if (widget.user?.username == 'Login') {
          setState(() {
            widget.user = widget.user?.copyWith(username: widget.user?.email);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                widget.user?.username ?? 'Login',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            if (widget.user == null)
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Login'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  ).then((value) {
                    if (value is User) {
                      setState(() {
                        widget.user = value;
                      });
                    }
                  });
                },
              ),
            if (widget.user != null)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  setState(() {
                    widget.user = null;
                  });
                  Navigator.pop(context);
                },
              ),
            // Add more options if needed
          ],
        ),
      ),
      body: widget.user == null
          ? const Center(
              child: Text('Profile Screen'),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome, ${widget.user?.username}!'),
                  const SizedBox(height: 10),
                  Text('Email: ${widget.user?.email}'),
                ],
              ),
            ),
    );
  }
}
