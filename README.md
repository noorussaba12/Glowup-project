# Glow — AI Skin Health App (Working MVP)

> A personalized clinical skincare and nutrition mobile app built with Flutter, Riverpod, Google ML Kit on-device face detection, Firebase, and a multimodal vision AI backend.
> Designed to match the luxury aesthetic of the reference Pinterest design: warm ivory/linen backgrounds, dusty blush rose accents, dark espresso pill buttons, refined serif headlines, and rounded card geometry.

---

## 🎨 Visual Design Matching Reference

- **Female Theme (Glow Pink):** Warm ivory `#FAF6F0`, soft blush rose `#C58B7D`, soft peach icon circles `#F5EBE6`, dark espresso pill buttons `#26201E`.
- **Male Theme (Glow Blue):** Cool crisp white `#F4F7F9`, calm slate sky blue `#4A7C9D`, ice blue icon circles `#E6EFF5`, deep navy charcoal pill buttons `#1A222E`.
- **Typography:** Playfair Display (editorial serif elegance for headers and logo) paired with Inter (modern readable sans for clinical data and chat).
- **Cards & Geometry:** 24px border radius with subtle diffused shadows and 30px stadium pill buttons.

---

## 📱 Complete App Flow (13 Screens)

1. **Screen 1: Splash** — Botanical Glow emblem, serif brand title, tagline, auto-routes based on auth & onboarding status.
2. **Screen 2: Sign Up / Sign In** — Pill segmented tab toggle, email/password, Google sign-in, age/name inputs, password reveal, terms checkbox, forgot password modal.
3. **Screen 3: Gender Selection** — "Let's personalize your Glow", Female (Pink theme) vs Male (Blue theme) cards with instant live theme switching.
4. **Screen 4: Home Dashboard** — Personalized greeting, AI skin score ring, last scan date, promotional banner card, primary "Scan your face" hero button, category icon circles (Hydration, Pores, Dark Circles, Sun Care), tip of the day, floating bottom nav.
5. **Screen 5: Scan Instructions** — Swipeable 6-tip carousel (daylight, glasses off, arm's length, neutral expression, oval guide, hold still) with "Don't show again" preference.
6. **Screen 6: Real Face Scanner** — Live front camera feed, oval face guide, animated laser scan line, real-time ML Kit validation (face detected, centered, distance, head angle straight, lighting), live feedback hints, gallery upload with quality checks, review modal with "Use Photo" / "Retake".
7. **Screen 7: Analysis Loading** — Pulsing glowing ring with rotating diagnostic messages ("Checking hydration...", "Analyzing pores...", "Detecting dark circles..."), timeout handling, retry mechanism.
8. **Screen 8: Detected Skin Issues** — Overall skin score (0-100), facial zone filter chips (Forehead, Cheeks, Under-Eyes, Nose, Chin), severity progress bars (None / Mild / Moderate / Severe), confidence levels, plain-language clinical explanations.
9. **Screen 9: Consultation Chat Questionnaire** — Chatbot UI with typing indicator, 13 structured clinical questions (skin type, sensitivity, tone, current products, SPF habits, water intake, sleep, diet, stress, sun exposure, goals, medical history) with tap chips and custom text.
10. **Screen 10: Doctor Consultation Report** — Warm empathetic cosmetic dermatologist consultation, profile summary, what you're doing right, what you could improve, likely causes, dermatologist warning flags, medical disclaimer, and **PDF Report Export/Share**.
11. **Screen 11: Priority Selection** — Select and rank top 3 priorities with numbered badges (Priority 1, 2, 3), custom recommendations for each concern, reordering/reset.
12. **Screen 12: My Plan** — Skincare routine (AM & PM steps, key active ingredients, application instructions, conflict warnings, weekly enzyme mask), Nutrition routine (foods to eat more, foods to limit, hydration target in Liters, 1-day sample meal plan, supplements), Lifestyle tips, 4-Week strategic roadmap, and interactive Daily Checklist with streak counter ("🔥 3 Day Streak").
13. **Screen 13: History & Profile** — Scan history timeline with score badges, side-by-side comparative mode (score diff, metric improvements), Profile settings with instant live Pink/Blue theme switcher, edit name/age, retake questionnaire, delete history, GDPR-compliant delete account & all data, sign out.

---

## 🛠️ Project Structure

```
Glow up/
├── glow_app/                  # Flutter Mobile Codebase
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/     # App constants, disclaimers, config
│   │   │   ├── router/        # go_router configuration for all 13 screens
│   │   │   ├── services/      # Firebase, LocalStorage, API client
│   │   │   └── theme/         # GlowTheme, GlowPalette (Pink & Blue), Riverpod ThemeNotifier
│   │   ├── features/
│   │   │   ├── analysis/      # Loading & Results screens
│   │   │   ├── auth/          # Sign In / Sign Up
│   │   │   ├── chat/          # Chat questionnaire
│   │   │   ├── history/       # History & Side-by-Side comparison
│   │   │   ├── home/          # Home dashboard
│   │   │   ├── onboarding/    # Splash & Gender selection
│   │   │   ├── plan/          # Priority selection & My Plan
│   │   │   ├── profile/       # Profile settings & theme switcher
│   │   │   ├── report/        # Doctor consultation & PDF export
│   │   │   └── scan/          # Scan instructions & Camera scanner
│   │   ├── shared/            # Reusable widgets (cards, pill buttons, tabs, models)
│   │   └── main.dart          # App entrypoint with ProviderScope
│   └── pubspec.yaml           # Dependencies (Riverpod, ML Kit, Camera, PDF, Firebase)
│
├── glow_backend/              # Express AI Vision & Plan Synthesis Server
│   ├── server.js              # Multer upload, Gemini Vision API, strict JSON schema
│   ├── package.json           # Node.js dependencies
│   ├── .env.example           # Environment template
│   └── .env                   # Local server configuration
│
├── glow_web_preview/          # Instant Live Web Simulator
│   └── index.html             # High-fidelity mobile simulator with all 13 screens
│
├── FIREBASE_SETUP.md          # Full Firebase Auth, Firestore, and Storage guide
├── start_glow.bat             # One-click launcher for backend & preview
└── README.md                  # This file
```

---

## 🚀 How to Run

### 1. Run the AI Backend
```bash
cd "Glow up/glow_backend"
npm install
npm start
```
The server will run at `http://localhost:5000` with endpoints:
- `GET  /api/health`
- `POST /api/analyze-skin`
- `POST /api/generate-plan`

*(Optional: Add your `GEMINI_API_KEY` in `glow_backend/.env` from Google AI Studio. If left blank, the server automatically uses the built-in clinical dermatological engine for offline testing).*

### 2. Run the Interactive Web Simulator
Double-click `start_glow.bat` or open `glow_web_preview/index.html` in any browser (Chrome, Edge, Safari). You can test all 13 screens, toggle themes, and run through the entire flow interactively!

### 3. Run the Flutter Mobile App
Make sure Flutter SDK and Android emulator / USB device are set up:
```bash
cd "Glow up/glow_app"
flutter pub get
flutter run
```

---

## 🚫 What is NOT Included in this MVP

To maintain a laser-focused, production-grade clinical MVP, the following are deliberately excluded from this scope:
1. In-app payment processing or paywalls (Stripe / In-App Purchases).
2. Push notifications / remote background messaging.
3. E-commerce product checkout / direct brand affiliate shopping cart.
4. Dark mode (the luxury Pinterest design specifies light ivory and slate white modes).
5. Multi-language internationalization (MVP is in English).

---

## ✅ Comprehensive Testing Checklist

### Theme Switching Verification
- [ ] Select **Female** -> Background switches to `#FAF6F0`, rose accents `#C58B7D`, peach icon badges `#F5EBE6`, espresso buttons.
- [ ] Select **Male** -> Background switches to `#F4F7F9`, slate blue accents `#4A7C9D`, ice blue icon badges `#E6EFF5`, navy buttons.
- [ ] Open **Profile > App Theme & Ambience** -> Toggle Pink vs Blue -> Entire app updates theme immediately without restarting.

### Screens 1 to 7 (Onboarding & Scanner)
- [ ] **Screen 1 (Splash):** Displays botanical emblem, serif font, tagline. Tapping "Get Started" routes correctly.
- [ ] **Screen 2 (Auth):** Toggle between Sign In and Sign Up tabs. Password obscure toggle works. Form validation blocks empty email/passwords. Google sign-in works.
- [ ] **Screen 3 (Gender):** Highlights selection card with border, updates theme live, saves to preferences.
- [ ] **Screen 4 (Home):** Displays greeting with user name, circular score gauge, banner card, 4 category circle buttons, tip of the day, and bottom navigation bar.
- [ ] **Screen 5 (Scan Instructions):** Swipe through all 6 carousel cards. Checking "Don't show again" skips screen on subsequent scans.
- [ ] **Screen 6 (Scanner):** Oval guide renders with sweeping laser animation. Real-time checks display passing pills. Gallery upload runs face detection and rejects tilted or non-face images. Capture triggers review mode with "Retake" and "Use Photo".
- [ ] **Screen 7 (Analysis Loading):** Pulsing animated spinner with rotating diagnostic messages. Handles server timeout and shows "Retry" button.

### Screens 8 to 13 (Report, Plan, History)
- [ ] **Screen 8 (Detected Issues):** Overall score ring displays (e.g. 82/100). Concern cards show severity badges (Mild, Moderate, Severe), progress bars, confidence %, and explanations. Zone filter chips filter concerns.
- [ ] **Screen 9 (Chat Questionnaire):** Assistant asks questions one by one with typing animation indicator. Options selectable via chips. Back button allows editing previous answers.
- [ ] **Screen 10 (Doctor Report):** Employs warm doctor voice ("First, here's what I noticed..."). Lists what you're doing right, what you could improve, likely causes, and dermatologist red flags. Tapping "Download / Share Report (PDF)" generates and opens a clean PDF document.
- [ ] **Screen 11 (Priority Selection):** Tapping concerns assigns Priority 1, Priority 2, Priority 3 numbered badges. Contextual recommendations display. Reset button clears selections.
- [ ] **Screen 12 (My Plan):** Segmented pill tabs switch smoothly between Skincare, Nutrition, Lifestyle, 4-Week Timeline, and Daily Checklist. Tapping checklist steps marks them complete and tracks streak count.
- [ ] **Screen 13 (History & Profile):** Past scans list chronologically with dates and scores. Tapping "Compare" displays side-by-side comparison with score differences and metric improvements. Profile allows editing details, retaking questionnaire, clearing scan history, deleting account & data, and signing out.
