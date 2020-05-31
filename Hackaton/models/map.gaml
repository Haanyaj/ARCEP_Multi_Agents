/***
* Name: map
* Author: Haan
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model map

/* Insert your model definition here */

global {
	file shape_file_factories <- file("../includes/places.shp");
	file shape_file_railways <- file("../includes/railways.shp");
	file shape_file_landuse <- file("../includes/landuse.shp");
	file shape_file_points <- file("../includes/points.shp");
	file shape_file_departement <- file("../includes/admin-departement.shp");
	string blue_points <- "Factory";
	string red_points <- "Centre des zones réseaux";
	string all_zones <- "Etendu des zones réseaux(bleu: encore disponible à l'achat | rouge: tout est acheté)";
	geometry shape <- envelope(shape_file_railways) + envelope(shape_file_landuse) + envelope(shape_file_factories) + envelope(shape_file_points);
	float step <- 20 #mn;
	float total <- 0.0;
	int count_buy <- 1;
	init {
		create factory from: shape_file_factories;
		create railway from: shape_file_railways;
		create hab_areas from: shape_file_landuse;
		create zone from: shape_file_points;
		create telecom from: shape_file_departement;
		create telecom from: shape_file_departement;
		create telecom from: shape_file_departement;
		create market;
	}
}

species client {
	int benef <- 10;
	bool want_to_sell;
	bool is_money <- flip(0.3);
	int money <- rnd(2000) + 4000;
	list<zone> zone_owned;
	list<int> payed;
	int index;
	int index1;
	int to_sell;
	float selled_zone;
	reflex benefice {
		bool win <- flip(0.4);
		if (win) {
		money <- money + rnd(benef);
		}
	}
	reflex sell {
		want_to_sell <- flip (0.001);
		if (want_to_sell and length(zone_owned) > 0) {
			to_sell <- rnd(length(zone_owned));
			if (to_sell > 0) {
				to_sell <- to_sell - 1;
			}
			if (to_sell >= 0) {
			ask zone_owned[to_sell] {
			myself.index1 <- self.who_buy index_of myself;
				if (myself.index1 >= 0) {
					market tmp;
					ask market {
						tmp <- self;
					}
				self.who_buy[myself.index1] <- tmp;
				}
			}
			ask market {
				add myself.zone_owned[myself.to_sell] to: self.zone_available;
				add myself.index1 to: self.frequ;
				add myself to: self.who_sell;
				//do sell;
			}
			}
			}
		}
}

species market parent: client {
	list<zone> zone_available;
	list<int> frequ;
	list<client> who_sell;
	//int count <- 0;
	reflex sell {
		ask zone {
			if (self.is_complete and myself.zone_available contains self) {
				//self.frequency[myself.index] <- 100;
					/*ask factory at_distance range {
						if (self.money > myself.frequency[index] + myself.price) {
							myself.frequency[index] <- myself.frequency[index] + myself.price;
						myself.who_buy[index] <- self;
				 		myself.i <- 0;
						} else { 
					myself.i <- myself.i +1;
						if (myself.i >= 5 and myself.who_buy[index].money - myself.frequency[index] >= 0 and myself.who_buy[index]){
							myself.who_buy[index].money <- myself.who_buy[index].money - myself.frequency[index];
							add myself to: myself.who_buy[index].zone_owned;
							self.index <- myself.count;
							total <- total + myself.frequency[index];
							count_buy <- count_buy +1;
							myself.count <- myself.count + 1;
						if (myself.count >= 10) {
							myself.is_complete <- true;
							}
						}
					}
				}*/
				ask client {
						if (self.money > myself.frequency[index] + myself.price) {
							myself.frequency[index] <- myself.frequency[index] + myself.price;
						myself.who_buy[index] <- self;
						myself.i <- 0;
						} else { 
					myself.i <- myself.i +1;
						if (myself.i >= 5 and myself.who_buy[index].money - myself.frequency[index] >= 0 and myself.who_buy[index]){
							myself.who_buy[index].money <- myself.who_buy[index].money - myself.frequency[index];
							add myself to: myself.who_buy[index].zone_owned;
							self.index <- myself.count;
							total <- total + myself.frequency[index];
							count_buy <- count_buy +1;
							myself.count <- myself.count + 1;
						if (myself.count >= 10) {
							myself.is_complete <- true;
							}
						}
					}
				}
			}
		}
	}
}
		
	


species factory  parent:client {
	rgb color <- #blue;
	aspect base {
		draw shape color: color;
	}
}


species railway  parent:client {
	init {
		money <- 100000;
		benef <- 100;
	}
	rgb color <- #black;
	aspect base {
		draw shape color: color ;
	}
}

