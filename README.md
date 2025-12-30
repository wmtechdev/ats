# ATS - Applicant Tracking System

ATS is a comprehensive Flutter web application designed to streamline the recruitment and job application process. The system provides separate interfaces for candidates and administrators, enabling efficient job posting, application management, and candidate evaluation.

## Overview

This Applicant Tracking System facilitates the complete recruitment workflow, from job posting to candidate selection. It allows organizations to manage job openings, review candidate applications, and track document submissions, while providing candidates with a user-friendly platform to search for jobs, submit applications, and manage their professional documents.

## Key Features

### Candidate Interface

The candidate portal provides a complete job application experience:

- **Profile Management**: Candidates can create and maintain their professional profiles, including personal information, contact details, and work history
- **Job Discovery**: Browse available job openings with detailed descriptions, requirements, and status information
- **Application Submission**: Apply to jobs directly through the platform with automatic validation of required documents
- **Document Management**: 
  - Upload required documents specified by employers
  - Create and manage custom documents
  - Track document approval status (pending, approved, denied)
  - View and download uploaded documents
- **Application Tracking**: Monitor the status of submitted applications and view application history
- **Dashboard**: Overview of profile completion status, active applications, and document status

### Admin Interface

The administrative portal offers comprehensive recruitment management:

- **Job Management**: 
  - Create, edit, and manage job postings
  - Set job requirements and required documents
  - Control job status (open/closed)
  - View job details and application statistics
- **Candidate Management**: 
  - View and search candidate profiles
  - Review candidate work history and qualifications
  - Track candidate document submissions
  - Assign agents to candidates (super admin only)
  - Review and manage candidate applications
- **Document Type Management**: 
  - Define required document types for job applications
  - Configure document requirements per job posting
  - Review and approve/deny candidate document submissions
- **Application Review**: 
  - Review submitted applications
  - Update application status (pending, reviewed, approved, denied)
  - Track application progress
- **Admin Management** (Super Admin only): 
  - Create and manage admin accounts
  - Assign roles and access levels (super admin, recruiter)
  - Manage admin profiles

## Architecture

The project follows **Clean Architecture** principles with clear separation of concerns:

- **Presentation Layer**: UI components, screens, and controllers using GetX for state management
- **Domain Layer**: Business logic, entities, repositories (interfaces), and use cases
- **Data Layer**: Repository implementations, data sources, and models for external data handling

The architecture ensures maintainability, testability, and scalability by separating business logic from UI and data sources.

## Technology Stack

- **Framework**: Flutter (Web)
- **State Management**: GetX
- **Backend Services**: 
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
  - Cloud Functions
- **UI Components**: Custom widget library with responsive design
- **Icons**: Iconsax
- **Animations**: Lottie

## Project Structure

```
lib/
├── core/              # Core functionality, utilities, and shared components
│   ├── app/          # App initialization and configuration
│   ├── constants/    # Application constants
│   ├── middleware/   # Route middleware (auth, profile completion)
│   ├── routes/       # Route definitions
│   ├── theme/        # App theming
│   ├── utils/        # Utility classes (colors, spacing, text styles, etc.)
│   └── widgets/      # Reusable UI components
├── data/             # Data layer
│   ├── data_sources/ # Firebase data source implementations
│   ├── models/       # Data models
│   └── repositories/ # Repository implementations
├── domain/           # Domain layer (business logic)
│   ├── entities/     # Domain entities
│   ├── repositories/ # Repository interfaces
│   └── usecases/     # Business use cases
└── presentation/     # Presentation layer
    ├── admin/        # Admin interface screens and controllers
    ├── candidate/    # Candidate interface screens and controllers
    └── common/       # Shared presentation components
```

## User Roles

- **Candidate**: Job seekers who can browse jobs, submit applications, and manage their profiles and documents
- **Recruiter**: Admin users who can manage jobs, review candidates, and process applications
- **Super Admin**: Full access including admin management and candidate agent assignment

## Application Flow

1. **Candidates** register and complete their profiles, then browse available jobs
2. **Candidates** upload required documents before applying to jobs
3. **Candidates** submit applications for positions of interest
4. **Admins** review candidate profiles, documents, and applications
5. **Admins** approve or deny documents and update application statuses
6. **Admins** manage job postings and track recruitment metrics

The system ensures a smooth workflow with proper validation, status tracking, and notifications throughout the recruitment process.
