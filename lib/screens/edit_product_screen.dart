import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:stock_management/models/category.dart';
import 'package:stock_management/models/product.dart';
import 'package:stock_management/screens/arguments/edit_product_screen_args.dart';
import 'package:stock_management/services/firebase_storage_service.dart';
import 'package:stock_management/services/firestore_service.dart';

class EditProductScreen extends StatefulWidget {
  static final routeName = '/edit_product';
  @override
  State<StatefulWidget> createState() {
    return EditProductScreenState();
  }
}

class EditProductScreenState extends State<EditProductScreen> {
  File _image;

  Future getImage() async {
    final imageSource = await showDialog<ImageSource>(
      context: context,
      builder: (context) =>
        AlertDialog(
          shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
          title: Text("Select the image source"),
          actions: <Widget>[
            MaterialButton(
              child: Text("Camera"),
              onPressed: () => Navigator.pop(context, ImageSource.camera),
            ),
            MaterialButton(
              child: Text("Gallery"),
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
            )
          ],
        )
    );

    if(imageSource != null) {
      final file = await ImagePicker.pickImage(source: imageSource, imageQuality: 80);
      if(file != null) {
        setState(() => _image = file);
      }else {
        setState(() {
          _image = null;
        });
      }
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _qtyController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _saveButtonState = true;

  String _categoryValue;
  Category selected;
  String tempSuggestion = '';
  List<String> suggestions = [];

  final firebaseStorageService = FirebaseStorageService();
  final firestoreService = FirestoreService();
  String imageUrl;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var db = FirestoreService();
    final EditProductScreenArgs args = ModalRoute.of(context).settings.arguments;
    var user = Provider.of<FirebaseUser>(context);
    var categories = Provider.of<List<Category>>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black87, //change your color here
        ),
        title: Text('Edit Product', style: TextStyle(color: Colors.black87),),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: StreamBuilder<Product>(
            stream: db.getProduct(user, args.id),
            builder: (context, snapshot) {
              String name = snapshot.data.name ?? '';
              String description = snapshot.data.description ?? '';
              int qty = snapshot.data.qty ?? 0;
              String category = snapshot.data.category ?? null;
              imageUrl = snapshot.data.imageUrl ?? null;

              _nameController.text = name;
              _descriptionController.text = description;
              _qtyController.text = qty.toString();
              _categoryController.text = category;

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: Container(
                        width: 150,
                        decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black87)),
                        child: _image == null
                          ? imageUrl == null
                            ? Image(image: AssetImage('assets/images/no_product_image.png'), fit: BoxFit.cover,)
                            : CachedNetworkImage(
                                imageUrl: imageUrl,
                                placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                                fit: BoxFit.cover,
                              )
                          : Image(image: FileImage(_image), fit: BoxFit.cover,)
                      ),
                    ),
                    Divider(color: Colors.black87,),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            maxLength: 50,
                            controller: _nameController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter product name';
                              }
                              return null;
                            },
                            decoration: ProductStyle.textFieldStyle(labelText: 'Name', controller: _nameController)
                          ),
                          SizedBox(height: 10.0,),
                          TextFormField(
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 4,
                            maxLength: 300,
                            controller: _descriptionController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter product description';
                              }
                              return null;
                            },
                            decoration: ProductStyle.textFieldStyle(labelText: 'Description', controller: _descriptionController)
                          ),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            maxLength: 50,
                            controller: _qtyController,
                            validator: (value) {
                              return null;
                            },
                            decoration: ProductStyle.textFieldStyle(labelText: 'Quantity', controller: _qtyController)
                          ),
                          StreamBuilder<List<Category>>(
                            stream: firestoreService.getCategorySuggestions(user),
                            builder: (context, snapshot) {
                              suggestions.clear();
                              if(snapshot.hasData) {
                                snapshot.data.forEach((data) {
                                  if(tempSuggestion.trim().toLowerCase() != data.category.trim().toLowerCase()){
                                    suggestions.add(data.category);
                                  }
                                  tempSuggestion = data.category;
                                });
                                print(suggestions);
                              }
                              return TypeAheadFormField(
                                autoFlipDirection: true,
                                textFieldConfiguration: TextFieldConfiguration(
                                  keyboardType: TextInputType.text,
                                  textCapitalization: TextCapitalization.sentences,
                                  controller: _categoryController,
                                  decoration: ProductStyle.categoryTextFieldStyle(labelText: 'Category', controller: _categoryController)
                                ),          
                                suggestionsCallback: (pattern) {
                                  return suggestions.where((data) => data.toLowerCase().contains(pattern.toLowerCase())).toList();
                                },
                                itemBuilder: (context, suggestion) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(width: 1)
                                      )
                                  ),
                                    child: ListTile(
                                      title: Text(suggestion),
                                    ),
                                  );
                                },
                                transitionBuilder: (context, suggestionsBox, controller) {
                                  return suggestionsBox;
                                },
                                onSuggestionSelected: (suggestion) {
                                  _categoryController.text = suggestion;
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please select a category';
                                  }
                                },
                                onSaved: (value) => _categoryValue = value,
                              );
                            }
                          ),
                        ]
                      )
                    ),
                  ],
                ),
              );
            }
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if(_saveButtonState == false) {
            return null;
          }else {
            if (_formKey.currentState.validate()) {
              setState(() {
                _saveButtonState = false;
              });
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: Row(
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Text("Saving...")
                    ],
                  ),
                )
              );
              FirebaseStorageResult result;
              if(_image == null) {
                result = null;
              }else {
                result = await firebaseStorageService.uploadFile(user, _image, 'product_' + DateTime.now().millisecondsSinceEpoch.toString());
              }

              _categoryValue = _categoryController.text;
              Map data = {
                'id': args.id,
                'name': _nameController.text ?? '',
                'description': _descriptionController.text ?? '',
                'qty': int.parse(_qtyController.text) ?? 0,
                'category': _categoryValue,
                'imageUrl': _image == null ? imageUrl == null ? null : imageUrl : result.imageUrl,
              };

              await firestoreService.updateProduct(user, data);
              Navigator.pop(context);
              _scaffoldKey.currentState
                  .showSnackBar(SnackBar(content: Text('Processing Data')));
            }
          }
        },
        child: _saveButtonState == false ? Icon(Icons.do_not_disturb) : Icon(Icons.save),
        tooltip: 'Save',
        backgroundColor: _saveButtonState == false ? Colors.grey : Colors.blue,
      ),
    );
  }
}

class ProductStyle{
  static InputDecoration textFieldStyle({String labelText="",String hintText="", TextEditingController controller}) {return InputDecoration(
    suffixIcon: IconButton(
      onPressed: () => controller.clear(),
      icon: Icon(Icons.clear),
    ),
    contentPadding: EdgeInsets.all(12),
    labelText: labelText,
    hintText:hintText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(color: Colors.grey)
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(color: Colors.grey)
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(color: Colors.black87)
    )
  );}

  static InputDecoration categoryTextFieldStyle({String labelText="",String hintText="", TextEditingController controller}) {return InputDecoration(
    suffixIcon: Icon(Icons.search),
    contentPadding: EdgeInsets.all(12),
    labelText: labelText,
    hintText:hintText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(color: Colors.grey)
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(color: Colors.grey)
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(color: Colors.black87)
    )
  );}
}