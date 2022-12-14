# Vectorisation dans le cadre d'une désambiguïsation du mot "café" dans un corpus d'articles en français sur l'alimentation à Montréal. 
# Sources: https://github.com/bnosac/word2vec, https://bookdown.org/rdpeng/rprogdatascience/regular-expressions.html et https://stackoverflow.com/questions/50210531/search-multiple-columns-for-string
# Autrice principale: Amélie Ducharme
# Co-autrices: Elisabeth Doyon et Lisa Teichmann

######
######
######
######
######
###### PARTIE 1 - PRÉPARATION DU CORPUS
######
######
######
######
######

# INSTALLATION
# Installer les packages word2vec (vectorisation) et data.table (fast and efficient, extension de data.frame)
install.packages(c("word2vec", "data.table","tidyr","dplyr","stringr","quanteda","uwot","ggplot2","ggrepel", "gt","webshot","wordcloud2","htmlwidgets", "webshot2"))
library(htmlwidgets)
library(wordcloud2)
library(webshot)
library(webshot2)
library(gt)
library(word2vec) # À référencer dans le plan de projet
library(data.table) # À référencer (toutes les librairies)
library(tidyr)
library(dplyr)
library(stringr)
library(quanteda)
library(uwot)
library(ggplot2)
library(ggrepel)

# IMPORTER LES DONNÉES
# Importer le corpus de textes en table de données .csv
corpuscomplet <- fread("corpus_alimentation.csv")

# REPÉRAGE DU MOT "CAFÉ" DANS LES TEXTES (COLONNE U1)
# Résultat: Sur 46,513 articles (corpuscomplet), 4863 articles (10,455%)
corpuscomplet[U1 %ilike% "[Cc]af[ée]s?([[:space:]]|[[:punct:]]|$)"]

# REPÉRAGE DU MOT "CAFÉ" DANS LES TITRES (COLONNE TI)
# Résultat: Sur 46,513 articles (corpuscomplet), 355 articles (0,763%)
corpuscomplet[TI %ilike% "[Cc]af[ée]s?([[:space:]]|[[:punct:]]|$)"]

# COMBINER LES COLONNES TI ET U1 POUR FAIRE UNE NOUVELLE COLONNE "ANALYSE"
corpuscomplet_analyse <- unite(corpuscomplet, Analyse, "TI", "U1", sep = "-", remove = FALSE)

# REPÉRAGE DU MOT "CAFÉ" DANS LA NOUVELLE COLONNE D'ANALYSE (TITRES + TEXTES)
# Résultat: Sur 46,513 articles (corpuscomplet), on en obtient 4875 qui contiennent une variation de "café" (5,934%), dont 4863 pour les textes et 355 pour les titres.
corpusréduit_cafe <- corpuscomplet_analyse[Analyse %ilike% "[Cc]af[ée]s?([[:space:]]|[[:punct:]]|$)"]

# EXPORTATION DU TABLEAU (CORPUS RÉDUIT)
write.csv(corpusréduit_cafe, file = "corpusréduit_cafe.csv", row.names = TRUE)

# CLASSIFICATION LINGUISTIQUE: SOUS-ENSEMBLE AVEC LA COLONNE "LA" (FR)
corpusréduit_cafe_FR <- corpusréduit_cafe[LA %like% "Français"]

# SOUS-ENSEMBLE FR AVEC COLONNES "ANALYSE" et "ID"
x <- (corpusréduit_cafe_FR %>% select(ID, Analyse))
# Unir les deux colonnes en une seule
corpusréduit_cafe_FR_analyse <- unite(x, ID_Analyse, "ID", "Analyse", sep = "-", remove = TRUE)
# Transformer la table de données en vecteur caractères (texte)
corpusréduit_cafe_FR_analyse <- corpusréduit_cafe_FR_analyse$ID_Analyse 

# NETTOYAGE DU TEXTE (FR)
corpusréduit_cafe_FR_analyse <- gsub("◊", " ", corpusréduit_cafe_FR_analyse)
corpusréduit_cafe_FR_analyse <- str_replace_all(corpusréduit_cafe_FR_analyse, "◊", " ")
corpusréduit_cafe_FR_analyse <- str_replace_all(corpusréduit_cafe_FR_analyse, "'", " ")
corpusréduit_cafe_FR_analyse <- str_replace_all(corpusréduit_cafe_FR_analyse, "’", " ")

######
######
######
######
######
###### PARTIE 2 - FENÊTRES CONTEXTUELLES
######
######
######
######
######

# SOUS-ENSEMBLE POUR FONCTION KWIC 
# Fait avec la valeur x, soit le tableau colonne ID et colonne Analyse (créé à la ligne 62)
corpus_KWIC <- x

# NETTOYAGE
corpus_KWIC$Analyse <- str_replace_all(corpus_KWIC$Analyse,"◊", "")
corpus_KWIC$Analyse <- str_replace_all(corpus_KWIC$Analyse,"'", "")
corpus_KWIC$Analyse <- str_replace_all(corpus_KWIC$Analyse,"’", "")
corpus_KWIC$Analyse <- str_replace_all(corpus_KWIC$Analyse,">", "")

# TABLEAU TRANSFORMÉ EN OBJET "CORPUS" DE QUANTEDA (AVEC DOCNAMES) 
# Référence: https://stackoverflow.com/questions/34507574/include-id-number-in-dfm-output
corpus_obj_KWIC <- corpus(corpus_KWIC[["Analyse"]], docnames = corpus_KWIC[["ID"]])

### KWIC - 10 MOTS

