import controlP5.*;
import java.net.*;
import java.io.*;

int scale=18;
int realSize=32;
int kanjiposX=200;
int count=0;
int currentTranslation;
boolean kanjiClickable = false;
boolean scaling = false;
boolean romaji;
ArrayList<boolean[][]> kanji = new ArrayList<boolean[][]>();
PrintWriter writer;
BufferedReader reader;
ControlP5 cp5;
color highlightColor = color(255, 100, 100);
PFont font;
PFont font2;
PFont font3;
PFont font4;

ArrayList<Kanji> kanjiObjects = new ArrayList<Kanji>();
ArrayList<String> kanjiList = new ArrayList<String>();

int[] orderedPrediction;


void setup()
{
  size(1280, 720);
  font = createFont("Arial", 32);
  font2 = createFont("Arial", 18);
  font3 = createFont("MS Gothic", 18);
  font4 = createFont("Arial",12);

  cp5 = new ControlP5(this);
  cp5.addButton("Save")
    .setPosition(realSize*scale+200, 50)
    .setSize(120, 40)
    .setFont(font);
  cp5.addButton("clear")
    .setFont(font4)
    .setPosition(realSize*scale+10, 0);
  cp5.addButton("next")
    .setFont(font4)
    .setPosition(realSize*scale+10, 40);
  cp5.addButton("open")
    .setPosition(realSize*scale+380, 50)
    .setSize(120, 40)
    .setFont(font);
  cp5.addButton("send")
    .setPosition(realSize*scale+200, 100)
    .setFont(font4)
    .setSize(55, 25);    
  cp5.addTextfield("")
    .setPosition(realSize*scale+200, 0)
    .setSize(300, 40)
    .setFont(font);
  cp5.addButton("create_new_Kanji")
    .setCaptionLabel("create new Kanji")
    .setPosition(realSize*scale+510, 50)
    .setFont(font4)
    .setSize(120, 40);
  cp5.addButton("update_Network")
    .setCaptionLabel("update Network")
    .setPosition(realSize*scale+510, 0)
    .setFont(font4)
    .setSize(120, 40);
  cp5.addButton("send_Training_Data")
    .setCaptionLabel("send Training Data")
    .setPosition(realSize*scale+kanjiposX+150, 225)
    .setSize(220, 25)
    .setVisible(false)
    .setFont(font2);

  cp5.addButton("romaji↹ひらがな")
    .setPosition(realSize*scale+kanjiposX+150, 265)
    .setSize(220, 25)
    .setVisible(false)
    .setFont(font3)
    .addCallback(new CallbackListener() 
    {
      public void controlEvent(CallbackEvent theEvent)
      {
        if(theEvent.getAction()==ControlP5.ACTION_PRESS)
        {
          if(romaji)
          {
            romaji=false;
            kanjiObjects.get(currentTranslation).showTranslations();
          }
          else
          {
            romaji=true;
            kanjiObjects.get(currentTranslation).showTranslations();
          }
        }
      }
    });

  background(255);
  strokeWeight(10);
  line(realSize*scale+5, 0, realSize*scale+5, realSize*scale+5);
  line(0, realSize*scale+5, realSize*scale+5, realSize*scale+5);
  strokeWeight(1);
  fill(0, 255, 0);
  rect(realSize*scale+10, realSize*scale+10, 15, 15);
  fill(0);


  kanji.add(new boolean[realSize][realSize]);

  //loading the kanjiList
  try {
    reader=createReader("kanjiList.txt");
    String line;
    while ((line=reader.readLine())!=null)
    {
      kanjiList.add(line);
    }
    reader.close();
  }
  catch(IOException e)
  {
    println("Datei konnte nicht geöffnet werden");
  }


  //initialising Kanji images
  for (String kanji : kanjiList)
  {
    try {
      ArrayList<String[]> translations = new ArrayList<String[]>();
      reader=createReader(kanji+"T"+".txt");
      int iterator = 0;
      String line;
      while ((line=reader.readLine())!=null)
      {
        String[] readingTranslation= new String[4];

        readingTranslation[0]=line;
        readingTranslation[1]=reader.readLine();
        readingTranslation[2]=reader.readLine();
        readingTranslation[3]=reader.readLine();

        translations.add(readingTranslation);
      }
      reader.close();
      kanjiObjects.add(new Kanji(loadImage(kanji+".png"), translations));
    }
    catch(IOException e)
    {
      println("Datei konnten nicht geladen werden");
    }
    catch(NullPointerException e)
    {
      println("keine Übersetzungen vorhanden");
      kanjiObjects.add(new Kanji(loadImage(kanji+".png")));
    }
  }
}
void draw()
{
  try {
    //es wird nur gemahlt, wenn sich die Maus innerhalb der Grenzen des
    //Zeichenfensters befindet und die Maustaste gedrückt ist
    if (mousePressed && mouseX<realSize*scale && mouseY<realSize*scale && pmouseX<realSize*scale && pmouseY<realSize*scale)
    {
      //Speichern der Daten in einem zweidimensionalen boolean array
      //in Echtzeit(true=schwarz,false=weiß)
      pixelLine();

      //festlegen von Farbe(0=schwarz) und Dicke der Linie
      stroke(0);
      strokeWeight(scale);

      //Zeichnen einer Hochauflösenden Linie im Zeichnenfenster zwischen der
      //Mausposition im letzten Durchlauf von draw und der derzeitigen Mausposition
      line(pmouseX, pmouseY, mouseX, mouseY);
      noStroke();
    }
  }
  catch(Exception e)
  {
    print("hey");
  }
  if (mousePressed && mouseX>realSize*scale+10 && mouseX<realSize*scale+25 && mouseY>realSize*scale+10 && mouseY<realSize*scale+25)
  {
    scaling=true;
  }
  if (!mousePressed)
  {
    scaling=false;
  }
  if (scaling)
  {
    if (mouseX<mouseY) {
      scale=int((mouseX-10)/realSize);
    } else {
      scale=int((mouseY-10)/realSize);
    }
    if (scale<4) {
      scale=4;
    }
    if (scale>18) {
      scale=18;
    }
    reload();
  }
  frameRate(60);
}
//lädt alle Positionen neu, wenn der Rahmen skaliert wird
void reload()
{
  //neue Ränder Zeichnen
  background(255);
  stroke(0);
  strokeWeight(10);
  line(realSize*scale+5, 0, realSize*scale+5, realSize*scale+5);
  line(0, realSize*scale+5, realSize*scale+5, realSize*scale+5);
  strokeWeight(1);
  fill(0, 255, 0);
  rect(realSize*scale+10, realSize*scale+10, 15, 15);
  fill(0);

  //Miniaturbilder und großes Bild neu zeichnen
  int tempCount=count;
  for (count= 0; count<kanji.size(); count++)
  {
    drawMini(false);
  }
  count=tempCount;
  drawMini(true);
  drawBig();

  //Textfeld und Knöpfe neu positionieren
  cp5.get(Textfield.class, "").setPosition(realSize*scale+200, 0);
  cp5.get(Button.class, "Save").setPosition(realSize*scale+200, 50);
  cp5.get(Button.class, "clear").setPosition(realSize*scale+10, 0);
  cp5.get(Button.class, "next").setPosition(realSize*scale+10, 40);
  cp5.get(Button.class, "open").setPosition(realSize*scale+380, 50);
  cp5.get(Button.class, "send").setPosition(realSize*scale+200, 100);
  cp5.get(Button.class, "create_new_Kanji").setPosition(realSize*scale+510, 50);
  cp5.get(Button.class, "update_Network").setPosition(realSize*scale+510, 0);
  cp5.get(Button.class, "send_Training_Data").setVisible(false);
  cp5.get(Button.class, "romaji↹ひらがな").setVisible(false);
}

