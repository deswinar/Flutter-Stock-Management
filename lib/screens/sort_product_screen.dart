import 'package:flutter/material.dart';

class SortProductScreen extends StatelessWidget {
  static final routeName = '/sort_product';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black87, //change your color here
        ),
        title: Text('Sort Product', style: TextStyle(color: Colors.black87),),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, {
                    'isDescending': false,
                    'sortBy': 'name',
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Name (A-Z)'),
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, {
                    'isDescending': true,
                    'sortBy': 'name',
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Name (Z-A)'),
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, {
                    'isDescending': false,
                    'sortBy': 'qty',
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Quantity (fewest)'),
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, {
                    'isDescending': true,
                    'sortBy': 'qty',
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Quantity (most)'),
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, {
                    'isDescending': false,
                    'sortBy': 'lastUpdated',
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Oldest'),
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context, {
                    'isDescending': true,
                    'sortBy': 'lastUpdated',
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Newest'),
                ),
              ),
            ),
          ],
        )
      ),
    );
  }

}