library(shiny)
library(googleAuthR)
library(waiter)

# options(googleAuthR.redirect = "deployed URL here")
options(googleAuthR.redirect = "http://localhost:1221")

gar_set_client(
  web_json = "client_secret.json",
  scopes = c("https://www.googleapis.com/auth/userinfo.email",
             "https://www.googleapis.com/auth/analytics.edit",
             "https://www.googleapis.com/auth/analytics.readonly"),
  activate = "web")

options(shiny.port = 1221)

options("spinner.color" = "blue")
auth <- jsonlite::read_json("auth.json")
Sys.setenv(BARB_API_USERNAME=auth$username)
Sys.setenv(BARB_API_PASSWORD=auth$password)

thematic::thematic_shiny(font = "auto")

demoApp <- function(...) {

  # Define UI for application that draws a histogram
  ui <- bslib::page_fluid(
    
    use_waiter(),
    waiter_on_busy(),
    
    title = "App Title",
    
    theme = bslib::bs_theme(
      version = 5,
      fg = "rgb(99, 99, 105)",
      primary = "#0568A6",
      secondary = "#D7D7D9",
      success = "#52BD6F",
      info = "#0568A6",
      warning = "#F2B705",
      danger = "#D92344",
      base_font = bslib::font_google("Nunito Sans"),
      heading_font = bslib::font_google("Nunito Sans"),
      font_scale = 0.8,
      `enable-rounded` = TRUE,
      preset = "cosmo",
      bg = "#fff"
    ),
    
    div(img(
      src = "background_crop.jpg",
      width = "100%",
      height = "100px",
      style = "margin:1px 1px; object-fit:cover; object-position:top",
    )),
    
    bslib::page_sidebar(
      title = "Title Here",
      
      header = imageOutput(
        "background_crop.jpg"
        ))

)

  # Define server logic required to draw a histogram
  server <- function(input, output, session) {
    
    # GA Auth -------------------
    
    token <- gar_shiny_auth(session)

    # module for authentication
    property_id <- googleAnalyticsR::accountPicker("auth_menu", ga_table = accs, id_only = TRUE)
    
    ga_id <- reactive({
      accs() |> 
        dplyr::filter(account_name==input$`auth_menu-account_name`,
                      property_name==input$`auth_menu-property_name`) |> 
        dplyr::pull(propertyId)
    })
    
    # END GA Auth -------------------
    
  }
  
  shinyApp(gar_shiny_ui(ui, login_ui = login_screen), server)
  # shinyApp(ui, server)
}
