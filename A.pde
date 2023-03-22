/////////////////////////////////////////////////////
//
// Asteroids
// DM2 "UED 131 - Programmation impérative" 2021-2022
// NOM         :  Bapin
// Prénom      :  Nathan
//
// Collaboration avec : 
//
/////////////////////////////////////////////////////

//===================================================
// les variables globales
//===================================================

import processing.sound.*;

//////////////////////
// Pour le vaisseau //
//////////////////////
float shipX, shipY;                    // Coordonnées du vaisseau         
float shipAngle=(3*PI)/2;              // Angle du vaisseau
float shipVx, shipVy;                  // Vecteurs vitesse du vaisseau
float shipAx, shipAy;                  // Vecteurs d'accélération du vaisseau
boolean engine=false;                  // Pour déterminer si le moteur est allumé ou non
SoundFile engineSound;                 // Son du moteur
//////////////////////
// Pour le missile  //
//////////////////////
float missX[], missY[];                // Coordonnées des missiles
float missVx[], missVy[];              // Vecteurs vitesse des missiles
int nbrMiss;                           // Nombre de missile
int nbrMaxMiss;                        // Nombre maximum de missile 
int temp;                              // Pour réguler la cadence de tir maximum 
SoundFile missSound;                   // Son des missiles
//////////////////////
// Pour l'astéroïde //
////////////////////// 
float astX[], astY[];                  // Coordonnées des astéroïdes
int tailleAst[];                       // Taille des astéroïdes
float astVx[], astVy[];                // Vecteurs vitesse des astéroïdes

int nbrMaxAst;                         // Nombre maximum d'astéroïde
int nbrInitAst;                        // Nombre initial d'astéroïde
int nbrAst;                            // Nombre actuel d'astéroïde
SoundFile bangL;                       // Son de grosse explosion
SoundFile bangS;                       // Son de petite explosion
////////////////////////////
// Pour la gestion du jeu //
////////////////////////////
boolean gameOver=false;                // Pour savoir si le joueur a perdu ou non
boolean init=true;                     // Pour savoir si la partie a commencé ou pas
int score10=10;                        // Pour ajouter un astéroïde tous les 10 points
int shot30=0;                          // Pour compter le nombre d'astéroïdes de taille 30 touchés 
int shot60=0;                          // Pour compter le nombre d'astéroïdes de taille 60 touchés 
int shot90=0;                          // Pour compter le nombre d'astéroïdes de taille 90 touchés 
SoundFile gameSong;                    // Son du jeu (il ralentit beaucoup le lancement du programme donc vous pouvez mettre en commentaire la ligne 107, 108, 789 et 796)
////////////////////////////////////
// Pour la gestion de l'affichage //
////////////////////////////////////
PFont courier;                         // Police courier de taille 20
PFont bauhaus;                         // Police bauhaus de taille 48
PFont bauhaus2;                        // Police bauhaus de taille 80
PFont Bahn;                            // Police bahn de taille 30
int score=0;                           // Score
int secondes;                          // Pour compter les secondes écoulés depuis le début de la partie
int minutes;                           // Pour compter les minutes écoulés depuis le début de la partie 
int startTime;                         // Temps au lancement de la partie 
int currentTime;                       // Temps écoulé depuis le début de la partie
int[] stopTime;                        // Temps à l'arrêt de la partie