//Diese Methode erstellt die Daten der Zeichnung in Echtzeit und malt das kleine Bild unter dem Fenster
void pixelLine()
{
  fill(0); //Die Farbe schwarz wird ausgewählt  
  int prevPixX=pmouseX/scale; //Berechnung der x- und y-Positionen des Quadranten
  int prevPixY=pmouseY/scale; //im letzten Durchlauf und in diesem Durchlauf
  int thisPixX=mouseX/scale;  //(scale beschreibt die Seitenlänge eines Quadranten)
  int thisPixY=mouseY/scale;
  int pixXdiff=prevPixX-thisPixX; //Berechnung der Differenzen dieser Quadranten in x- und y- Richtung. Wenn die vorherige
  int pixYdiff=prevPixY-thisPixY; //Position größer ist als die derzeitige ist dieser Wert positiv, gleich=0, sonst negativ

  if (abs(pixXdiff)>abs(pixYdiff)) //Wenn die x-Differenz größer ist als die y-Differenz 
  {                               //bestimmt sie die Anzahl an Pixeln, die wir setzen
    int iterator=1; //der Iterator ist abhängig vom Vorzeichen der x-Differenz
    if (pixXdiff<0)
    {
      iterator=-1;
    }
    for (int a=0; a!=pixXdiff; a+=iterator) //bei positiver Differenz gehen wir von links nach rechts, sonst von rechts
    {                                     //nach links. Der Startpunkt ist immer die derzeitige Position der Maus

      //Der Platz in der Liste der dem Quadranten entspricht wird auf true gesetzt. Die x-Position wir bei jedem Durchlauf um 
      //einen erhöht bzw. verringert. Die y-Position wird bestimmt durch a mal den Differenzenquotienten der beiden Positionen
      //(der Wert wird abgerundet). Ist der Differenzenquotient z.B: 1/2, so wird bei jeder zweiten Erhöhung der x-Position
      //auch die y-Position des Quadranten erhöht.
      kanji.get(count)[thisPixX+a][thisPixY+int(a*pixYdiff/pixXdiff)]=true;

      //hier wird der Pixel im entsprechenden Miniaturbild schwarz gefärbt
      rect((count%scale)*realSize+thisPixX+a, count/scale*realSize+realSize*scale+10+thisPixY+int(a*pixYdiff/pixXdiff), 1, 1);
    }
  } else //Wenn die y-Differenz größer oder gleich ist, übernimmt sie die Rolle der x-Differenz oben
  {
    int iterator=1;
    if (pixYdiff<0)
    {
      iterator=-1;
    }
    for (int a=0; a!=pixYdiff; a+=iterator)
    {
      kanji.get(count)[thisPixX+int(a*pixXdiff/pixYdiff)][thisPixY+a]=true;
      rect((count%scale)*realSize+thisPixX+int(a*pixXdiff/pixYdiff), count/scale*realSize+realSize*scale+10+thisPixY+a, 1, 1);
    }
  }
}

