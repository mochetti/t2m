import processing.video.*;
import processing.serial.*;

// Flags de debug
boolean debug = true;

// Controla a entrada da imagem
// 0 - camera
// 1 - video 
// 2 - simulador
int inputVideo = 2;

boolean calibra = true;  //Flag de controle se deve ou não calibrar as cores
boolean visao = false;  //Flag de controle para parar o código logo após jogar a imagem no canvas (visão) a visão ou não
boolean controle = true;  // Flag para rodar o bloco de controle
boolean estrategia = true; // Flag para rodar o bloco de estratégia
boolean radio = true; //Flag de controle para emitir ou não sinais ao rádio (ultimo passo da checagem)
boolean gameplay = false;  //Flag de controle que diz se o jogo está no automático ou no manual (apenas do robô 0 por enquanto)
boolean simManual = true;

// variaveis pro controle do arrasto do mouse
PVector clique = new PVector();
int dragged = 0;

// Verifica se ainda estamos configurando o robo
//boolean configRobo = false;

boolean pausado = false;

//boolean andaReto = false; //DENTRO DE INERCIA()

Serial myPort;

// Salvar as cores num txt pra poupar tempo na hora de calibrar (?)
// Cores
color cores[] = { 
  color(255, 150, 0), // Laranja
  color(0, 255, 0), // Verde
  color(255, 0, 0) // Vermelho
};

// id de cada objeto
// 0 - Bola
// 1 - Meio Robo 0 (vermelho maior)
// 2 - Meio Robo 1 (robo xadrez)
// 3 - Meio Robo 2 (vermelho na direita)
// 4 - Quina Robo 0
// 5 - Quina Robo 1
// 6 - Quina Robo 2

// 6 - Quina 1 Robo 1
// 7 - Quina 0 Robo 2
// 8 - Quina 1 Robo 2
// 9 - Quina 2 Robo 2
// 10 - Inimigo

// campo[i]
// 0        1
// 3        2

color trackColor;  //Qual cor estou procurando
color mouseColor;  //Ultima cor selecionada no clique do mouse

// current color sendo calibrada
int calColor = -1;

// Numero de pixels do maior blob da cor vermelha, usado para distinguir o goleiro dos outros dois robôs (robo 0)
int pxMaiorBlobVermelho = 0;

// Numero de pixels do menor blob da cor verde, usado para distinguir do outro robô com verde (robo 1)
int pxMenorBlobVerde = 0;

// Conta o tempo de execucao
double tempo = millis();
double antes = millis();

// Quantidade de quadros para vencer a inercia no controle alinhandando
//int contagemAlinhandando = 0;


// Propriedades do campo
int Y_AREA = 200;

// define o campo como dois pontos
//PVector shapeCampo.getVertex(0) = new PVector();
//PVector shapeCampo.getVertex(2) = new PVector();

// define o campo como quatro pontos
//PVector campo[] = {new PVector(), new PVector(), new PVector(), new PVector()};


//Movie mov;
Capture cam;
//PImage screenshot;

// quantidade de objetos de cada cor
// [] - Cor
// 0 - Laranja
// 1 - Verde
// 2 - Vermelho
int[] quantCor = {1, 3, 3};

ArrayList<Blob> blobs = new ArrayList<Blob>();
ArrayList<Blob> oldBlobs = new ArrayList<Blob>();
ArrayList<Robo> robos = new ArrayList<Robo>();
ArrayList<Robo> oldRobos = new ArrayList<Robo>();
ArrayList<Robo> robosSimulados = new ArrayList<Robo>();
ArrayList<PVector> rastro = new ArrayList<PVector>();
PVector bola = new PVector();

void setup() {

  shapeCampo = createShape();

  //mov = new Movie(this, "real.mp4");
  //mov.play();
  //mov.loop();

  //mov.frameRate(30);
  ellipseMode(RADIUS);
  size(800, 448);

  frame.removeNotify();
  frameRate(30);
  if (inputVideo == 0) {
    printArray(Serial.list());
    myPort = new Serial(this, Serial.list()[3], 115200);
    camConfig();
  }
}

void movieEvent(Movie m) {
  m.read();
}
void captureEvent(Capture c) {
  c.read();
}

