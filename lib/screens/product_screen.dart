import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_management/models/product.dart';
import 'package:stock_management/screens/add_product_screen.dart';
import 'package:stock_management/screens/arguments/edit_product_screen_args.dart';
import 'package:stock_management/screens/edit_product_screen.dart';
import 'package:stock_management/screens/sort_product_screen.dart';
import 'package:stock_management/services/firestore_service.dart';

var result;

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final db = FirestoreService();

  Widget _appBarTitle = Text('Products', style: TextStyle(color: Colors.black87),);
  String _searchText = "";
  Icon _searchIcon = new Icon(Icons.search);
  TextEditingController _searchController = TextEditingController();

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(Icons.close);
        this._appBarTitle = TextField(
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search...'
          ),
          onChanged: (text) {
            setState(() {
              _searchText = text;
            });
          },
        );
      } else {
        this._searchIcon = Icon(Icons.search);
        this._appBarTitle = Text('Products', style: TextStyle(color: Colors.black87),);
        _searchController.clear();
        setState(() {
          _searchText = "";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black87, //change your color here
        ),
        title: _appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: _searchIcon,
            onPressed: () {
              _searchPressed();
            }
          )
        ],
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: StreamProvider<List<Product>>.value(
        value: user == null ? null : db.getProducts(user, sort: result, search: _searchText),
        child: ProductList(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: 'sort',
            tooltip: 'Sort',
            backgroundColor: Colors.white,
            child: Icon(Icons.sort, color: Colors.black,),
            onPressed: () {
              _navigateToSortScreen(context);
            }
          ),
          SizedBox(height: 10,),
          FloatingActionButton(
            heroTag: 'filter',
            tooltip: 'Filter',
            backgroundColor: Colors.white,
            child: Icon(Icons.filter_list, color: Colors.black,),
            onPressed: () {
              Navigator.pushNamed(context, AddProductScreen.routeName);
            }
          ),
          SizedBox(height: 10,),
          FloatingActionButton(
            heroTag: 'newProduct',
            tooltip: 'New Product',
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AddProductScreen.routeName);
            }
          ),
        ],
      ),
    );
  }
}

_navigateToSortScreen(context) async {
  result = await Navigator.pushNamed(context, SortProductScreen.routeName);
  print(result);
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
      // double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll == currentScroll) {
        isLoading = true;
        if(products != null) {
          var a = db.getMoreProducts(user, [products[products.length - 1].lastUpdated], sort: result);
          Stream<List<Product>> stream = a;
          a.listen((data) {
            print('data: ${data}');
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
                return Dismissible(
                  key: Key(product.id),
                  onDismissed: (direction) {
                    setState(() {
                      products.removeAt(index);
                      db.deleteProduct(user, product.id).then((a){
                        Scaffold.of(context)
                          .showSnackBar(SnackBar(content: Text("${product.name} deleted")));
                      });
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(alignment: Alignment.centerRight, child: Icon(Icons.delete, color: Colors.white)),
                    ),
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context,
                            EditProductScreen.routeName,
                            arguments: EditProductScreenArgs(product.id));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          leading: product.imageUrl == null ||  product.imageUrl == ''
                              ? Image.asset('assets/images/no_product_image.png', fit: BoxFit.cover, width: 50, alignment: Alignment.center,)
                              // : Image.network(product.imageUrl, fit: BoxFit.fill,),
                              : CachedNetworkImage(
                                width: 50,
                                imageUrl: product.imageUrl,
                                placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                          title: Text(product.name),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Category : ${product.category}'),
                              Text('Stock : ${product.qty}'),
                              Text('Last updated : ' + product.lastUpdated.toDate().toString().split(' ')[0] ?? ''),
                            ],
                          ),
                        ),
                      ),
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