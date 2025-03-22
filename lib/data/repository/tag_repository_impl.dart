// lib/data/repositories/tag_repository_impl.dart

import 'dart:convert';
import 'package:app/domain/entity/tag/tag.dart';
import 'package:app/domain/repositories/tag_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class TagRepositoryImpl implements TagRepository {
  final FirebaseFirestore _firestore;

  TagRepositoryImpl(this._firestore);

  @override
  Future<List<Tag>> getAllTags() async {
    try {
      final query = await _firestore
          .collection('tags')
          .orderBy('usageCount', descending: true)
          .get();

      return query.docs.map((doc) => Tag.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get tags: $e');
    }
  }

  @override
  Future<List<Tag>> getTagsByCategory(String category) async {
    try {
      final query = await _firestore
          .collection('tags')
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return query.docs.map((doc) => Tag.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get tags by category: $e');
    }
  }

  @override
  Future<Tag?> getTagById(String tagId) async {
    try {
      final doc = await _firestore.collection('tags').doc(tagId).get();

      if (!doc.exists) {
        return null;
      }

      return Tag.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get tag: $e');
    }
  }

  @override
  Future<List<Tag>> searchTags(String query) async {
    try {
      // 完全一致ではなく、前方一致で検索
      // Firestoreでは部分一致検索に制限があるため
      final querySnapshot = await _firestore
          .collection('tags')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) => Tag.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search tags: $e');
    }
  }

  @override
  Future<void> incrementTagUsage(String tagId) async {
    try {
      await _firestore
          .collection('tags')
          .doc(tagId)
          .update({'usageCount': FieldValue.increment(1)});
    } catch (e) {
      throw Exception('Failed to increment tag usage: $e');
    }
  }

  @override
  Future<void> uploadInitialTags(List<Tag> tags) async {
    try {
      final batch = _firestore.batch();

      for (final tag in tags) {
        final docRef = _firestore.collection('tags').doc(tag.id);
        batch.set(docRef, tag.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to upload initial tags: $e');
    }
  }

  @override
  Future<void> toggleTagActive(String tagId, bool isActive) async {
    try {
      await _firestore
          .collection('tags')
          .doc(tagId)
          .update({'isActive': isActive});
    } catch (e) {
      throw Exception('Failed to toggle tag active status: $e');
    }
  }

  // ローカルのJSONファイルから初期タグを読み込む
  Future<List<Tag>> loadInitialTagsFromAsset(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString);

      return jsonList.map((data) => Tag.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load initial tags from asset: $e');
    }
  }
}
