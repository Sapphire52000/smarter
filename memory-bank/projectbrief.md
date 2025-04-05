# Project Summary: Smart Academy Management App

## Project Overview
This project is an AI-powered academy management app developed with Flutter and Firebase. It is designed for academy owners and instructors to manage class schedules, communicate with parents, and automate administrative tasks.

The core feature is an AI assistant that reads chat messages exchanged between instructors and parents and **suggests schedule updates**. These suggestions must be confirmed by the academy owner or instructor before being applied. Additionally, the app automatically calculates the number of classes taught, carried-over sessions from the previous month, and tuition fees due—providing real-time financial visibility to the academy administrator.

---

## Key Requirements
1. Firebase-based authentication with role distinction (admin/instructor/parent)  
2. Class schedule management with AI-powered suggestions  
3. AI chat analysis that recommends schedule updates based on parent-teacher conversations  
4. Confirmation prompt to instructor/admin before applying schedule changes  
5. Automatic calculation of class count, carried-over sessions, and current tuition  
6. Dashboard showing monthly attendance and fee status  
7. Monthly roll-over logic for unused class sessions

---

## Tech Stack
- **Flutter** (mobile frontend framework)  
- **Firebase Authentication** (user login and role management)  
- **Cloud Firestore** (database for class, user, and attendance data)  
- **Firebase Functions / Flask** (AI integration backend)  
- **ChatGPT API / Claude / Dialogflow** (chat analysis engine)  
- **Provider or Riverpod** (state management)

---

## Goal
To automate administrative tasks in academy operations using AI, reduce manual scheduling and communication overhead, and ensure accurate, transparent tuition calculations for administrators and instructors.

---

## Project Scope
- Role-based login (admin, instructor, parent)  
- Real-time schedule creation and update system  
- AI-powered chat interpretation with confirmation prompt  
- Attendance tracking and class count aggregation  
- Roll-over session management and automated billing calculation  
- Dashboard UI for academy admin

---

## Constraints
- Dependency on Firebase ecosystem  
- AI model misinterpretation risks (must include user confirmation before applying schedule updates)  
- Multi-platform support (iOS & Android)  
- Data privacy and access control for student and attendance information