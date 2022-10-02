import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  ImagePicker image = ImagePicker();
  File? file;
  String url = '';

  bool isLoading = true;
  TextEditingController description = TextEditingController();

  FirebaseFirestore firestoreRef = FirebaseFirestore.instance;
  FirebaseStorage storageRef = FirebaseStorage.instance;
  String collectionName = 'image';

  getImage() async {
    var img = await image.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        file = File(img!.path);
        // description.text = Faker().lorem.sentense;
      });
    }
  }

  // uploadImage() async {
  //   var imageFile =
  //       await FirebaseStorage.instance.ref().child("path").child('/.jpg');
  //   UploadTask task = imageFile.putFile(file!);
  //   TaskSnapshot snapshot = await task;

  //   url = await snapshot.ref.getDownloadURL();
  //   print(url);
  // }

  postImage() async {
    setState(() {
      isLoading = true;
    });
    var uniqeyKey = firestoreRef.collection(collectionName).doc();

    String uploadFileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference reference =
        storageRef.ref().child(collectionName).child(uploadFileName);

    UploadTask uploadTask = reference.putFile(File(file!.path));
    uploadTask.snapshotEvents.listen((event) {
      print(event.bytesTransferred.toString() +
          "/t" +
          event.totalBytes.toString());
    });

    await uploadTask.whenComplete(() async {
      var file = await uploadTask.snapshot.ref.getDownloadURL();

      if (file.isNotEmpty) {
        firestoreRef
            .collection(collectionName)
            .doc(uniqeyKey.id)
            .set({'description': description.text, 'image': file}).then(
                (value) => showMesssage('Record Insertd.'));
      } else {
        showMesssage('Something while Uploading Image');
      }
      setState(() {
        isLoading = false;
        // description.text = '';
        // file = '';
      });

      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/homepage');
    });
  }

  showMesssage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pushNamed(context, '/homepage');
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: 220,
                    child: const Text('Click to upload image below...'),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  getImage();
                },
                child: Center(
                  child: Container(
                      margin: const EdgeInsets.only(left: 40),
                      width: 250,
                      height: 200,
                      color: Colors.white,
                      child: CircleAvatar(
                          radius: 2,
                          backgroundColor: Colors.white,
                          backgroundImage: file == null
                              ? const AssetImage('')
                              : FileImage(File(file!.path)) as ImageProvider)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: description,
                  minLines: 2,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                width: 200,
                height: 80,
                child: ElevatedButton(
                  onPressed: postImage,
                  style: ElevatedButton.styleFrom(primary: Colors.amberAccent),
                  child: const Text(
                    "Post Image",
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