//===================================================
// l'initialisation
//===================================================
void setup() {
  //Taille de la fenêtre : 800x800
  size(800, 800);
  //Couleur de d'arrière plan : noir
  background(0);
  //Initialisation des astéroïdes
  nbrInitAst=5;
  nbrMaxAst=100;
  nbrAst=nbrInitAst;
  astX = new float[nbrMaxAst];     
  astY = new float[nbrMaxAst];
  tailleAst = new int[nbrMaxAst];      
  astVx = new float[nbrMaxAst];     
  astVy = new float[nbrMaxAst];
  //Initialisation des missiles
  nbrMaxMiss=100;
  missX = new float[nbrMaxMiss];
  missY = new float[nbrMaxMiss];
  missVx = new float[nbrMaxMiss];
  missVy = new float[nbrMaxMiss];
  //Initialisation du tableau de temps
  stopTime= new int[2];
  //Initialisation des sons
  engineSound = new SoundFile(this, "thrust.mp3");
  engineSound.amp(0.3);    //Réduction du volume du son du moteur
  missSound = new SoundFile(this, "fire.mp3");
  missSound.amp(0.5);      //Réduction du volume du son des missiles
  bangL = new SoundFile(this, "bangLarge.mp3");
  bangL.amp(0.5);
  bangS = new SoundFile(this, "bangSmall.mp3");
  bangS.amp(0.5);
  gameSong = new SoundFile(this, "celeste_original_soundtrack.mp3");
  gameSong.amp(0.2);
  //Initialisation des polices
  courier=createFont("courier",20);
  bauhaus=loadFont("Bauhaus93-48.vlw");
  bauhaus2=loadFont("Bauhaus93-80.vlw");
  Bahn=loadFont("Bahnschrift-30.vlw");
  //Initialisation du jeu
  initGame();
}

// -------------------- //
// Initialise le jeu    //
// -------------------- //
void initGame() {
  //Initialise le vaisseau
  initShip();
  //Initialise les astéroïdes
  initAsteroids(nbrInitAst);
  //Affiche l'écran d'accueil
  displayInitScreen();
}

//===================================================
// la boucle de rendu
//===================================================
void draw() {
  if (init==false) {
    //Couleur de l'arrière plan : noir
    background(0);    
    //Permet de régler le délai possible entre chaque tir de missile en fonction de la fonction draw
    temp--;
    //Affiche les astérïdes
    displayAsteroids();
    //Affiche le vaisseau
    displayShip();
    //Affiche les missilles
    displayBullets();
    //Affiche le score
    displayScore();
    //Affiche le temps
    displayChrono();
    //Affiche l'écran de fin si le joueur perd
    if (gameOver==true)
      displayGameOverScreen();
    //Déplace les astéroïdes
    moveAsteroids();
    //Déplace le vaisseau
    moveShip();
    //Déplace les missilles
    moveBullets();
    //Test les collisions
    shipCollision();
    missCollision();   
  }

}

// ------------------------ //
//  Initialise le vaisseau  //
// ------------------------ //
void initShip() {
  //Initialise les coordonnées du vaisseau à 400
  shipX=400;
  shipY=400;
  //Initialise la vitesse et l'accélération du vaisseau à 0
  shipVx=0;
  shipVy=0;
  shipAx=0;
  shipAy=0;
  
  for (int i=0; i<nbrMaxMiss; i++) {
    //Initialise les coordonées des missiles à -100
    missX[i]=-100;
    missY[i]=-100;
    //Initialise la vitesse des missiles à 0
    missVx[i]=0;
    missVy[i]=0;
  }
}

// --------------------- //
//  Deplace le vaisseau  //
// --------------------- //
void moveShip() {
  if (gameOver==false) {
    //Augmente la vitesse du vaisseau
    shipVx+=shipAx;
    shipVy+=shipAy;
    //Déplace le vaisseau selon son vecteur vitesse
    shipX+=shipVx;
    shipY+=shipVy;
    //Effet wraparound
    if (shipX>800) 
      shipX-=800;
    if (shipY>800) 
      shipY-=800;    
    if (shipX<0) 
      shipX+=800;   
    if (shipY<0) 
      shipY+=800;
    
  }
}

// -------------------------- //
//  Crée un nombre n d'asteroïdes  //
// -------------------------- //
void initAsteroids(int n) {
  for (int i=0; i<nbrMaxAst; i++) {
    //Initialise les coordonées des astéroïdes à -200
    astX[i]=-200;
    astY[i]=-200;
    //Initialise la vitesse et la taille des astéroïdes à 0
    astVx[i]=-200;
    astVy[i]=-200;
    tailleAst[i]=0;
  }
  //Créé un nombre n d'astéroïdes
  for (int i=0; i<n; i++) {
    initAsteroid(i);
  }
}

