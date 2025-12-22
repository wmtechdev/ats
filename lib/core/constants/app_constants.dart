class AppConstants {
  AppConstants._();

  // Collections
  static const String usersCollection = 'users';
  static const String candidateProfilesCollection = 'candidateProfiles';
  static const String adminProfilesCollection = 'adminProfiles';
  static const String jobsCollection = 'jobs';
  static const String documentTypesCollection = 'documentTypes';
  static const String candidateDocumentsCollection = 'candidateDocuments';
  static const String applicationsCollection = 'applications';

  // Storage Paths
  static const String documentsStoragePath = 'documents';

  // User Roles
  static const String roleCandidate = 'candidate';
  static const String roleAdmin = 'admin';

  // Admin Access Levels
  static const String accessLevelSuperAdmin = 'super_admin';
  static const String accessLevelRecruiter = 'recruiter';

  // Job Status
  static const String jobStatusOpen = 'open';
  static const String jobStatusClosed = 'closed';

  // Document Status
  static const String documentStatusPending = 'pending';
  static const String documentStatusApproved = 'approved';
  static const String documentStatusDenied = 'denied';

  // Application Status
  static const String applicationStatusPending = 'pending';
  static const String applicationStatusReviewed = 'reviewed';
  static const String applicationStatusApproved = 'approved';
  static const String applicationStatusDenied = 'denied';

  // Route Names
  // Candidate Auth Routes
  static const String routeLogin = '/candidate/login';
  static const String routeSignUp = '/candidate/signup';
  static const String routeForgotPassword = '/candidate/forgot-password';
  // Admin Auth Routes
  static const String routeAdminLogin = '/admin/login';
  static const String routeAdminSignUp = '/admin/signup';
  static const String routeAdminForgotPassword = '/admin/forgot-password';
  // Candidate Routes
  static const String routeCandidateDashboard = '/candidate/dashboard';
  static const String routeCandidateProfile = '/candidate/profile';
  static const String routeCandidateJobs = '/candidate/jobs';
  static const String routeCandidateJobDetails = '/candidate/job-details';
  static const String routeCandidateApplications = '/candidate/applications';
  static const String routeCandidateDocuments = '/candidate/documents';
  static const String routeAdminDashboard = '/admin/dashboard';
  static const String routeAdminJobs = '/admin/jobs';
  static const String routeAdminJobCreate = '/admin/jobs/create';
  static const String routeAdminJobEdit = '/admin/jobs/edit';
  static const String routeAdminCandidates = '/admin/candidates';
  static const String routeAdminCandidateDetails = '/admin/candidates/details';
  static const String routeAdminDocumentTypes = '/admin/document-types';
  static const String routeAdminManageAdmins = '/admin/manage-admins';
}

