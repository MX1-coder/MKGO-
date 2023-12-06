// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  Set<dynamic> selectedItems = {};
  String selectedType = '';
  TextEditingController searchController1 = TextEditingController();

  Future<dynamic> bottomSheet1(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    void clearTextField() {
      searchController1.text = '';
    }

    final box = GetStorage();
    List<dynamic> type = (box.read('type') ?? []);

    print('The type list in the function called: $type');

    List<dynamic> filteredType = List.from(type);

    selectedItems.clear();

    return showModalBottomSheet(
      backgroundColor: Color(0xFFE6F7FD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(38),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 1.6,
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Select the type of race',
                                style: TextStyle(
                                  color: Color(0xFF524D4D),
                                  fontSize: 18,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w400,
                                  height: 0.05,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 75,
                        ),
                        Divider(
                          thickness: 0.5,
                          color: Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 54,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: TextFormField(
                                onChanged: (text) {
                                  setState(
                                    () {
                                      filteredType = type
                                          .where((item) => item["libelle"]
                                              .toLowerCase()
                                              .contains(text.toLowerCase()))
                                          .toList();
                                    },
                                  );
                                },
                                controller: searchController1,
                                decoration: InputDecoration(
                                    hintText: 'Search',
                                    border: InputBorder.none,
                                    suffixIcon: Icon(
                                      Icons.search,
                                      color: Colors.black,
                                    )),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: searchController1.text.isEmpty
                              ? ListView.builder(
                                  itemCount: type.length,
                                  itemBuilder: ((context, index) {
                                    final item = type[index];
                                    bool isSelected =
                                        selectedItems.contains(item["libelle"]);

                                    return ListTile(
                                      title: Text(item["libelle"]),
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedItems
                                                .remove(item["libelle"]);
                                          } else {
                                            selectedItems.add(item["libelle"]);
                                          }
                                        });
                                      },
                                      trailing:
                                          isSelected ? Icon(Icons.check) : null,
                                    );
                                  }),
                                )
                              : ListView.builder(
                                  itemCount: filteredType.length,
                                  itemBuilder: ((context, index) {
                                    final item = filteredType[index];
                                    bool isSelected =
                                        selectedItems.contains(item["libelle"]);

                                    return ListTile(
                                      title: Text(item["libelle"]),
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedItems
                                                .remove(item["libelle"]);
                                          } else {
                                            selectedItems.add(item["libelle"]);
                                          }
                                        });
                                      },
                                      trailing: isSelected
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.blue,
                                            )
                                          : null,
                                    );
                                  }),
                                ),
                        ),
                        GestureDetector(
                          onTap: () {
                            print(
                                '==================================================');
                          },
                          child: Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 250,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Color(0xFF3954A4),
                                      ),
                                      child: Text('Valider'),
                                      onPressed: () {
                                        Navigator.pop(
                                            context, selectedItems.join(','));
                                        // Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            print(
                                '==================================================');
                            setState(() {
                              selectedItems.clear();
                            });
                          },
                          child: Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 250,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.grey,
                                      ),
                                      child: Text('Reset'),
                                      onPressed: () {
                                        setState(() {
                                          selectedItems.clear();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(clearTextField);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Center(
                      child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Color(0xFF3954A4),
                            size: 30,
                          )),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Text(
                      'Location',
                      style: TextStyle(
                        color: Color(0xFF3954A4),
                        fontSize: 20,
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  bottomSheet1(context).then(
                    (value) {
                      if (value != null && value.isNotEmpty) {
                        setState(
                          () {
                            selectedType = value;
                          },
                        );
                      }
                    },
                  );
                },
                child: Container(
                  width: 180,
                  height: 45,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF3954A4),
                          blurRadius: 4,
                          offset: Offset(0, 0),
                          spreadRadius: 0,
                        )
                      ]),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // SizedBox(width: 10),
                        if (selectedType.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedType = '';
                              });
                            },
                            child: Image.asset(
                              'assets/images/cross2.png',
                              color: Colors.red,
                              scale: 1.6,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            selectedType.isNotEmpty ? selectedType : 'Type',
                            style: TextStyle(
                              color: Color(0xFF524D4D),
                              fontSize: 14,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w400,
                              height: 0.11,
                            ),
                          ),
                        ), 
                      ],
                    ),
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
