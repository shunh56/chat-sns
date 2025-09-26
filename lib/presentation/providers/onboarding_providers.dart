import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State providers for form data
final usernameProvider = StateProvider<String>((ref) => '');
final nameProvider = StateProvider<String>((ref) => '');
final selectedOtherIdsProvider = StateProvider<List<String>>((ref) => []);
final doingProvider = StateProvider<String>((ref) => '');
final imageProvider = StateProvider<File?>((ref) => null);

// Page control
const ONBOARDING_LENGTH = 4;
final pageIndexProvider = StateProvider((ref) => 0);
final pageControllerProvider =
    Provider((ref) => PageController(initialPage: 0));

// Process state
final creatingProcessProvider = StateProvider.autoDispose((ref) => false);

// Animation providers
final fadeTransitionProvider = StateProvider.autoDispose((ref) => false);
