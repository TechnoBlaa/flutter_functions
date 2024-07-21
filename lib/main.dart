import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firestore Stream',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('Componentes');
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> deleteDocument(String docId) async {
    try {
      // print('Attempting to delete document with ID: $docId');
      HttpsCallable callable = _functions.httpsCallable('deleteDocument');
      final results = await callable.call(<String, dynamic>{
        'docId': docId,
      });

      if (results.data['status'] == 'Document deleted successfully') {
        // print('Document deleted successfully');
      } else {
        // print('Failed to delete document: ${results.data['status']}');
      }
    } catch (e) {
      // print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('Documents'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _collectionRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Text('Error: ${snapshot.error}');
            return const Center(child: Text('Something is wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No documents in the collection'));
          }

          final documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              Text('Document ID: ${doc.id}');
              return ListTile(
                title: Text(doc.id),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await deleteDocument(doc.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
