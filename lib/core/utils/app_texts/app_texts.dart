class AppTexts {
  AppTexts._();

  // App Name
  static const String appName = "ATS";

  // Auth
  static const String login = "Login";
  static const String signUp = "Sign Up";
  static const String candidateLogin = "Candidate Login";
  static const String candidateSignUp = "Candidate Sign Up";
  static const String adminLogin = "Admin Login";
  static const String adminSignUp = "Admin Sign Up";
  static const String email = "Email";
  static const String password = "Password";
  static const String firstName = "First Name";
  static const String lastName = "Last Name";
  static const String dontHaveAccount = "Don't have an account? Sign Up";
  static const String alreadyHaveAccount = "Already have an account? Login";

  // Dashboard
  static const String dashboard = "Dashboard";
  static const String adminDashboard = "Admin Dashboard";
  static const String profile = "Profile";
  static const String jobs = "Jobs";
  static const String applications = "Applications";
  static const String documents = "Documents";
  static const String myApplications = "My Applications";
  static const String myDocuments = "My Documents";
  static const String pendingApplications = "Pending Applications";
  static const String openJobs = "Open Jobs";

  // Profile
  static const String saveProfile = "Save Profile";
  static const String profileSaved = "Profile saved successfully";
  static const String phone = "Phone";
  static const String address = "Address";

  // Jobs
  static const String jobDetails = "Job Details";
  static const String jobTitle = "Job Title";
  static const String description = "Description";
  static const String requirements = "Requirements";
  static const String requirementsCommaSeparated = "Requirements (comma separated)";
  static const String apply = "Apply";
  static const String applyNow = "Apply Now";
  static const String applied = "Applied";
  static const String alreadyApplied = "You have already applied to this job";
  static const String noJobsAvailable = "No jobs available";
  static const String createJob = "Create Job";
  static const String editJob = "Edit Job";
  static const String updateJob = "Update Job";
  static const String jobCreated = "Job created successfully";
  static const String jobUpdated = "Job updated successfully";
  static const String jobDeleted = "Job deleted successfully";
  static const String jobNotFound = "Job not found";
  static const String searchJobs = "Search jobs by title or description...";
  static const String all = "All";
  static const String open = "Open";
  static const String closed = "Closed";
  static const String requiredDocuments = "Required Documents";
  static const String noDocumentsAvailable = "No documents available. Create documents first.";
  static const String noRequiredDocuments = "No required documents";
  static const String uploadRequiredDocuments = "Please upload all required documents in the Documents screen before applying for this job";
  static const String allDocumentsUploaded = "All required documents have been uploaded";
  static const String deleteJob = "Delete Job";
  static const String deleteJobConfirmation = "Are you sure you want to delete";
  static const String deleteJobWarning = "This action cannot be undone.";
  static const String closeJob = "Close Job";
  static const String openJob = "Open Job";
  static const String noJobsFound = "No jobs found matching your filters";

  // Applications
  static const String noApplicationsYet = "No applications yet";
  static const String applicationSubmitted = "Application submitted successfully";
  static const String applicationStatus = "Application Status";
  static const String status = "Status";
  static const String pending = "Pending";
  static const String underReview = "Under Review";
  static const String approved = "Approved";
  static const String denied = "Denied";
  static const String totalApplications = "Total Applications";
  static const String approvedApplications = "Approved Applications";
  static const String rejectedApplications = "Rejected Applications";

  // Documents
  static const String upload = "Upload";
  static const String uploading = "Uploading...";
  static const String documentUploaded = "Document uploaded successfully";
  static const String noDocumentTypesAvailable = "No document types available";
  static const String documentStatusUpdated = "Document status updated";
  static const String documentName = "Document Name";
  static const String documentTypes = "Document Types";
  static const String createDocumentType = "Create Document Type";
  static const String documentTypeCreated = "Document type created successfully";
  static const String documentTypeUpdated = "Document type updated successfully";
  static const String documentTypeDeleted = "Document type deleted successfully";
  static const String name = "Name";
  static const String isRequired = "Required";
  static const String documentTitle = "Document Title";
  static const String searchDocuments = "Search documents by title or description...";
  static const String noDocumentsFound = "No documents found matching your search";
  static const String addNewDocument = "Add New Document";
  static const String selectDocument = "Select Document";
  static const String documentFileRequired = "Please select a document file";
  static const String noFileSelected = "No file selected";
  static const String documentFile = "Document File";
  static const String goToDocuments = "Go to Documents";

  // Candidates
  static const String candidate = "Candidate";
  static const String candidates = "Candidates";
  static const String candidateDetails = "Candidate Details";
  static const String noCandidatesAvailable = "No candidates available";
  static const String noCandidatesFound = "No candidates found matching your search";
  static const String candidateNotFound = "Candidate not found";
  static const String searchCandidates = "Search candidates by name, email, company, or position...";
  static const String role = "Role";
  static const String applicationStatusUpdated = "Application status updated";
  static const String agent = "Agent";

  // Admins
  static const String manageAdmins = "Manage Admins";
  static const String manageAdminsToBeImplemented = "Manage Admins - To be implemented";
  static const String administrator = "Administrator";
  static const String admin = "Admin";
  static const String logout = "Logout";
  static const String createNewUser = "Create New User";
  static const String createUser = "Create User";
  static const String fullName = "Full Name";
  static const String recruiter = "Recruiter";
  static const String searchAdmins = "Search admins and recruiters by name...";
  static const String noAdminsFound = "No admins or recruiters found matching your search";
  static const String noAdminsAvailable = "No admins or recruiters available";
  static const String changeRole = "Change Role";
  static const String changeRoleConfirmation = "Are you sure you want to change the role of";
  static const String roleChanged = "Role changed successfully";
  static const String roleChangeFailed = "Failed to change role";
  static const String deleteUser = "Delete User";
  static const String deleteUserConfirmation = "Are you sure you want to delete";
  static const String userDeleted = "User deleted successfully";
  static const String userDeleteFailed = "Failed to delete user";

  // Validation
  static const String emailRequired = "Email is required";
  static const String emailInvalid = "Please enter a valid email address";
  static const String passwordRequired = "Password is required";
  static const String passwordMinLength = "Password must be at least 6 characters";
  static const String firstNameRequired = "First name is required";
  static const String firstNameMinLength = "First name must be at least 2 characters";
  static const String lastNameRequired = "Last name is required";
  static const String lastNameMinLength = "Last name must be at least 2 characters";
  static const String phoneRequired = "Phone number is required";
  static const String phoneInvalid = "Please enter a valid phone number (at least 10 digits)";
  static const String addressRequired = "Address is required";
  static const String addressMinLength = "Address must be at least 5 characters";
  static const String companyRequired = "Company name is required";
  static const String companyMinLength = "Company name must be at least 2 characters";
  static const String positionRequired = "Position is required";
  static const String positionMinLength = "Position must be at least 2 characters";
  static const String jobTitleRequired = "Job title is required";
  static const String jobTitleMinLength = "Job title must be at least 3 characters";
  static const String descriptionRequired = "Description is required";
  static const String descriptionMinLength = "Description must be at least 10 characters";
  static const String requirementsRequired = "Requirements are required";
  static const String documentTitleRequired = "Document title is required";
  static const String documentTitleMinLength = "Document title must be at least 3 characters";

  // Common
  static const String cancel = "Cancel";
  static const String create = "Create";
  static const String update = "Update";
  static const String delete = "Delete";
  static const String edit = "Edit";
  static const String success = "Success";
  static const String error = "Error";
  static const String info = "Info";
  static const String unknownJob = "Unknown Job";
  static const String workHistory = "Work History";
  static const String workTitle = "Work";
  static const String addWorkHistory = "Add Work History";
  static const String company = "Company";
  static const String position = "Position";
  static const String field = "Field";
  static const String value = "Value";
  static const String view = "View";
  static const String request = "Request";
  static const String approve = "Approve";
  static const String deny = "Deny";
  static const String documentsUploadedCount = "Documents Uploaded Count";
  static const String jobsAppliedCount = "Jobs Applied Count";
  
  // Document Viewer
  static const String openInNewTab = "Open in New Tab";
  static const String openInBrowser = "Open in Browser";
  static const String download = "Download";
  static const String pdfViewerNotAvailable = "PDF viewer not available on this platform. Please use the browser to view.";
  static const String documentPreviewNotAvailable = "Document preview not available. Please download or open in browser.";
  static const String documentTypeNotSupported = "This document type is not supported for preview. Please download to view.";
  static const String failedToLoadImage = "Failed to load image";
  static const String failedToLoadDocument = "Failed to load document";
  
  // Document Actions
  static const String reupload = "Reupload";
  static const String deleteDocument = "Delete Document";
  static const String areYouSureDeleteDocument = "Are you sure you want to delete this document?";
  static const String reapply = "Re-apply";
  static const String denyDocument = "Deny Document";
  static const String denyDocumentConfirmation = "Are you sure you want to deny this document? An email will be sent to the candidate.";
  static const String denialReason = "Denial Reason";
  static const String denialReasonHint = "Enter the reason for denial (optional)";
  static const String optional = "Optional";
  static const String documentDenied = "Document denied successfully";
  static const String emailSent = "Email sent successfully";
  static const String emailFailed = "Failed to send email";
}
