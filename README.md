# Pet Store Flutter Web App

A clean, minimal Flutter web application for managing pets using the Swagger Petstore API. Built with modern Flutter architecture patterns including Riverpod for state management, go_router for navigation, and responsive design.

## Features

- **Browse Pets**: View pets in a responsive grid layout with status filtering (Available, Pending, Sold)
- **Create Pet**: Add new pets via modal dialog with form validation and random ID generation
- **Edit Pet**: Update existing pets with prefilled modal forms
- **Delete Pet**: Remove pets with confirmation dialog
- **Hero Animations**: Smooth image transitions between list and detail views
- **Responsive Design**: Dynamic grid layout (1-4 columns) optimized for all screen sizes
- **Clean URLs**: Hash-free routing for better SEO and user experience
- **Modern UI**: Bold typography, dynamic cards with gradients and shadows
- **Smart Loading**: Custom loading states with proper spacing

## Architecture

- **Clean Architecture**: Feature-based folder structure with separation of concerns
- **State Management**: Riverpod for reactive state management with AsyncNotifier pattern
- **Navigation**: go_router for type-safe routing with clean URLs (no hash fragments)
- **HTTP Client**: Dio with custom error handling for mixed response formats (JSON/plain text)
- **UI Components**: Reusable widgets (AsyncBody, PetCard) with Material Design 3
- **Theme System**: Comprehensive theme with typography scale and consistent spacing constants

## API Configuration

- **Base URL**: `https://petstore.swagger.io/v2`
- **API Documentation**: [Swagger Petstore](https://petstore.swagger.io/)

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Chrome browser for web development

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd atome_test
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run -d chrome
```

The app will open in your default browser at `http://localhost:xxx`.

## Demo Script

To record a complete demo of the application:

1. **Browse Pets**: 
   - Open the app to see the pets list
   - Try different status filters (Available, Pending, Sold)
   - Notice the responsive grid layout

2. **View Pet Details**:
   - Click on any pet card
   - Observe the Hero animation transition
   - View pet details including category, tags, and photos

3. **Create New Pet**:
   - Click the floating action button (+)
   - Fill out the form with pet details
   - Add category and comma-separated tags
   - Submit to create the pet
   - Notice the success SnackBar

4. **Edit Pet**:
   - From pet details, click the edit button
   - Modify pet information in the prefilled form
   - Save changes and see the success confirmation

5. **Delete Pet**:
   - From pet details, click the delete button
   - Confirm deletion in the dialog
   - Return to home screen with updated list

6. **Navigation**:
   - Use the back button to return to list
   - Notice the automatic refresh of pet data

## Tech Stack

- **Flutter Web** - Cross-platform UI framework
- **go_router** ^14.0.0 - Declarative routing with clean URLs
- **flutter_riverpod** ^3.0.0 - State management
- **dio** ^5.7.0 - HTTP client
- **flutter_web_plugins** - Web-specific plugins (URL strategy)
- **flutter_lints** ^4.0.0 - Code quality and linting

## Project Structure

```
lib/
├── core/
│   ├── networking/          # HTTP client configuration (DioClient)
│   ├── theme/              # App theme and typography
│   └── widgets/            # Reusable UI components (AsyncBody, PetCard)
├── features/
│   └── pets/
│       ├── data/           # Models (Pet, Category, Tag) and API layer
│       └── presentation/   # Controllers, pages, and widgets
│           ├── controllers/ # Riverpod controllers for state management
│           ├── pages/      # Main pages (PetsListPage, PetDetailPage)
│           └── widgets/    # Feature-specific widgets (dialogs)
├── routing/                # App routing configuration (GoRouter)
└── main.dart              # App entry point with URL strategy
```

## Key Technologies

- **Flutter Web**: Cross-platform web application framework
- **Riverpod**: State management with dependency injection
- **go_router**: Declarative routing solution
- **Dio**: HTTP client with interceptors and error handling
- **Material 3**: Modern Material Design components

## Development Notes

- **CRUD Operations**: All operations include proper error handling and SnackBar user feedback
- **Form Validation**: Required field validation with consistent styling
- **Image Handling**: Graceful fallback to centered placeholders when URLs fail
- **State Management**: Automatic refresh after mutations with proper loading states
- **Responsive Design**: Dynamic grid layout adapts to screen sizes (mobile to desktop)
- **Error Handling**: Custom error handling for API quirks (plain text vs JSON responses)
- **URL Strategy**: Clean URLs without hash fragments for better web experience
- **Typography**: Bold, modern typography with proper hierarchy and spacing
- **Visual Polish**: Cards with shadows, gradients, and smooth animations

## Testing

The app has been tested with:
- Creating pets with various field combinations
- Editing existing pet information
- Deleting pets and confirming list updates
- Status filtering functionality
- Error handling for invalid pet IDs
- Network error scenarios
