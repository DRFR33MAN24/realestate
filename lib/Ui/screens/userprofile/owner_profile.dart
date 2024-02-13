import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:flutter/material.dart';
import '../../../data/cubits/property/owner_property_cubit.dart';
import '../../../data/model/property_model.dart';
import '../../../exports/main_export.dart';
import '../../../utils/AppIcon.dart';
import '../../../utils/api.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/ui_utils.dart';
import '../home/Widgets/property_horizontal_card.dart';
import '../widgets/Erros/no_internet.dart';
import '../widgets/Erros/something_went_wrong.dart';

class OwnerProfileScreen extends StatefulWidget {
  final PropertyModel propertyModel;
  const OwnerProfileScreen({Key? key, required this.propertyModel})
      : super(key: key);

  @override
  _OwnerProfileScreenState createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  late ScrollController controller;

  @override
  void initState() {
    super.initState();

    // context.read<PropertyCubit>().fetchProperty(context, {});
    context.read<GetOwnerCubit>().getOwnerProperties(
        widget.propertyModel.customerId!, widget.propertyModel.id!,
        offset: 0);

    controller = ScrollController()..addListener(pageScrollListen);
  }

  void pageScrollListen() {
    if (controller.isEndReached()) {
      if (context.read<GetOwnerCubit>().hasMoreData()) {
        context.read<GetOwnerCubit>().fetchMoreData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: UiUtils.buildAppBar(context,
            title: UiUtils.getTranslatedLabel(context, "owner_info"),
            showBackButton: true),
        body: ScrollConfiguration(
            behavior: RemoveGlow(),
            child: SingleChildScrollView(
                controller: controller,
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: buildProfilePicture(),
                          ),
                          SizedBox(
                            height: 40.rh(context),
                          ),
                          Text(UiUtils.getTranslatedLabel(context, "fullName")),
                          SizedBox(
                            height: 10.rh(context),
                          ),
                          Text(widget.propertyModel.customerName!).size(24),
                          SizedBox(
                            height: 10.rh(context),
                          ),
                          Text(UiUtils.getTranslatedLabel(
                              context, "companyEmailLbl")),
                          SizedBox(
                            height: 10.rh(context),
                          ),
                          Text(widget.propertyModel.customerEmail!).size(24),
                          SizedBox(
                            height: 10.rh(context),
                          ),
                          Text(UiUtils.getTranslatedLabel(
                              context, "phoneNumber")),
                          SizedBox(
                            height: 10.rh(context),
                          ),
                          Text(widget.propertyModel.customerNumber!).size(24),
                          SizedBox(
                            height: 10.rh(context),
                          ),
                          Text(UiUtils.getTranslatedLabel(
                              context, "addressLbl")),
                          SizedBox(
                            height: 10.rh(context),
                          ),
                          Text(widget.propertyModel.clientAddress!).size(24),
                          const SizedBox(height: 20),
                          Text(UiUtils.getTranslatedLabel(
                                  context, "more_from_owner"))
                              .color(context.color.textColorDark)
                              .size(16)
                              .bold(weight: FontWeight.w600),
                          SizedBox(
                            height: 10.rh(context),
                          ),
                          Container(
                            child:
                                BlocBuilder<GetOwnerCubit, OwnerPropertyState>(
                              builder: (context, state) {
                                return listWidget(state);
                              },
                            ),
                          ),
                        ])))));
  }

  Widget buildProfilePicture() {
    return Stack(
      children: [
        Container(
          height: 200.rh(context),
          width: 200.rw(context),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.color.tertiaryColor, width: 2)),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.color.tertiaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            width: 180.rw(context),
            height: 180.rh(context),
            child: UiUtils.getImage(widget.propertyModel.customerProfile ?? "",
                fit: BoxFit.cover),
          ),
        ),
        (widget.propertyModel.customerVerified == 1)
            ? PositionedDirectional(
                bottom: 0,
                end: 0,
                child: InkWell(
                  onTap: null,
                  child: Container(
                      height: 60.rh(context),
                      width: 60.rw(context),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: context.color.buttonColor, width: 1.5),
                          shape: BoxShape.circle,
                          color: Colors.transparent),
                      child: SizedBox(
                          width: 30.rw(context),
                          height: 30.rh(context),
                          child: UiUtils.getSvg(AppIcons.verified))),
                ),
              )
            : SizedBox()
      ],
    );
  }

  Widget listWidget(OwnerPropertyState state) {
    if (state is GetOwnerFetchProgress) {
      return Center(
        child:
            UiUtils.progress(normalProgressColor: context.color.tertiaryColor),
      );
    }
    if (state is GetOwnerFailure) {
      if (state.errorMessage is ApiException) {
        return NoInternet(
          onRetry: () {
            context.read<GetOwnerCubit>().getOwnerProperties(
                widget.propertyModel.customerId!, widget.propertyModel.id!,
                offset: 0);
          },
        );
      }
      return const SomethingWentWrong();
    }

    if (state is GetOwnerSuccess) {
      if (state.ownerproperties.isEmpty) {
        return Center(
          child: Text(
            UiUtils.getTranslatedLabel(context, "nodatafound"),
          ),
        );
      }
      // if (searchController.text == "") {
      //   return Center(
      //     child: Text(
      //       UiUtils.getTranslatedLabel(context, "nodatafound"),
      //     ),
      //   );
      // }
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Wrap(
              direction: Axis.horizontal,
              children: List.generate(state.ownerproperties.length, (index) {
                PropertyModel property = state.ownerproperties[index];
                List propertiesList = state.ownerproperties;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      HelperUtils.goToNextPage(
                          Routes.propertyDetails, context, false, args: {
                        'propertyData': property,
                        'propertiesList': propertiesList
                      });
                    },
                    child: PropertyHorizontalCard(property: property),
                  ),
                );
              }),
            ),
            if (state.isLoadingMore) UiUtils.progress()
          ],
        ),
      );
    }
    return Container();
  }
}
