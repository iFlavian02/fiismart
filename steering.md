# Agent Steering — FiiSmart

## Model Preferences
- UI widgets, screens, animations: Gemini 3.1 Pro
- GoRouter configuration and navigation logic: Gemini 3.1 Pro
- Firebase integration (Auth, Firestore, Storage, FCM): Gemini 3.1 Pro
- Riverpod providers and state logic: Claude Opus 4.6
- Cloud Functions and Genkit flows: Claude Opus 4.6
- Data models and Dart business logic: Claude Opus 4.6
- Weakness tracking logic and decay algorithm: Claude Opus 4.6
- Complex debugging and error handling: Claude Opus 4.6

---

## Folder Structure
```
lib/
  features/
    auth/
      data/           # AuthRepository, FirebaseAuthDataSource
      domain/         # UserModel
      presentation/   # LoginScreen, RegisterScreen, auth_provider.dart
    topics/
      data/           # TopicRepository, FirestoreTopicDataSource
      domain/         # TopicModel, SubjectModel
      presentation/   # HomeScreen, TopicDetailScreen, topics_provider.dart
    quiz/
      data/           # QuizRepository, CloudFunctionDataSource
      domain/         # QuizModel, QuestionModel
      presentation/   # QuizScreen, WrongAnswerScreen, ResultsScreen,
                      # quiz_provider.dart
    progress/
      data/           # ProgressRepository, QuizHistoryDataSource
      domain/         # QuizHistoryModel, WeaknessModel
      presentation/   # ProgressScreen, WeaknessProfileScreen,
                      # progress_provider.dart
    upload/
      data/           # UploadRepository, StorageDataSource
      domain/         # UploadRecordModel
      presentation/   # UploadScreen, upload_provider.dart
  core/
    constants/        # firestore_paths.dart, storage_paths.dart,
                      # route_names.dart
    theme/            # app_theme.dart, colors.dart, text_styles.dart
    utils/            # date_utils.dart, validators.dart
    widgets/          # shared reusable widgets
  main.dart
  router.dart

functions/            # Cloud Functions root (Node.js)
  src/
    flows/            # Genkit flows (uploadPipeline, generateQuiz)
    triggers/         # onObjectFinalized trigger
    scheduled/        # weaknessDecay cron job
  index.ts
```

---

## Coding Conventions

### State Management
- Use Riverpod exclusively — never setState, never Provider, never GetX, never BLoC
- All async providers must use AsyncNotifier
- All providers must handle three states explicitly: loading, error, data
- Keep providers in the presentation layer of each feature folder

### Navigation
- GoRouter only — never Navigator.push directly
- All routes defined in router.dart at the root level
- All route name strings defined as constants in core/constants/route_names.dart
- Auth guard implemented as a GoRouter redirect — never inside screens

### Firebase
- Never call Firebase SDKs directly from widgets
- All Firebase interactions go through a Repository class in the data layer
- All Firestore collection and document path strings defined in
  core/constants/firestore_paths.dart — never hardcode paths inline
- All Cloud Storage path strings defined in core/constants/storage_paths.dart

### Data Models
- Every model must implement: fromJson(), toJson(), copyWith()
- Models live in the domain layer of their feature
- Use freezed package for immutable models if complexity warrants it

### Cloud Functions
- All AI calls (Gemini) happen in Cloud Functions — never from the Flutter
  client directly
- Quiz generation is a callable Cloud Function (not a trigger)
- Material upload processing is a Storage trigger (onObjectFinalized)
- Weakness decay is a scheduled function (runs daily at midnight)

### Error Handling
- Every repository method must return either a Result type or throw typed
  exceptions — never return null to indicate failure
- Every screen must display a meaningful error state, not just a blank screen
- Cloud Functions must catch all errors and update the relevant Firestore
  document with status: "error" before rethrowing

### Code Style
- Prefer const constructors wherever possible
- No magic strings anywhere in the codebase
- All colors referenced from theme tokens only — never hardcode Color(0xFF...)
- All text styles from theme — never hardcode font sizes inline
- Every public method and class must have a dartdoc comment

---

## What to Avoid
- Never use setState in any widget
- Never put business logic inside widgets or screens
- Never call Gemini or any AI API from the Flutter client
- Never hardcode Firestore paths, Storage paths, or route names as strings
- Never use Navigator.push — always use GoRouter named routes
- Never use GetX, BLoC, or Provider
- Never ignore error states in UI — always show loading, error, and empty

---

## Quiz JSON Contract
Cloud Functions must return quiz data in this exact structure:

```json
{
  "quizId": "string",
  "topicId": "string",
  "questions": [
    {
      "questionText": "string",
      "hint": "string | null",
      "options": ["string", "string", "string", "string"],
      "correctIndex": 0,
      "explanation": "string",
      "conceptTag": "string",
      "isWeaknessTargeted": false
    }
  ]
}
```

The Flutter app must never mutate this structure — treat it as read-only.

---

## Gemini Prompt Templates

### Delta Detection Prompt (Genkit — uploadPipeline flow)
```
You are a CS knowledge base curator.

Document A (Existing Master Theory):
{existingTheory}

Document B (Student Upload):
{uploadedContent}

Compare the two documents. Identify any technical concepts, definitions,
or code examples present in Document B that are NOT already covered in
Document A. Output only the genuinely new content formatted in Markdown.
If no new information exists, output exactly: NO_NEW_CONTENT
```

### Quiz Generation Prompt (Genkit — generateQuiz flow)
```
You are a CS exam preparation assistant for university students.

Topic Theory:
{theoryContent}

{weaknessBlock}
// weaknessBlock is injected only if weaknesses exist:
// "The student has the following recorded weaknesses on this topic:
//  {weaknessList}
//  Include at least one question per weak concept.
//  For questions targeting a weakness, include a subtle hint in the
//  question wording that guides the student toward the correct answer
//  without giving it away."

Generate a 10-question multiple choice quiz. Each question must have
exactly 4 options with one correct answer. For each question provide a
clear explanation of why the correct answer is right.

Respond ONLY with a valid JSON array of question objects matching this
schema:
{
  questionText: string,
  hint: string | null,
  options: string[4],
  correctIndex: number,
  explanation: string,
  conceptTag: string,
  isWeaknessTargeted: boolean
}
```

## Design System

All UI must strictly follow the design tokens defined in these files:
- lib/core/theme/colors.dart (AppColors)
- lib/core/theme/text_styles.dart (AppTextStyles)  
- lib/core/theme/app_theme.dart (AppTheme)

These files already exist in the project. Never deviate from them.

### Rules
- Background: always AppColors.background
- Cards and surfaces: AppColors.surface or AppColors.surfaceHighlight
- Primary actions: AppColors.primaryDark
- All text: AppTextStyles tokens only
- Border radius: 12 on buttons, 16 on cards — always use BorderRadius.circular()
- Never use Colors.white, Colors.black, or any raw Color() values in widgets
- All screens use dark theme — never introduce light mode elements