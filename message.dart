import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'main.dart';
import 'package:sms/contact.dart';
import 'package:intl/intl.dart';

class MyInbox extends StatefulWidget {
  @override
  State createState() {
    return MyInboxState();
  }
}

class MyInboxState extends State {
  SmsQuery query = new SmsQuery();
  List messages = new List();
  List contact_names = new List();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool isLoading = false;
  @override
  initState() {
    super.initState();
    initUser();
  }

  initUser() async {
    user = await _auth.currentUser();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              print("Floating Action");
            },
            child: Icon(Icons.add)),
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text("${user?.displayName}"),
                accountEmail: Text("${user?.email}"),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage("${user?.photoUrl}"),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Close Menu'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Sign Out'),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  googleSignIn.disconnect();
                  googleSignIn.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => MyApp()),
                      (Route<dynamic> route) => false);
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text("SMS Inbox"),
          backgroundColor: Colors.blue,
        ),
        body: FutureBuilder(
          future: fetchSMS(),
          builder: (context, snapshot) {
            return ListView.separated(
                separatorBuilder: (context, index) => Divider(
                      color: Colors.black,
                    ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.account_circle,
                        color: Colors.blue,
                        size: 50,
                      ),
                      title: Text(contact_names[index]),
                      subtitle: Text(messages[index].body, maxLines: 2),
                      trailing: Text(
                        DateFormat('yyyy-MM-dd – kk:mm')
                            .format(messages[index].date),
                        style: TextStyle(),
                      ),
                    ),
                  );
                });
          },
        ));
  }

  fetchSMS() async {
    messages = await query.getAllSms;
    _contact(messages, contact_names);
  }

  _contact(List messages, List contact_names) async {
    ContactQuery contacts = new ContactQuery();
    for (var i = 0; i < messages.length; i++) {
      Contact contact = await contacts.queryContact(messages[i].address);
      if (contact.fullName != null) {
        contact_names.add(contact.fullName);
      } else {
        contact_names.add(messages[i].address);
      }
    }
    print(contact_names);
  }
}