// -------------------------- //
//  Crée un nouvel asteroïde  //
// -------------------------- //
void initAsteroid(int i) {
  //Donne des coordonnées aléatoire à l'astéroïde i
  astX[i]=random(0, 800);
  astY[i]=random(0, 800);
  //Corrige ses coordonnées pour le placer sur le bord de la fenêtre (60<x,y<160, 640<x,y<740)
  if ((astX[i]>160) && (astX[i]<400)) {     
    astX[i]=random(60, 160);
  }   
  
  if ((astX[i]>=400) && (astX[i]<640)) {
    astX[i]=random(640, 740);
  }

  if ((astY[i]>160) && (astY[i]<400)) {
    astY[i]=random(60, 160);
  }
  if ((astY[i]>=400) && (astY[i]<640)) {
    astY[i]=random(640, 740);
  }
  
  //Lui donne une taille aléatoire entre 30,60 et 90 
  tailleAst[i]=int(random(1,4))*30;       
  //Lui donne une vitesse et une direction aléatoire
  astVx[i] = 3*cos(random(0, PI*2));
  astVy[i] = 3*sin(random(0, PI*2));
}




// ------------------------------ //
//  Crée la forme de l'asteroïde  //
// ------------------------------ //
// i : l'indice de l'asteroïde dans le tableau
//
void createAsteroid(int i) {
}

// --------------------- //
//  Deplace les asteroïdes  //
// --------------------- //
void moveAsteroids() {
  for (int i=0; i<nbrAst; i++) {
    //Déplace l'astéroïde d'indice i selon son vecteur vitesse
    astX[i]+=astVx[i];
    astY[i]+=astVy[i];
    
    //Effet wraparound
    if (astX[i]>800) 
      astX[i]-=800;
    if (astY[i]>800) 
      astY[i]-=800;
    if (astX[i]<0) 
      astX[i]+=800;
    if (astY[i]<0) 
      astY[i]+=800;
  }
}

// ------------------------ //
//  Détecte les collisions  //
// ------------------------ //
// o1X, o1Y : les coordonnées (x,y) de l'objet1
// o1D      : le diamètre de l'objet1 
// o2X, o2Y : les coordonnées (x,y) de l'objet2
// o2D      : le diamètre de l'objet2 
//
boolean collision(float o1X, float o1Y, float o1D, float o2X, float o2Y, float o2D) {
  //Si la distance entre l'object 1 et l'object 2 est inférieure ou égale à la somme du diamètre de l'object 1 divisé par 2 et de l'object 2 divisé par 2
  if (dist(o1X, o1Y, o2X, o2Y)<=(o1D/2)+(o2D/2)) 
    return true;
  else 
    return false;
}

//J'ai préféré créer des fonctions pour tester les collisions plutôt que de le mettre directement dans le draw().

//Collisions entre le vaisseau et les astéroïdes
void shipCollision() {
  for (int i=0; i<=nbrAst; i++) {
    if (collision(shipX, shipY, 10, astX[i], astY[i], tailleAst[i])==true) {
      gameOver=true;
      stopTime[0]=minutes;
      stopTime[1]=secondes;
      bangL.play();
      gameSong.stop();
      for (int j=0; i<nbrMaxAst; i++) {
        //Arrête le mouvement du vaisseau et de tous les astéroides et missilles
        astVx[j]=0;
        astVy[j]=0;
        shipX=-100;
        shipY=-100;
        shipVx=0;
        shipVy=0;
        missVx[j]=0;
        missVy[j]=0;
        //Déplace les missiles en dehors de la fenêtre
        missX[j]=-100;
        missY[j]=-100;          
      }
    }
  }
}

