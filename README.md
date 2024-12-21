# Sofia
https://jumperche.shinyapps.io/f9c528a87ee244e3b8622138f219bc6c/

### README for GitHub Repository

# Sofia Attractions - Shiny Application

This Shiny application provides an interactive platform to explore popular attractions in Sofia, Bulgaria. It offers a rich user interface with dynamic filtering, maps, and detailed information about each location. Designed for local and international visitors, the app delivers an engaging and visually appealing experience.

---

## Features

- **Attractions Catalog**: Explore a catalog of popular attractions with filters for categories and search functionality.
- **Interactive Map**: View attractions on an interactive Leaflet map with popup details.
- **Dynamic Status**: Displays whether an attraction is currently open or closed based on operating hours.
- **Favorites**: Mark and manage favorite attractions locally using browser storage.
- **Details Popup**: Show detailed information, including images and links, in a modal dialog.
- **Multilingual Support**: The app includes descriptions and functionality in Bulgarian.

---

## Prerequisites

Before running the app, ensure you have the following installed:

- R (version ≥ 4.0)
- RStudio (optional)
- Required R packages:
  ```r
  install.packages(c(
    "shiny", "shinythemes", "leaflet", "dplyr", "digest"
  ))
  ```

---

## Getting Started

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Prepare Images**
   Place images for attractions in the root folder with names `1.jpg`, `2.jpg`, ..., `20.jpg`.

3. **Launch the App**
   Open the `app.R` file in RStudio or your preferred R IDE, and click "Run App". Alternatively, run:
   ```r
   shiny::runApp("path/to/app.R")
   ```

4. **Navigate the Interface**
   - **Home Tab**: Displays a welcoming banner with changing images.
   - **Catalog Tab**: Search and filter attractions and view details.
   - **Map Tab**: Explore attractions on an interactive map.
   - **History Tab**: Learn about Sofia's historical background.
   - **Contact Tab**: Access contact information for feedback and inquiries.

---

## Folder Structure

```plaintext
.
├── app.R                # Main application file
├── 1.jpg, 2.jpg, ...    # Images for attractions
├── README.md            # This README file
└── history1.jpg, history2.jpg  # Optional images for the history section
```

---

## Application Highlights

### Data Preparation

- The dataset includes a variety of attractions in Sofia with fields such as name, description, category, operating hours, and GPS coordinates.
- A unique hash (`Key`) is generated for each attraction using the `digest` package.

### UI

- **Dynamic Filtering**: Filter attractions by category or search by name.
- **Responsive Cards**: Each attraction is displayed as a card with a status (open/closed), an image, and a favorite icon.
- **Favorites Management**: Favorites are stored in the browser using `localStorage`.

### Server Logic

- **Status Updates**: Attraction status (open/closed) is updated in real-time based on the current hour.
- **Map Integration**: Attractions are plotted on a Leaflet map with interactive popups.
- **Details Modal**: Detailed information about each attraction is displayed in a modal dialog.

---

## Future Enhancements

- **Language Options**: Add support for multiple languages (e.g., English).
- **Advanced Filters**: Include options to filter by distance, ratings, or opening hours.
- **User Accounts**: Enable user authentication for saving favorites across devices.
- **Event Integration**: Add information about events near attractions.

---

## Contribution

Feel free to contribute to this project by submitting issues or pull requests. Ensure that your code follows proper guidelines and is thoroughly tested.

---

## License

This project is licensed under the BSD 3-Clause License. See the `LICENSE` file for details.

---

Enjoy discovering the beautiful attractions of Sofia with this Shiny app! 😊