contexte_café_10 <- kwic(corpus_obj_KWIC, c("café","cafés","cafe","cafes"), window = 10)
# Exporter le kwic pour transformer en csv 
write.csv(contexte_café_10, file = "contexte_café_10.csv", row.names = TRUE)
# Importer le csv du kwic
contexte_café_10 <- fread("contexte_café_10.csv")
# Ajouter sous-numéro de chaque ID (colonne "from")
contexte_café_10 <- unite(contexte_café_10, ID, "docname", "from", sep = "-", remove = TRUE)
# Ne garder que les colonnes essentielles
contexte_café_10 <- (contexte_café_10 %>% select(ID, pre, keyword, post))
# Exporter le KWIC final
write.csv(contexte_café_10, file = "contexte_café_10.csv", row.names = TRUE)

### KWIC - 5 MOTS
contexte_café_5 <- kwic(corpus_obj_KWIC, c("café","cafés","cafe","cafes"), window = 5)
# Exporter le kwic pour transformer en csv 
write.csv(contexte_café_5, file = "contexte_café_5.csv", row.names = TRUE)
# Importer le csv du kwic
contexte_café_5 <- fread("contexte_café_5.csv")
# Ajouter sous-numéro de chaque ID (colonne "from")
contexte_café_5 <- unite(contexte_café_5, ID, "docname", "from", sep = "-", remove = TRUE)
# Ne garder que les colonnes essentielles
contexte_café_5 <- (contexte_café_5 %>% select(ID, pre, keyword, post))
# Exporter le KWIC final
write.csv(contexte_café_5, file = "contexte_café_5.csv", row.names = TRUE)

### KWIC - 2 MOTS
contexte_café_2 <- kwic(corpus_obj_KWIC, c("café","cafés","cafe","cafes"), window = 2)
# Exporter le kwic pour transformer en csv 
write.csv(contexte_café_2, file = "contexte_café_2.csv", row.names = TRUE)
# Importer le csv du kwic
contexte_café_2 <- fread("contexte_café_2.csv")
# Ajouter sous-numéro de chaque ID (colonne "from")
contexte_café_2 <- unite(contexte_café_2, ID, "docname", "from", sep = "-", remove = TRUE)
# Ne garder que les colonnes essentielles
contexte_café_2 <- (contexte_café_2 %>% select(ID, pre, keyword, post))
# Exporter le KWIC final
write.csv(contexte_café_2, file = "contexte_café_2.csv", row.names = TRUE)

### VISUALISATIONS


# --------- Visualisation (table de données) du mot-clé dans son contexte (10 mots avant-après)

# La fonction suivante ignore la casse, donc pour ne pas doubler les résultats inutilement, on ne mettra que les noms en minuscule.
ContexteDeCafé10 <- kwic(corpusréduit_cafe_FR_analyse, c("café","cafés","cafe","cafes"), window = 10) # window = le nombre de mots avant et après "café"... 10 = bon pour la classification manuelle (compréhension humaine selon le contexte)
View(ContexteDeCafé10)
# Extraire une table avec les résultats
write.csv(ContexteDeCafé10, file = "ContexteDeCafé10.csv", row.names = TRUE)

# --------- Visualisation (table de données) du mot-clé dans son contexte (5 mots avant-après)

# La fonction suivante ignore la casse, donc pour ne pas doubler les résultats inutilement, on ne mettra que les noms en minuscule.
ContexteDeCafé5 <- kwic(corpusréduit_cafe_FR_analyse, c("café","cafés","cafe","cafes"), window = 5) # window = le nombre de mots avant et après "café"... 5 = mieux lors de l'analyse automatisée de la fréquence du contexte lexical (moins lourd pour l'ordinateur, plus efficace pour voir le pourcentage de chaque mot avant/après et ainsi développer une règle)
View(ContexteDeCafé5)
# Extraire une table avec les résultats
write.csv(ContexteDeCafé5, file = "ContexteDeCafé5.csv", row.names = TRUE)

# --------- Visualisation (table de données) du mot-clé dans son contexte (2 mots avant-après)

# La fonction suivante ignore la casse, donc pour ne pas doubler les résultats inutilement, on ne mettra que les noms en minuscule.
ContexteDeCafé2 <- kwic(corpusréduit_cafe_FR_analyse, c("café","cafés","cafe","cafes"), window = 2) # window = le nombre de mots avant et après "café"
View(ContexteDeCafé2)
# Extraire une table avec les résultats
write.csv(ContexteDeCafé2, file = "ContexteDeCafé2.csv", row.names = TRUE)


# --------- Visualisation (table de données) du mot-clé dans son contexte (1 mot avant-après)

# La fonction suivante ignore la casse, donc pour ne pas doubler les résultats inutilement, on ne mettra que les noms en minuscule.
ContexteDeCafé1 <- kwic(corpusréduit_cafe_FR_analyse, c("café","cafés","cafe","cafes"), window = 1) # window = le nombre de mots avant et après "café"... 5 = mieux lors de l'analyse automatisée de la fréquence du contexte lexical (moins lourd pour l'ordinateur, plus efficace pour voir le pourcentage de chaque mot avant/après et ainsi développer une règle)
View(ContexteDeCafé1)
# Extraire une table avec les résultats
write.csv(ContexteDeCafé1, file = "ContexteDeCafé1.csv", row.names = TRUE)