//Collision entre les missiles et les astéroïdes
void missCollision() {
  for (int i=0; i<nbrMiss; i++) {
    //Pour chaque missile, teste la collision avec tous les astéroïdes
      for (int j=0; j<nbrAst; j++) {
        if (collision(missX[i], missY[i], 0, astX[j], astY[j], tailleAst[j])==true) {
          shootAsteroid(j,missVx[i],missVy[i]);
          deleteBullet(i);
          //Ajoute un nouvel astéroïde si le score atteint un multiple de 10 (sauf 0)
          if ((score>=score10) && (nbrAst<nbrMaxAst)) {
            initAsteroid(nbrAst);
            nbrAst+=1;
            score10+=10;
          }
        }
      } 
    }
}

// ----------------- //
//  Tire un missile  //
// ----------------- //
void shoot() {
  //Coordonnées du nouveau missille = coordonnées du vaisseau
  missX[nbrMiss]=shipX;
  missY[nbrMiss]=shipY;
  //Vitesse du nouveau missille
  missVx[nbrMiss]=5*cos(shipAngle);
  missVy[nbrMiss]=5*sin(shipAngle);
  //Incrémente le nombre de missille
  nbrMiss++;
}

// ------------------------------------------- //
//  Calcule la trajectoire du ou des missiles  //
// ------------------------------------------- //
void moveBullets() {
  for (int i=0; i<nbrMiss; i++) {
    //Déplace le missile d'indice i selon son vecteur vitesse 
    missX[i]+=missVx[i];
    missY[i]+=missVy[i];
    //Supprime le missile si il dépasse la taille de la fenêtre
    if ((missX[i]>800) || (missX[i]<0) || (missY[i]>800) || (missY[i]<0)) {
      if (missX[i]>-100)
        deleteBullet(i);
    }
    
  }
  
}

// --------------------- //
//  Supprime un missile  //
// --------------------- //
// idx : l'indice du missile à supprimer
//
void deleteBullet(int idx) {
  //Supprime le missile d'indice idx et à partir de celui-ci, décale la position des missiles dans le tableau : tout missile d'indice i>idx, i=i-1 
  for (int i=idx; i<nbrMiss; i++) {
    missX[i]=missX[i+1];
    missY[i]=missY[i+1];
    missVx[i]=missVx[i+1];
    missVy[i]=missVy[i+1];
  }
  //Décrémente le nombre de missiles
  nbrMiss--;
}

// --------------------- //
//  touche un astéroïde  //
// --------------------- //
// idx    : l'indice de l'atéroïde touché
// vx, vy : le vecteur vitesse du missile
//
void shootAsteroid(int idx, float vx, float vy) {
  //Angle d'incidence du missile 
  float angle=atan2(vx,vy);
  //Si la taille de l'astéroïde est 30
  if (tailleAst[idx]==30) {   
    int t=int(random(2));
    //50% de chance qu'un nouvel astéroïde soit créé à l'indice idx (celui de l'astéroïde touché)
    if (t==0) 
      initAsteroid(idx);
    //50% de chance que l'astéroïde soit juste supprimé
    else 
      deleteAsteroid(idx);  
    //Lance le son "bangS"
    bangS.play();
    score+=3;
    shot30++;
  }
  
  else {
    //Si la taille de l'astéroïde est 60
    if (tailleAst[idx]==60) {
      //Sépare l'astéroïde en deux astéroïde de taille 30
      tailleAst[idx]=30;
      tailleAst[nbrAst]=30;
      //Ajoute un nouvel astéroïde aux même coordonnées que l'ancien
      astX[nbrAst]=astX[idx];
      astY[nbrAst]=astY[idx];
      //Projette les deux astéoïdes dans une direction aléatoire en s'éloignant du vaisseau
      astVx[idx]=angle+cos(random(-PI*2,PI*2));
      astVy[idx]=angle+sin(random(-PI*2,PI*2));
      
      astVx[nbrAst]=angle+cos(random(-PI*2,PI*2));
      astVy[nbrAst]=angle+sin(random(-PI*2,PI*2));
      
      nbrAst++;
      bangS.play();
      score+=2;
      shot60++;
    } 
    //Si la taille de l'astéroïde est 90
    if (tailleAst[idx]==90) {
      //Sépare l'astéroïde en deux astéroïde de taille 60
      tailleAst[idx]=60;
      tailleAst[nbrAst]=60;
      //Ajoute un nouvel astéroïde aux même coordonnées que l'ancien
      astX[nbrAst]=astX[idx];
      astY[nbrAst]=astY[idx];
      //Projette les deux astéoïdes dans une direction aléatoire en s'éloignant du vaisseau
      astVx[idx]=angle+cos(random(-PI*2,PI*2));        
      astVy[idx]=angle+sin(random(-PI*2,PI*2));
      
      astVx[nbrAst]=angle+cos(random(-PI*2,PI*2));
      astVy[nbrAst]=angle+sin(random(-PI*2,PI*2));
      
      nbrAst++; 
      bangL.play();
      score+=1;
      shot90++;
    }
  }
  
}

