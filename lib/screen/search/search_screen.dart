import 'package:flutter/material.dart';
import 'package:game_gear/shared/widget/appbar_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
  });
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: "Search"),
    );
  }
}
