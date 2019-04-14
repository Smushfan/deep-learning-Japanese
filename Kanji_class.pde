class Kanji
{
  PImage img;
  Kanji(PImage img)
  {
    this.img=img;
  }
  
  //zeigt das Kanji Bild und die Prozentzahl auf dem richtigen Platz an, sodass die Kanji sortiert nach 
  //Prozentzahlen angezeigt werden
  void show(int rank, float percentage)
  {
    fill(0);
    image(img,kanjiposX+realSize*scale+(rank%5)*100,200+rank/5*150);
    textSize(24);
    text(round(percentage*100)+"%",kanjiposX+realSize*scale+(rank%5)*100,180+rank/5*150);
  }
}
