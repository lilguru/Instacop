import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instacop/src/helpers/screen.dart';
import 'package:instacop/src/helpers/shared_preferrence.dart';
import 'package:instacop/src/model/product.dart';
import 'package:instacop/src/views/HomePage/Customer/HomePage/ProductDetail/main_detail_product_view.dart';
import 'package:instacop/src/widgets/card_product.dart';

class WishListView extends StatefulWidget {
  @override
  _WishListViewState createState() => _WishListViewState();
}

class _WishListViewState extends State<WishListView>
    with AutomaticKeepAliveClientMixin {
  StreamController _uidStreamController = new StreamController();
  StreamController _dataStreamController = new StreamController();
  List<ProductCard> listProduct = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    StorageUtil.getUid().then((uid) {
      _uidStreamController.add(uid);
      getWishlistList(uid);
    });
  }

  removeProduct(String idProduct) {
    var result =
        listProduct.firstWhere((it) => it.id == idProduct, orElse: () => null);
    if (result != null) {
      int index = listProduct.indexOf(result);
      print('TRUE : $index');
      print('TRUE : ${listProduct.length}');
      setState(() {
        listProduct.removeAt(index);
      });
      print('TRUE : ${listProduct.length}');
    }
  }

  Future<void> getWishlistList(String uid) async {
    List<ProductCard> list = [];
    await Firestore.instance
        .collection('Wishlists')
        .document(uid)
        .collection(uid)
        .getDocuments()
        .then((snap) async {
      if (snap.documents != null) {
        for (var document in snap.documents) {
          var doc = await Firestore.instance
              .collection('Products')
              .document(document['id'])
              .get();
          print(document['id']);
          print(doc['name']);
          listProduct.add(ProductCard(
            id: doc['id'],
            productName: doc['name'],
            image: doc['image'][0],
            isSoldOut: (doc['quantity'] == '0'),
            price: int.parse(doc['price']),
            salePrice: int.parse(doc['sale_price']),
            isIconClose: true,
            onTap: () {
              Product product = new Product(
                id: doc['id'],
                productName: doc['name'],
                imageList: doc['image'],
                category: doc['categogy'],
                sizeList: doc['size'],
                colorList: doc['color'],
                price: doc['price'],
                salePrice: doc['sale_price'],
                brand: doc['brand'],
                madeIn: doc['made_in'],
                quantityMain: doc['quantity'],
                quantity: '',
                description: doc['description'],
                rating: doc['rating'],
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainDetailProductView(
                    product: product,
                  ),
                ),
              );
            },
            onClosePress: () {
              Firestore.instance
                  .collection('Wishlists')
                  .document(uid)
                  .collection(uid)
                  .document(doc['id'])
                  .delete();
              removeProduct(doc['id']);
            },
          ));
        }
      }

      _dataStreamController.add(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    ConstScreen.setScreen(context);
    return StreamBuilder(
        stream: _uidStreamController.stream,
        builder: (context, snapshotMain) {
          if (snapshotMain.hasData) {
            return Padding(
              padding: EdgeInsets.symmetric(
                  vertical: ConstScreen.setSizeHeight(10),
                  horizontal: ConstScreen.setSizeWidth(20)),
              child: StreamBuilder(
                  stream: _dataStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 68 / 110,
                          crossAxisSpacing: ConstScreen.setSizeHeight(30),
                          mainAxisSpacing: ConstScreen.setSizeHeight(40),
                        ),
                        itemCount: listProduct.length,
                        itemBuilder: (_, index) => listProduct[index],
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            );
          } else {
            return Container();
          }
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}
