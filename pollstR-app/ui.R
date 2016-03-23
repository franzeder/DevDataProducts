shinyUI(fluidPage(
        titlePanel("2016 Presidential primaries: Hufington Post Opinion Polls"),

        sidebarLayout(position = "right",
                sidebarPanel(
                        helpText("1. Choose between Democratic (Dem) and Republican (Rep)
                                 Primaries and Caucuses:"),

                        selectInput("party",
                                    label = "Dem or Rep?",
                                    choices = c("Dem", "Rep",
                                    selected = "Dem")),
                        helpText("2. Select Candidates:"),
                        uiOutput('candidates'),
                        
                        helpText("3. Select States:"),
                        uiOutput('states')
                ),

                mainPanel(
                        tabsetPanel(
                                tabPanel("Plot", plotOutput("plot")),
                                tabPanel("Table", tableOutput("table")),
                                tabPanel("About", includeMarkdown("about.md"))
                        )
                )


        )
))