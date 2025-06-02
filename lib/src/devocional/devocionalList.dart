import 'package:flutter/material.dart';

class DevocionalList extends StatefulWidget {
  const DevocionalList ({super.key});

  @override
  _DevocionalListState createState() => _DevocionalListState();
}

class _DevocionalListState extends State<DevocionalList> {

  List<String> filteredDevocionalTopic = [];
  Set<String> favoriteDevocionalTopic = {};

  final TextEditingController _filterController = TextEditingController();
  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