void mouseClicked()
{
  //ändern der ausgewählten Zeichnung durch Klicken auf ein Miniaturbild
  if (mouseX<realSize*scale && mouseY>realSize*scale+10)
  {
    drawMini(false);
    if (mouseX/realSize+(mouseY-realSize*scale-10)/realSize*scale<kanji.size())
    {
      count=mouseX/realSize+(mouseY-realSize*scale-10)/realSize*scale;
      removePredictions();
    }
    drawMini(true);
    drawBig();
  }
  if (kanjiClickable && mouseX>kanjiposX+realSize*scale && mouseX<kanjiposX+realSize*scale+500 && mouseY>180)
  {
    currentTranslation=orderedPrediction[(mouseY-180)/150*5+(mouseX-kanjiposX-realSize*scale)/100];
    kanjiObjects.get(currentTranslation).showTranslations();
  }
}



public void send_Training_Data()
{
  //Kanji mit einem Klick auswählen und Trainingsdaten zum Server senden
  try {
    String msg = kanjiList.get(currentTranslation);
    msg+="#";
    Socket soc=new Socket("localhost", 2052);  
    DataOutputStream dout=new DataOutputStream(soc.getOutputStream()); 
    dout.writeUTF("td"+msg+drawingToString(count));
    dout.flush();
    println("Trainingsdaten erfolgreich gesendet");
    textSize(24);
    fill(0, 255, 0);
    text("training data has been sent!", kanjiposX+realSize*scale+150, 190);
    kanjiClickable=false;
  }
  catch(IndexOutOfBoundsException e)
  {
    println("An dieser Stelle ist kein Kanji");
  }
  catch(IOException e)
  {
    println("konnte Daten nicht zum Server senden");
  }
  catch(Exception e)
  {
    println("something else");
  }
}

