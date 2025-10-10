// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleting_posts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deletingPostsHash() => r'0e33604b14c13106b2d7d299b0c825f3cc8dc9ae';

/// 削除中の投稿IDを管理するProvider
///
/// Copied from [DeletingPosts].
@ProviderFor(DeletingPosts)
final deletingPostsProvider =
    NotifierProvider<DeletingPosts, Set<String>>.internal(
  DeletingPosts.new,
  name: r'deletingPostsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deletingPostsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeletingPosts = Notifier<Set<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
