const admin = require("firebase-admin");
admin.initializeApp();

exports.currentStatusPosts = require("./current_status_posts");
exports.posts = require("./posts");
exports.agora = require("./agora");
exports.pushNotification = require("./push_notification");
exports.voip = require("./voip");
exports.deviceCleanup = require("./cleanup_inactive_devices");