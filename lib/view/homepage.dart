import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore firestoreRef = FirebaseFirestore.instance;
  FirebaseStorage storageRef = FirebaseStorage.instance;
  String collectionName = 'image';

  void onSubmit(String value) {
    Navigator.pushNamed(context, '/postpage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff242424),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Post your photo...",
                      hintStyle: TextStyle(color: Colors.white),
                      fillColor: Colors.white,
                    ),
                    onSubmitted: onSubmit,
                  ),
                ),
                Container(
                  child: IconButton(
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pushNamed(context, "/postpage");
                    },
                    icon: const Icon(Icons.search),
                  ),
                ),
              ],
            ),
            Container(
              child: Expanded(
                  child: FutureBuilder<QuerySnapshot>(
                future: firestoreRef.collection(collectionName).get(),
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.blueGrey,
                    ));
                  } else if (snapshot.hasData &&
                      snapshot.data!.docs.length > 0) {
                    List<DocumentSnapshot> arrData = snapshot.data!.docs;
                    print(arrData.length);
                    return ListView.builder(
                      itemCount: arrData.length,
                      itemBuilder: ((context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                    child: Image.network(
                                        arrData[index]['image'],
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover, loadingBuilder:
                                            (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      }
                                    }),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        margin: const EdgeInsets.only(
                                          left: 10,
                                          top: 20,
                                        ),
                                        child: Text(
                                          arrData[index]['description'],
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      const LikeButton(
                                        size: 10,
                                        likeCount: 121,
                                      )
                                    ],
                                  )
                                ],
                              )),
                        );
                      }),
                    );
                  } else {
                    return const Center(
                      child: Text(
                        "No Data Yet",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }
                }),
              )),
            )
          ],
        ),
      ),
    );
  }
}
