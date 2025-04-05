# Active Context: Smart Academy Management App

## Current Focus  
The project is entering a new phase, shifting from a single-interface model to a role-based UI architecture. We're restructuring the app to provide different experiences for academy owners, teachers, parents, and students, with appropriate permissions and features for each role.

## Recent Updates  
1. Implemented basic tab structure with Dashboard, Schedule, Classes, and Students tabs
2. Fixed Firebase compound query issues in AttendanceService
3. Added time scheduling features and calendar integration
4. Restructured UI to eliminate duplicate app bars
5. Enhanced error handling in ViewModels
6. Added attendance tracking in student management section

## Next Steps  
1. Reorganize file structure for role-based views
2. Implement role-based routing in main.dart
3. Create separate home screens for each user role
4. Develop parent-specific views (children tracking, attendance, payments)
5. Develop teacher-specific views (class management, student attendance)
6. Enhance authentication with role-specific permissions
7. Apply consistent UI components across role-specific interfaces

## New Architectural Plan
The app will be restructured with role-based views:

```
lib/
  ├── views/
  │    ├── common/      # Shared components (login, profile)
  │    ├── academy/     # Academy owner views
  │    ├── parent/      # Parent views
  │    ├── teacher/     # Teacher views
  │    └── student/     # Student views (if needed)
```

This allows for specialized interfaces while maintaining shared business logic through common ViewModels and Services.

## Current User Role Discovery
Current user authentication is working and retrieving roles correctly:
- User roles: student, teacher, parent, academyOwner, superAdmin
- Role-based routing needs to be implemented
- Firebase currently returns user information including role

## Technical Challenges  
1. Maintaining consistent data access across different role views
2. Implementing appropriate data visibility and permissions
3. Sharing common UI components while providing role-specific features
4. Ensuring proper navigation flows for different user types
5. Handling transitions between roles (if a user has multiple roles)

## Current Priorities  
1. Complete the role-based architecture plan
2. Reorganize the file structure
3. Implement basic screens for each role
4. Ensure consistent UI and UX across all user types