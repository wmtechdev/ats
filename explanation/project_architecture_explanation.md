# Complete Code Structure Explanation - ATS Flutter Web Application

## 📋 Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Clean Architecture Layers](#clean-architecture-layers)
3. [Entities - What They Are & Why](#entities)
4. [Use Cases - Purpose & Usage](#use-cases)
5. [Middlewares - Functionality](#middlewares)
6. [Data Flow Diagram](#data-flow)
7. [Layer-by-Layer Breakdown](#layer-breakdown)
8. [Dependency Injection](#dependency-injection)

---

## 🏗️ Architecture Overview

This project follows **Clean Architecture** principles, which separates the code into three main layers:

```
┌─────────────────────────────────────────┐
│     PRESENTATION LAYER (UI)            │
│  - Views (Widgets)                     │
│  - Controllers (GetX State Management) │
│  - Bindings (Dependency Injection)     │
└──────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│     DOMAIN LAYER (Business Logic)       │
│  - Entities (Pure Dart Classes)         │
│  - Repositories (Interfaces)            │
│  - Use Cases (Business Rules)            │
└──────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│     DATA LAYER (External Sources)       │
│  - Models (Firestore Mappings)           │
│  - Data Sources (Firebase APIs)          │
│  - Repository Implementations            │
└─────────────────────────────────────────┘
```

**Key Principle**: Dependencies flow inward. Outer layers depend on inner layers, but inner layers never depend on outer layers.

---

## 📦 Clean Architecture Layers

### 1. **Domain Layer** (Innermost - Business Logic)
**Location**: `lib/domain/`

**Purpose**: Contains pure business logic, independent of frameworks and external libraries.

**Components**:
- **Entities**: Pure Dart classes representing business objects
- **Repositories**: Abstract interfaces defining data operations
- **Use Cases**: Single-purpose business logic operations

**Key Characteristics**:
- ✅ No dependencies on Flutter, Firebase, or GetX
- ✅ Pure Dart code
- ✅ Testable without UI or database
- ✅ Business rules live here

**Example Flow**:
```
Entity → Repository Interface → Use Case
```

---

### 2. **Data Layer** (Middle - Data Management)
**Location**: `lib/data/`

**Purpose**: Handles all data operations, implements domain interfaces.

**Components**:
- **Models**: Extend entities, add Firestore serialization
- **Data Sources**: Direct Firebase API calls
- **Repository Implementations**: Implement domain repository interfaces

**Key Characteristics**:
- ✅ Implements domain interfaces
- ✅ Handles Firebase/Firestore operations
- ✅ Converts between Models and Entities
- ✅ Handles errors and exceptions

**Example Flow**:
```
Firebase API → Data Source → Model → Repository Impl → Entity
```

---

### 3. **Presentation Layer** (Outermost - UI)
**Location**: `lib/presentation/`

**Purpose**: User interface and state management.

**Components**:
- **Views**: Flutter widgets (UI)
- **Controllers**: GetX controllers (State management)
- **Bindings**: Dependency injection setup

**Key Characteristics**:
- ✅ Depends on domain layer
- ✅ Uses GetX for state management
- ✅ Handles user interactions
- ✅ Calls use cases through controllers

**Example Flow**:
```
User Action → View → Controller → Use Case → Repository → Data Source
```

---

## 🎯 Entities - What They Are & Why

### **What are Entities?**

Entities are **pure Dart classes** that represent core business objects. They contain **no framework-specific code** (no Firebase, no Flutter).

### **Purpose**:

1. **Business Object Representation**
   - Represent real-world concepts (User, Job, Application)
   - Define what data is important to your business

2. **Framework Independence**
   - Can be used in any Dart project
   - No dependencies on Firebase, Flutter, or GetX
   - Easy to test

3. **Single Source of Truth**
   - Define the structure of your business data
   - Models in data layer extend entities

### **Example: UserEntity**

```dart
// lib/domain/entities/user_entity.dart
class UserEntity {
  final String userId;
  final String email;
  final String role;
  final String? profileId;
  final DateTime createdAt;

  UserEntity({
    required this.userId,
    required this.email,
    required this.role,
    this.profileId,
    required this.createdAt,
  });
}
```

**Why this structure?**
- ✅ Pure Dart - no external dependencies
- ✅ Immutable (final fields)
- ✅ Represents core business concept
- ✅ Used across all layers

### **All Entities in the Project**:

1. **UserEntity**: Represents a user (candidate or admin)
2. **CandidateProfileEntity**: Candidate's profile information
3. **AdminProfileEntity**: Admin's profile information
4. **JobEntity**: Job posting details
5. **ApplicationEntity**: Job application by candidate
6. **DocumentTypeEntity**: Type of document required
7. **CandidateDocumentEntity**: Document uploaded by candidate

### **Entity Usage Flow**:

```
Domain Layer: Entity (Pure Dart)
    ↓
Data Layer: Model extends Entity (Adds Firestore methods)
    ↓
Presentation Layer: Uses Entity (via Repository)
```

---

## 🔄 Use Cases - Purpose & Usage

### **What are Use Cases?**

Use Cases are **single-purpose business operations**. Each use case represents **one specific action** your app can perform.

### **Purpose**:

1. **Encapsulate Business Logic**
   - One use case = one business operation
   - Example: "Sign Up User", "Create Job", "Upload Document"

2. **Reusability**
   - Can be used by multiple controllers
   - Business logic in one place

3. **Testability**
   - Easy to test in isolation
   - Mock repositories for testing

4. **Separation of Concerns**
   - Controllers don't contain business logic
   - Business logic separate from UI logic

### **Example: SignUpUseCase**

```dart
// lib/domain/usecases/auth/sign_up_usecase.dart
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
  }
}
```

**Why this structure?**
- ✅ Single responsibility (only sign up)
- ✅ Takes repository as dependency
- ✅ Returns `Either<Failure, Success>` for error handling
- ✅ Can be called from any controller

### **Use Case Flow**:

```
Controller → Use Case → Repository → Data Source → Firebase
```

### **All Use Cases in the Project**:

**Authentication**:
- `SignUpUseCase`: Create new user account
- `SignInUseCase`: Authenticate existing user
- `SignOutUseCase`: Log out user
- `ForgotPasswordUseCase`: Send password reset email

**Profile**:
- `CreateProfileUseCase`: Create candidate profile

**Jobs**:
- `GetJobsUseCase`: Retrieve list of jobs
- `CreateJobUseCase`: Create new job posting

**Applications**:
- `CreateApplicationUseCase`: Apply to a job
- `UpdateApplicationStatusUseCase`: Approve/deny application

**Documents**:
- `UploadDocumentUseCase`: Upload candidate document
- `UpdateDocumentStatusUseCase`: Approve/deny document

### **How Controllers Use Use Cases**:

```dart
// In AuthController
final signUpUseCase = SignUpUseCase(Get.find<AuthRepository>());

Future<void> signUp({...}) async {
  final result = await signUpUseCase(
    email: email,
    password: password,
    firstName: firstName,
    lastName: lastName,
  );

  result.fold(
    (failure) => errorMessage.value = failure.message,
    (user) => Get.offAllNamed(AppConstants.routeCandidateProfile),
  );
}
```

---

## 🛡️ Middlewares - Functionality

### **What are Middlewares?**

Middlewares are **route guards** that intercept navigation requests. They run **before** a route is accessed.

### **Purpose**:

1. **Authentication Checks**
   - Verify user is logged in
   - Redirect to login if not authenticated

2. **Authorization Checks**
   - Verify user has correct role (admin vs candidate)
   - Block unauthorized access

3. **Route Protection**
   - Protect sensitive routes
   - Redirect based on user state

### **Example: AuthMiddleware**

```dart
// lib/core/middleware/auth_middleware.dart
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authRepo = Get.find<AuthRepository>();
    
    // Check if user is authenticated
    if (authRepo is AuthRepositoryImpl) {
      final currentUser = authRepo.getCurrentUser();
      
      if (currentUser == null) {
        // Not authenticated, redirect to login
        if (route != AppConstants.routeLogin && 
            route != AppConstants.routeSignUp) {
          return const RouteSettings(name: AppConstants.routeLogin);
        }
      } else {
        // Authenticated, redirect away from login
        if (route == AppConstants.routeLogin) {
          return const RouteSettings(name: AppConstants.routeCandidateDashboard);
        }
      }
    }
    
    return null; // Allow navigation
  }
}
```

**How it works**:
1. User tries to navigate to a route
2. Middleware intercepts the request
3. Checks authentication status
4. Returns `RouteSettings` to redirect OR `null` to allow

### **All Middlewares**:

1. **AuthMiddleware** (`lib/core/middleware/auth_middleware.dart`)
   - **Purpose**: Protect routes requiring authentication
   - **Logic**:
     - If not logged in → redirect to login
     - If logged in → redirect away from login/signup
   - **Usage**: Applied to protected routes

2. **AdminMiddleware** (`lib/core/middleware/admin_middleware.dart`)
   - **Purpose**: Protect admin-only routes
   - **Logic**:
     - If not logged in → redirect to login
     - If not admin → redirect to candidate dashboard
   - **Usage**: Applied to `/admin/*` routes

### **Middleware Flow**:

```
User clicks link → GetX Router → Middleware checks → Allow/Redirect
```

### **How to Apply Middleware**:

```dart
// In app_routes.dart
GetPage(
  name: AppConstants.routeCandidateDashboard,
  page: () => const CandidateDashboardView(),
  binding: CandidateBindings(),
  middlewares: [AuthMiddleware()], // Apply middleware
),
```

---

## 🔄 Data Flow Diagram

### **Complete Request Flow**:

```
┌─────────────────────────────────────────────────────────────┐
│                    USER INTERACTION                         │
│  User clicks "Sign Up" button in LoginView                 │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              PRESENTATION LAYER                             │
│  LoginView (UI Widget)                                      │
│    ↓                                                         │
│  AuthController.signUp()                                    │
│    ↓                                                         │
│  SignUpUseCase.call()                                       │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                DOMAIN LAYER                                 │
│  SignUpUseCase                                              │
│    ↓                                                         │
│  AuthRepository.signUp() [Interface]                        │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                 DATA LAYER                                   │
│  AuthRepositoryImpl [Implementation]                        │
│    ↓                                                         │
│  FirebaseAuthDataSource.signUp()                             │
│    ↓                                                         │
│  FirestoreDataSource.createUser()                            │
│    ↓                                                         │
│  UserModel.toEntity() → UserEntity                          │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              FIREBASE BACKEND                               │
│  Firebase Auth: Create User                                 │
│  Firestore: Create User Document                            │
└─────────────────────────────────────────────────────────────┘
                        │
                        ▼ (Response flows back up)
┌─────────────────────────────────────────────────────────────┐
│  Either<Failure, UserEntity>                                │
│    ↓                                                         │
│  Controller handles result                                  │
│    ↓                                                         │
│  Navigate to Profile or Show Error                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 📂 Layer-by-Layer Breakdown

### **1. Core Layer** (`lib/core/`)

**Purpose**: Shared utilities, constants, and infrastructure code.

**Structure**:
```
core/
├── constants/
│   ├── app_constants.dart      # Route names, status values, roles
│   └── firebase_constants.dart # Firestore field names
├── errors/
│   ├── failures.dart           # Domain error types
│   └── exceptions.dart          # Data layer exceptions
├── middleware/
│   ├── auth_middleware.dart     # Auth route protection
│   └── admin_middleware.dart    # Admin route protection
├── routes/
│   ├── app_routes.dart          # Route definitions
│   └── app_pages.dart           # GetX pages configuration
├── theme/
│   └── app_theme.dart           # App theme configuration
└── utils/
    ├── app_colors/             # Color constants
    ├── app_fonts/              # Font definitions
    ├── app_responsive/         # Responsive utilities
    ├── app_spacing/            # Spacing utilities
    └── app_text_styles/        # Text style utilities
```

**Usage Examples**:
- `AppConstants.routeLogin` - Route name constant
- `AppColors.primary` - Color constant
- `AppResponsive.isMobile(context)` - Check device type
- `AppSpacing.padding(context)` - Get responsive padding

---

### **2. Domain Layer** (`lib/domain/`)

**Purpose**: Pure business logic, no dependencies.

**Structure**:
```
domain/
├── entities/
│   ├── user_entity.dart
│   ├── candidate_profile_entity.dart
│   ├── job_entity.dart
│   ├── application_entity.dart
│   └── ... (7 total entities)
├── repositories/
│   ├── auth_repository.dart           # Interface
│   ├── job_repository.dart            # Interface
│   ├── application_repository.dart    # Interface
│   └── ... (6 total repository interfaces)
└── usecases/
    ├── auth/
    │   ├── sign_up_usecase.dart
    │   ├── sign_in_usecase.dart
    │   └── ...
    ├── job/
    │   ├── get_jobs_usecase.dart
    │   └── create_job_usecase.dart
    └── ... (10+ use cases)
```

**Key Files**:

**Entity Example**:
```dart
// Pure business object
class JobEntity {
  final String jobId;
  final String title;
  final String description;
  // ... no Firebase, no Flutter
}
```

**Repository Interface Example**:
```dart
// Defines what operations are available
abstract class JobRepository {
  Future<Either<Failure, List<JobEntity>>> getJobs({String? status});
  Future<Either<Failure, JobEntity>> createJob({...});
}
```

**Use Case Example**:
```dart
// Single business operation
class GetJobsUseCase {
  final JobRepository repository;
  
  Future<Either<Failure, List<JobEntity>>> call({String? status}) {
    return repository.getJobs(status: status);
  }
}
```

---

### **3. Data Layer** (`lib/data/`)

**Purpose**: Implement domain interfaces, handle Firebase operations.

**Structure**:
```
data/
├── data_sources/
│   ├── firebase_auth_data_source.dart    # Firebase Auth API
│   ├── firestore_data_source.dart        # Firestore API
│   └── firebase_storage_data_source.dart # Storage API
├── models/
│   ├── user_model.dart                   # Extends UserEntity
│   ├── job_model.dart                    # Extends JobEntity
│   └── ... (7 total models)
└── repositories/
    ├── auth_repository_impl.dart         # Implements AuthRepository
    ├── job_repository_impl.dart          # Implements JobRepository
    └── ... (6 total implementations)
```

**Key Files**:

**Model Example**:
```dart
// Extends entity, adds Firestore methods
class JobModel extends JobEntity {
  // Inherits all entity fields
  
  // Firestore serialization
  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobModel(
      jobId: doc.id,
      title: data['title'] ?? '',
      // ...
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      // ...
    };
  }
  
  // Convert to entity
  JobEntity toEntity() {
    return JobEntity(...);
  }
}
```

**Data Source Example**:
```dart
// Direct Firebase API calls
class FirestoreDataSourceImpl {
  final FirebaseFirestore firestore;
  
  Future<String> createJob({...}) async {
    final docRef = await firestore
        .collection('jobs')
        .add({...});
    return docRef.id;
  }
}
```

**Repository Implementation Example**:
```dart
// Implements domain interface
class JobRepositoryImpl implements JobRepository {
  final FirestoreDataSource firestoreDataSource;
  
  @override
  Future<Either<Failure, List<JobEntity>>> getJobs({String? status}) async {
    try {
      final jobsData = await firestoreDataSource.getJobs(status: status);
      final jobs = jobsData.map((data) => JobModel(...).toEntity()).toList();
      return Right(jobs);
    } catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

---

### **4. Presentation Layer** (`lib/presentation/`)

**Purpose**: UI and state management.

**Structure**:
```
presentation/
├── candidate/
│   ├── bindings/
│   │   └── candidate_bindings.dart      # DI setup
│   ├── controllers/
│   │   ├── auth_controller.dart
│   │   ├── jobs_controller.dart
│   │   └── ... (5 controllers)
│   └── views/
│       ├── auth/
│       │   ├── login_view.dart
│       │   └── signup_view.dart
│       ├── jobs/
│       │   └── jobs_list_view.dart
│       └── ... (7 views)
└── admin/
    ├── bindings/
    │   └── admin_bindings.dart
    ├── controllers/
    │   ├── admin_dashboard_controller.dart
    │   └── ... (4 controllers)
    └── views/
        ├── dashboard/
        │   └── admin_dashboard_view.dart
        └── ... (8 views)
```

**Key Files**:

**Binding Example**:
```dart
// Dependency injection setup
class CandidateBindings extends Bindings {
  @override
  void dependencies() {
    // Create data sources
    final authDataSource = FirebaseAuthDataSourceImpl(...);
    
    // Create repositories
    final authRepo = AuthRepositoryImpl(...);
    
    // Register for DI
    Get.lazyPut<AuthRepository>(() => authRepo);
    
    // Create controllers
    Get.lazyPut(() => AuthController(authRepo));
  }
}
```

**Controller Example**:
```dart
// State management
class JobsController extends GetxController {
  final JobRepository jobRepository;
  
  final jobs = <JobEntity>[].obs;  // Observable list
  final isLoading = false.obs;      // Observable loading state
  
  @override
  void onInit() {
    super.onInit();
    loadJobs();  // Load data when controller initializes
  }
  
  void loadJobs() {
    jobRepository.streamJobs().listen((jobsList) {
      jobs.value = jobsList;  // Update observable
    });
  }
}
```

**View Example**:
```dart
// UI Widget
class JobsListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobsController>();
    
    return Scaffold(
      body: Obx(() => ListView.builder(
        itemCount: controller.jobs.length,
        itemBuilder: (context, index) {
          final job = controller.jobs[index];
          return ListTile(title: Text(job.title));
        },
      )),
    );
  }
}
```

---

## 🔌 Dependency Injection

### **How It Works**:

1. **Bindings** set up dependencies
2. **GetX** manages dependency lifecycle
3. **Controllers** get dependencies via `Get.find<>()`

### **Example Flow**:

```dart
// 1. Binding sets up dependencies
class CandidateBindings extends Bindings {
  @override
  void dependencies() {
    // Create and register
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(...));
    Get.lazyPut(() => AuthController(Get.find<AuthRepository>()));
  }
}

// 2. Route uses binding
GetPage(
  name: '/login',
  page: () => LoginView(),
  binding: CandidateBindings(),  // Dependencies created here
)

// 3. Controller gets dependency
class AuthController {
  final signUpUseCase = SignUpUseCase(
    Get.find<AuthRepository>()  // Gets from GetX DI container
  );
}
```

---

## 🎯 Key Concepts Summary

### **Entities**:
- ✅ Pure Dart classes
- ✅ Represent business objects
- ✅ No framework dependencies
- ✅ Used across all layers

### **Use Cases**:
- ✅ Single-purpose operations
- ✅ Encapsulate business logic
- ✅ Reusable across controllers
- ✅ Easy to test

### **Middlewares**:
- ✅ Route guards
- ✅ Authentication checks
- ✅ Authorization checks
- ✅ Run before route access

### **Data Flow**:
```
View → Controller → Use Case → Repository → Data Source → Firebase
```

### **Dependency Direction**:
```
Presentation → Domain ← Data
```
(Inner layers never depend on outer layers)

---

## 📝 Next Steps

Now that you understand the structure, you can:
1. Modify entities to add/remove fields
2. Create new use cases for new features
3. Add middlewares for route protection
4. Extend controllers with new functionality
5. Add new views following the same pattern

The architecture is designed to be:
- ✅ **Maintainable**: Clear separation of concerns
- ✅ **Testable**: Each layer can be tested independently
- ✅ **Scalable**: Easy to add new features
- ✅ **Flexible**: Can swap implementations (e.g., different data sources)

## Complete Sign Up workflow
┌─────────────────────────────────────────────────────────────┐│ STEP 1: USER INTERACTION (Presentation Layer)               │└─────────────────────────────────────────────────────────────┘File: lib/presentation/candidate/views/auth/signup_view.dartUser fills form and clicks "Sign Up" button    ↓SignUpView (UI Widget)    ↓controller.signUp(  email: emailController.text,  password: passwordController.text,  firstName: firstNameController.text,  lastName: lastNameController.text,)┌─────────────────────────────────────────────────────────────┐│ STEP 2: CONTROLLER (Presentation Layer)                    │└─────────────────────────────────────────────────────────────┘File: lib/presentation/candidate/controllers/auth_controller.dartAuthController.signUp() is called    ↓1. Set loading state: isLoading.value = true2. Clear errors: errorMessage.value = ''3. Call use case: await signUpUseCase(...)    ↓SignUpUseCase.call() is invoked┌─────────────────────────────────────────────────────────────┐│ STEP 3: USE CASE (Domain Layer)                             │└─────────────────────────────────────────────────────────────┘File: lib/domain/usecases/auth/sign_up_usecase.dartSignUpUseCase.call() executes    ↓Calls repository: repository.signUp(...)    ↓AuthRepository.signUp() [Interface - no implementation]┌─────────────────────────────────────────────────────────────┐│ STEP 4: REPOSITORY IMPLEMENTATION (Data Layer)              │└─────────────────────────────────────────────────────────────┘File: lib/data/repositories/auth_repository_impl.dartAuthRepositoryImpl.signUp() executes    ↓1. Create Firebase Auth user:   authDataSource.signUp(email, password)   → Returns UserCredential with userId    ↓2. Create Firestore user document:   firestoreDataSource.createUser(userId, email, role)   → Creates document in 'users' collection    ↓3. Create candidate profile:   firestoreDataSource.createCandidateProfile(...)   → Creates document in 'candidateProfiles' collection   → Returns profileId    ↓4. Update user with profileId:   firestoreDataSource.createUser(..., profileId)    ↓5. Create UserModel and convert to Entity:   UserModel(...).toEntity()    ↓6. Return: Right(UserEntity) or Left(AuthFailure)┌─────────────────────────────────────────────────────────────┐│ STEP 5: DATA SOURCES (Data Layer)                            │└─────────────────────────────────────────────────────────────┘Files:- lib/data/data_sources/firebase_auth_data_source.dart- lib/data/data_sources/firestore_data_source.dartFirebaseAuthDataSource.signUp()    ↓FirebaseAuth.instance.createUserWithEmailAndPassword(...)    ↓Returns UserCredentialFirestoreDataSource.createUser()    ↓FirebaseFirestore.instance  .collection('users')  .doc(userId)  .set({...})    ↓Creates document in Firestore┌─────────────────────────────────────────────────────────────┐│ STEP 6: RESPONSE FLOW (Back to Presentation)                │└─────────────────────────────────────────────────────────────┘File: lib/presentation/candidate/controllers/auth_controller.dartResult flows back:Either<Failure, UserEntity>    ↓result.fold(  (failure) {    // Error case    errorMessage.value = failure.message    isLoading.value = false  },  (user) {    // Success case    isLoading.value = false    if (user.role == 'admin') {      Get.offAllNamed('/admin/dashboard')    } else {      Get.offAllNamed('/candidate/profile')    }  })    ↓UI updates automatically (GetX reactive)    ↓User sees success or error message


