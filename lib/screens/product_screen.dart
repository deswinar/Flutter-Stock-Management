import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_management/models/product.dart';
import 'package:stock_management/screens/add_product_screen.dart';
import 'package:stock_management/services/firestore_service.dart';

class ProductScreen extends StatelessWidget {
  final db = FirestoreService();
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black87, //change your color here
        ),
        title: Text('Products', style: TextStyle(color: Colors.black87),),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: StreamProvider<List<Product>>.value(
        value: db.getProducts(user),
        child: ProductList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, AddProductScreen.routeName);
        }
      ),
    );
  }
}

typedef void StringCallback(String val);

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  ScrollController _scrollController = ScrollController();

  final db = FirestoreService();
  var isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var products = Provider.of<List<Product>>(context);
    var user = Provider.of<FirebaseUser>(context);
    _scrollController.addListener(() {  
      double maxScroll = _scrollController.position.maxScrollExtent;  
      double currentScroll = _scrollController.position.pixels;  
      double delta = MediaQuery.of(context).size.height * 0.20;  
      if (maxScroll == currentScroll) {
        isLoading = true;
        if(products != null) {
          var a = db.getMoreProducts(user, [products[products.length - 1].lastUpdated]);
          Stream<List<Product>> stream = a;
          a.listen((data) {
            if(data.length != 0) {
              setState(() {
                products.addAll(data);
                isLoading = false;
              });
            }
          }, onDone: () {
            print('Done');
          }, onError: (error) {
            print(error);
          });
        }
      } 
    }); 
    // print(products);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: products == null
        ? Center(child: Text('Loading...'))
        : products.length == 0
          ? Center(child: Text('No Product'))
          : ListView.builder(
            controller: _scrollController,
            itemCount: products == null ? 0 : products.length + 1,
            itemBuilder: (context, index) {
              if(index == products.length) {
                if(isLoading == true) {
                  return Center(child: Text('Loading more data...'));
                }
              } else {
                Product product = products[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: product.imageUrl == null ||  product.imageUrl == ''
                          ? Image.asset('assets/images/no_product_image.png', fit: BoxFit.cover, width: 50,)
                          // : Image.network(product.imageUrl, fit: BoxFit.fill,),
                          : CachedNetworkImage(
                            width: 50,
                            imageUrl: product.imageUrl,
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                      title: Text(product.name),
                      subtitle: Text('Stock : ' + product.qty),
                    ),
                  ),
                );
              }
            }
          ),
    );
  }
}

// The base class for the different types of items the list can contain.
abstract class ListItem {}

// A ListItem that contains data to display a heading.
class CategoryItem implements ListItem {
  final String category;

  CategoryItem(this.category);
}

// A ListItem that contains data to display a message.
class ProductItem implements ListItem {
  final String name;
  final String description;
  final String qty;

  ProductItem(this.name, this.description, this.qty);
}