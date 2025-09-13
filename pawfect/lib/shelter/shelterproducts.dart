import 'package:flutter/material.dart';
import 'package:pawfect/shelter/addproduct.dart';
import 'package:pawfect/shelter/appbar.dart';
import 'package:pawfect/shelter/drawer.dart';
import 'package:pawfect/shelter/manageproduct.dart';

class Shelterproducts extends StatefulWidget {
  const Shelterproducts({super.key});

  @override
  State<Shelterproducts> createState() => _ShelterproductsState();
}

class _ShelterproductsState extends State<Shelterproducts> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // ✅ Two tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Manage Products"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add), text: "Add Product"),
              Tab(icon: Icon(Icons.manage_search), text: "Manage Products"),
            ],
          ),
        ),
        drawer: const ShelterDrawer(),
        body: const TabBarView(
          children: [
            AddProductPage(),
            ManageProductsPage(),
          ],
        ),
      ),
    );
  }
}
