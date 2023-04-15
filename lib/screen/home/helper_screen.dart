import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:support/global/color.dart';
import 'package:support/screen/home/helper_detail_screen.dart';
import 'package:support/screen/search/search_screen.dart';

import '../../api/api_constant.dart';
import '../../api/api_services.dart';
import '../../model/listner_display_model.dart';
import '../../sharedpreference/sharedpreference.dart';
import '../../widget/shimmer_progress_widget.dart';

class HelperScreen extends StatefulWidget {
  final ListnerDisplayModel? listnerDisplayModel;
  final bool isNavigatedFromSearchScreen;
  const HelperScreen(
      {this.listnerDisplayModel,
      this.isNavigatedFromSearchScreen = false,
      Key? key})
      : super(key: key);

  @override
  State<HelperScreen> createState() => _HelperScreenState();
}

class _HelperScreenState extends State<HelperScreen> {
  ListnerDisplayModel? listnerDisplayModel;

  RatingReviews? ratingModel;
  bool isProgressRunning = false;
  String walletAmount = "0.0";
  int totalRating = 0;

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh() async {
    await apiGetListnerList();
    refreshController.refreshCompleted();
  }

  // Listner Display API

  Future<void> apiGetListnerList() async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      listnerDisplayModel = await APIServices.getListnerData();
    } catch (e) {
      log(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isProgressRunning = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    log(SharedPreference.getValue(PrefConstants.MERA_USER_ID) ?? '',
        name: 'UserId');
    if (widget.listnerDisplayModel != null) {
      listnerDisplayModel = widget.listnerDisplayModel;
    } else {
      apiGetListnerList();
    }
    // apiGetListnerList();
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.isNavigatedFromSearchScreen
            ? AppBar(
                leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back, color: colorWhite)),
                title: const Text(
                  "Search Results",
                  style: TextStyle(fontSize: 20),
                ),
              )
            : null,
        floatingActionButton: widget.isNavigatedFromSearchScreen
            ? null
            : FloatingActionButton(
                backgroundColor: primaryColor,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchScreen(
                                listnerDisplayModel: listnerDisplayModel,
                              )));
                },
                child: const Icon(Icons.search),
              ),
        body: isProgressRunning
            ? ShimmerProgressWidget(
                count: 8, isProgressRunning: isProgressRunning)
            : SafeArea(
                child: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: false,
                  onRefresh: onRefresh,
                  controller: refreshController,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 8, 15, 8),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: listnerDisplayModel?.data?.length ?? 0,
                        scrollDirection: Axis.vertical,
                        physics: const ScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: colorWhite,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    if (mounted) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HelperDetailScreen(
                                                    listnerDisplayModel:
                                                        listnerDisplayModel
                                                            ?.data?[index],
                                                    ratingModel: ratingModel,
                                                  )));
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        12.0, 12, 12, 12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color: colorWhite,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(children: [
                                            Expanded(
                                              flex: 2,
                                              child: Stack(
                                                children: [
                                                  if (listnerDisplayModel
                                                          ?.data?[index]
                                                          .image !=
                                                      null) ...{
                                                    CachedNetworkImage(
                                                      imageUrl:
                                                          "${APIConstants.BASE_URL}${listnerDisplayModel?.data?[index].image}",
                                                      fit: BoxFit.cover,
                                                      height: 80,
                                                      width: 80,
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        width: 80.0,
                                                        height: 80.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Image.asset(
                                                        "assets/logo.png",
                                                        width: 30,
                                                        height: 30,
                                                      ),
                                                      placeholder:
                                                          (context, url) =>
                                                              Image.asset(
                                                        "assets/logo.png",
                                                        width: 30,
                                                        height: 30,
                                                      ),
                                                    ),
                                                  } else ...{
                                                    Container(
                                                      width: 80,
                                                      height: 80,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              width: 3,
                                                              color:
                                                                  primaryColor),
                                                          shape:
                                                              BoxShape.circle),
                                                      child: Image.asset(
                                                        "assets/logo.png",
                                                        width: 30,
                                                        height: 30,
                                                      ),
                                                    ),
                                                  },
                                                  Positioned(
                                                      right: 4,
                                                      bottom: 3,
                                                      child: Container(
                                                        height: 15,
                                                        width: 15,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              width: 2,
                                                              color:
                                                                  Colors.white),
                                                          shape:
                                                              BoxShape.circle,
                                                          color: listnerDisplayModel
                                                                      ?.data?[
                                                                          index]
                                                                      .onlineStatus ==
                                                                  1
                                                              ? Colors.green
                                                              : Colors.red,
                                                        ),
                                                      ))
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Expanded(
                                              flex: 7,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 6,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    listnerDisplayModel
                                                                            ?.data?[index]
                                                                            .name ??
                                                                        "",
                                                                    style: const TextStyle(
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                  if (listnerDisplayModel
                                                                          ?.data?[
                                                                              index]
                                                                          .busyStatus ==
                                                                      1)
                                                                    Text(
                                                                      listnerDisplayModel?.data?[index].busyStatus ==
                                                                              1
                                                                          ? "Busy"
                                                                          : "",
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              12.0),
                                                                    )
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: colorBlue
                                                                    .withOpacity(
                                                                        0.2),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        9,
                                                                        2,
                                                                        9,
                                                                        2),
                                                                child: Text(
                                                                  "${listnerDisplayModel?.data?[index].age ?? ""}Years",
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          colorBlue),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          listnerDisplayModel
                                                                  ?.data?[index]
                                                                  .about ??
                                                              "",
                                                          maxLines: 2,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  const SizedBox(
                                                      height: 90,
                                                      child: VerticalDivider()),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          listnerDisplayModel
                                                                  ?.data?[index]
                                                                  .ratingReviews
                                                                  ?.averageRating
                                                                  ?.toString() ??
                                                              '0',
                                                          // snapshot.data
                                                          //         ?.averageRating
                                                          //         ?.toString() ??

                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  colorDarkBlue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900),
                                                        ),
                                                        Row(
                                                          children: [
                                                            RatingBar.builder(
                                                              ignoreGestures:
                                                                  true,
                                                              initialRating: double.tryParse(listnerDisplayModel
                                                                          ?.data?[
                                                                              index]
                                                                          .ratingReviews
                                                                          ?.averageRating
                                                                          ?.toString() ??
                                                                      '0.0') ??
                                                                  0.0,
                                                              minRating: 1,
                                                              direction: Axis
                                                                  .horizontal,
                                                              allowHalfRating:
                                                                  true,
                                                              itemCount: 5,
                                                              itemSize: 8,
                                                              itemPadding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          1.0),
                                                              itemBuilder:
                                                                  (context,
                                                                          _) =>
                                                                      const Icon(
                                                                Icons.star,
                                                                color:
                                                                    primaryColor,
                                                                size: 2,
                                                              ),
                                                              onRatingUpdate:
                                                                  (rating) {},
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          (listnerDisplayModel!
                                                                      .data![
                                                                          index]
                                                                      .ratingReviews!
                                                                      .rating5! +
                                                                  listnerDisplayModel!
                                                                      .data![
                                                                          index]
                                                                      .ratingReviews!
                                                                      .rating4! +
                                                                  listnerDisplayModel!
                                                                      .data![
                                                                          index]
                                                                      .ratingReviews!
                                                                      .rating3! +
                                                                  listnerDisplayModel!
                                                                      .data![
                                                                          index]
                                                                      .ratingReviews!
                                                                      .rating2! +
                                                                  listnerDisplayModel!
                                                                      .data![
                                                                          index]
                                                                      .ratingReviews!
                                                                      .rating1!)
                                                              .toString(),
                                                          // listnerDisplayModel
                                                          //         ?.data?[index]
                                                          //         .ratingReviews
                                                          //         ?.averageRating
                                                          //         ?.toString() ??
                                                          //     '0',

                                                          // totalRating.toString(),
                                                          // snapshot.data
                                                          //         ?.rating3
                                                          //         ?.toString() ??
                                                          //     '0',
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  colorBlack),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ]),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          );
                        }),
                  ),
                ),
              ));
  }
}