### VISUALISATION DE KWIC (classification manuelle)
# 1) Effectuer une classification manuelle à l'aide d'un des csv généré aux étapes suivantes (garder 100 lignes sans doublons)
# 2) Importer ce csv manuellement classifié
ContexteDeCafé10_clasmanuelle <- fread("20220814_AD_classificationmanuelle_lieubreuvage.csv")
# 3) Créer un tableau 
Tableau_ContexteDeCafé10_clasmanuelle <- gt(data = ContexteDeCafé10_clasmanuelle,
   rowname_col = "rowname",
   caption = NULL,
   rownames_to_stub = FALSE,
   auto_align = TRUE,
   id = NULL,
   locale = NULL,
   row_group.sep = getOption("gt.row_group.sep", " - "),
 ) %>%
 #tab_header(title = "Termes similaires à une variation du mot-clé") %>%
 cols_label(
    pre = "Segment précédent",
    keyword = "Variation du mot-clé",
    post = "Segment suivant",
    Classification = "L = Lieu"
  )%>%
  cols_hide(columns = c(V1, docname, from, to, pattern))%>%
  cols_width(
    pre ~ px(700),
    post ~ px(500),
    everything() ~ px(100)
  )

gtsave(Tableau_ContexteDeCafé10_clasmanuelle, "Visualisation_Tableau_ContexteDeCafé10_clasmanuelle.html")
      webshot::install_phantomjs(force = TRUE)




######
######
######
######
###### PARTIE 3 - STATS - OCCURRENCES DES VARIATIONS DE "CAFÉ" DANS LE CORPUS FR (corpusréduit_cafe_FR_analyse)
######
######
######
######
####### 

# Créer les vecteurs avec nombre d'occurrences pour chaque variation possible
café <- sum(str_count(corpusréduit_cafe_FR_analyse, "café([[:space:]]|[[:punct:]]|$)"))

Café <- sum(str_count(corpusréduit_cafe_FR_analyse, "Café([[:space:]]|[[:punct:]]|$)"))

cafés <- sum(str_count(corpusréduit_cafe_FR_analyse, "cafés([[:space:]]|[[:punct:]]|$)"))

Cafés <- sum(str_count(corpusréduit_cafe_FR_analyse, "Cafés([[:space:]]|[[:punct:]]|$)"))

cafe <- sum(str_count(corpusréduit_cafe_FR_analyse, "cafe([[:space:]]|[[:punct:]]|$)"))

Cafe <- sum(str_count(corpusréduit_cafe_FR_analyse, "Cafe([[:space:]]|[[:punct:]]|$)"))

cafes <- sum(str_count(corpusréduit_cafe_FR_analyse, "cafes([[:space:]]|[[:punct:]]|$)"))

Cafes <- sum(str_count(corpusréduit_cafe_FR_analyse, "Cafes([[:space:]]|[[:punct:]]|$)"))

nb_café <- sum(str_count(corpusréduit_cafe_FR_analyse, "[Cc]af[ée]s?([[:space:]]|[[:punct:]]|$)"))

nb_articles <- length(corpusréduit_cafe_FR_analyse)

nb_articles_FR <- length((corpuscomplet[LA %like% "Français"])$LA)

nb_articles_corpuscomplet <- length(corpuscomplet$ID)

# Créer les vecteurs de pourcentage (sur total des variations)
    # café
p_café <- paste((round(((café/nb_café)*100), digits = 2)), "%", sep=" ") # Fonction "round" pour arrondir les décimales
    # Café
p_Café <- paste((round(((Café/nb_café)*100), digits = 2)), "%", sep=" ") # Fonction "round" pour arrondir les décimales
    # cafés
p_cafés <- paste((round(((cafés/nb_café)*100), digits = 2)), "%", sep=" ") # Fonction "round" pour arrondir les décimales
    # Cafés
p_Cafés <- paste((round(((Cafés/nb_café)*100), digits = 2)), "%", sep=" ") # Fonction "round" pour arrondir les décimales
    # cafe
p_cafe <- paste((round(((cafe/nb_café)*100), digits = 2)), "%", sep=" ") # Fonction "round" pour arrondir les décimales
    # Cafe
p_Cafe <- paste((round(((Cafe/nb_café)*100), digits = 2)), "%", sep=" ") # Fonction "round" pour arrondir les décimales
    # cafes
p_cafes <- paste((round(((cafes/nb_café)*100), digits = 2)), "%", sep=" ") # Fonction "round" pour arrondir les décimales
    # Cafes
p_Cafes <- paste((round(((Cafes/nb_café)*100), digits = 2)), "%", sep=" ") # Fonction "round" pour arrondir les décimales
    # Variations (nb_café)
p_nb_café <- "-"
    # Corpus réduit (nb_articles)
p_nb_articles <- "-"
    # Corpus de langue française
p_nb_articles_FR <- "-"
    # Corpus complet (nb_articles_corpuscomplet)
p_nb_articles_corpuscomplet <- "-"

# Créer les vecteurs de pourcentage (sur total articles FR)
    # café
pfr_café <- "-"
    # Café
pfr_Café <- "-"
    # cafés
pfr_cafés <- "-"
    # Cafés
pfr_Cafés <- "-"
    # cafe
pfr_cafe <- "-"
    # Cafe
pfr_Cafe <- "-"
    # cafes
pfr_cafes <- "-"
    # Cafes
pfr_Cafes <- "-"
    # Variations (nb_café)
pfr_nb_café <- "-"
    # Corpus réduit (nb_articles)
pfr_nb_articles <- paste((round(((nb_articles/nb_articles_FR)*100), digits = 2)), "%", sep=" ")
    # Corpus de langue française
pfr_nb_articles_FR <- "-"
    # Corpus complet (nb_articles_corpuscomplet)
pfr_nb_articles_corpuscomplet <- "-"

# Créer les vecteurs de pourcentage (sur corpus complet)
    # café
pcc_café <- "-"
    # Café
pcc_Café <- "-"
    # cafés
pcc_cafés <- "-"
    # Cafés
pcc_Cafés <- "-"
    # cafe
pcc_cafe <- "-"
    # Cafe
