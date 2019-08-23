/*
// Funcao que atribui identidade aos objetos
boolean id() {
  // raio de busca por verdes com o vermelho no centro
  int raioBusca = 55;
  for(Blob b : blobs) {
    switch(b.cor) {
      // O id depende da cor do blob
      case 0:    // Laranja
        // O objeto só pode ser a bola
        b.id = 0;
      break;
      
      case 1:    // Vermelho
        // O objeto depende da quantidade de verdes ao redor
        int qVerde = 0;
        for(Blob v : blobs) {
          if(v.cor == 2 && distSq(b.center().x, b.center().y, v.center().x, v.center().y) < raioBusca*raioBusca) {
            qVerde++;
          }
        }
        if(qVerde > 0) b.id = qVerde;
        else b.id = -1;
        
        // Raio de busca por verdes
        //noFill();
        //stroke(255);
        //ellipse(b.center().x, b.center().y, raioBusca, raioBusca);
      break;
      
      case 2:    // Verde
        // O objeto depende da orientação do robo
        // Verifica qual robo
        for(Blob v : blobs) {
          // Distancia entre as tags vermelha e verde
          float distVV = dist(b.center().x, b.center().y, v.center().x, v.center().y);
          float ang, cx, cy;
          boolean achou = false, achou2 = false;
          
          if(v.cor == 1 && distVV < raioBusca) {
            
            switch(v.id) {
              case 1:     // Somente 1 verde
                b.id = 4;
              break;
              
              case 2:    // 2 verdes
                // Calcula o angulo da reta formada pelo verde em questao e o centro do robo
                ang = atan2(- v.center().y + b.center().y, - v.center().x + b.center().x);
                //println("Ang = " + ang*180/PI);
                
                // Soma 90 graus nesse angulo
                if(ang < 0) ang += PI/2;
                else ang -= PI/2;
                
                // Coordenada de onde o outro verde pode estar
                cx = v.center().x + distVV * cos(ang);
                cy = v.center().y + distVV * sin(ang);
                
                // Raio de busca por outra quina
                //noFill();
                //stroke(255);
                //ellipse(cx, cy, 15, 15);
                                                
                // Verifica se há outro verde onde deveria haver
                achou = false;
                for(Blob t : blobs) {
                  if(t.cor == 2 && distSq(t.center().x, t.center().y, cx, cy) < 15*15) {
                    // Havia outro verde lá
                    b.id = 5;
                    achou = true;
                    //b.show(color(0,255,0));
                  }
                }
                if(!achou) {
                  // Não havia outro verde lá
                  b.id = 6;
                  //b.show(color(255,0,0));
                }
              break;
              
              case 3:    // 3 verdes
                ang = atan2(b.center().x - v.center().x, b.center().y - v.center().y);
                //println("Ang = " + ang*180/PI);
                if(ang > -PI/2 && ang < 0) ang -= PI/2;
                else ang += PI/2;
             
                cx = v.center().x + distVV * cos(ang);
                cy = v.center().y + distVV * sin(ang);
                
                // Raio de busca por outra quina
                //noFill();
                //stroke(255);
                //ellipse(cx, cy, 15, 15);
                
                // Verifica se há outro verde onde deveria haver
                for(Blob t : blobs) {
                  if(t.cor == 2 && distSq(t.center().x, t.center().y, cx, cy) < 15*15) {
                    // Verifica se há um terceiro verde
                    if(ang > -PI/2 && ang < 0) ang -= PI/2;
                    else ang += PI/2;
                    cx = v.center().x + distVV * cos(ang);
                    cy = v.center().y + distVV * sin(ang);
                    
                    // Raio de busca por outra quina
                    //noFill();
                    //stroke(255);
                    //ellipse(cx, cy, 15, 15);
                    
                    for(Blob u : blobs) {
                      if(u.cor == 2 && distSq(u.center().x, u.center().y, cx, cy) < 15*15) {
                        //println("id 9");
                        b.id = 9;
                        achou = true;
                      }
                      else {
                        //println("id 8");
                        b.id = 8;
                        achou2 = true;
                      }
                      if(achou) break;
                    }
                  }
                  else {
                    //println("id 7");
                    b.id = 7; 
                  }
                  if(achou || achou2) break;
                }
              break;
              
              default:
                b.id = -1;
              break;
            }
          }
        }
      default:
      break;
    }
  }
  
  // Coloca em ordem crescente de id
  if(ordenar()) return true;
  return false;
}


boolean idf() {
  // raio de busca com o vermelho no centro
  int raioBusca = 55;
  for(Blob b : blobs) {
    // Laranja
    if(b.cor == 0) {
      // O objeto só pode ser a bola
      b.id = 0;
      continue;
    }
      
    // Verde
    if(b.cor == 1) {
        for(Blob v : blobs) {
          // Verifica se o v já foi catalogado
          //if(v.id >= 0) continue;
          if(v.cor == 2 && (distSq(b.center(), v.center()) < (raioBusca*raioBusca))) {
            noFill();
            stroke(255);
            //ellipse(b.center().x, b.center().y, raioBusca, raioBusca);
            
            // Verifica se é o vermelho comprido
            if(v.numPixels == numMaior) {
              b.id = 1;
              v.id = 4;
              continue;
            }
            
            // Tem que separar entre os dois vermelhos simetricos (na esquerda e na direita)
            // Tentativa de usar o angulo entre os pontos: centro do verde, (xMax Verde, yMedio Verde), centro do vermelho
            PVector verdVerm = new PVector();
            verdVerm = b.center().sub(v.center());
            PVector verdMX = new PVector(b.center().x - b.maxx, b.center().y);
            float ang = PVector.angleBetween(verdVerm, verdMX);
          }
        }
    }
            
            
  }
  // Confere o numero de ids validos
  int idsValidos = 0;
  for(Blob b : blobs) if(b.id >= 0) idsValidos++;
  if(idsValidos >= 7) {
    // Coloca em ordem crescente de id
    if(ordenar()) return true;
  }
  return false;
}


if(dAng < radians(tolAng)) {
    // Anda reto
    println("CONTROLE: Anda reto");
    r.velE = velMaxima;
    r.velD = velMaxima;
  }
  
  else {
    // gira horario
    if(r.getAng() < atan2(robObj.y, robObj.x)) {
      println("CONTROLE: Gira horário");
      if(r.velD < limiteMenor && r.velD > 0) r.velD -= taxaVel;
      if(r.velD == 0) r.velD = limiteMenor + velMinima;
      else if(r.velD >= limiteMenor && r.velD < limiteMenor+velMaxima) r.velD += taxaVel;
      
      if(r.velE >= limiteMenor) r.velE = velMinima;
      if(r.velE < velMinima) r.velE = velMinima;
      else if(r.velE < velMaxima) r.velE += taxaVel;
    }
    // gira anti horario
    else {
      println("CONTROLE: Gira antihorário");
      if(r.velE < limiteMenor && r.velE > 0) r.velE -= taxaVel;
      if(r.velE == 0) r.velE = limiteMenor + velMinima;
      else if(r.velE >= limiteMenor && r.velE < limiteMenor+velMaxima) r.velE += taxaVel;
      
      if(r.velD > limiteMenor) r.velD = velMinima;
      if(r.velD < velMinima) r.velD = velMinima;
      else if(r.velD < velMaxima) r.velD += taxaVel;
    }
  }
  
  *******
  CÓDIGO PARA ETIQUETAS SIMETRICAS
  *******
  // Verifica de qual lado está o vermelho
            float distVV = dist(b.center().x, b.center().y, v.center().x, v.center().y);
            float ang, cx, cy;
            // Calcula o angulo da reta formada pelos centros do vermelho e verde
            ang = atan2(- v.center().y + b.center().y, - v.center().x + b.center().x);
            //println("Ang = " + ang*180/PI);
                
            // Soma 45 graus nesse angulo
            //if(ang < 0) ang += PI/4;
            //else ang -= PI/4;
            
            ang += (PI/2 - atan(2));
            // PI/4 é a média dos dois angulos ideais (atan(2) e (PI/2 - atan(2)))
            //ang += PI/4;
            
            // Coordenada de onde pode haver vermelho ou preto
            cx = v.center().x + 0.6 * distVV * cos(ang);
            cy = v.center().y + 0.6 * distVV * sin(ang);
            int ladoC = 8;
            // Raio de busca por outra quina
            noFill();
            stroke(255);
            rectMode(CENTER);
            rect(cx, cy, ladoC, ladoC);
            rectMode(CORNER);
            
            //line(v.center().x, v.center().y, b.center().x, b.center().y);
            line(cx, cy, v.center().x, v.center().y);
            
            // Verifica a cor daquela regiao
            int pixelsVerdes = 0;
            for(int x=int(cx)-ladoC/2; x<cx+ladoC/2; x++) {
              for(int y=int(cy)-ladoC/2; y<cy+ladoC/2; y++) {
                int loc = x + y * cam.width;
                // What is current color
                color currentColor = cam.pixels[loc];
                if(msmCor(currentColor, cores[1])) pixelsVerdes++;
              }
            }
            // A regiao projetada é verde
            if(pixelsVerdes > 0.5*ladoC*ladoC) {
              b.id = 2;
              v.id = 5;
            }
            // A regiao projetada é preta
            else {
              b.id = 3;
              v.id = 6;
            }
  
  */