species zone {
	bool is_zone <- flip(0.0006);
	rgb color <- #skyblue;
	int price <- 10;
	int count <- 0;
	float range <- 0.04;
	list<int> frequency <- [100, 100, 100, 100, 100, 100, 100, 100, 100, 100];
	list<client> who_buy <- [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil];
	bool is_complete <- false;
	int i <- 0;
	aspect base {
		if (is_zone) {
			if (is_complete) {
				draw circle(range) color: #red;
			} else {
			draw circle(range) color: color;
			}
		} else {
		do die;
		}
	}
	aspect base2 {
		if (is_zone) {
			draw circle(0.0007) color: #red;
		} else {
		do die;
		}
	}
	reflex buy {
		ask factory at_distance range {
			if (length(self.zone_owned) < 1 and myself.is_complete = false) {
				if (self.money > myself.frequency[myself.count] + myself.price) {
					myself.frequency[myself.count] <- myself.frequency[myself.count] + myself.price;
					myself.who_buy[myself.count] <- self;
					myself.i <- 0;
				} else { 
					myself.i <- myself.i +1;
					if (myself.i >= 5 and myself.who_buy[myself.count].money - myself.frequency[myself.count] >= 0 and myself.who_buy[myself.count]){
						myself.who_buy[myself.count].money <- myself.who_buy[myself.count].money - myself.frequency[myself.count];
						add myself to: myself.who_buy[myself.count].zone_owned;
						self.index <- myself.count;
						total <- total + myself.frequency[myself.count];
						count_buy <- count_buy +1;
						myself.count <- myself.count + 1;
						if (myself.count >= 10) {
							myself.is_complete <- true;
						}
					}
				}
			}
		}
		ask zone at_distance range {
			ask telecom {
				int invest <- (self.zone_owned contains myself) ? myself.price : myself.price * 2;
				if (myself.is_complete = false) {
					if (self.money > myself.frequency[myself.count] + invest) {
						myself.frequency[myself.count] <- myself.frequency[myself.count] + invest;
						myself.who_buy[myself.count] <- self;
						myself.i <- 0;
					} else { 
						myself.i <- myself.i +1;
						if (myself.who_buy[myself.count] = self and myself.i >= 5 and myself.who_buy[myself.count].money - myself.frequency[myself.count] >= 0){
							myself.who_buy[myself.count].money <- myself.who_buy[myself.count].money - myself.frequency[myself.count];
							add myself to: self.zone_owned;
							total <- total + myself.frequency[myself.count];
							count_buy <- count_buy +1;
							myself.count <- myself.count + 1;
							if (myself.count >= 10) {
								myself.is_complete <- true;
							}
						}
					}
				}
			}
		}
		ask railway at_distance range {
				int invest <- myself.price * 4;
				if (myself.is_complete = false and !(self.zone_owned contains myself)) {
					if (self.money > myself.frequency[myself.count] + invest) {
						myself.frequency[myself.count] <- myself.frequency[myself.count] + invest;
						myself.who_buy[myself.count] <- self;
						myself.i <- 0;
					} else { 
						myself.i <- myself.i +1;
						if (myself.who_buy[myself.count] = self and myself.i >= 5 and myself.who_buy[myself.count].money - myself.frequency[myself.count] >= 0){
							myself.who_buy[myself.count].money <- myself.who_buy[myself.count].money - myself.frequency[myself.count];
							add myself to: self.zone_owned;
							total <- total + myself.frequency[myself.count];
							count_buy <- count_buy +1;
							myself.count <- myself.count + 1;
							if (myself.count >= 10) {
								myself.is_complete <- true;
							}
						}
					}
				}
			}	
	}
}

species hab_areas  {
	rgb color <- #gray;
	aspect base {
		draw shape color: color;
	}
}

species telecom parent:client {
	int nb <- 0;	
	init {
	money <- rnd(10000) + 50000;
	benef <- 100;
	}
}


experiment frequency type:gui {
	parameter "Shapefile for the factories:" var: shape_file_factories category: "GIS";
	parameter "Shapefile for the railways:" var: shape_file_railways category: "GIS";
	parameter "Shapefile for the landuse:" var: shape_file_landuse category: "GIS";
	parameter "Shapefile for the telecom:" var: shape_file_landuse category: "GIS";
	parameter "Shapefile for the networks zones:" var: shape_file_points category: "GIS";
	parameter "Blue points:" var: blue_points category: "Légende";
	parameter "Circles:" var: all_zones category: "Légende";
	parameter "Red points:" var: red_points category: "Légende";
	output {
		display charts {
			chart "Prix Moyen d'une bande" {
					data "Prix par bande" value: total/count_buy ;
			}
		}
		
		display city_display type:opengl {
			species hab_areas aspect:base;
 			species factory aspect: base;
			species railway aspect: base;
			species zone aspect: base transparency:0.7;
			species zone aspect: base2;
		}
	}
}