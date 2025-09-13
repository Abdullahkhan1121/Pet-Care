// lib/shelter/petlisting.dart
import 'package:flutter/material.dart';
import 'package:pawfect/shelter/add_pet.dart';
import 'package:pawfect/shelter/drawer.dart';
import 'package:pawfect/shelter/manage_pets.dart';

class PetListingPage extends StatefulWidget {
  const PetListingPage({super.key});

  @override
  State<PetListingPage> createState() => _PetListingPageState();
}

class _PetListingPageState extends State<PetListingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pet Listings"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add), text: "Add Pet"),
            Tab(icon: Icon(Icons.pets), text: "Manage Pets"),
          ],
        ),
      ),
      drawer: ShelterDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AddPetPage(),   // from lib/shelter/add_pet.dart
          ManagePetsPage(), // from lib/shelter/manage_pets.dart
        ],
      ),
    );
  }
}
