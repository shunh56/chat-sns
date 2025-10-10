const admin = require("firebase-admin");
admin.initializeApp();

// 既存の機能
exports.currentStatusPosts = require("./current_status_posts");
exports.posts = require("./posts");
exports.agora = require("./agora");
exports.pushNotification = require("./push_notification");
exports.voip = require("./voip");
exports.deviceCleanup = require("./cleanup_inactive_devices");

// 監視・アラート機能（v2 - 新アーキテクチャ）
const firestoreMonitoringV2 = require("./monitoring/firestore_monitoring_v2");
const functionsMonitoring = require("./monitoring/functions_monitoring");
const authMonitoring = require("./monitoring/auth_monitoring");
const storageMonitoring = require("./monitoring/storage_monitoring");
const reportGenerator = require("./monitoring/report_generator");
const metricsDashboard = require("./monitoring/metrics_dashboard");

// Firestore監視
exports.monitoring_collectFirestoreMetrics = firestoreMonitoringV2.collectFirestoreMetrics;
exports.monitoring_detectAnomalousPatterns = firestoreMonitoringV2.detectAnomalousPatterns;
exports.monitoring_monitorPostsChanges = firestoreMonitoringV2.monitorPostsChanges;
exports.monitoring_monitorUsersChanges = firestoreMonitoringV2.monitorUsersChanges;

// Cloud Functions監視
exports.monitoring_collectFunctionsMetrics = functionsMonitoring.collectFunctionsMetrics;

// Authentication監視
exports.monitoring_collectAuthMetrics = authMonitoring.collectAuthMetrics;
exports.monitoring_monitorUserCreation = authMonitoring.monitorUserCreation;
exports.monitoring_monitorUserDeletion = authMonitoring.monitorUserDeletion;

// Storage監視
exports.monitoring_collectStorageMetrics = storageMonitoring.collectStorageMetrics;
exports.monitoring_monitorFileUpload = storageMonitoring.monitorFileUpload;
exports.monitoring_monitorFileDelete = storageMonitoring.monitorFileDelete;

// 定時レポート
exports.monitoring_generateDailyReport = reportGenerator.generateDailyReport;
exports.monitoring_generateWeeklyReport = reportGenerator.generateWeeklyReport;

// メトリクスダッシュボードAPI
exports.monitoring_getMetricsDashboard = metricsDashboard.getMetricsDashboard;
exports.monitoring_getAlerts = metricsDashboard.getAlerts;
exports.monitoring_healthCheck = metricsDashboard.healthCheck;