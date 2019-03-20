import controlP5.*;
import java.net.*;
import java.io.*;

int scale=10;
int realSize=32;
int count=0;
boolean[][] px = new boolean[realSize][realSize];
boolean kanjiClickable = false;
ArrayList<boolean[][]> kanji = new ArrayList<boolean[][]>();
PrintWriter writer;
BufferedReader reader;
String line;
ControlP5 cp5;
color highlightColor = color(255, 100, 100);

ArrayList<Kanji> kanjiObjects = new ArrayList<Kanji>();
ArrayList<String> kanjiList = new ArrayList<String>();

//Kontrollvariablen
boolean allSelected;

int[] orderedPrediction;


void setup()
{
  size(1280, 720);

  cp5 = new ControlP5(this);
  cp5.addButton("save_Drawings")
    .setPosition(realSize*scale+200, 50)
    .setSize(120, 40);
  cp5.addButton("clear")
    .setPosition(realSize*scale+10, 0);
  cp5.addButton("next")
    .setPosition(realSize*scale+10, 40);
  cp5.addButton("open")
    .setPosition(realSize*scale+380, 50)
    .setSize(120, 40);
  cp5.addButton("send")
    .setPosition(realSize*scale+200, 100)
    .setSize(55,25);
  cp5.addButton("send_all")
    .setPosition(realSize*scale+265, 100)
    .setSize(55,25);
  cp5.addTextfield("")
    .setPosition(realSize*scale+200, 0)
    .setSize(300, 40)
    .setFont(createFont("arial", 36));
  cp5.addButton("create_new_Kanji")
    .setPosition(realSize*scale+510, 50)
    .setSize(120, 40);

  background(255);
  strokeWeight(10);
  line(realSize*scale+5, 0, realSize*scale+5, realSize*scale+5);
  line(0, realSize*scale+5, realSize*scale+5, realSize*scale+5);
  strokeWeight(1);

  kanji.add(new boolean[realSize][realSize]);
  
  //loading the kanjiList
  try{
    reader=createReader("KanjiList.txt");
    String line;
    while((line=reader.readLine())!=null)
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
  for(String kanji : kanjiList)
  {
    kanjiObjects.add(new Kanji(loadImage(kanji+".png")));
  }
}
void draw()
{
  fill(0);
  if (mousePressed)
  {
    try {
      kanji.get(count)[mouseX/scale][mouseY/scale]=true;
      //rect(mouseX/scale*scale, mouseY/scale*scale, scale, scale);
      fill(0);
      stroke(0);
      strokeWeight(scale);
      line(pmouseX,pmouseY,mouseX,mouseY);
      noStroke();
      rect((count%scale)*realSize+mouseX/scale, count/scale*realSize+realSize*scale+10+mouseY/scale, 1, 1);
    }
    catch(Exception e)
    {
      print();
    }
  }
  frameRate(960);
}

void mouseClicked()
{
  //change selected Kanji with a click
  if (mouseX<realSize*scale && mouseY>realSize*scale+10)
  {
    drawMini(false);
    if (mouseX/realSize+(mouseY-realSize*scale-10)/realSize*scale<kanji.size())
    {
      count=mouseX/realSize+(mouseY-realSize*scale-10)/realSize*scale;
      kanjiClickable=false;
    }
    drawMini(true);
    drawBig();
  }
  
  //select drawn Kanji with a click to send it to server
  if(kanjiClickable && mouseX>500 && mouseX<1000 && mouseY>180)
  {
    try{
      String msg = kanjiList.get(orderedPrediction[(mouseY-180)/150*5+(mouseX-500)/100]);
      msg+="#";
      Socket soc=new Socket("localhost", 2052);  
      DataOutputStream dout=new DataOutputStream(soc.getOutputStream()); 
      if(!allSelected)
      {
        dout.writeUTF("td"+msg+drawingToString(count));
      }
      else
      {
        BufferedReader in = new BufferedReader(new InputStreamReader(soc.getInputStream()));
        for(int i=0;i<kanji.size();i++)
        {
          dout.writeUTF("td"+msg+drawingToString(i));
          print("still here");
          print(in.readLine());
          int time=millis();
          while(millis()-time<100)
          {
            noLoop();
          }
          loop();
          print("lol");
          
        }
      }
      dout.flush();
      println("Trainingsdaten erfolgreich gesendet");
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
    
  }
}
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
public void next(int value)
{
  clear(0);
  if (count==kanji.size()-1)
    kanji.add(new boolean[realSize][realSize]);
  drawMini(false);
  count+=1;
  drawMini(true);
  drawBig();
}
public void save_Drawings(int value)
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
  rect(0, realSize*scale+10, realSize*scale+20, height-(realSize*scale));
  try
  {
    int c = 0;
    while (true)
    {
      String bytecode=reader.readLine();
      if (bytecode==null)
      {
        reader.close();
        drawMini(false);
        kanji.remove(count);
        count-=1;
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
public void create_new_Kanji(int value)
{
  PImage kanjiPicture = get(0,0,realSize*scale,realSize*scale);
  kanjiPicture.resize(100,100);
  kanjiPicture.save(cp5.get(Textfield.class,"").getText()+".png");
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
public void extendKanjiList(String extension)
{
  if(!kanjiList.contains(extension))
  {
    kanjiList.add(extension);
    writer=createWriter("KanjiList.txt");
    for(String k : kanjiList)
    {
      writer.println(k);
    }
    writer.close();
    
  }
  else
  {
    println("dieses Kanji existiert bereits");
  }
}

//convert a drawing into a String of ones and zeroes c is the index of the drawing in kanji. If c is -1, a String with all drawings
//gets created where each Kanji is seperated by a ";"
public String drawingToString(int c)
{
  if(c==-1)
  {
    String s=drawingToString(0);
    for(int i=1;i<kanji.size();i++)
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

public void send(boolean single)
{
  //get the String code from current drawing
  String msg;
  if(single)
  {
    allSelected=false;
  }
  else
  {
    allSelected=true;
  }
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
    fill(255);
    noStroke();
    rect(500,150,1000,1000);
    stroke(0);
    textSize(24);
    fill(255,0,0);
    text("Which Kanji did you draw?",500,150);
    int numberOfKanji=percentages.length;
    orderedPrediction = new int[numberOfKanji];
    for(int i = 0; i < numberOfKanji; i++)
    {
      float currentMaxValue=0;
      int currentIndex=0;
      for(int a = 0; a<percentages.length;a++)
      {
        if(percentages[a]>currentMaxValue)
        {
          currentMaxValue=percentages[a];
          currentIndex=a;
        }
      }
      kanjiObjects.get(currentIndex).show(i,currentMaxValue);
      percentages[currentIndex]=0;
      orderedPrediction[i]=currentIndex;
    }
    kanjiClickable=true;
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}

public void send_all(int value)
{
  send(false);
}
