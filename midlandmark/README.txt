1. Project Overview:
Smart Geo-Tagged Landmarks is a Flutter application that allows users to discover, visit, and add landmarks in Bangladesh. It features a map view, detailed listings, visit history, and robust offline support.

2. Features Implemented:
- Landmarks Display: Fetched from a REST API and displayed in both map and list formats.
- Map View: Centered on Bangladesh, showing markers with colors indicating landmark scores.
- Visit Feature: Users can "visit" landmarks based on their current GPS location.
- Activity History: A log of all visited landmarks with timestamps and distances.
- Add Landmark: Users can add new landmarks by capturing an image and fetching their current GPS coordinates.
- Filtering & Sorting: Landmarks can be sorted by score and filtered by a minimum score threshold.
- Soft Delete: Support for removing landmarks from the display.
- Offline Support: Local caching using SQLite, offline viewing, and a sync queue for visit requests.

3. API Usage:
- Base URL: https://labs.asustools.info/cse489/exam3/api.php
- Actions: get_landmarks, visit_landmark, create_landmark, delete_landmark, restore_landmark.
- Authentication: API Key (Student ID) passed as a query parameter.

4. Offline Strategy:
- Data is cached in a local SQLite database whenever a successful API fetch occurs.
- If the app is offline, it loads data from the local database.
- Visit requests made while offline are stored in a 'pending_visits' table.
- A sync mechanism checks for connectivity on app launch and periodically to push pending visits to the server.

5. Architecture Used:
- Provider Pattern for state management.
- Service-oriented architecture with separate classes for API communication (ApiService) and local database operations (DatabaseService).
- Repository-like pattern within the Provider to manage data flow between API, Database, and UI.

6. Challenges Faced:
- Coordinating the sync of offline visits to ensure data consistency.
- Handling multipart/form-data for image uploads in Flutter.
- Managing Google Maps markers and custom colors based on dynamic data.
