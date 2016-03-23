### getting and cleaning the data for the shiny app-----------------------------

# load pollstR-package to get Huffpost opinion polls
require(pollstR)

# load dplyr and tidyr for data wrangling
require(dplyr)
require(tidyr)

# load ggplot2 for plotting
require(ggplot2)

# download 2016 GOP presidential primaries
repPoll <- pollstr_charts(topic='2016-president-gop-primary', showall = TRUE)

# extract and combine columns needed
choice <- repPoll$estimates$choice
value <- repPoll$estimates$value
election <- repPoll$estimates$slug
party <- repPoll$estimates$party

rep.df <- data_frame(election, choice, value, party)


# extract and combine slug and state info to add list of US state abbreviations
election <- repPoll$charts$slug
state <- repPoll$charts$state

r.stateAbb <- data_frame(election, state)

# join both data frames based on slug
rep.df <- left_join(rep.df, r.stateAbb, by = "election")
rep.df <- rep.df %>% filter(choice %in% c("Bush", "Carson", "Christie", "Cruz",
                                          "Kasich", "Rubio","Trump"))

## download 2016 DEM presidential primaries
demPoll <- pollstr_charts(topic='2016-president-dem-primary', showall = TRUE)

# extract and combine columns needed
choice <- demPoll$estimates$choice
value <- demPoll$estimates$value
election <- demPoll$estimates$slug
party <- demPoll$estimates$party

dem.df <- data_frame(election, choice, value, party)

# extract and combine slug and state info to add list of US state abbreviations
election <- demPoll$charts$slug
state <- demPoll$charts$state

d.stateAbb <- data_frame(election, state)

# join both data frames based on slug
dem.df <- left_join(dem.df, d.stateAbb, by = "election")
dem.df <- dem.df %>% filter(choice %in% c("Clinton", "Sanders"))

# combine dem and rep datasets
polls <- bind_rows(dem.df, rep.df)

polls$party <- as.factor(polls$party)
polls$state <- as.factor(polls$state)
polls$choice <- as.factor(polls$choice)


shinyServer(function(input, output) {
        
        # thank you warmoverflow from Stackoverflow for helping me with the renderUI
        # selecting the party and based on that, choosing the candidates
        observeEvent(input$party, {
                output$candidates <- renderUI({
                        checkboxGroupInput(
                                "candidate",
                                ifelse(input$party == 'Dem', "", ""),
                                as.vector(unique(filter(polls,party==input$party)$choice))
                        )
                })
        })
        
        # choosing the candidates and based on that, selecting the states
        observeEvent(input$candidate, {
                output$states <- renderUI({
                        states_list <- as.vector(unique(filter(polls, party==input$party & choice==input$candidate)$state))
                        checkboxGroupInput(
                                "state",
                                "",
                                states_list,
                                inline = TRUE
                        )
                })
        })
        
       # generate figures
        observe({      
                df <- polls %>% filter(party %in% input$party) %>% filter(choice %in% input$candidate) %>%
                        filter(state %in% input$state)
                height <- ceiling(length(input$state) / 2) * 200
                output$plot <- renderPlot({
                p <- ggplot(df)
                p <- p + geom_bar(aes(x = choice, weight = value, fill = choice),
                                  position = "dodge", width=.5) 
                
                # colorize bars based on parties        
                if (input$party == "Dem")
                        p <- p + scale_fill_brewer(palette = "Blues", direction = -1)
                if (input$party == "Rep")
                        p <- p + scale_fill_brewer(palette = "Reds", direction = -1)
                
                # add hlines for waffle-design
                p <- p + geom_hline(yintercept=seq(0, 100, by = 10), col = 'white') +
                        geom_text(aes(label = value, x = choice, y = value + 1), position = position_dodge(width=0.9), vjust=-0.25) +
                        # facet display
                        facet_wrap( ~ state, ncol = 2) +
                        # scale of y-axis
                        ylim(0, 100) + 
                        # delete labels of x- and y-axis
                        xlab("") + ylab("") +
                        # blank background and now grids and legend
                        theme(panel.grid.major.x = element_blank(), panel.grid.major.y = element_blank(),
                              panel.grid.minor.y = element_blank(),
                              panel.background = element_blank(), legend.position = "none")
                print(p)    
                }, height = height)
        })
        
        # Generate a table view of the data
        output$table <- renderTable({
                polls %>% filter(party %in% input$party) %>% filter(choice %in% input$candidate) %>%
                        filter(state %in% input$state)
        })
        
}
)