// ----------------------- //
//  supprime un astéroïde  //
// ----------------------- //
// idx    : l'indice de l'atéroïde touché
//
void deleteAsteroid(int idx) {
  //Supprime l'astéroïde d'indice idx et à partir de celui-ci, décale la position des missiles dans le tableau : tout missile d'indice i>=idx, i=i-1 
  for (int i=idx; i<nbrAst; i++) {
    astX[i]=astX[i+1];
    astY[i]=astY[i+1];
    astVx[i]=astVx[i+1];
    astVy[i]=astVy[i+1];
    tailleAst[i]=tailleAst[i+1];
  }
  nbrAst--;
  //Remet le nombre initial d'astéroïdes si le nombre d'astéroïdes atteint 0
  if (nbrAst<=0)
    initAsteroids(nbrInitAst);
}

//===================================================
// Gère les affichages
//===================================================

// ------------------- //
// Ecran d'accueil     //
// ------------------- //
void dessinVaisseau() {
  noFill();
  stroke(0,255,0);
  strokeWeight(5);
  translate(0,140);
  rotate(radians(-30));
  
  //Dessin du vaisseau
  beginShape();
  vertex(150, 100);
  vertex(40, 60);
  vertex(60, 100);
  vertex(40, 140);
  vertex(150, 100);
  endShape();
  resetMatrix();
  
  //Dessin des missiles
  translate(350,-50);
  rotate(radians(10));
  line(260,180,310,200);
  translate(-130,50);
  rotate(radians(-20));
  line(260,180,310,200);
  translate(-130,50);
  rotate(radians(-20));
  line(260,180,310,200);
  translate(-130,50);
  rotate(radians(-20));
  line(260,180,310,200);
  translate(-81,-29);
  line(260,180,310,200);
  resetMatrix();
  
  //Dessin de l'astéroïde
  translate(550,100);
  beginShape();
  vertex(131,39);
  vertex(175, 58);
  vertex(214, -29);
  vertex(173, -62);
  vertex(110, -19);
  vertex(131,39);
  endShape();
  
  strokeWeight(1);
  resetMatrix();
}



