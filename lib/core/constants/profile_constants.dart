import 'world_countries.dart';

class ProfileConstants {
  ProfileConstants._();

  // US States
  static const List<String> usStates = [
    'Alabama',
    'Alaska',
    'Arizona',
    'Arkansas',
    'California',
    'Colorado',
    'Connecticut',
    'Delaware',
    'Florida',
    'Georgia',
    'Hawaii',
    'Idaho',
    'Illinois',
    'Indiana',
    'Iowa',
    'Kansas',
    'Kentucky',
    'Louisiana',
    'Maine',
    'Maryland',
    'Massachusetts',
    'Michigan',
    'Minnesota',
    'Mississippi',
    'Missouri',
    'Montana',
    'Nebraska',
    'Nevada',
    'New Hampshire',
    'New Jersey',
    'New Mexico',
    'New York',
    'North Carolina',
    'North Dakota',
    'Ohio',
    'Oklahoma',
    'Oregon',
    'Pennsylvania',
    'Rhode Island',
    'South Carolina',
    'South Dakota',
    'Tennessee',
    'Texas',
    'Utah',
    'Vermont',
    'Virginia',
    'Washington',
    'West Virginia',
    'Wisconsin',
    'Wyoming',
  ];

  // Country Codes for Phone Numbers
  // Note: Using comprehensive worldwide list from WorldCountries
  // Each entry has a unique 'id' to avoid duplicate values in dropdown
  // The 'code' is the actual phone country code, 'name' is the country name
  static List<Map<String, String>> get countryCodes =>
      WorldCountries.allCountries;

  // Professions (can be changed later as per user requirement)
  static const List<String> professions = [
    'Registered Nurse (RN)',
    'Licensed Practical Nurse (LPN)',
    'Certified Nursing Assistant (CNA)',
    'Nurse Practitioner (NP)',
    'Physician Assistant (PA)',
    'Medical Doctor (MD)',
    'Physical Therapist (PT)',
    'Occupational Therapist (OT)',
    'Respiratory Therapist (RT)',
    'Radiologic Technologist',
    'Medical Laboratory Technologist',
    'Pharmacy Technician',
    'Emergency Medical Technician (EMT)',
    'Paramedic',
    'Medical Assistant',
    'Surgical Technologist',
    'Sonographer',
    'Other',
  ];
}
