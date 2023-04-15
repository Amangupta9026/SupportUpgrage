import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:support/api/api_services.dart';
import 'package:support/global/color.dart';
import 'package:support/model/listner_display_model.dart';
import 'package:support/screen/home/helper_screen.dart';

import '../../api/api_constant.dart';

class TrendingSearches {
  String searchData;

  TrendingSearches({
    required this.searchData,
  });
}

class SearchScreen extends StatefulWidget {
  final ListnerDisplayModel? listnerDisplayModel;
  const SearchScreen({required this.listnerDisplayModel, Key? key})
      : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<TrendingSearches> trendingSearches = [
    TrendingSearches(searchData: "feeling lonely need to talk"),
    TrendingSearches(searchData: "having low confidence"),
    TrendingSearches(searchData: "need to achieve my dream"),
    TrendingSearches(searchData: "no friends in life feeling lonely"),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: colorWhite)),
        title: const Text("Support Search"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22.0, 16, 22, 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Support App",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.listnerDisplayModel?.data?.length ?? 0,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Stack(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 3, color: primaryColor),
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: ExtendedNetworkImageProvider(
                                        "${APIConstants.BASE_URL}${widget.listnerDisplayModel?.data?[index].image}",
                                        cache: true,
                                      ),
                                      fit: BoxFit.fill,
                                    )),
                              ),
                              Positioned(
                                  right: 0,
                                  bottom: 30,
                                  child: Container(
                                    height: 15,
                                    width: 15,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 2, color: Colors.white),
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                  ))
                            ],
                          ),
                        );
                      }),
                ),
                const Text("1000+ Listeners Active Now"),
                const SizedBox(
                  height: 30,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "What do you want to talk about?",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          onFieldSubmitted: (value) async {
                            ListnerDisplayModel? listenerModel =
                                await APIServices.searchListener(
                                    searchTerm: value);
                            if (!mounted) return;
                            if (listenerModel?.status == true) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HelperScreen(
                                            listnerDisplayModel: listenerModel,
                                            isNavigatedFromSearchScreen: true,
                                          )));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("No Listener Found")));
                            }
                          },
                          controller: _searchController,
                          decoration: InputDecoration(
                              isDense: true,
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 20,
                              ),
                              suffixIcon: InkWell(
                                onTap: () {
                                  _searchController.text = "";
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide:
                                      const BorderSide(color: Colors.black)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide:
                                      const BorderSide(color: Colors.black)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide:
                                      const BorderSide(color: Colors.black))),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      "Trending Searches",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    for (int i = 0; i < trendingSearches.length; i++) ...{
                      InkWell(
                        // onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trendingSearches[i].searchData,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            const Divider()
                          ],
                        ),
                      )
                    }
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
