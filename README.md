# Projet « café-café » (désambiguisation)
* Autrice principale: Amélie Ducharme (amelie-ducharme)
* Contributrices: Lisa Teichmann et Elisabeth Doyon

Le projet « café-café » avait pour but de désambiguïser deux termes, « café » le lieu et « café » la chose (breuvage, grain, industrie…), afin d’aider à repérer automatiquement les mentions d’emplacements géographiques dans les textes analysés par le Laboratoire d’analyse des discours et récits collectifs (LADIREC). 

En utilisant un corpus médiatique sur l’alimentation composé de 46 513 articles récoltés par le LADIREC, nous avons d’abord réduit le nombre de textes en conservant seulement ceux dans lesquels nous avons trouvé, grâce à une expression régulière, certaines variations du mot « café » (avec ou sans accent/majuscule/marque du pluriel). 

Ensuite, nous n’avons retenu que les articles de langue française, puisque l’ambiguïté du mot « café » est inexistante en anglais (où « coffee house » et « cafe » se distinguent plus clairement du simple « coffee »). 

Ensuite, grâce à des procédés de vectorisation (word-to-vec), nous avons pu déterminer quels termes du sous-corpus étaient les plus similaires à chaque variation de « café » et, donc, quelles tendances se dégagent de l’emploi de chaque variation (catégorie grammaticale, accord, champ lexical, etc). 

Nous avons également usé de fenêtres contextuelles (keyword-in-context) pour analyser les segments qui précèdent et suivent chaque occurrence de « café », encore dans le but de dégager les tendances quant à l’emploi de chaque variation et, ultimement, de formuler des hypothèses de stratégies qui rendraient l’ordinateur capable de distinguer les deux sens du mot « café » lors d’une analyse automatisée.
