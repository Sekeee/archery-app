import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewMatchState {
  // Loading state
  final RxBool isLoading = false.obs;
  
  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController endsController = TextEditingController();
  final TextEditingController arrowsPerEndController = TextEditingController();
  
  // Reactive values for total calculation
  final RxInt totalArrows = 0.obs;
  
  // Match type (category)
  final RxString selectedMatchType = 'Range'.obs;
  
  // Available match types (categories)
  final List<String> matchTypes = [
    'Range',
    'Moving Object',
    'Horseback',
    'Long Distance',
    'Dynamic Shooting',
  ];
  
  // Error message
  final RxString errorMessage = ''.obs;
}
