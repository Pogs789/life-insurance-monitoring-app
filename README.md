# iRemitMo: The Insurance Agent's Remittance Management System

This is a simple tool for insurance agents which automatically calculates the monthly collection needed to be remitted to the insurance company.

## 🚧 Project Status

https://insurance-agent-remittance-engine-frontend.vercel.app

Documentation may not reflect the latest implementation yet.
Major updates to architecture and features are ongoing.

Last updated: June 2026

## 📋 Table of Contents
- [Problem Statement](#problem-statement)
- [Features of the Application](#features-of-the-application)
- [Technologies Used](#technologies-used)
- [Architecture](#architecture)
- [Folder Structure](#folder-structure)
    - [Flutter (Mobile App)](#flutter-mobile-app)
    - [NestJS (Backend API)](#nestjs-backend-api)
- [Getting Started](#getting-started)
- [API Documentation](#api-documentation)
- [Contributing](#contributing)

---

## 🎯 Problem Statement

Insurance Agents every single month have to manually monitor insurance planholders to ensure that they are making their payments on time.  This process is tedious, time-consuming, and prone to human error.  Additionally, insurance agents often struggle to keep track of multiple insurance plans and their respective remittance schedules.

### Solution
This application provides an automated monitoring system that:
- Tracks payment schedules automatically
- Sends timely reminders to planholders
- Provides real-time dashboard for agents
- Reduces manual tracking errors
- Streamlines the entire remittance process

---

## ✨ Features of the Application

### For Insurance Agents
- **User Authentication** - Secure Sign Up, Login, and Logout
- **Automated Calculation of Insurance Remittance** - Automated tracking of payment schedules
- **User Profile Management** - Manage agent profile and preferences

### For Admin/Insurance Providers
- **Admin Dashboard** - Comprehensive overview of all agents and policies
- **Agent Performance Tracking** - Monitor agent activities and success rates
- **Reports & Analytics** - Generate insights on payments and policy performance

---

## 🛠️ Technologies Used

### Frontend (Mobile Application)
- **Flutter** - Cross-platform framework (iOS and Android)
- **Dart** - Programming language
- **Provider** - State management solution
- **Dio** - HTTP client for API requests
- **Secure Storage** - Secured Data persistence

### Backend (API Server)
- **NestJS** - Progressive Node.js framework
- **TypeScript** - Strongly-typed programming language
- **PostgreSQL** - Relational database
- **PrismaORM** - Object-Relational Mapping
- **JWT** - JSON Web Tokens for authentication
- **Passport** - Authentication middleware

### DevOps & Tools
- **Git** - Version control
- **Docker** - Containerization (optional)
- **Postman** - API testing
- **AWS** - Cloud Platform

---

## 🏗️ Architecture

This application follows **Clean Architecture** principles, ensuring:
- ✅ **Separation of Concerns** - Each layer has a single responsibility
- ✅ **Testability** - Easy to write unit and integration tests
- ✅ **Maintainability** - Changes in one layer don't affect others
- ✅ **Scalability** - Easy to add new features
- ✅ **Independence** - Business logic is independent of frameworks and UI

### Architecture Layers

```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)         │  ← User Interface (Flutter Widgets)
├─────────────────────────────────────┤
│     Providers (State Management)    │  ← State & UI Logic
├─────────────────────────────────────┤
│     Domain Layer (Business Logic)   │  ← Use Cases & Entities
├─────────────────────────────────────┤
│     Data Layer (Data Management)    │  ← Repositories & Models
├─────────────────────────────────────┤
│     Core Layer (Utilities)          │  ← API Client, Constants, Utils
└─────────────────────────────────────┘
```

### Data Flow

```
User Action → Provider → Use Case → Repository → Data Source → API → Backend
                                                                        ↓
User sees result ← Provider ← Entity ← Repository ← Model ← Response ←
```

### Database Design

<img width="500" height="900" alt="prisma-erd" src="https://github.com/user-attachments/assets/29a97d4f-7bcb-45f6-b085-44398842e5a0" />

## 📁 Folder Structure

### Flutter (Mobile App)

```
lib/
├── core/                           # Shared utilities and tools
│   ├── constants/                  # App-wide constants
│   │   ├── api_constants.dart      # API endpoints and base URLs
│   │   ├── app_constants.dart      # Application constants (limits, defaults)
│   │   └── storage_constants.dart  # Local storage keys
│   ├── errors/                     # Error handling
│   │   ├── exceptions.dart         # Custom exception classes
│   │   └── failures.dart           # Failure classes for error states
│   ├── network/                    # Network layer
│   │   ├── api_client.dart         # ⭐ Centralized API client (GET, POST, PUT, DELETE)
│   │   ├── network_info.dart       # Internet connectivity checker
│   │   └── interceptors.dart       # HTTP interceptors (auth, logging)
│   ├── utils/                      # Utility functions
│   │   ├── validators.dart         # Input validation functions
│   │   ├── formatters.dart         # Data formatting utilities
│   │   └── date_helpers.dart       # Date manipulation helpers
│   ├── themes/                     # App theming
│   │   ├── app_theme.dart          # Theme configuration
│   │   ├── app_colors.dart         # Color palette
│   │   └── app_text_styles.dart    # Text styles
│   └── di/                         # Dependency injection
│       └── injection_container.dart # Service locator setup
│
├── data/                           # Data layer - handles data operations
│   ├── models/                     # Data models (API response/request)
│   │   ├── monthly_remittance_model.dart       # Monthly remittance data model with JSON serialization
│   │   ├── agent_model.dart        # Agent data model
│   ├── repositories/               # Repository implementations
│   │   ├── monthly_remittance_impl.dart
│   │   ├── agent_repository_impl.dart
│   └── datasources/                # Data sources (remote & local)
│       ├── remote/                 # API data sources
│       │   ├── monthly_remittance_remote_datasource.dart
│       │   ├── agent_remote_datasource.dart
│       └── local/                  # Local storage data sources
│           ├── monthly_remittance_local_datasource.dart
│           ├── agent_local_datasource.dart
│           └── app_database. dart   # Local database setup (Hive/SQLite)
│
├── domain/                         # Domain layer - business logic
│   ├── entities/                   # Pure business objects
│   │   ├── monthly_remittance.dart             # Monthly Remittance entity
│   │   ├── agent.dart              # Agent entity
│   ├── repositories/               # Repository interfaces (contracts)
│   │   ├── monthly_remittance_repository.dart
│   │   ├── agent_repository.dart
│   └── usecases/                   # Business use cases (single responsibility)
│       ├── monthly_remittance/
│       │   ├── get_monthly_remittances.dart
│       │   ├── get_monthly_remittance_details.dart
│       │   ├── create_monthly_remittance.dart
│       │   ├── update_monthly_remittance.dart
│       ├── agent/
│       │   ├── get_agents.dart
│       │   ├── get_agent_details.dart
│       │   └── update_agent_profile.dart
│
└── presentation/                   # Presentation layer - UI
    ├── pages/                      # Screen pages
    │   ├── splash/
    │   │   └── splash_page.dart
    │   ├── auth/
    │   │   ├── login_page.dart
    │   │   └── register_page.dart
    │   ├── dashboard/
    │   │   └── dashboard_page.dart
    │   ├── monthly_remittance/
    │   │   ├── monthly_remittance_list_page.dart
    │   │   ├── monthly_remittance_detail_page.dart
    ├── widgets/                    # Reusable UI components
    │   ├── common/
    │   │   ├── custom_button.dart
    │   │   ├── custom_text_field.dart
    │   │   ├── loading_indicator.dart
    │   │   └── error_widget.dart
    │   ├── monthly_remittance/
    │   │   └── monthly_remittance_card.dart
    └── providers/                  # State management (Provider pattern)
        ├── monthly_remittance/
        │   ├── monthly_remittance_provider.dart
        │   └── monthly_remittance_state.dart
        └── auth/
            ├── auth_provider.dart
            └── auth_state.dart
```

#### 📂 Folder Purpose Summary

| Folder | Purpose | When to Use |
|--------|---------|-------------|
| **core/** | Shared utilities used across the app | Place reusable tools, constants, API client |
| **data/** | Manages data from API and local storage | Create models, implement data fetching |
| **domain/** | Pure business logic, no framework dependencies | Define entities, business rules, use cases |
| **presentation/** | Everything user sees and interacts with | Build UI screens, widgets, state management |

---

### NestJS (Backend API)

```
src/
├── common/                         # Shared utilities across all modules
│   ├── decorators/                 # Custom decorators
│   │   ├── current-user.decorator.ts
│   │   └── roles.decorator.ts
│   ├── filters/                    # Exception filters
│   │   ├── http-exception.filter.ts
│   │   └── all-exceptions.filter.ts
│   ├── guards/                     # Route guards (authentication/authorization)
│   │   ├── jwt-auth.guard.ts
│   │   └── roles.guard.ts
│   ├── interceptors/               # Request/Response interceptors
│   │   ├── logging.interceptor.ts
│   │   └── transform.interceptor.ts
│   ├── pipes/                      # Validation pipes
│   │   └── validation.pipe.ts
│   ├── interfaces/                 # Shared TypeScript interfaces
│   │   └── response.interface.ts
│   └── constants/                  # Application constants
│       └── app.constants.ts
│
├── modules/                        # Feature modules
│   ├── auth/                       # Authentication module
│   │   ├── dto/
│   │   │   ├── login. dto.ts
│   │   │   ├── register.dto.ts
│   │   │   └── refresh-token.dto.ts
│   │   ├── auth.controller.ts      # Routes:  POST /auth/login, /auth/register
│   │   ├── auth.service.ts         # Business logic for authentication
│   │   └── auth.module.ts
│   │
│   ├── monthly_remittance/                   # Monthly Remittance module
│   │   ├── dto/
│   │   │   ├── create-monthly_remittance.dto.ts
│   │   │   ├── update-monthly_remittance.dto.ts
│   │   │   └── query-monthly_remittance.dto.ts
│   │   ├── monthly_remittance.controller.ts  # Routes: GET/POST/PUT/DELETE /policies
│   │   ├── monthly_remittance.service.ts     # Business logic for Monthly Remittance
│   │   └── monthly_remittance. module.ts
│   │
│   ├── agents/                     # Insurance agents module
│   │   ├── dto/
│   │   │   ├── create-agent.dto.ts
│   │   │   └── update-agent.dto.ts
│   │   ├── agents.controller.ts
│   │   ├── agents.service.ts
│   │   └── agents.module.ts
│   └── notifications/              # Push notifications module
│       ├── dto/
│       │   └── send-notification.dto.ts
│       ├── notifications.service.ts
│       └── notifications.module.ts
├── prisma/
│   ├── prisma.module.ts
│   └── prisma.service.ts
│
├── app.module.ts                   # Root application module
└── main.ts                         # Application entry point
```

#### 📂 NestJS Module Structure

Each module follows this pattern:

| File | Purpose | Example |
|------|---------|---------|
| **dto/** | Data Transfer Objects - validation schemas | Ensures incoming data is correct format |
| **entities/** | Database table definitions (TypeORM) | Defines what columns exist in the database |
| **controller. ts** | Handles HTTP requests (routes) | `GET /policies`, `POST /policies` |
| **service.ts** | Contains business logic | Calculates premiums, validates rules |
| **repository.ts** | Interacts with database | CRUD operations on database |
| **module.ts** | Bundles everything together | Exports the module to be used elsewhere |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Node.js (>=18.0.0)
- PostgreSQL (>=14.0)
- Firebase account (for notifications)

### Flutter Setup

```bash
# Clone the repository
git clone https://github.com/Pogs789/insurance-agent-remittance-engine.git

# Navigate to project directory
cd apps/mobile

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Backend Setup

```bash
# Navigate to backend directory
cd apps/backend

# Install dependencies
pnpm install

# Set up environment variables
cp .env.example . env
# Edit .env with your database credentials

# Run migrations
pnpm run migration: run

# Start the server
pnpm dev:backend
```

---

## 📡 API Documentation

### Base URL
```
Development: http://localhost:3000/api
Production: https://insurance-agent-remittance-engine-b.vercel.app/api
```

### Authentication
All protected routes require JWT token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

### Endpoints

#### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `POST /auth/refresh` - Refresh access token

#### Policies
- `GET /agent` - Get all agents
- `GET /agent/:id` - Get agent by ID
- `POST /agent` - Create new agent
- `PUT /agent/:id` - Update agent
- `DELETE /agent/:id` - Delete agent

#### Monthly Remittances
- `GET /monthly-remittances` - Get all monthly-remittances
- `GET /monthly-remittances/get-history/:agent-id` - Get all monthly-remittances by agent id
- `GET /monthly-remittances/:policyId` - Get all planholders for specific policy
- `POST /monthly-remittance/calculate` - Record premium payment
- `POST /monthly-remittance/upgate-calculation` - Calculate premium amount

---

## 🧪 Testing

### Flutter
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test
```

### Backend
```bash
# Run unit tests
pnpm run test

# Run e2e tests
pnpm run test: e2e

# Test coverage
pnpm run test:cov
```

---

## 📱 Screenshots

<work in progress>

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/<your feature>`)
3. Commit your changes (`git commit -m 'What changes do you made.'`)
4. Push to the branch (`git push origin feature/<your feature>`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Cesphillip M. Lorica**
- GitHub: [@Pogs789](https://github.com/Pogs789)
- LinkedIn: [Cesphillip Lorica](https://www.linkedin.com/in/cesphillip-lorica-5923a523b/)
- Email: loricaphillip@outlook.com

---

## 🙏 Acknowledgments

- Insurance industry requirements gathered from an Insurance Agent, who inspired this project
- Clean Architecture principles by Robert C. Martin
- Flutter and NestJS communities

---

## 📊 Project Status

🚧 **Currently in development** - Version 1.0.0 coming soon!

- [x] Project structure setup
- [x] Blueprint and planning
- [x] Clean architecture implementation
- [ ] Authentication module
- [x] Remittance Calculation module
- [ ] User Management module
- [ ] Admin dashboard
- [ ] Testing coverage (>80%)
- [ ] Documentation completion