//Die derzeitig ausgewählte Zeichnung löschen, wenn der Knopf "clear" gedrückt wird
public void clear(int value)
{
  if (value==1)
  {
    kanji.set(count, new boolean[realSize][realSize]);
    fill(highlightColor);
    noStroke();
    rect((count%scale)*realSize, count/scale*realSize+realSize*scale+10, realSize, realSize);
  }
  fill(255);
  noStroke();
  rect(0, 0, realSize*scale, realSize*scale);
  removePredictions();
}
public void drawMini(boolean highlighted)
{
  if (highlighted)
    fill(highlightColor);
  else
    fill(255);

  noStroke();
  rect((count%scale)*realSize, count/scale*realSize+realSize*scale+10, realSize, realSize);
  fill(0);
  for (int i = 0; i<realSize; i++)
  {
    for (int b = 0; b<realSize; b++)
    {
      if (kanji.get(count)[b][i]==true)
      {
        rect((count%scale)*realSize+b, count/scale*realSize+realSize*scale+10+i, 1, 1);
      }
    }
  }
}

//dem Server senden, dass das Netz neu berechnet wrden soll (wenn der Knopf "update_Network gedrückt wird")
void update_Network()
{
  try {
    Socket soc=new Socket("localhost", 2052);  
    DataOutputStream dout=new DataOutputStream(soc.getOutputStream()); 
    dout.writeUTF("up");
  }
  catch(IOException e) {
    println("update konnte nicht gesendet werden");
  }
}

//Ausgewähltes Zeichen in groß in das Zeichenfeld malen
public void drawBig()
{
  clear(0);
  fill(0);
  for (int i = 0; i<realSize; i++)
  {
    for (int b = 0; b<realSize; b++)
    {
      if (kanji.get(count)[b][i]==true)
      {
        rect(b*scale, i*scale, scale, scale);
      }
    }
  }
}

//die Anzeige der Vorhersage des neuronalen Netzes löschen
public void removePredictions()
{
  fill(255);
  noStroke();
  rect(kanjiposX+realSize*scale, 110, 1000, 1000);
  kanjiClickable=false;
  cp5.get(Button.class, "send_Training_Data").setVisible(false);
  cp5.get(Button.class, "romaji↹ひらがな").setVisible(false);
}

//zur nächsten Zeichnung wechseln bzw. eine neue Zeichnung anlegen, wenn gerade die letzte ausgewählt ist
public void next(int value)
{
  clear(0);
  if (count==kanji.size()-1)
    kanji.add(new boolean[realSize][realSize]);
  drawMini(false);
  count+=1;
  drawMini(true);
  drawBig();
  removePredictions();
}

//Alle derzeit geladenen Zeichnungen in einer Textdatei speichern (wenn der Knopf "Save" gedrückt wird)
public void Save(int value)
{
  writer=createWriter(cp5.get(Textfield.class, "").getText()+".txt");
  for (boolean[][] frame : kanji)
  { 
    for (boolean[] a : frame)
    {
      for (boolean b : a)
      {
        if (b)
        {
          writer.print(1);
        } else
        {
          writer.print(0);
        }
      }
    }
    writer.println();
  }
  writer.close();
}
public void open(int value)
{
  reader=createReader(cp5.get(Textfield.class, "").getText()+".txt");
  if (reader==null)
  {
    println("Datei konnte nicht geöffnet werden");
    return;
  }
  kanji.clear();
  kanji.add(new boolean[realSize][realSize]);
  fill(255);
  noStroke();
  rect(0, realSize*scale+10, realSize*scale+10, height-(realSize*scale));
  try
  {
    int c = 0;
    count = 0;
    while (true)
    {
      String bytecode=reader.readLine();
      if (bytecode==null)
      {
        reader.close();
        drawMini(false);
        if(c!=0)
        {
          kanji.remove(count);
          count-=1;
        }
        return;
      }
      for (int i=0; i<realSize*realSize; i++)
      {
        if (bytecode.charAt(i)=='1')
          kanji.get(c)[i/realSize][i%realSize]=true;
      }
      count=c;
      next(0);
      c+=1;
  }
  }
  catch(IOException e)
  {
    println("something went wrong here");
  }
}