pcc_Cafe <- "-"
    # cafes
pcc_cafes <- "-"
    # Cafes
pcc_Cafes <- "-"
    # Variations (nb_café)
pcc_nb_café <- "-"
    # Corpus réduit (nb_articles)
pcc_nb_articles <- paste((round(((nb_articles/nb_articles_corpuscomplet)*100), digits = 2)), "%", sep=" ")
    # Corpus de langue française
pcc_nb_articles_FR <- paste((round(((nb_articles_FR/nb_articles_corpuscomplet)*100), digits = 2)), "%", sep=" ")
    # Corpus complet (nb_articles_corpuscomplet)
pcc_nb_articles_corpuscomplet <- "-"

# TABLEAU DE STATISTIQUES GÉNÉRALES
stats_corpusréduit_cafe_FR_analyse <- data.frame(
  Donnée=c("Variation « café »","Variation « Café »","Variation « cafés »","Variation « Cafés »","Variation « cafe »","Variation « Cafe »","Variation « cafes »","Variation « Cafes »","Toutes les variations", "Articles en français parlant de café (corpus réduit)", "Articles en français (corpus FR)", "Articles du corpus complet"),
  Quantité=c(café, Café, cafés, Cafés, cafe, Cafe, cafes, Cafes, nb_café, nb_articles, nb_articles_FR, nb_articles_corpuscomplet),
  Pourcentage_variations=c(p_café, p_Café, p_cafés, p_Cafés, p_cafe, p_Cafe, p_cafes, p_Cafes, p_nb_café, p_nb_articles, p_nb_articles_FR, p_nb_articles_corpuscomplet),
  Pourcentage_corpusFR=c(pfr_café, pfr_Café, pfr_cafés, pfr_Cafés, pfr_cafe, pfr_Cafe, pfr_cafes, pfr_Cafes, pfr_nb_café, pfr_nb_articles, pfr_nb_articles_FR, pfr_nb_articles_corpuscomplet),
  Pourcentage_corpuscomplet=c(pcc_café, pcc_Café, pcc_cafés, pcc_Cafés, pcc_cafe, pcc_Cafe, pcc_cafes, pcc_Cafes, pcc_nb_café, pcc_nb_articles, pcc_nb_articles_FR, pcc_nb_articles_corpuscomplet)
) 

# VISUALISATION (STATS GÉNÉRALES)
gt_stats_corpusréduit_cafe_FR_analyse <- gt(data = stats_corpusréduit_cafe_FR_analyse,
   rowname_col = "rowname",
   caption = NULL,
   rownames_to_stub = FALSE,
   auto_align = TRUE,
   id = NULL,
   locale = NULL,
   row_group.sep = getOption("gt.row_group.sep", " - "),
 ) %>%
 tab_header(title = "Description statistique du corpus (quantité brute et pourcentage)")  %>%
 cols_label(
    Donnée = " ",
   Quantité = "Quantité",
    Pourcentage_variations = "Pourcentage des variations",
    Pourcentage_corpusFR = "Pourcentage du corpus FR",
    Pourcentage_corpuscomplet = "Pourcentage du corpus complet"
  ) %>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_column_labels()
        )%>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_body()
        )

# EXPORTATION
write.csv(stats_corpusréduit_cafe_FR_analyse, file = "stats_corpusréduit_cafe_FR_analyse.csv", row.names = TRUE)
gtsave(gt_stats_corpusréduit_cafe_FR_analyse, "Visualisation_gt_stats_corpusréduit_cafe_FR_analyse.png")
      webshot::install_phantomjs(force = TRUE)

### CRÉER DEUX SOUS-TABLEAUX (mots-clés recherchés / articles)

# TABLEAU DES MOTS-CLÉS
statsKW_corpusréduit_cafe_FR_analyse <- data.frame(
  Variations=c("« café »","« Café »","« cafés »","« Cafés »","« cafe »","« Cafe »","« cafes »","« Cafes »","Total"),
  Quantité=c(café, Café, cafés, Cafés, cafe, Cafe, cafes, Cafes, nb_café),
  Pourcentage_variations=c(p_café, p_Café, p_cafés, p_Cafés, p_cafe, p_Cafe, p_cafes, p_Cafes, p_nb_café))

# VISUALISATION
gt_statsKW_corpusréduit_cafe_FR_analyse <- gt(data = statsKW_corpusréduit_cafe_FR_analyse,
   rowname_col = "rowname",
   caption = NULL,
   rownames_to_stub = FALSE,
   auto_align = TRUE,
   id = NULL,
   locale = NULL,
   row_group.sep = getOption("gt.row_group.sep", " - "),
 ) %>%
 tab_header(title = "Sommaire statistique des variations du mot-clé dans le corpus réduit")  %>%
 cols_label(
    Variations = "Variation",
   Quantité = "Nb. d'occurrences",
    Pourcentage_variations = "Pourcentage"
  ) %>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_column_labels()
        )%>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_body()
        )

# EXPORTATION
write.csv(statsKW_corpusréduit_cafe_FR_analyse, file = "statsKW_corpusréduit_cafe_FR_analyse.csv", row.names = TRUE)
gtsave(gt_statsKW_corpusréduit_cafe_FR_analyse, "Visualisation_gt_statsKW_corpusréduit_cafe_FR_analyse.png")
      webshot::install_phantomjs(force = TRUE)

# TABLEAU DES ARTICLES
statsART_corpusréduit_cafe_FR_analyse <- data.frame(
  Données=c("Articles du corpus réduit", "Articles en français", "Articles du corpus complet"),
  Quantité=c(nb_articles, nb_articles_FR, nb_articles_corpuscomplet),
  Pourcentage_corpusFR=c(pfr_nb_articles, pfr_nb_articles_FR, pfr_nb_articles_corpuscomplet),
  Pourcentage_corpuscomplet=c(pcc_nb_articles, pcc_nb_articles_FR, pcc_nb_articles_corpuscomplet)
) 

