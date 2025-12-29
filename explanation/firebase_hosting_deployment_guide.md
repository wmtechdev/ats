# Firebase Hosting Deployment Guide - ATS Application

## 📋 Table of Contents
1. [Overview](#overview)
2. [Deployment Sites](#deployment-sites)
3. [Deploying Updates](#deploying-updates)
4. [Deployment Commands](#deployment-commands)
5. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

This ATS (Applicant Tracking System) application has **two separate Flutter web applications** deployed on Firebase Hosting:

- **Candidate Application**: User-facing portal for job seekers
- **Admin Application**: Internal dashboard for recruiters and administrators

Both applications are built from the same codebase but use different entry points and are deployed to separate Firebase Hosting sites.

---

## 🌐 Deployment Sites

### Active Sites
- **Candidate Site**: `ats-maximum-candidate`
  - URL: `https://ats-maximum-candidate.web.app`
  - Entry Point: `lib/main_candidate.dart`
  - Build Output: `build/candidate-web/`

- **Admin Site**: `ats-maximum-admin`
  - URL: `https://ats-maximum-admin.web.app`
  - Entry Point: `lib/main_admin.dart`
  - Build Output: `build/admin-web/`

### Configuration
The hosting configuration is defined in `firebase.json` with two hosting targets:
- `candidate` → `ats-maximum-candidate`
- `admin` → `ats-maximum-admin`

---

## 🚀 Deploying Updates

When you make changes to either the candidate or admin side of the application, follow these steps to deploy the updates:

### Step 1: Build the Application(s)

**If you changed candidate-side code:**
```bash
flutter build web --target=lib/main_candidate.dart --release
xcopy /E /I /Y build\web build\candidate-web
```

**If you changed admin-side code:**
```bash
flutter build web --target=lib/main_admin.dart --release
xcopy /E /I /Y build\web build\admin-web
```

**If you changed shared code (affects both):**
```bash
# Build candidate
flutter build web --target=lib/main_candidate.dart --release
xcopy /E /I /Y build\web build\candidate-web

# Build admin
flutter build web --target=lib/main_admin.dart --release
xcopy /E /I /Y build\web build\admin-web
```

### Step 2: Deploy to Firebase Hosting

**Deploy candidate site:**
```bash
firebase deploy --only hosting:candidate
```

**Deploy admin site:**
```bash
firebase deploy --only hosting:admin
```

**Deploy both sites (if you updated shared code):**
```bash
firebase deploy --only hosting:candidate
firebase deploy --only hosting:admin
```

**Note:** Deploy them separately as the combined command syntax may not work correctly.

---

## 📝 Deployment Commands

### Quick Reference

#### Deploy Candidate Updates Only
```bash
flutter build web --target=lib/main_candidate.dart --release
xcopy /E /I /Y build\web build\candidate-web
firebase deploy --only hosting:candidate
```

#### Deploy Admin Updates Only
```bash
flutter build web --target=lib/main_admin.dart --release
xcopy /E /I /Y build\web build\admin-web
firebase deploy --only hosting:admin
```

#### Deploy Both (Full Deployment)
```bash
# Build candidate
flutter build web --target=lib/main_candidate.dart --release
xcopy /E /I /Y build\web build\candidate-web

# Build admin
flutter build web --target=lib/main_admin.dart --release
xcopy /E /I /Y build\web build\admin-web

# Deploy both
firebase deploy --only hosting:candidate
firebase deploy --only hosting:admin
```

---

## 🔍 What Gets Deployed?

### Candidate Application
- **Source**: `lib/main_candidate.dart`
- **Routes**: All candidate routes (login, signup, dashboard, jobs, applications, profile)
- **Features**: Job browsing, application submission, document upload, profile management

### Admin Application
- **Source**: `lib/main_admin.dart`
- **Routes**: All admin routes (login, dashboard, candidates, jobs, applications)
- **Features**: Candidate management, job posting, application review, document approval

### Shared Code
Both applications share:
- Domain layer (entities, repositories, use cases)
- Data layer (models, data sources, repository implementations)
- Core widgets and utilities
- Firebase configuration

---

## 🛠️ Troubleshooting

### Issue: Build fails
**Solution**: 
- Ensure Flutter is up to date: `flutter upgrade`
- Clean build: `flutter clean`
- Get dependencies: `flutter pub get`
- Try building again

### Issue: Deployment fails with "target not found"
**Solution**:
- Verify targets are applied: `firebase target:apply hosting candidate ats-maximum-candidate`
- Verify targets are applied: `firebase target:apply hosting admin ats-maximum-admin`
- Check `firebase.json` has correct target names

### Issue: Changes not reflecting after deployment
**Solution**:
- Clear browser cache or use incognito mode
- Wait a few minutes for CDN propagation
- Check Firebase Console for deployment status
- Verify you deployed to the correct site

### Issue: Build output directory missing
**Solution**:
- Ensure you run the `xcopy` command after building
- Check that `build/candidate-web` and `build/admin-web` directories exist
- Verify the build completed successfully before copying

---

## 📌 Important Notes

1. **Always build before deploying**: The `firebase deploy` command uses the pre-built files in `build/candidate-web` and `build/admin-web`

2. **Deploy separately**: Use separate deploy commands for each site rather than combining them

3. **Check build output**: Verify the build completed successfully before deploying

4. **Test locally first**: Use `flutter run -d chrome --target=lib/main_candidate.dart` to test locally before deploying

5. **Version control**: The `build/` directory should be in `.gitignore` - don't commit build artifacts

---

## 🔗 Related Files

- `firebase.json` - Firebase configuration and hosting setup
- `lib/main_candidate.dart` - Candidate app entry point
- `lib/main_admin.dart` - Admin app entry point
- `lib/core/app/candidate_app.dart` - Candidate app widget
- `lib/core/app/admin_app.dart` - Admin app widget

---

## 📚 Additional Resources

- [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Firebase Hosting Multi-Site Setup](https://firebase.google.com/docs/hosting/multisites)

## 📌 URLs Corrections
    To remove the # (use path-based routing)
    Since Firebase Hosting already rewrites all routes to index.html, you can switch to path-based routing. Add this to your main entry points:
    For main_candidate.dart:
    import 'package:flutter/material.dart';import 'package:flutter_web_plugins/flutter_web_plugins.dart';import 'package:ats/core/app/candidate_initializer.dart';import 'package:ats/core/app/candidate_app.dart';void main() async {  setUrlStrategy(PathUrlStrategy()); // Remove this line to keep hash routing  await CandidateInitializer.initialize();  runApp(const CandidateApp());}
    For main_admin.dart:
    import 'package:flutter/material.dart';import 'package:flutter_web_plugins/flutter_web_plugins.dart';import 'package:ats/core/app/admin_initializer.dart';import 'package:ats/core/app/admin_app.dart';void main() async {  setUrlStrategy(PathUrlStrategy()); // Remove this line to keep hash routing  await AdminInitializer.initialize();  runApp(const AdminApp());}
    For main.dart:
    import 'package:flutter/material.dart';import 'package:flutter_web_plugins/flutter_web_plugins.dart';import 'package:ats/core/app/app_initializer.dart';import 'package:ats/core/app/ats_app.dart';void main() async {  setUrlStrategy(PathUrlStrategy()); // Remove this line to keep hash routing  await AppInitializer.initialize();  runApp(const ATSApp(appType: AppType.admin));}
    After this change, URLs will be:
    https://ats-maximum-candidate.firebaseapp.com/candidate/dashboard (no #)
    Note: Your Firebase Hosting configuration already supports this with the rewrites in firebase.json.