//erstellt ein neues Kanji mit Bild und fügt es zu den zu klassifizierenden Kanji hinzu
public void create_new_Kanji(int value)
{
  PImage kanjiPicture = get(0, 0, realSize*scale, realSize*scale);
  kanjiPicture.resize(100, 100);
  kanjiPicture.save(cp5.get(Textfield.class, "").getText()+".png");
  kanjiObjects.add(new Kanji(kanjiPicture));
  extendKanjiList(cp5.get(Textfield.class, "").getText());
  try {      
    Socket soc=new Socket("localhost", 2052);  
    DataOutputStream dout=new DataOutputStream(soc.getOutputStream());  
    dout.writeUTF("nk"+cp5.get(Textfield.class, "").getText()+"#"+drawingToString(count));
    dout.flush();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}
//fügt ein Kanji zur KanjiList Textdatei hinzu, welche alle derzeitig benutzten Kanji enthält
public void extendKanjiList(String extension)
{
  if (!kanjiList.contains(extension))
  {
    kanjiList.add(extension);
    /*
    writer=createWriter("KanjiList.txt");
    for (String k : kanjiList)
    {
      writer.println(k);
    }
    writer.close();
    */
  }
  else
  {
    println("dieses Kanji existiert bereits");
  }
}

//konvertiert eine Zeichnung zu einem String aus 1 und 0. "c" ist der Index der Zeichnung in der ArrayList kanji
public String drawingToString(int c)
{
  if (c==-1)
  {
    String s=drawingToString(0);
    for (int i=1; i<kanji.size(); i++)
    {
      s+=";"+drawingToString(i);
    }
    return s;
  }
  String s="";
  for (boolean[] a : kanji.get(c))
  {
    for (boolean b : a)
    {
      if (b)
      {
        s+="1";
      } else
      {
        s+="0";
      }
    }
  }
  return s;
}

//sendet die derzeitig ausgewählte Zeichnung zum neuronalem Netz, welches dann eine Vorhersage zurücksendet. Die Vorhersage wird angezeigt
public void send()
{
  //get the String code from current drawing
  String msg;
  msg = drawingToString(count);

  try {      
    Socket soc=new Socket("localhost", 2052);  
    DataOutputStream dout=new DataOutputStream(soc.getOutputStream());  
    dout.writeUTF("pr"+msg);
    dout.flush();
    BufferedReader in = new BufferedReader(new InputStreamReader(soc.getInputStream()));
    String serverResponse = in.readLine();
    System.out.println("Server-Antwort: " + serverResponse);
    float[] percentages = float(serverResponse.split(";"));
    soc.close();

    //displaying probabilities
    removePredictions();
    stroke(0);
    textFont(createFont("Arial", 28));
    fill(255, 0, 0);
    text("Predictions(click for more Information)", kanjiposX+realSize*scale, 150);
    int numberOfKanji=percentages.length;
    orderedPrediction = new int[numberOfKanji];
    for (int i = 0; i < numberOfKanji; i++)
    {
      float currentMaxValue=0;
      int currentIndex=0;
      for (int a = 0; a<percentages.length; a++)
      {
        if (percentages[a]>currentMaxValue)
        {
          currentMaxValue=percentages[a];
          currentIndex=a;
        }
      }
      kanjiObjects.get(currentIndex).show(i, currentMaxValue);
      percentages[currentIndex]=0;
      orderedPrediction[i]=currentIndex;
    }
    kanjiClickable=true;
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}
