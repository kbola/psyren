    // All Examples Written by Casey Reas and Ben Fry
    
    // unless otherwise stated.
    
    // arrays to hold ellipse coordinate data
    
    float[] px, py, cx, cy, cx2, cy2;
    
    
    
    // global variable-points in ellipse
    
    int pts = 4;
    
    float colorModulator = 0;
    float colorModulatorRate = 1.0;

    float inputRadius = 0;
    
    float thetaXMain = 0.0;//0.1;
    float thetaYMain = 0.0;// 0.2;
    float thetaZMain = PI / 4.0;
    float freeRunningThetaZMain = 0.0;

    float rotationRateXMain = 0;//0.0023;
    float rotationRateYMain = 0;//0.0023;
    float rotationRateZMain = 0.01;
    
    float thetaX = 0.00;
    float thetaY = 0.00;
    float thetaZ = 0.00;
  
    float rotationRateX = 0;//0.0000017;
    float rotationRateY = 0;//0.0000023;
    float rotationRateZ = 0;//0.000029;
    
    float lastX;
    float lastY;
    
    float lastTouchTheta;

    float deltaTouchTheta;
    
    float[][] modulators;
  
    boolean inputActive = false;
    
    color controlPtCol = #222222;
    
    color anchorPtCol = #BBBBBB;
    
    void shuffleModulatorRates(){
      for(int i = 0; i < numberOfAnalyserBands; i++){
        for(int d = 0; d < 3; d++){
          modulators[i][(d*2) + 1] = random(0.1);
        }
      }
    }
    void shuffleModulatorPhases(){
      
      for(int i = 0; i < numberOfAnalyserBands; i++){
        for(int d = 0; d < 3; d++){
          modulators[i][(d*2)] = random(PI);
        }
      }
      
    }

        
    void setup(){
    
      size(960, 960, P3D);
    
      smooth();
    
      setEllipse(pts, 65, 65);
    
      frameRate(60);
    
      background(0);
      
      colorMode(HSB, 255);    
      
      modulators = new int[numberOfAnalyserBands][6];
      
      for(int i = 0; i < numberOfAnalyserBands; i++){
        for(int d = 0; d < 3; d++){
          modulators[i][(d*2)] = 0.0;
          modulators[i][(d*2) + 1] = random(0.1);
        }
      }

      deltaTouchTheta = 0.0;
    
    }
    
    void draw(){
      
      for(int i = 0; i < numberOfAnalyserBands; i++){
        for(int d = 0; d < 3; d++){
          modulators[i][d*2] += modulators[i][(d*2)+1];
        }
      }
      
      //console.log("current touch theta " + currentTouchTheta);

      if(touchPressed){
        shuffleModulatorRates();
        shuffleModulatorPhases();
        //if at center, shuffle modulators
        //float centerWidth = 0.21;
        //if(dragCurrentX > (0.5 - centerWidth) && dragCurrentX < (0.5 + centerWidth) &&
        //  dragCurrentY > (0.5 - centerWidth) && dragCurrentY < (0.5 + centerWidth)){


        // }
        
        float dx = dragCurrentX - lastX;
        float dy = dragCurrentY - lastY;
        lastX = dragCurrentX;
        lastY = dragCurrentY;
        rotationRateZMain = atan(dy, dx);
      }


    
        //lights();

      translate(0,0,-10);
      
      //rotating the screen

      translate(width/2,height/2,0);
      rotateX(thetaXMain);
      thetaXMain += rotationRateXMain;
      
      //thetaYMain = inputRadius / 20.0;

      rotateY(thetaYMain);
      thetaYMain += rotationRateYMain;
      
     
      if(!touchPressed){
        thetaZMain += deltaTouchTheta;
      }
      else{
        float currentTouchTheta = atan((dragCurrentY - 0.5) / (dragCurrentX - 0.5));
        deltaTouchTheta = currentTouchTheta - lastTouchTheta;
        lastTouchTheta = currentTouchTheta;
        thetaZMain = currentTouchTheta;
      }
     
      rotateZ(thetaZMain);

      translate(-width/2,-height/2,0);

      rectMode(CENTER);
  
      if(touchPressed){
         inputRadius = touchDistanceNormal * 500;
      }
      else{
         inputRadius *= 0.96; 
      }
      background(0);

      //translate(0,0,20);
  
      
      if(isUnlocked){
        
        for(int i = 0; i < 1; i++){

            drawEllipse();
        }
        
        float ellipseRadius = inputRadius * (1 + pow(touchDistanceNormal, 1.9)) * 0.7;

    
        setEllipse(int(random(3, 12)), random(-1 * ellipseRadius, 1.5 * ellipseRadius),  random(-1 * ellipseRadius, 1.5 * ellipseRadius));
      
        
        strokeWeight(4);
        
        analyser.getByteFrequencyData(frequencyData);
        
        float widthMultiplier = (width * 0.5) / numberOfAnalyserBands;
        
        colorModulator += colorModulatorRate;
        
        //zoom
        translate(0,0,inputRadius * 8);

        int localI = 0;
        for (int i=0; i<numberOfAnalyserBands; i++){
            
          if(i % 4 == 0){
           
            if(frequencyData[i] > -1){
            float floatIndexNormal = float(i)/float(numberOfAnalyserBands);
             //nice blue pink
             
            float hueValue = float(float(frequencyData[i] * 0.6) + 112.0) + colorModulator;
            fill(hueValue % 256, 255,frequencyData[i]);
            noStroke();
            float widthPerRect = width / numberOfAnalyserBands;
           

            
            //start at center
            //translate(width/2,height/2,0);
            rectMode(CENTER);

            float ringCount = 10.5 + (float(i + 12)/128.0);
            float divisor = (float(localI + 24) % ringCount)/ ringCount;
            float axisZTheta = (2 * PI) * divisor;// / float(i % ringCount);
            float radius = 20 + (pow(i + 24,2) / 56);
            //rotate on axis
            translate(width/2,height/2,0);
            rotateZ(axisZTheta);

            translate(0, radius, 0);
            rotateX(modulators[i][2]);
            rotateY(modulators[i][0]);
            translate(-width/2,-height/2,0);

            float floatRectSize = 10 +( (pow(float(i),2)) * 0.01  * widthMultiplier);// * (float(frequencyData[i]) / 64);
            
            if(frequencyData[i] > 1){

              rect(width/2.0,height/2.0,floatRectSize,floatRectSize);
            }
            
            //unrotate
            translate(width/2,height/2,0);
            rotateY(-modulators[i][0]);
            rotateX(-modulators[i][2]);
            translate(0, -radius, 0);
            rotateZ(-axisZTheta);
            translate(-width/2,-height/2,0);

            localI++;
           }
           
           //translate outside of % check so we can thin without changing dimensions
            translate(width/2,height/2,0);
            //rotateZ(0.1);
            translate(-width/2,-height/2,-50);
          }
      
        }
       
      }
    
    }
    
    
    
    // draw ellipse with anchor/control points
    
    void drawEllipse(){
    
      strokeWeight(2);
    
      stroke(colorModulator, 255, 255);
      colorModulator += 3;
      colorModulator %= 256;
      noFill();
    
      // create ellipse
    
      for (int i=0; i<pts; i++){
    
        if (i==pts-1) {
    
          //bezier(px[i], py[i], cx[i], cy[i], cx2[i], cy2[i],  px[0], py[0]);
          bezier(px[i], py[i], 0, cx[i], cy[i], 0, cx2[i], cy2[i], 0,  px[0], py[0], 0);
  
        }
    
        else{
    
          bezier(px[i], py[i], 0, cx[i], cy[i], 0, cx2[i], cy2[i], 0, px[i+1], py[i+1], 0);
    
        }
    
      }
    
      strokeWeight(1.0);
    
      //stroke(50);
      stroke(random(255), 255, 255);
    
      rectMode(CENTER);    
    
    
      for ( int i=0; i< pts; i++){
    
        fill(random(255), 255, 255);
    
        noStroke();
    
        //control handles
    
        rect(cx[i], cy[i], 4, 4);
    
        rect(cx2[i], cy2[i], 4, 4);
    
    
    
        fill(anchorPtCol);
    
        stroke(0);
    
        //anchor points
    
        rect(px[i], py[i], 5, 5);
    
      }
    }
    
    // fill up arrays with ellipse coordinate data
    
    void setEllipse(int points, float radius, float controlRadius){
    
      pts = points;
    
      px = new float[points];
    
      py = new float[points];
    
      cx = new float[points];
    
      cy = new float[points];
    
      cx2 = new float[points];
    
      cy2 = new float[points];
    
      float angle = 360.0/points;
    
      float controlAngle1 = angle/3.0;
    
      float controlAngle2 = controlAngle1*2.0;
    
      for ( int i=0; i<points; i++){
    
        px[i] = width/2+cos(radians(angle))*radius;
    
        py[i] = height/2+sin(radians(angle))*radius;
    
        cx[i] = width/2+cos(radians(angle+controlAngle1))* 
    
          controlRadius/cos(radians(controlAngle1));
    
        cy[i] = height/2+sin(radians(angle+controlAngle1))* 
    
          controlRadius/cos(radians(controlAngle1));
    
        cx2[i] = width/2+cos(radians(angle+controlAngle2))* 
    
          controlRadius/cos(radians(controlAngle1));
    
        cy2[i] = height/2+sin(radians(angle+controlAngle2))* 
    
          controlRadius/cos(radians(controlAngle1));
    
        angle+=360.0/points;
    
      }
    
    }