# VISUALISATION
gt_statsART_corpusréduit_cafe_FR_analyse <- gt(data = statsART_corpusréduit_cafe_FR_analyse,
   rowname_col = "rowname",
   caption = NULL,
   rownames_to_stub = FALSE,
   auto_align = TRUE,
   id = NULL,
   locale = NULL,
   row_group.sep = getOption("gt.row_group.sep", " - "),
 ) %>%
 tab_header(title = "Sommaire statistique des différents corpus")  %>%
 cols_label(
    Données = " ",
   Quantité = "Quantité",
    Pourcentage_corpusFR = "Proportion dans le corpus en français",
    Pourcentage_corpuscomplet = "Proportion dans le corpus complet"
  ) %>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_column_labels()
        )%>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_body()
        )

# EXPORTATION
write.csv(statsART_corpusréduit_cafe_FR_analyse, file = "statsARTcorpusréduit_cafe_FR_analyse.csv", row.names = TRUE)
gtsave(gt_statsART_corpusréduit_cafe_FR_analyse, "Visualisation_gt_statsART_corpusréduit_cafe_FR_analyse.png")
      webshot::install_phantomjs(force = TRUE)

######
######
######
######
###### PARTIE 4 - PROCESSUS DE VECTORISATION SUR LES VARIATIONS DE "CAFÉ" (CORPUS FR)
######
######
######
######
####### 


# CRÉATION DE REGEX (FR) SELON PRÉSENCE DE CHAQUE VARIATION DANS LE CORPUS 

# Créer la liste
café_regex_FR <- list(a = "", b = "", c = "", d = "",
                      e = "", f = "", g = "", h = "" )

# Si cette variation est présente un nombre de fois supérieur à 0, on le rajoute à la regex FR. 
if (café > 0) {
café_regex_FR$a <- "café"
} else
  {
    café_regex_FR$a <- NULL
  }

if (Café > 0) {
café_regex_FR$b <- "Café"
} else
  {
    café_regex_FR$b <- NULL
  }

if (cafés > 0) {
café_regex_FR$c <- "cafés"
} else
  {
    café_regex_FR$c <- NULL
  }

if (Cafés > 0) {
café_regex_FR$d <- "Cafés"
} else
  {
    café_regex_FR$d <- NULL
  }

if (cafe > 0) {
café_regex_FR$e <- "cafe"
} else
  {
    café_regex_FR$e <- NULL
  }

if (Cafe > 0) {
café_regex_FR$f <- "Cafe"
} else
  {
    café_regex_FR$f <- NULL
  }

if (cafes > 0) {
café_regex_FR$g <- "cafes"
} else
  {
    café_regex_FR$g <- NULL
  }

if (Cafes > 0) {
café_regex_FR$h <- "Cafes"
} else
  {
    café_regex_FR$h <- NULL
  }

# Résultat: regex qui ne contient que les variations existantes dans le corpus
café_regex_FR <- unlist(café_regex_FR, use.names = FALSE)

# CRÉER MODÈLE WORD2VEC - Créer le modèle/fonction de vectorisation (word2vec)
# Dans quel genre de contexte apparaît "café" (Synonymes, voisins, champ lexical large/réduit...)?

set.seed(0001)
model <- word2vec(x = corpusréduit_cafe_FR_analyse, type = "cbow", dim = 15, iter = 20)
embedding <- as.matrix(model)

embedding <- predict(model, café_regex_FR, type = "embedding") # travailler une variable contenant toutes les variations présentes, car le word2vec se concentre sur un mot à la fois.
lookslike <- predict(model, café_regex_FR, type = "nearest", top_n = 25) # ajuster la quantité de top_n pour augmenter ou diminuer le nombre de termes dans la liste.

# Exporter le modèle sur l'ordi, créer et nommer avec le nom qu'on veut
write.word2vec(model, file = "ModèleWord2vec.bin")
# puis en important ce modèle déjà fait, c'est moins long
model     <- read.word2vec("ModèleWord2vec.bin")
terms     <- summary(model, "vocabulary")
embedding <- as.matrix(model)

### VISUALISATIONS (TABLEAUX ET NUAGES DE MOTS)

# --------- Table de données des mots selon leurs coordonnées
View(embedding)
write.csv(embedding, file = "embeddingCafé_.csv", row.names = TRUE)
# --------- Table de données des mots selon leurs coordonnées et les mots les plus similaires/proches
View(lookslike)
write.csv(lookslike, file = "lookslikeCafé.csv", row.names = TRUE)

# --------- Visualisation (espace 2D) de la similarité d'un mot-clé par rapport aux autres mots-clés
viz <- umap(embedding, n_neighbors = 6, n_threads = 2)
      # Si erreur "n_neighbors must be smaller than the dataset size", choisir un nombre égal ou inférieur aux lignes dans "embedding"

df  <- data.frame(word = gsub("//.+", "", rownames(embedding)), 
                  xpos = gsub(".+//", "", rownames(embedding)), 
                  x = viz[, 1], y = viz[, 2], 
                  stringsAsFactors = FALSE)

MotsClésSelonCoordonnées <- ggplot(df, aes(x = x, y = y, label = word)) + 
  geom_text_repel() + theme_void() + 
  labs(title = "Les mots-clés selon leurs coordonnées (indice de similarité)")

View(df)

png("Visualisation_MotsClésSelonCoordonnées.png", width = 500, height = 500)
print(MotsClésSelonCoordonnées)
dev.off()

