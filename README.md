# Herramientas_Desarrollo_Smartbudget

## Backend — Estructura

```txt
Documents\GitHub\SmartBudget\Backend\
├── api/
│   ├── main.py                  ← FastAPI app + CORS + routers
│   ├── dependencies.py          ← DB session injection
│   ├── routes/
│   │   ├── auth.py
│   │   ├── budgets.py
│   │   ├── expenses.py
│   │   ├── goals.py
│   │   ├── alerts.py
│   │   ├── smartscore.py
│   │   └── simulator.py
│   └── schemas/                 ← Pydantic DTOs
├── core/
│   ├── config.py                ← Settings (pydantic-settings)
│   ├── security.py              ← JWT + hashing
│   ├── auth.py
│   ├── budgets.py
│   ├── expenses.py
│   ├── goals.py
│   ├── alerts.py
│   ├── smartscore.py            ← Lógica del score
│   ├── simulator.py             ← Lógica what-if
│   └── enums.py
├── db/
│   ├── base.py                  ← Declarative Base
│   ├── session.py               ← Engine + SessionLocal
│   └── models.py                ← ORM (User, Budget, Expense, Goal, Alert, SmartScoreSnapshot)
├── requirements.txt
└── .env

mobile/lib/
├── main.dart                          ← Entry point + ProviderScope
├── app.dart                           ← SmartBudgetApp + locale + theme
│
├── core/
│   ├── api_client.dart                ← Dio provider + interceptors (JWT auto-inject)
│   ├── runtime_config.dart            ← Carga apiBaseUrl + ocrWebhookUrl desde runtime.json
│   ├── token_storage.dart             ← Secure storage para access/refresh tokens
│   └── theme.dart                     ← SBColors + buildTheme()
│
├── data/
│   ├── models/
│   │   ├── user.dart
│   │   ├── expense.dart               ← Expense, ExpenseDraft, ExpenseCategory, ExpenseSource
│   │   ├── auth_tokens.dart
│   │   └── ocr_scan_result.dart
│   └── repositories/
│       ├── auth_repository.dart       ← register, login, fetchProfile, logout
│       ├── expense_repository.dart    ← fetchExpenses, createExpense, runAutomation (n8n)
│       ├── budget_repository.dart
│       ├── goals_repository.dart
│       └── smartscore_repository.dart
│
└── features/
    ├── auth/
    │   ├── controllers/
    │   │   └── auth_controller.dart   ← AsyncNotifier<User?> + login/logout/register
    │   └── presentation/
    │       └── login_page.dart
    │
    └── home/
        ├── presentation/
        │   ├── home_shell.dart        ← IndexedStack + NavigationBar (5 tabs)
        │   ├── overview_page.dart     ← Dashboard (stats + transacciones)
        │   ├── budget_page.dart
        │   ├── expenses_page.dart
        │   ├── goals_page.dart
        │   └── profile_page.dart
        └── controllers/
            ├── budget_controller.dart
            └── providers.dart


Flutter App                  Backend (FastAPI)
    │                              │
    │──── POST /api/auth/login ────▶│
    │◀─── { access_token } ─────────│
    │                              │
    │  (Dio interceptor inyecta     │
    │   Bearer token en todos los   │
    │   requests que requieren auth)│
    │                              │
    │──── GET /api/budgets/current ─▶│
    │──── POST /api/expenses/ ─────▶│
    │──── GET /api/goals/ ─────────▶│
    │──── GET /api/smartscore/ ─────▶│
    │──── POST /api/simulator/ ─────▶│
    │                              │
    │  OCR via n8n webhook          │
    │──── POST webhook (multipart) ──→ n8n ──→ OCR ──→ JSON
