# Pet Store Flutter Web App

A clean, minimal Flutter web application for managing pets using the Swagger Petstore API. Built with modern Flutter architecture patterns including Riverpod for state management, go_router for navigation, and responsive design.

## Features

- **Browse Pets**: View pets in a responsive grid layout with status filtering (Available, Pending, Sold)
- **Create Pet**: Add new pets via modal dialog with form validation
- **Edit Pet**: Update existing pets with prefilled modal forms
- **Delete Pet**: Remove pets with confirmation dialog
- **Hero Animations**: Smooth image transitions between list and detail views
- **Responsive Design**: Optimized for both desktop and mobile layouts

## Architecture

- **Clean Architecture**: Feature-based folder structure with separation of concerns
- **State Management**: Riverpod for reactive state management
- **Navigation**: go_router for type-safe routing
- **HTTP Client**: Dio with custom error handling for API communication
- **UI Components**: Reusable widgets with Material Design 3

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
- **go_router** ^14.0.0 - Declarative routing
- **flutter_riverpod** ^3.0.0 - State management
- **dio** ^5.7.0 - HTTP client
- **flutter_lints** ^4.0.0 - Code quality and linting

## Project Structure

```
lib/
├── core/
│   ├── networking/          # HTTP client configuration
│   ├── routing/            # App routing configuration
│   ├── theme/              # App theme and styling
│   └── widgets/            # Reusable UI components
├── features/
│   └── pets/
│       ├── data/           # Models and API layer
│       └── presentation/   # Controllers, pages, and widgets
└── main.dart              # App entry point
```

## Key Technologies

- **Flutter Web**: Cross-platform web application framework
- **Riverpod**: State management with dependency injection
- **go_router**: Declarative routing solution
- **Dio**: HTTP client with interceptors and error handling
- **Material 3**: Modern Material Design components

## Development Notes

- All CRUD operations include proper error handling and user feedback
- Forms include validation for required fields
- Images gracefully fallback to placeholders when URLs fail
- State is automatically refreshed after mutations
- Responsive design adapts to different screen sizes

## Testing

The app has been tested with:
- Creating pets with various field combinations
- Editing existing pet information
- Deleting pets and confirming list updates
- Status filtering functionality
- Error handling for invalid pet IDs
- Network error scenarios