# --------- Visualisation (espace 2D) d'un mot-clé et de ses voisins similaires

# 1) Choisir un mot-clé et transformer ses embeddings en un vecteur (table de données) >>>>> Faire avec chaque mot-clé!
lookslike_café <- as.data.frame(lookslike[["café"]])
lookslike_Café <- as.data.frame(lookslike[["Café"]])
lookslike_cafés <- as.data.frame(lookslike[["cafés"]])
lookslike_Cafés <- as.data.frame(lookslike[["Cafés"]])
lookslike_cafe <- as.data.frame(lookslike[["cafe"]])
lookslike_Cafe <- as.data.frame(lookslike[["Cafe"]])
lookslike_cafes <- as.data.frame(lookslike[["cafes"]])
lookslike_Cafes <- as.data.frame(lookslike[["Cafes"]])

# 2) À partir de la table de données, on filtre les termes qui ont moins de 80% ou 90% de similarité... >>>>> Faire avec chaque mot-clé!
# Plus c'est haut (en pourcentage et en Y), plus c'est similaire!

# "café" (1)
vis_café1 <- lookslike_café %>%
  filter(similarity > 0.90) %>%
  ggplot(aes(x = term2, y = similarity, label = term2)) +
  geom_text_repel() + theme_void() +
  labs(title = "word2vec - Mots-clés les plus similaires à café")
png("Visualisation_MotsClésSimilaires_café1.png", width = 500, height = 500)
print(vis_café1)
dev.off()
# y = similarité / x = distance

    # Nuage de mots
    reverserank <- order(lookslike_café$rank, decreasing = TRUE) # La colonne "rank" assigne les mots plus similaires à un rang plus petit et il faut donc inverser ce rang pour que le nuage de mots soit représentatif.
    wc_café <- data.frame(lookslike_café$term2, reverserank)
    Nuage_MotsClésSimilaires_café1 <- wordcloud2(wc_café, size = 0.5, gridSize =  5, fontFamily = "Arial", color = "#7b4a18")  %>% 
#htmlwidgets::prependContent(htmltools::tags$h1("Termes similaires à une variation du mot-clé (« café »)")) %>%
#htmlwidgets::prependContent(htmltools::tags$h4("Occurrences de « café » dans le corpus analysé: 6572*"))%>%
#htmlwidgets::prependContent(htmltools::tags$a("*Afin de relativiser les données ci-dessous, notons que la proportion élevée d'un mot dans le corpus assure l'uniformité de ses termes les plus similaires."))

          # Exporter
webshot::install_phantomjs()
saveWidget(Nuage_MotsClésSimilaires_café1,"1.html",selfcontained = F)
webshot::webshot("1.html","Visualisation_Nuage_MotsClésSimilaires_café1.png",vwidth = 1000, vheight = 1000, delay =0.2)

    # Tableau  
    Tableau_MotsClésSimilaires_café1 <- gt(data = lookslike_café,
   rowname_col = "rowname",
   caption = NULL,
   rownames_to_stub = FALSE,
   auto_align = TRUE,
   id = NULL,
   locale = NULL,
   row_group.sep = getOption("gt.row_group.sep", " - "),
 ) %>%
 #tab_header(title = "Termes similaires à une variation du mot-clé") %>%
 cols_label(
    term1 = "Variation",
   term2 = "Terme associé",
    similarity = "Indice de similarité (sur 1)",
    rank = "Rang"
  )%>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_column_labels()
        )%>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_body()
        )%>%
  cols_hide(columns = c(term1))
gtsave(Tableau_MotsClésSimilaires_café1, "Visualisation_Tableau_MotsClésSimilaires_café1.png")
      webshot::install_phantomjs()

    

# "Café" (2)
  vis_café2 <- lookslike_Café %>%
  filter(similarity > 0.90) %>%
  ggplot(aes(x = term2, y = similarity, label = term2)) +
  geom_text_repel() + theme_void() +
  labs(title = "word2vec - Mots-clés les plus similaires à Café")
 png("Visualisation_MotsClésSimilaires_café2.png", width = 500, height = 500)
print(vis_café2)
dev.off()

      # Nuage de mots
    reverserank <- order(lookslike_Café$rank, decreasing = TRUE) # La colonne "rank" assigne les mots plus similaires à un rang plus petit et il faut donc inverser ce rang pour que le nuage de mots soit représentatif.
    wc_Café <- data.frame(lookslike_Café$term2, reverserank)
    Nuage_MotsClésSimilaires_café2 <- wordcloud2(wc_Café, size = 0.5, gridSize =  5, fontFamily = "Arial", color = "#7b4a18")
   # %>% htmlwidgets::prependContent(htmltools::tags$h1("Termes similaires à une variation du mot-clé (« Café »)")) %>%
#htmlwidgets::prependContent(htmltools::tags$h4("Occurrences de « Café » dans le corpus analysé: 2377*"))%>%
#htmlwidgets::prependContent(htmltools::tags$a("*Afin de relativiser les données ci-dessous, notons que la proportion élevée d'un mot dans le corpus assure l'uniformité de ses termes les plus similaires."))
   
          # Exporter
webshot::install_phantomjs()
saveWidget(Nuage_MotsClésSimilaires_café2,"1.html",selfcontained = F)
webshot::webshot("1.html","Visualisation_Nuage_MotsClésSimilaires_café2.png",vwidth = 1000, vheight = 1000, delay =0.2)
 
    # Tableau  
    Tableau_MotsClésSimilaires_café2 <- gt(data = lookslike_Café,
   rowname_col = "rowname",
   caption = NULL,
   rownames_to_stub = FALSE,
   auto_align = TRUE,
   id = NULL,
   locale = NULL,
   row_group.sep = getOption("gt.row_group.sep", " - "),
 ) %>%
 #tab_header(title = "Termes similaires à une variation du mot-clé") %>%
 cols_label(
    term1 = "Variation",
   term2 = "Terme associé",
    similarity = "Indice de similarité (sur 1)",
    rank = "Rang"
  )%>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_column_labels()
        )%>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_body()
        )%>%
  cols_hide(columns = c(term1))