void displayInitScreen() {
  
  //Police du texte : bauhaus
  textFont(bauhaus);
  //Centre le texte
  textAlign(CENTER);
  //Couleur du texte : blanc
  fill(255);
  textSize(60);
  //Ecrit "ASTEROID" aux coordonnées 400,300
  text("ASTEROID", 400, 250);
  //Change la police
  textFont(Bahn);
  textSize(25);
  text("Vous êtes confrontés à des champs d'astéroïdes !\nVotre but est de survivre le plus longtemps possible en évitant \nles astéroïdes et en les détruisants.", 400,350);
  
  //Affiche les points gagnés selon la taille des astéroides touchés
  textAlign(LEFT);
  textFont(bauhaus);
  textSize(20);
  stroke(255);
  noFill();
  strokeWeight(2);
  ellipse(550,500,20,20);
  text("   : 3 point",575,505);
  ellipse(550,550,40,40);
  text("   : 2 points",575,555);
  ellipse(550,620,60,60);
  text("   : 1 points",575,625);
  strokeWeight(1);
  
  //Affiche les commandes
  fill(0,255,0);
  text("COMMANDES",80,510);
  text("---------------------------",80,525);
  text("   : Tourne à droite",85,550);
  text("   : Tourne à gauche",85,575);
  text("   : Allume le moteur",85,600);
  text(" ESAPCE : Tire",75,625);
  text(" ENTRER : Téléportation aléatoire",75,650);
  
  textSize(30);
  textAlign(CENTER);
  text("Press ENTER to start", 400, 750);
  
  textFont(courier);
  textSize(15);
  text("▶",80,550);
  text("◀",80,575);
  text("▲",80,600);
  
  //Affiche le dessin du haut
  dessinVaisseau();
}

// -------------- //
//  Ecran de fin  //
// -------------- //
void displayGameOverScreen() {
  background(0);
  //Police du texte : bauhaus2
  textFont(bauhaus2);
  //Centre le texte
  textAlign(CENTER);
  //Couleur du texte : blanc
  fill(255);
  
  //Ecrit "GAME OVER" aux coordonnées 400,200
  text("GAME OVER", 400, 300);
  textFont(bauhaus);
  textSize(25);
  text("Votre score final est de :",600,400);
  text("Votre partie a duré :",200,400); 
  fill(0,255,0);
  //Affiche le temps auquel c'est arrêté la partie
  text(stopTime[0]+" minutes et "+stopTime[1]+" secondes",200,430);
  //Affiche le score final du joueur
  text(score,600,430);
  
  //Affiche le nombre d'astéroïdes touchés selon leur taille
  noFill();
  stroke(255);
  strokeWeight(2);
  ellipse(150,550,30,30);
  ellipse(400,550,60,60);
  ellipse(700,550,90,90);
  
  fill(0,255,0);
  text(shot30,150,650);
  text(shot60,400,650);
  text(shot90,700,650);
  
  text("ENTRER pour recommencer",400,750);
  
  //Affiche le dessin du haut
  dessinVaisseau();
}


// --------------------- //
//  Affiche le vaisseau  //
// --------------------- //
void displayShip() {
  //Déplace le tout aux coordonnées du vaisseau
  translate(shipX, shipY);
  //Tourne le vaisseau pour qu'il soit orienté selon son angle
  rotate(shipAngle);
  //Couleur de remplissage : noir
  fill(0);
  //Dessin des flammes derrière le vaisseau quand le moteur est allumé
  if (engine==true) {
    stroke(255, 0, 0);
    triangle(-25, 0, -15, -5, -15, 5);
  }
  //Couleur du trait : blanc
  stroke(255);
  //Dessin du vaisseau
  beginShape();
  vertex(0, 0);
  vertex(-17, -7);
  vertex(-15, 0);
  vertex(-17, 7);
  vertex(0, 0);
  endShape();
  //Annule l'effet de la translation
  resetMatrix();
}

// ------------------------ //
//  Affiche les asteroïdes  //
// ------------------------ //
void displayAsteroids() {
  //Couleur de remplissage : noir
  fill(0);
  //Couleur du trait : blanc
  stroke(255);
  //Dessine tous les astéroïdes
  for (int i=0; i<nbrAst; i++) {
    ellipse(astX[i], astY[i], tailleAst[i], tailleAst[i]);
  }
}

// ---------------------- //
//  Affiche les missiles  //
// ---------------------- //
void displayBullets() {
  //Dessine tous les missiles
  for (int i=0; i<nbrMiss; i++) {
    line(missX[i], missY[i], missX[i]+missVx[i], missY[i]+missVy[i]); 
  }
}

