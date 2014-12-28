library(knitr)
render_jekyll(highlight="pygments")
knit("R/kuusamo.Rmd", "fmi-stations.md")