gtsave(Tableau_MotsClésSimilaires_café2, "Visualisation_Tableau_MotsClésSimilaires_café2.png")
      webshot::install_phantomjs()


 

# "cafés" (3)
    vis_café3 <- lookslike_cafés %>%
  filter(similarity > 0.90) %>%
  ggplot(aes(x = term2, y = similarity, label = term2)) +
  geom_text_repel() + theme_void() +
  labs(title = "word2vec - Mots-clés les plus similaires à cafés")
 png("Visualisation_MotsClésSimilaires_café3.png", width = 500, height = 500)
print(vis_café3)
dev.off()

      # Nuage de mots
    reverserank <- order(lookslike_cafés$rank, decreasing = TRUE) # La colonne "rank" assigne les mots plus similaires à un rang plus petit et il faut donc inverser ce rang pour que le nuage de mots soit représentatif.
    wc_cafés <- data.frame(lookslike_cafés$term2, reverserank)
    Nuage_MotsClésSimilaires_café3 <- wordcloud2(wc_cafés, size = 0.5, gridSize =  5, fontFamily = "Arial", color = "#7b4a18")
    #%>% 
#htmlwidgets::prependContent(htmltools::tags$h1("Termes similaires à une variation du mot-clé (« cafés »)")) %>%
#htmlwidgets::prependContent(htmltools::tags$h4("Occurrences de « cafés » dans le corpus analysé: 1374*"))%>%
#htmlwidgets::prependContent(htmltools::tags$a("*Afin de relativiser les données ci-dessous, notons que la proportion élevée d'un mot dans le corpus assure l'uniformité de ses termes les plus similaires."))

    
          # Exporter
webshot::install_phantomjs()
saveWidget(Nuage_MotsClésSimilaires_café3,"1.html",selfcontained = F)
webshot::webshot("1.html","Visualisation_Nuage_MotsClésSimilaires_café3.png",vwidth = 1000, vheight = 1000, delay =0.2)

    # Tableau  
    Tableau_MotsClésSimilaires_café3 <- gt(data = lookslike_cafés,
   rowname_col = "rowname",
   caption = NULL,
   rownames_to_stub = FALSE,
   auto_align = TRUE,
   id = NULL,
   locale = NULL,
   row_group.sep = getOption("gt.row_group.sep", " - "),
 ) %>%
 #tab_header(title = "Termes similaires à une variation du mot-clé") %>%
 cols_label(
    term1 = "Variation",
   term2 = "Terme associé",
    similarity = "Indice de similarité (sur 1)",
    rank = "Rang"
  )%>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_column_labels()
        )%>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_body()
        )%>%
  cols_hide(columns = c(term1))
gtsave(Tableau_MotsClésSimilaires_café3, "Visualisation_Tableau_MotsClésSimilaires_café3.png")
      webshot::install_phantomjs()



# "Cafés" (4)
    vis_café4 <- lookslike_Cafés %>%
  filter(similarity > 0.90) %>%
  ggplot(aes(x = term2, y = similarity, label = term2)) +
  geom_text_repel() + theme_void() +
  labs(title = "word2vec - Mots-clés les plus similaires à Cafés")
 png("Visualisation_MotsClésSimilaires_café4.png", width = 500, height = 500)
print(vis_café4)
dev.off()

      # Nuage de mots
    reverserank <- order(lookslike_Cafés$rank, decreasing = TRUE) # La colonne "rank" assigne les mots plus similaires à un rang plus petit et il faut donc inverser ce rang pour que le nuage de mots soit représentatif.
    wc_Cafés <- data.frame(lookslike_Cafés$term2, reverserank)
    Nuage_MotsClésSimilaires_café4 <- wordcloud2(wc_Cafés, size = 0.5, gridSize =  5, fontFamily = "Arial", color = "#7b4a18")
    #%>% 
#htmlwidgets::prependContent(htmltools::tags$h1("Termes similaires à une variation du mot-clé (« Cafés »)")) %>%
#htmlwidgets::prependContent(htmltools::tags$h4("Occurrences de « Cafés » dans le corpus analysé: 58*"))%>%
#htmlwidgets::prependContent(htmltools::tags$a("*Afin de relativiser les données ci-dessous, notons que la proportion élevée d'un mot dans le corpus assure l'uniformité de ses termes les plus similaires."))

    
          # Exporter
webshot::install_phantomjs()
saveWidget(Nuage_MotsClésSimilaires_café4,"1.html",selfcontained = F)
webshot::webshot("1.html","Visualisation_Nuage_MotsClésSimilaires_café4.png",vwidth = 1000, vheight = 1000, delay =0.2)

    # Tableau  
    Tableau_MotsClésSimilaires_café4 <- gt(data = lookslike_Cafés,
   rowname_col = "rowname",
   caption = NULL,
   rownames_to_stub = FALSE,
   auto_align = TRUE,
   id = NULL,
   locale = NULL,
   row_group.sep = getOption("gt.row_group.sep", " - "),
 ) %>%
 #tab_header(title = "Termes similaires à une variation du mot-clé") %>%
 cols_label(
    term1 = "Variation",
   term2 = "Terme associé",
    similarity = "Indice de similarité (sur 1)",
    rank = "Rang"
  )%>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_column_labels()
        )%>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_body()
        )%>%
  cols_hide(columns = c(term1))