void draw() {
  //loadPixels();
  tempo = millis();

  //noFill();
  stroke(255);
  if (isCampoDimensionado) {
    if (inputVideo == 0) image(cam, 0, 0);
    else if  (inputVideo == 2) simulador();
    // Mostra o campo na tela

    shape(shapeCampo);
    shape(shapeCampo.getChild(0));
    shape(shapeCampo.getChild(1));
    // Mostra os gols
    golInimigo = new PVector((shapeCampo.getVertex(1).x + shapeCampo.getVertex(2).x) /2, (shapeCampo.getVertex(1).y+shapeCampo.getVertex(2).y) / 2);
    golAmigo = new PVector((shapeCampo.getVertex(0).x + shapeCampo.getVertex(3).x) /2, (shapeCampo.getVertex(0).y+shapeCampo.getVertex(3).y) / 2);

    fill(color(0));

    ellipse(golAmigo.x, golAmigo.y, 20, 20);
    ellipse(golInimigo.x, golInimigo.y, 20, 20);

    // Armazena as ultimas coordenadas de cada robo
    oldRobos.clear();
    for (Robo r : robos) oldRobos.add(new Robo(r.clone()));
    //robos.clear();

    // Armazena as ultimas coordenadas de cada blob
    oldBlobs.clear();
    for (Blob b : blobs) oldBlobs.add(new Blob(b.clone()));
    blobs.clear();

    if (debug) return;

    // Confere o numero de ids validos
    //print("MAIN: ids validos: ");
    //for (Blob b : oldBlobs) if (b.id >= 0) print(b.id + "  ");
    //println("");
    // Busca os objetos
    if (!track()) return;

    // debug da visao
    if (visao) return;

    bola = new PVector(blobs.get(0).center().x, blobs.get(0).center().y);

    //showBola();
    //velBola();

    // Inicializa os robos
    if (robos.size() == 0) {
      for (int i=0; i<3; i++) {
        robos.add(new Robo(i));
      }
    } else {
      // Atualiza os robos
      for (int i=0; i<robos.size(); i++) {
        robos.get(i).atualiza();
      }
    }
    if (estrategia) {
      // Define as estratégias dos robos
      robos.get(0).setEstrategia(0);
      robos.get(1).setEstrategia(1);
    }
    // Debug das estrategias
    for (int i=0; i<robos.size(); i++) {
      if (robos.get(i).obj.x != 0 || robos.get(i).obj.y != 0) robos.get(i).debugObj();
    }

    // Seleciona controle manual ou automatico para o robo 0
    if (gameplay) gameplay(robos.get(0));
    if (controle) {
      alinhaGoleiro(robos.get(0));
      alinhaAnda(robos.get(1));
      //alinha(robos.get(2));
    }

    // Envia os comandos
    if (inputVideo == 0) enviar();
  } else {
    // no simulador, o campo é o próprio canvas
    if (inputVideo == 2) {
      dimensionaCampo(0, 0);
      dimensionaCampo(width, 0);
      dimensionaCampo(width, height);
      dimensionaCampo(0, height);
      return;
    }
    //desenha as linhas na tela se formando
    for (int i = 0; i < shapeCampo.getVertexCount() - 1; i++) {
      strokeWeight(2);
      line(shapeCampo.getVertex(i).x, shapeCampo.getVertex(i).y, shapeCampo.getVertex(i+1).x, shapeCampo.getVertex(i+1).y);
    }
  }
}

void keyPressed() {
  if (key == TAB) {
    roboControlado++;
    if (roboControlado == 3) roboControlado = 0;
    println("KEY: Controlando o robo " + roboControlado);
  }
  if (key == 'd') {
    println("KEY: debug on/off");
    debug = !debug;
  }
  if (key == 'c') {
    calibra = !calibra;
    if (calibra) {
      println("KEY: calibra on");
    } else {
      println("KEY: calibra off");
    }
  }
  if (key >= '0' && key <= '9') {
    println("KEY: Cor " + key);
    calColor = key;
  }
  if (key == 'r') {
    println("KEY: radio on/off");
    radio = !radio;
  }
  if (key == 'C') {
    println("KEY: redefinir campo");
    isCampoDimensionado = false;
    shapeCampo = createShape();
  }

  //MOVIE
  if (key == ' ') {
    // chute aleatorio na bola
    bolaV.vel.set(random(10)-5, random(10)-5);
    if (pausado) {
      //mov.play();
      pausado = false;
    } else {
      //mov.pause();
      pausado = true;
    }
  }
  if (key == 'v') {
    println("KEY: debug visao on/off");
    visao = !visao;
  }
  if (key == 'S') {
    println("KEY: simulador manual/automatico");
    simManual = !simManual;
  }
  if (key == 'g') {
    println("KEY: gameplay on/off");
    gameplay = !gameplay;
  }
  // posicao inicial
  if (key == 'P') {
    println("KEY: posicao inicial");
    robos.get(0).setObj(golAmigo.x + 100, golAmigo.y);
    estrategia = false;
  }
}

void mouseDragged() {
}

void mouseReleased() {
  PVector mouse = new PVector(mouseX, mouseY);
  PVector tiro = mouse.sub(clique);
  tiro.setMag(sqrt(distSq(mouse, clique))/40);
  bolaV.vel = tiro;
}

void keyReleased() {
  if (robos.size() > 0) {
    robos.get(0).velE = 0;
    robos.get(0).velD = 0;
  }
}

void mousePressed() {
  clique.x = mouseX;
  clique.y = mouseY;

  print("R = " + red(mouseColor));
  print("  G = " + green(mouseColor));
  println("  B = " + blue(mouseColor));
  //println("X: " + mouseX + " Y: " + mouseY);

  if (!isCampoDimensionado) dimensionaCampo(mouseX, mouseY);
  if (calibra) calibra();
}
