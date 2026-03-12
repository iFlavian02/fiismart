# FiiSmart — Spec v1.0

## Overview
A Flutter mobile app for Computer Science students to learn and prepare for
exams by taking AI-generated quizzes on specific CS topics. The app adapts
to each student's weaknesses over time, injecting personalized hints into
quiz prompts to help reinforce weak concepts rather than penalize them.

The app's knowledge base grows over time as students upload their own notes
and materials, which are automatically merged into the developer-curated
topic files using Gemini's semantic understanding.

---

## Target Users
Computer Science university students preparing for theoretical exams.

---

## User Stories

### Authentication
- As a student, I can register with my university email and password
- As a student, I can log in and stay logged in across sessions
- As a student, I can reset my password via email

### Quiz Flow
- As a student, I can browse all available CS topics
- As a student, I can select a topic and start a quiz
- As a student, I can answer multiple choice questions one at a time
- As a student, if I answer correctly, I move to the next question immediately
- As a student, if I answer incorrectly, I see an explanation of the correct
  answer before moving to the next question
- As a student, I can see my score and a concept-level breakdown at the end
  of each quiz

### Personalization
- As a student, I can view my weakness profile per topic
- As a student, I receive hints on questions targeting my recorded weaknesses
- As a student, my weaknesses decay over time as I answer correctly

### Material Upload
- As a student, I can upload my personal notes (PDF or plain text) for a
  specific topic
- As a student, I am notified when my upload has been processed and merged

### Progress Tracking
- As a student, I can view my quiz history
- As a student, I can see my improvement over time per topic and per concept

---

## Functional Requirements

### Authentication
- Email/password registration and login via Firebase Auth
- Persistent session across app restarts
- Password reset via email link

### Topic Browser
- Topics are organized by CS subject (e.g. Data Structures, OOP, Algorithms)
- Each subject contains multiple concept-level topic files
- Topics display a difficulty indicator and the student's last score if
  previously attempted

### Quiz Generation
- Quizzes are generated on demand by Gemini 3.1 Flash
- Each quiz contains 10 multiple choice questions with 4 options each
- Gemini receives the topic's theory file as context (with context caching)
- If the student has recorded weaknesses on the selected topic, the prompt
  includes the specific weak concepts and instructs Gemini to:
    - Include at least one question per weak concept
    - Provide a subtle hint in the question wording for those concepts
- Questions are returned as structured JSON
- Wrong answer flow: display correct answer explanation → student taps
  "Next Question" → proceed

### Weakness Tracking
- Unit of weakness: a specific concept (e.g. "recoloring red-black trees",
  "OOP constructor overloading")
- Concepts are extracted from Gemini's quiz JSON response as metadata tags
  per question
- When a student answers incorrectly: increment weakness score for that
  concept
- When a student answers correctly on a previously weak concept: decrement
  weakness score
- Weakness score reaches zero: concept is removed from weakness profile
- Weakness decay: if a concept has not been encountered in 30 days, reduce
  its score by 1 automatically (Cloud Function scheduled job)

### Material Upload Pipeline
1. Student selects a topic and uploads a PDF or .txt file from their device
2. File is uploaded to Cloud Storage for Firebase under
   uploads/{userId}/{topicId}/{timestamp}_{filename}
3. A Cloud Function triggers on upload completion (onObjectFinalized)
4. A Genkit flow is invoked:
   a. Retrieve the existing master theory file from Firestore for that topic
   b. Send both the existing theory and the uploaded file to Gemini Flash
   c. System prompt instructs Gemini to extract only concepts, definitions,
      or code examples in the uploaded file NOT present in the existing theory
   d. If Gemini returns NO_NEW_CONTENT, terminate the flow
   e. If new content is found, invoke a second Gemini call to cleanly
      integrate the new content into the master theory file
   f. Overwrite the master theory document in Firestore with the updated file
5. Update the upload record in Firestore with status: "merged" or
   "no_new_content"
6. Send a Firebase Cloud Messaging push notification to the student

### Context Caching
- Master theory files are cached in Gemini's context cache on first access
- Cache is invalidated and refreshed whenever a theory file is updated after
  a successful merge

### Progress & History
- Every completed quiz is stored in Firestore under
  quizHistory/{userId}/{quizId}