gtsave(Tableau_MotsClésSimilaires_café4, "Visualisation_Tableau_MotsClésSimilaires_café4.png")
      webshot::install_phantomjs()



# "cafe" (5)
    vis_café5 <- lookslike_cafe %>%
  filter(similarity > 0.90) %>%
  ggplot(aes(x = term2, y = similarity, label = term2)) +
  geom_text_repel() + theme_void() +
  labs(title = "word2vec - Mots-clés les plus similaires à cafe")
 png("Visualisation_MotsClésSimilaires_café5.png", width = 500, height = 500)
print(vis_café5)
dev.off()

      # Nuage de mots
    reverserank <- order(lookslike_cafe$rank, decreasing = TRUE) # La colonne "rank" assigne les mots plus similaires à un rang plus petit et il faut donc inverser ce rang pour que le nuage de mots soit représentatif.
    wc_cafe <- data.frame(lookslike_cafe$term2, reverserank)
    Nuage_MotsClésSimilaires_café5 <- wordcloud2(wc_cafe, size = 0.5, gridSize =  5, fontFamily = "Arial", color = "#7b4a18")
    #%>% 
#htmlwidgets::prependContent(htmltools::tags$h1("Termes similaires à une variation du mot-clé (« cafe »)")) %>%
#htmlwidgets::prependContent(htmltools::tags$h4("Occurrences de « cafe » dans le corpus analysé: 50*"))%>%
#htmlwidgets::prependContent(htmltools::tags$a("*Afin de relativiser les données ci-dessous, notons que la proportion élevée d'un mot dans le corpus assure l'uniformité de ses termes les plus similaires."))

    
          # Exporter
webshot::install_phantomjs()
saveWidget(Nuage_MotsClésSimilaires_café5,"1.html",selfcontained = F)
webshot::webshot("1.html","Visualisation_Nuage_MotsClésSimilaires_café5.png",vwidth = 1000, vheight = 1000, delay =0.2)

    # Tableau  
    Tableau_MotsClésSimilaires_café5 <- gt(data = lookslike_cafe,
   rowname_col = "rowname",
   caption = NULL,
   rownames_to_stub = FALSE,
   auto_align = TRUE,
   id = NULL,
   locale = NULL,
   row_group.sep = getOption("gt.row_group.sep", " - "),
 ) %>%
 #tab_header(title = "Termes similaires à une variation du mot-clé") %>%
 cols_label(
    term1 = "Variation",
   term2 = "Terme associé",
    similarity = "Indice de similarité (sur 1)",
    rank = "Rang"
  )%>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_column_labels()
        )%>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_body()
        )%>%
  cols_hide(columns = c(term1))
gtsave(Tableau_MotsClésSimilaires_café5, "Visualisation_Tableau_MotsClésSimilaires_café5.png")
      webshot::install_phantomjs()


 
 # "Cafe" (6)
    vis_café6 <- lookslike_Cafe %>%
  filter(similarity > 0.90) %>%
  ggplot(aes(x = term2, y = similarity, label = term2)) +
  geom_text_repel() + theme_void() +
  labs(title = "word2vec - Mots-clés les plus similaires à Cafe")
 png("Visualisation_MotsClésSimilaires_café6.png", width = 500, height = 500)
print(vis_café6)
dev.off()

      # Nuage de mots
    reverserank <- order(lookslike_Cafe$rank, decreasing = TRUE) # La colonne "rank" assigne les mots plus similaires à un rang plus petit et il faut donc inverser ce rang pour que le nuage de mots soit représentatif.
    wc_Cafe <- data.frame(lookslike_Cafe$term2, reverserank)
    Nuage_MotsClésSimilaires_café6 <- wordcloud2(wc_Cafe, size = 0.5, gridSize =  5, fontFamily = "Arial", color = "#7b4a18")
    #%>% 
#htmlwidgets::prependContent(htmltools::tags$h1("Termes similaires à une variation du mot-clé (« Cafe »)")) %>%
#htmlwidgets::prependContent(htmltools::tags$h4("Occurrences de « Cafe » dans le corpus analysé: 84*"))%>%
#htmlwidgets::prependContent(htmltools::tags$a("*Afin de relativiser les données ci-dessous, notons que la proportion élevée d'un mot dans le corpus assure l'uniformité de ses termes les plus similaires."))
    
          # Exporter
webshot::install_phantomjs()
saveWidget(Nuage_MotsClésSimilaires_café6,"1.html",selfcontained = F)
webshot::webshot("1.html","Visualisation_Nuage_MotsClésSimilaires_café6.png",vwidth = 1000, vheight = 1000, delay =0.2)

    # Tableau  
    Tableau_MotsClésSimilaires_café6 <- gt(data = lookslike_Cafe,
   rowname_col = "rowname",
   caption = NULL,
   rownames_to_stub = FALSE,
   auto_align = TRUE,
   id = NULL,
   locale = NULL,
   row_group.sep = getOption("gt.row_group.sep", " - "),
 ) %>%
 #tab_header(title = "Termes similaires à une variation du mot-clé") %>%
 cols_label(
    term1 = "Variation",
   term2 = "Terme associé",
    similarity = "Indice de similarité (sur 1)",
    rank = "Rang"
  )%>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_column_labels()
        )%>%
  tab_style(
        style = "padding-right:40px",
        locations = cells_body()
        )%>%
  cols_hide(columns = c(term1))
gtsave(Tableau_MotsClésSimilaires_café6, "Visualisation_Tableau_MotsClésSimilaires_café6.png")
      webshot::install_phantomjs()