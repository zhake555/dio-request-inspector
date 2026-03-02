import 'package:dio_request_inspector/src/common/enum.dart';
import 'package:dio_request_inspector/src/common/storage.dart';
import 'package:dio_request_inspector/src/model/http_activity.dart';
import 'package:dio_request_inspector/src/page/dashboard/widget/item_response_widget.dart';
import 'package:dio_request_inspector/src/page/dashboard/widget/password_protection_dialog.dart';
import 'package:dio_request_inspector/src/page/detail/detail_page.dart';
import 'package:dio_request_inspector/src/page/resources/app_color.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  final String password;
  final HttpActivityStorage storage;
  final bool showSummary;

  const DashboardPage({
    Key? key,
    this.password = '',
    required this.storage,
    required this.showSummary,
  }) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isSearch = false;
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  SortActivity currentSort = SortActivity.byTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.password.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dialogInputPassword();
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void toggleSearch() {
    setState(() {
      isSearch = !isSearch;
      if (!isSearch) {
        searchController.clear();
        focusNode.unfocus();
      }
    });
  }

  void search(String query) {
    setState(() {});
  }

  void sortAllResponses(SortActivity sortType) {
    setState(() {
      currentSort = sortType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.red,
        shape: const CircleBorder(),
        child: Icon(
          Icons.delete,
          color: AppColor.white,
        ),
        onPressed: () {
          widget.storage.clear();
        },
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.primary),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: toggleSearch,
            icon: Icon(
              isSearch ? Icons.close : Icons.search,
              color: AppColor.primary,
            ),
          ),
          PopupMenuButton(
            icon: Icon(
              Icons.sort,
              color: AppColor.primary,
            ),
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: SortActivity.byTime,
                  child: Text('Time'),
                ),
                const PopupMenuItem(
                  value: SortActivity.byMethod,
                  child: Text('Method'),
                ),
                const PopupMenuItem(
                  value: SortActivity.byStatus,
                  child: Text('Status'),
                ),
              ];
            },
            onSelected: sortAllResponses,
          ),
        ],
        title: !isSearch
            ? Text('Http Activities', style: TextStyle(color: AppColor.primary))
            : TextField(
                style: TextStyle(color: AppColor.primary),
                autofocus: true,
                onChanged: search,
                focusNode: focusNode,
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  focusColor: AppColor.primary,
                  hintStyle: TextStyle(color: AppColor.primary),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: ValueListenableBuilder<List<HttpActivity>>(
            valueListenable: widget.storage.activitiesNotifier,
            builder: (context, activities, _) {
              List<HttpActivity> displayedActivities = activities;

              if (isSearch && searchController.text.isNotEmpty) {
                final query = searchController.text.toLowerCase();
                displayedActivities = displayedActivities
                    .where((activity) =>
                        activity.toString().toLowerCase().contains(query))
                    .toList();
              } else {
                displayedActivities = List.from(displayedActivities);
              }

              switch (currentSort) {
                case SortActivity.byTime:
                  displayedActivities
                      .sort((a, b) => b.createdTime.compareTo(a.createdTime));
                  break;
                case SortActivity.byMethod:
                  displayedActivities
                      .sort((a, b) => a.method.compareTo(b.method));
                  break;
                case SortActivity.byStatus:
                  displayedActivities.sort((a, b) => (a.response?.status ?? 0)
                      .compareTo(b.response?.status ?? 0));
                  break;
              }

              if (displayedActivities.isEmpty) {
                return const Text('No data');
              }

              return _buildBody(displayedActivities);
            },
          ),
        ),
      ),
    );
  }

  void dialogInputPassword() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PasswordProtectionDialog(
          password: widget.password,
        );
      },
    );
  }

  Widget _buildBody(List<HttpActivity> filteredActivities) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredActivities.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 8);
      },
      itemBuilder: (context, index) {
        var data = filteredActivities[index];

        return InkWell(
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(
                  data: data,
                ),
              ),
            );
          },
          child: ItemResponseWidget(data: data),
        );
      },
    );
  }
}