// ------------------- //
//  Affiche le chrono  //
// ------------------- //
void displayChrono() {
  //Permet de pouvoir recommencer le chrono si le joueur relance une partie
  currentTime=millis()-startTime;
  secondes=currentTime/1000;
  minutes=secondes/60;
  //Affiche le chrono
  textFont(bauhaus);
  textAlign(CENTER);
  textSize(25);
  fill(0,255,0);
  text("Time : "+minutes+": "+secondes, 100, 50);
  
}

// ------------------- //
//  Affiche le score   //
// ------------------- //
void displayScore() {
  //Police du texte : bauhaus
  textFont(bauhaus);
  //Centre le texte
  textAlign(CENTER);
  //Taille du texte : 30
  textSize(25);
  //Couleur de remplissage : blanc
  fill(0,255,0);
  //Ecrit le score aux coordonnées 700,50
  text("Score : "+score, 700, 50);
}

//===================================================
// Gère l'interaction clavier
//===================================================

// ------------------------------- //
//  Quand une touche est enfoncée  //
// ------------------------------- //
// flèche droite  = tourne sur droite
// flèche gauche  = tourne sur la gauche
// flèche haut    = accélère
// barre d'espace = tire
// entrée         = téléportation aléatoire
//
void keyPressed() {
  //Si le joueur n'a pas perdu
  if (gameOver==false) {
    //Augmente l'angle du vaisseau de 5 degrés si le joueur appui sur la flèche de droite
    if (keyCode==RIGHT) 
      shipAngle+=radians(5);
    //Diminue l'angle du vaisseau de 5 degrés si si le joueur appui sur la flèche de gauche
    if (keyCode==LEFT) 
      shipAngle-=radians(5);
    //Tire un missile si le joueur appui sur la barre espace
    if ((key==' ') && (temp<=0)) {
      shoot();
      //Permet de ne pouvoir tirer que tous les 5 appels de la fonction draw
      temp=5;
      //Lance le son "missSound"
      missSound.play();
    }
    //Si le joueur appui sur la flèche du haut
    if (keyCode==UP) {
      if (gameOver==false) {
        //Permet que le son "engineSound" ne se répète pas si la touche est maintenue
        if (engine==false)
          engineSound.play();
        //Allume le moteur
        engine=true;
        //Vecteur d'accélération du vaisseau de norme 0.5 
        shipAx= 0.25*cos(shipAngle);
        shipAy= 0.25*sin(shipAngle);     
      }
    }
  }
  //Si la touche entrée est appuyée
  if (keyCode==ENTER) {
    //Lance le jeu si le joueur appui sur la touche entrée sur l'écran d'acceuil
    if (init==true) {
      startTime=millis();        //Lance le chrono
      init=false;
      //Lance la musique du jeu
      gameSong.loop();
    }
    else {
      //Relance une partie si le joueur appui sur entrée alors qu'il a perdu
      if (gameOver==true) {
        gameOver=false;
        //Relance la musique du jeu
        gameSong.loop();
        //Réinitialise les scores
        score=0;
        shot30=0;
        shot60=0;
        shot90=0;
        //Réinitialise le vaisseau au milieu de la fenêtre
        shipX=400;
        shipY=400;
        shipAngle=3*PI/2;
        //Réinitialise les astéroïdes
        initAsteroids(nbrInitAst);
        nbrAst=nbrInitAst;
        nbrMiss=0;
        //Réinitialise le chrono
        currentTime=0;
        startTime=millis();
      } 
      else {
        //Téléporte le vaisseau à des coordonnées aléatoires si le joueur appui sur entrée en cours de partie
        shipX=int(random(0, 800));
        shipY=int(random(0, 800));   
      }
    }
  } 
}

// ------------------------------- //
//  Quand une touche est relâchée  //
// ------------------------------- //
void keyReleased() {
  //Eteint le moteur et met le vecteur d'accélération du vaisseau à 0 quand le joueur relâche la flèche du haut
  if (keyCode==UP) {
    engine=false;
    shipAx=0;
    shipAy=0;
  }
}
