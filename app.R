library(shiny)
library(shinythemes)
library(leaflet)
library(dplyr)
library(digest)

# Подготовка на данните
attractions <- tibble(
  Name = c("Александър Невски", "Национален музей", "Витоша", "Боянска църква", "Света София",
           "Централен пазар", "Национална художествена галерия", "Софийска зоологическа градина", 
           "Южен парк", "Северен парк", "Борисова градина", "Света Неделя", "Музей Земята и хората",
           "Античен театър", "Национален исторически музей", "Театър Иван Вазов", 
           "Катедрала на Александър Невски", "Света Параскева", "Национален военноисторически музей", "Национална библиотека"),
  Description = c("Една от най-големите катедрали.", "Музей с исторически артефакти.", 
                  "Популярна планина до София.", "Средновековна църква.", 
                  "Една от най-старите църкви в града.", "Място за разнообразие от стоки.",
                  "Една от най-известните галерии.", "Най-голямата зоологическа градина в България.",
                  "Голяма зелена площ за почивка.", "Природен парк в северната част на София.", 
                  "Емблематична градина в центъра.", "Храм с дълга история.", 
                  "Голям геоложки музей.", "Древен театър с римска архитектура.", 
                  "Музей, който представя историята на България.", 
                  "Известен театър за културни събития.", "Катедрала.", 
                  "Малка, но значима църква.", "Национален военноисторически музей.", 
                  "Основна библиотека в България."),
  Category = c("Църкви", "Музеи", "Природа", "Църкви", "Църкви", "Търговия", "Култура", 
               "Зоология", "Природа", "Природа", "Природа", "Църкви", "Музеи", "Култура", 
               "История", "Култура", "Църква", "Църкви", "Музеи", "Култура"),
  Link = c("https://en.wikipedia.org/wiki/St._Alexander_Nevsky_Cathedral,_Sofia",
           "https://historymuseum.org/", "https://www.raionvitosha.eu/bg/", "https://boyanachurch.org", 
           "https://en.wikipedia.org/wiki/Church_of_St._Sophia,_Sofia",
           "https://en.wikipedia.org/wiki/Central_Hali", "https://nationalgallery.bg",
           "https://zoosofia.eu/", "https://en.wikipedia.org/wiki/South_Park,_Sofia",
           "https://en.wikipedia.org/wiki/North_Park,_Sofia", "https://en.wikipedia.org/wiki/Borisova_gradina",
           "https://en.wikipedia.org/wiki/Sveta_Nedelya_Church", "https://www.nmnhs.com/index_bg.php",
           "https://bg.wikipedia.org/wiki/%D0%A1%D0%BE%D1%84%D0%B8%D0%B9%D1%81%D0%BA%D0%B8_%D1%80%D0%B8%D0%BC%D1%81%D0%BA%D0%B8_%D0%B0%D0%BC%D1%84%D0%B8%D1%82%D0%B5%D0%B0%D1%82%D1%8A%D1%80",
           "https://historymuseum.org", "https://nationaltheatre.bg",
           "https://www.cathedral.bg/",
           "https://bg.wikipedia.org/wiki/%D0%A1%D0%B2%D0%B5%D1%82%D0%B0_%D0%9F%D0%B0%D1%80%D0%B0%D1%81%D0%BA%D0%B5%D0%B2%D0%B0_(%D0%A1%D0%BE%D1%84%D0%B8%D1%8F)",
           "https://en.wikipedia.org/wiki/National_Museum_of_Military_History",
           "https://en.wikipedia.org/wiki/National_Library_of_Bulgaria"),
  Longitude = c(23.3238, 23.3201, 23.2600, 23.3185, 23.3301, 23.3209, 23.3265, 23.3154, 
                23.3101, 23.3052, 23.3145, 23.3285, 23.3187, 23.3274, 23.3195, 23.3300,
                23.3228, 23.3241, 23.3215, 23.3189),
  Latitude = c(42.6952, 42.6977, 42.6286, 42.6431, 42.6973, 42.6981, 42.6935, 42.6753, 
               42.6648, 42.6725, 42.6801, 42.6965, 42.6864, 42.6895, 42.6851, 42.6912,
               42.6958, 42.6897, 42.6824, 42.6945),
  OpenHour = sample(8:10, 20, replace = TRUE),
  CloseHour = sample(12:20, 20, replace = TRUE),
  Image = c("1.jpg", "2.jpg", "3.jpg", "4.jpg", "5.jpg", "6.jpg", "7.jpg", "8.jpg",
            "9.jpg", "10.jpg", "11.jpg", "12.jpg", "13.jpg", "14.jpg", "15.jpg",
            "16.jpg", "17.jpg", "18.jpg", "19.jpg", "20.jpg")
) %>%
  mutate(Image = ifelse(is.na(Image) | Image == "", 
                        "https://via.placeholder.com/200x150?text=No+Image", Image),
         Image = paste0(Image, "?nocache=", Sys.time()),
         Key = sapply(Name, function(x) digest(x, algo = "md5")))

