# ARCEP_Multi_Agent
Simulation of 5G repartition with GAMA framework
global {
 #chargement des fichiers .shp -> cartes IGN
 #légende du projet
 #float step -> temps du cycle pour simuler des interactions agents
 #création des fichiers importés sur la plateforme
 
 init{
  #création des agents issues des fichiers importés
 }
}

species client {
  #classe parent de télécom, railway, factory
 reflex benefice {
   #permet la simulation de l'argent possédé par les agents
 }
}

species factory parent: client # héritage client {

}

species railway parent: client # héritage client {

}

species zone parent:client #héritage client {
#contient la portée de la zone, le prix de vente aux enchères de base
#ainsi que ceux détenant la zone
#aspect : rouge-> zone complète / bleue-> zone incomplète
#reflex buy {
ask factory, zone, telecom, railways #achat aux enchères des bandes de la zone
#ajout des acheteurs de la zone
#ajout de la zone à l'acheteur
#valeur d'achat de la zone modifiée
}
}

species hab_areas {
#création des zones habitées
}

experiment frequency {
#affichage du chemin des fichiers importés
#affichage de la légende
#affichage de la carte
#affichage d'un graphe du prix du moyen de la bande
}
