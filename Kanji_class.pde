class Kanji
{
  PImage img;
  Kanji(PImage img)
  {
    this.img=img;
  }
  
  void show(int rank, float percentage)
  {
    fill(0);
    image(img,500+(rank%5)*100,200+rank/5*150);
    textSize(24);
    text(round(percentage*100)+"%",500+(rank%5)*100,180+rank/5*150);
  }
}
