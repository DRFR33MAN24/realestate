// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ebroker/data/Repositories/property_repository.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class OwnerPropertyState {}

class GetOwnerInitial extends OwnerPropertyState {}

class GetOwnerFetchProgress extends OwnerPropertyState {}

class GetOwnerProgress extends OwnerPropertyState {}

class GetOwnerSuccess extends OwnerPropertyState {
  final int total;
  final int offset;
  final int currentId;
  final int owner_email;
  final bool isLoadingMore;
  final bool hasError;
  final List<PropertyModel> ownerproperties;

  GetOwnerSuccess({
    required this.owner_email,
    required this.total,
    required this.offset,
    required this.currentId,
    required this.isLoadingMore,
    required this.hasError,
    required this.ownerproperties,
  });

  GetOwnerSuccess copyWith({
    int? total,
    int? offset,
    int? currentId,
    int? owner_email,
    bool? isLoadingMore,
    bool? hasError,
    List<PropertyModel>? ownerproperties,
  }) {
    return GetOwnerSuccess(
      total: total ?? this.total,
      offset: offset ?? this.offset,
      currentId: currentId ?? this.currentId,
      owner_email: owner_email ?? this.owner_email,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      ownerproperties: ownerproperties ?? this.ownerproperties,
    );
  }
}

class GetOwnerFailure extends OwnerPropertyState {
  final dynamic errorMessage;
  GetOwnerFailure(this.errorMessage);
}

class GetOwnerCubit extends Cubit<OwnerPropertyState> {
  GetOwnerCubit() : super(GetOwnerInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();
  Future<void> getOwnerProperties(int owner_email, int currentId,
      {required int offset, bool? useOffset}) async {
    try {
      emit(GetOwnerFetchProgress());

      DataOutput<PropertyModel> result = await _propertyRepository
          .getOwnerProperties(owner_email, currentId, offset: 0);

      emit(GetOwnerSuccess(
          owner_email: owner_email,
          currentId: currentId,
          total: result.total,
          hasError: false,
          isLoadingMore: false,
          offset: 0,
          ownerproperties: result.modelList));
    } catch (e) {
      emit(GetOwnerFailure(e));
    }
  }

  void clearData() {
    if (state is GetOwnerSuccess) {
      emit(GetOwnerInitial());
    }
  }

  Future<void> fetchMoreData() async {
    try {
      if (state is GetOwnerSuccess) {
        if ((state as GetOwnerSuccess).isLoadingMore) {
          return;
        }
        emit((state as GetOwnerSuccess).copyWith(isLoadingMore: true));

        DataOutput<PropertyModel> result =
            await _propertyRepository.getOwnerProperties(
          (state as GetOwnerSuccess).owner_email,
          (state as GetOwnerSuccess).currentId,
          offset: (state as GetOwnerSuccess).ownerproperties.length,
        );

        GetOwnerSuccess bookingsState = (state as GetOwnerSuccess);
        bookingsState.ownerproperties.addAll(result.modelList);
        emit(
          GetOwnerSuccess(
            owner_email: (state as GetOwnerSuccess).owner_email,
            currentId: (state as GetOwnerSuccess).currentId,
            isLoadingMore: false,
            hasError: false,
            ownerproperties: bookingsState.ownerproperties,
            offset: (state as GetOwnerSuccess).ownerproperties.length,
            total: result.total,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as GetOwnerSuccess).copyWith(
          isLoadingMore: false,
          hasError: true,
        ),
      );
    }
  }

  bool hasMoreData() {
    if (state is GetOwnerSuccess) {
      return (state as GetOwnerSuccess).ownerproperties.length <
          (state as GetOwnerSuccess).total;
    }
    return false;
  }
}
