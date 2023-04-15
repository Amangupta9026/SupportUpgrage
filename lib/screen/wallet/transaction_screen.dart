import 'dart:developer';

import 'package:flutter/material.dart';

import '../../api/api_constant.dart';
import '../../api/api_services.dart';
import '../../global/color.dart';
import '../../model/show_transaction_model.dart';
import '../../sharedpreference/sharedpreference.dart';
import '../../widget/shimmer_progress_widget.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  TransactionScreenState createState() => TransactionScreenState();
}

class TransactionScreenState extends State<TransactionScreen> {
  bool isProgressRunning = false;
  ShowTransactionModel? transactionhistorydata = ShowTransactionModel();
  // TransactionHistory transactionHistory;
  bool isloading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      isloading = false;
    });

    _getTransactionHistory();
  }

  Future<void> _getTransactionHistory() async {
    try {
      setState(() {
        isProgressRunning = true;
      });
      transactionhistorydata = (await APIServices.getTransactionHistory(
        SharedPreference.getValue(PrefConstants.MERA_USER_ID) ?? '',
      ));
    } catch (error) {
      log("$error", name: "error");
    } finally {
      if (mounted) {
        setState(() {
          isProgressRunning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isProgressRunning
        ? ShimmerProgressWidget(count: 8, isProgressRunning: isProgressRunning)
        : transactionhistorydata?.transections?.length != null &&
                transactionhistorydata!.transections!.isNotEmpty
            ? Container(
                color: colorWhite,
                height: MediaQuery.of(context).size.height,
                child: Padding(
                    padding:
                        const EdgeInsets.only(left: 15.0, right: 15, top: 0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          itemCount:
                              transactionhistorydata?.transections?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            return transactionCard(context, index);
                          }),
                    )),
              )
            : _noTransactionFound();
  }

  Widget transactionCard(BuildContext context, int index) {
    // var duration =
    //     transactionhistorydata?.transections?[index].drAmount ?? 0 / 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          transactionhistorydata?.transections?[index].mode?.toUpperCase() ??
              '',
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: colorBlack),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            if (transactionhistorydata?.transections?[index].paymentId ==
                null) ...{
              Text(
                'with ${transactionhistorydata?.transections?[index].listnerName ?? ''}',
                // transactionhistorydata?.transections?[index].paymentId ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorGrey),
              ),
            } else ...{
              Text(
                transactionhistorydata?.transections?[index].paymentId ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colorGrey),
              ),
            },
            const Spacer(),
            if (transactionhistorydata?.transections?[index].crAmount
                    ?.toInt() !=
                0) ...{
              Text(
                '+${transactionhistorydata?.transections?[index].crAmount}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.green),
              ),
            } else ...{
              Text(
                "-₹${transactionhistorydata?.transections?[index].drAmount ?? ""}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: colorRed),
              ),
            }
          ],
        ),
        const SizedBox(
          height: 3,
        ),
        Text(
          "Duration ${transactionhistorydata?.transections?[index].duration ?? "0"} min",
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: colorGrey),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          transactionhistorydata?.transections?[index].createdAt
                  .toString()
                  .substring(0, 10) ??
              "",
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: colorGrey),
        ),
        const SizedBox(
          height: 8,
        ),
        const Divider(
          thickness: 0.5,
          color: colorGrey,
        ),
      ],
    );
  }

  Widget _noTransactionFound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Center(
              child: Text(
                "No Transaction History",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colorBlack),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