# UI
ui <- fluidPage(
  theme = shinytheme("cosmo"),
  
  tags$head(
    tags$style(HTML("
      .truncate {
        display: -webkit-box;
        -webkit-line-clamp: 3;
        -webkit-box-orient: vertical;
        overflow: hidden;
      }
      .attraction-container {
        display: flex;
        flex-wrap: wrap;
        gap: 15px;
      }
      .attraction-container .col-sm-4 {
        display: flex;
        flex-direction: column;
        flex: 1 1 calc(33.333% - 15px);
        box-sizing: border-box;
      }
      .attraction-card {
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        border: 1px solid #ddd;
        border-radius: 10px;
        background-color: #fff;
        box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.1);
        margin-bottom: 15px;
      }
      .attraction-card img {
        height: 150px;
        object-fit: cover;
        border-radius: 10px 10px 0 0;
      }
      .card-body {
        padding: 10px;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
        text-align: center;
      }
      .card-title {
        font-size: 16px;
        font-weight: bold;
        margin-bottom: 5px;
        line-height: 1.4em;
        height: 2.8em;
        overflow: hidden;
      }
      .card-title::after {
        content: '';
        display: block;
        height: 0.8em;
      }
      .card-text {
        font-size: 12px;
        color: #555;
        margin-bottom: 10px;
        line-height: 1.2em;
        height: 3.6em;
        overflow: hidden;
      }
      .card-text::after {
        content: '';
        display: block;
        height: 0.2em;
      }
      .card-category {
        font-size: 12px;
        margin-top: 5px;
      }
      .navbar {
        background-color: #8ab4f7;
        color: white;
      }
      .navbar .navbar-brand, .navbar .navbar-nav > li > a {
        color: white;
      }
      .navbar .navbar-nav > li > a:hover {
        color: #978af7;
      }
      .navbar .navbar-toggler {
        border-color: white;
      }
      .navbar .navbar-toggler-icon {
        background-image: url('data:image/svg+xml;charset=utf8,%3Csvg ... %3E');
      }
      .status {
        text-align: center;
        font-weight: bold;
      }
      .status.open {
        color: green;
      }
      .status.closed {
        color: red;
      }
      .favorite {
        font-size: 24px;
        cursor: pointer;
        color: grey;
        transition: color 0.3s ease;
      }
      .favorite:hover {
        color: #ff6666;
      }
      .banner {
        width: 120%;
        height: 350px;
        margin-left: -10%;
        position: relative;
        left: 50%;
        transform: translateX(-50%);
        overflow: hidden;
        border-radius: 10px; 
    "))
  ),
  
  tags$script(HTML("
    Shiny.addCustomMessageHandler('updateStatus', function(data) {
      data.forEach(function(item) {
        const statusElement = document.getElementById('status-' + item.id);
        if (statusElement) {
          statusElement.className = 'status ' + (item.isOpen ? 'open' : 'closed');
          statusElement.textContent = item.isOpen ? 'Отворено' : 'Затворено';
        }
      });
    });
  ")),
  
  tags$script(HTML("
    function updateFavoriteIcons() {
      const favorites = JSON.parse(localStorage.getItem('favorites') || '[]');
      const cards = document.querySelectorAll('.card');
      cards.forEach(card => {
        const key = card.dataset.key;
        const favoriteIcon = card.querySelector('.favorite');
        if (favoriteIcon) {
          if (favorites.includes(key)) {
            favoriteIcon.style.color = '#e63946';
          } else {
            favoriteIcon.style.color = 'grey';
          }
        }
      });
    }
    document.addEventListener('DOMContentLoaded', () => {
      updateFavoriteIcons();
    });
    $(document).on('shiny:outputrendered', function(event) {
      if (event.target.id === 'attractions_ui') {
        updateFavoriteIcons();
      }
    });
    
    function toggleFavorite(element, key) {
      let favorites = JSON.parse(localStorage.getItem('favorites') || '[]');
      const index = favorites.indexOf(key);
      if (index > -1) {
        favorites.splice(index, 1);
        element.style.color = 'grey';
      } else {
        favorites.push(key);
        element.style.color = '#e63946';
      }
      localStorage.setItem('favorites', JSON.stringify(favorites));
    }
  ")),
  
  titlePanel("Забележителности на София"),
  
  navbarPage(
    title = NULL,
    fluid = TRUE,
    windowTitle = "Забележителности на София",
    
    tabPanel("Начало",
             fluidRow(
               column(12,
                      div(id = "banner", style = "width: 100%; height: 500px; overflow: hidden; border-radius: 5px;",
                          img(id = "bannerImage", src = "1.jpg", alt = "Banner", 
                              style = "width: 100%; height: 100%; object-fit: cover;")
                      ),
                      br(),
                      p("Добре дошли в нашето приложение за забележителностите на София!", 
                        style = "font-size: 18px; text-align: center; margin-top: 20px;")
               )
             )
    ),
    
    tags$script(HTML("
    const bannerImages = Array.from({length: 8}, (_, i) => `${i + 1}.jpg`);

    function changeBannerImage() {
      const randomIndex = Math.floor(Math.random() * bannerImages.length);
      document.getElementById('bannerImage').src = bannerImages[randomIndex];
    }

    setInterval(changeBannerImage, 5000);
")),
    
    
    tabPanel("Каталог",
             sidebarLayout(
               sidebarPanel(
                 textInput("search", "Търси забележителност:", placeholder = "Въведете име..."),
                 selectInput("category", "Категория:", 
                             choices = c("Всички", "Църкви", "Музеи", "Природа", "Търговия", "Култура", "История", "Зоология"), 
                             selected = "Всички")
               ),
               mainPanel(
                 uiOutput("attractions_ui")
               )
             )
    ),
    
    tabPanel("Карта",
             leafletOutput("map", height = "600px")
    ),
    
    
    
    tabPanel("История",
             fluidRow(
               column(12,
                      h3("История на София", style = "text-align: center; margin-top:20px;"),
                      p("София е един от най-старите градове в Европа...", 
                        style = "font-size:16px; text-align:justify; margin: 20px;"),
                      p("Днес София е съвременна европейска столица...", 
                        style = "font-size:16px; text-align:justify; margin: 20px;"),
                      tags$img(src="history1.jpg", style="width:45%; margin: 10px; border-radius:5px;", alt="Историческа снимка на София"),
                      tags$img(src="history2.jpg", style="width:45%; margin: 10px; border-radius:5px;", alt="Древни останки в София"),
                      p("За повече информация можете да посетите:", style = "font-size:16px; text-align:left; margin: 20px;"),
                      tags$ul(
                        tags$li(tags$a(href="https://bg.wikipedia.org/wiki/%D0%A1%D0%BE%D1%84%D0%B8%D1%8F", 
                                       target="_blank", "Уикипедия - София")),
                        tags$li(tags$a(href="https://www.sofiahistorymuseum.bg", 
                                       target="_blank", "Регионален исторически музей - София"))
                      )
               )
             )
    ),
    tabPanel("Контакт",
             fluidRow(
               column(12,
                      h3("Контактна информация", style = "text-align: center;"),
                      p("Ако имате въпроси или предложения, моля свържете се с нас на:", 
                        style = "font-size: 16px;"),
                      p("Имейл: info@sofia-attractions.bg", style = "font-size: 16px;"),
                      p("Телефон: +359 2 123 4567", style = "font-size: 16px;")
               )
             )
    )
  ),
  
  fluidRow(
    column(12,
           hr(),
           tags$footer(
             style = "text-align: center; padding: 10px; background-color: #f8f9fa;",
             "© 2024 Забележителности на София"
           )
    )
  )
)

# Server
server <- function(input, output, session) {
  filtered_attractions <- reactive({
    data <- attractions
    if (input$search != "") {
      data <- data %>% filter(grepl(input$search, Name, ignore.case = TRUE))
    }
    if (input$category != "Всички") {
      data <- data %>% filter(Category == input$category)
    }
    data
  })
  
  output$attractions_ui <- renderUI({
    data <- filtered_attractions()
    if (nrow(data) == 0) {
      return(h4("Няма намерени забележителности по вашите критерии.", 
                style = "color: red; text-align: center;"))
    }
    current_hour <- as.numeric(format(Sys.time(), "%H"))
    
    
    ui_elements <- tagList(
      lapply(1:nrow(data), function(i) {
        attraction <- data[i, ]
        isOpen <- current_hour >= attraction$OpenHour & current_hour < attraction$CloseHour
        status_text <- ifelse(isOpen, "Отворено", "Затворено")
        status_class <- ifelse(isOpen, "status open", "status closed")
        
        div(class = "col-sm-4 card", `data-key` = attraction$Key,
            div(class = "attraction-card",
                img(src = attraction$Image, alt = attraction$Name, 
                    style = "width: 100%; height: 150px; object-fit: cover;"),
                div(class = "card-body",
                    h4(attraction$Name, class = "card-title"),
                    p(attraction$Description, class = "card-text"),
                    p(paste("Категория:", attraction$Category), class = "card-category"),
                    div(class = status_class, id = paste0("status-", i), status_text),
                    span(HTML("&#9825;"), class = "favorite", 
                         onclick = sprintf("toggleFavorite(this, '%s')", attraction$Key),
                         style = "font-size: 24px; cursor: pointer; color: grey;"),
                    actionButton(inputId = paste0("details_", i), label = "Детайли", class = "btn btn-primary")
                )
            )
        )
      })
    )
    tagList(ui_elements, tags$script("updateFavoriteIcons();"))
  })
  
  observeEvent(filtered_attractions(), {
    lapply(1:nrow(filtered_attractions()), function(i) {
      observeEvent(input[[paste0("details_", i)]], {
        attraction <- filtered_attractions()[i, ]
        showModal(modalDialog(
          title = attraction$Name,
          div(
            img(src = attraction$Image, style = "width: 100%; height: auto;"),
            p(attraction$Description),
            p(paste("Категория:", attraction$Category)),
            p(tags$a(href = attraction$Link, "Научи повече", target = "_blank"))
          ),
          easyClose = TRUE,
          footer = modalButton("Затвори")
        ))
      })
    })
  })
  
  output$map <- renderLeaflet({
    leaflet(data = attractions) %>%
      addTiles() %>%
      setView(lng = 23.3219, lat = 42.6977, zoom = 13) %>%
      addMarkers(~Longitude, ~Latitude, popup = ~paste0("<b>", Name, "</b><br>", Description))
  })
  
  observe({
    current_hour <- as.numeric(format(Sys.time(), "%H"))
    data <- filtered_attractions()
    status_data <- lapply(1:nrow(data), function(i) {
      attraction <- data[i, ]
      list(
        id = i,
        isOpen = current_hour >= attraction$OpenHour & current_hour < attraction$CloseHour
      )
    })
    session$sendCustomMessage("updateStatus", status_data)
  })
}

# Стартиране на приложението
shinyApp(ui = ui, server = server)
