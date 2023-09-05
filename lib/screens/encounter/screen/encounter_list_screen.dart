import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/internet_connectivity_widget.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/encounter_model.dart';
import 'package:kivicare_flutter/network/appointment_repository.dart';
import 'package:kivicare_flutter/network/encounter_repository.dart';
import 'package:kivicare_flutter/screens/doctor/fragments/appointment_fragment.dart';
import 'package:kivicare_flutter/screens/encounter/component/encounter_component.dart';
import 'package:kivicare_flutter/screens/encounter/screen/add_encounter_screen.dart';
import 'package:kivicare_flutter/screens/shimmer/screen/encounter_shimmer_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/int_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

class EncounterListScreen extends StatefulWidget {
  @override
  _EncounterListScreenState createState() => _EncounterListScreenState();
}

class _EncounterListScreenState extends State<EncounterListScreen> {
  Future<List<EncounterModel>>? future;

  List<EncounterModel> encounterList = [];

  int total = 0;
  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    if (appStore.isLoading) {
      appStore.setLoading(false);
    }

    init();
  }

  Future<void> init({bool showLoader = false}) async {
    if (showLoader) appStore.setLoading(true);
    future = getPatientEncounterList(
      id: (isPatient() ? userStore.userId.validate() : null),
      page: page,
      encounterList: encounterList,
      getTotalPatient: (b) => total = b,
      lastPageCallback: (b) => isLastPage = b,
    ).then((value) {
      total = value.length;
      setState(() {});
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      throw e;
    });
  }

  Future<void> updateStatus({int? id, int? status}) async {
    appStore.setLoading(true);

    Map<String, dynamic> request = {
      "appointment_id": id.toString(),
      "appointment_status": status.toString(),
    };

    await updateAppointmentStatus(request).then((value) {
      appStore.setLoading(false);
      appointmentStreamController.add(true);
      toast(locale.lblChangedTo + " ${status.getStatus()}");
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
      throw e;
    });
    setState(() {});
    appStore.setLoading(false);
  }

  Future<void> deleteEncounter(int encounterId) async {
    Map request = {"encounter_id": encounterId};
    appStore.setLoading(true);

    await deleteEncounterData(request).then((value) {
      toast(value['message']);
      init(showLoader: true);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "${locale.lblPatientsEncounter} ${total != 0 ? "($total)" : ""}",
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: InternetConnectivityWidget(
        retryCallback: () {
          setState(() {});
        },
        child: Stack(
          children: [
            SnapHelperWidget<List<EncounterModel>>(
              future: future,
              loadingWidget: EncounterShimmerScreen(),
              errorBuilder: (error) {
                return ErrorStateWidget(
                  error: error.toString(),
                );
              },
              onSuccess: (snap) {
                if (snap.isEmpty) {
                  return NoDataFoundWidget(text: locale.lblNoEncounterFound.capitalizeEachWord(), iconSize: 160);
                }
                return AnimatedScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  disposeScrollController: true,
                  padding: EdgeInsets.only(bottom: 80, top: 16, right: 16, left: 16),
                  onSwipeRefresh: () async {
                    page = 1;
                    init();
                    return await 2.seconds.delay;
                  },
                  onNextPage: () async {
                    if (!isLastPage) {
                      setState(() {
                        page++;
                      });
                      init(showLoader: true);
                      await 1.seconds.delay;
                    }
                  },
                  listAnimationType: listAnimationType,
                  slideConfiguration: SlideConfiguration(verticalOffset: 400),
                  children: [
                    Text('${locale.lblNote} :  ${locale.lblSwipeMassage}', style: secondaryTextStyle(size: 10, color: appSecondaryColor)),
                    8.height,
                    ...snap
                        .map(
                          (encounterData) => GestureDetector(
                            onTap: () {
                              if (isReceptionist() || isDoctor()) {
                                AddEncounterScreen(patientId: encounterData.patientId.toInt(), patientEncounterData: encounterData).launch(context).then((value) {
                                  init();
                                });
                              }
                            },
                            child: EncounterComponent(
                              data: encounterData,
                              deleteEncounter: deleteEncounter,
                              callForRefresh: () {
                                updateStatus(id: encounterData.appointmentId.toInt(), status: CheckOutStatusInt);
                                init(showLoader: true);
                              },
                            ),
                          ),
                        )
                        .toList()
                  ],
                );
              },
            ),
            Observer(
              builder: (context) {
                return LoaderWidget().visible(appStore.isLoading).center();
              },
            )
          ],
        ),
      ),
    );
  }
}