- Stored fields: topic, score, timestamp, per-question result, concepts
  encountered
- Progress screen shows score trend per topic over time

---

## Non-Functional Requirements
- Offline support: topic list and quiz history browsable without internet
  (cached via Hive)
- Quiz generation response time: target under 3 seconds on 4G
- Support Android 10+ and iOS 14+
- Firebase App Check enabled to prevent unauthorized API quota usage
- All Gemini calls happen server-side via Cloud Functions — never from the
  client directly

---

## Screens
1. Splash / Onboarding
2. Login / Register / Password Reset
3. Home — topic browser organized by subject
4. Topic Detail — subject info, student's last score, start quiz button,
   upload materials button
5. Quiz Screen — one question at a time, progress bar, hint badge if
   weakness-targeted
6. Wrong Answer Screen — correct answer highlighted, explanation text,
   "Next Question" button
7. Quiz Results — score, concept breakdown, weaknesses updated indicator
8. Progress Screen — score history charts per topic, weakness profile
9. Upload Screen — file picker, topic selector, upload status

---

## Data Models

### User (Firestore: users/{userId})
```
{
  uid: string,
  email: string,
  displayName: string,
  createdAt: timestamp
}
```

### WeaknessProfile (Firestore: weaknesses/{userId}/concepts/{conceptId})
```
{
  conceptId: string,
  conceptLabel: string,
  topicId: string,
  score: number,         // increments on wrong, decrements on correct
  lastEncountered: timestamp
}
```

### TopicFile (Firestore: topics/{subjectId}/concepts/{topicId})
```
{
  topicId: string,
  label: string,
  subjectId: string,
  theoryMarkdown: string,   // the master theory content
  updatedAt: timestamp,
  geminiCacheToken: string  // context cache reference
}
```

### QuizHistory (Firestore: quizHistory/{userId}/{quizId})
```
{
  quizId: string,
  topicId: string,
  score: number,
  totalQuestions: number,
  timestamp: timestamp,
  questions: [
    {
      questionText: string,
      options: string[],
      correctIndex: number,
      selectedIndex: number,
      conceptTag: string,
      wasWeak: boolean,
      explanation: string
    }
  ]
}
```

### UploadRecord (Firestore: uploads/{userId}/{uploadId})
```
{
  uploadId: string,
  topicId: string,
  storageUrl: string,
  status: "processing" | "merged" | "no_new_content" | "error",
  uploadedAt: timestamp,
  processedAt: timestamp
}
```

---

## Tech Stack

| Layer | Technology | Rationale |
|---|---|---|
| Mobile | Flutter (Dart) | Cross-platform iOS + Android |
| State Management | Riverpod | Official Flutter recommendation, clean async |
| Navigation | GoRouter | URL-style routing, auth guards |
| Local Cache | Hive | Fast offline storage for topics and history |
| Auth | Firebase Auth | Simple email/password, persistent sessions |
| Database | Firestore | Real-time, scales automatically |
| File Storage | Cloud Storage for Firebase | Native Firebase integration |
| Backend Logic | Cloud Functions (Node.js) | Serverless, Firebase-native |
| AI Orchestration | Firebase Genkit | Multi-step AI flow management |
| AI Model | Gemini 3.1 Flash | Fast, large context window, context caching |
| Push Notifications | Firebase Cloud Messaging | Upload completion alerts |
| Security | Firebase App Check | Prevent unauthorized API usage |

---

## Architecture Diagram

```
Flutter App
    │
    ├── Firebase Auth (login/register)
    ├── Firestore (read topics, quiz history, weaknesses)
    ├── Hive (offline cache)
    ├── Cloud Storage (upload notes)
    └── FCM (receive notifications)

Cloud Functions
    │
    ├── onObjectFinalized → Genkit Flow
    │       ├── Gemini Flash (delta detection)
    │       ├── Gemini Flash (theory merge)
    │       └── Firestore (update theory file)
    │
    ├── generateQuiz (callable)
    │       ├── Firestore (fetch theory + weaknesses)
    │       ├── Gemini Flash (generate quiz JSON)
    │       └── Return quiz to Flutter app
    │
    └── scheduledWeaknessDecay (cron daily)
            └── Firestore (decrement stale weakness scores)
```
