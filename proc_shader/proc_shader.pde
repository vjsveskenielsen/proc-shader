import de.looksgood.ani.*;
int n = 5;
int t = 0;
PShader graphics;
ArrayList<Animation> animations = new ArrayList<Animation>();
float linewidth = .1;
float bleed = 0.001;

void setup() {
  size(640, 360, P2D);
  noStroke();
  Ani.init(this);
  Ani.setDefaultEasing(Ani.LINEAR);
  graphics = loadShader("data/graphics.glsl");
  if (graphics.res != null) graphics.set("res", float(width), float(height));
}

void draw() {
  background(0);
  print("t: ", t, "//");
  rect(0, 0, width, height);
  for (int i = animations.size()-1; i >= 0; i--) {
    Animation a = animations.get(i);
    if (a.isActive == false) animations.remove(i);
    else a.update();
  }
  println();

  //shader(graphics);
  String txt_fps = String.format(getClass().getName()+ "   [size %d/%d]   [fps %6.2f]", width, height, frameRate);
  surface.setTitle(txt_fps);

}

private static double round (double value, int precision) {
    int scale = (int) Math.pow(10, precision);
    return (double) Math.round(value * scale) / scale;
}

void keyPressed() {
  if (keyCode==DOWN && animations.size()<n) {
    animations.add(new Animation(t, "ring", 2., 1.0, 0.));
    t++;
  }
}

class Animation {
  boolean isActive = true;
  float progress; //animation progress (normalised)
  float local_lw;
  float local_bl;
  String type; // easing type
  int target;
  Ani ani;
  // type animation // speed // start // end
  Animation(int _target, String _type, float localspeed, float start, float end) {
    progress = start;
    local_lw = linewidth;
    local_bl = bleed;
    type = _type;
    target = _target;
    ani = new Ani(this, localspeed, "progress", end, Ani.getDefaultEasing(), "onEnd:reset");
    ani.start();
  }
  void update() {
    String gname = "g" + target;
    float offset = 0.;
    if (type=="ring") offset = 2.;
    if (type=="lineV") offset = 1.;
    PVector output = new PVector(progress+offset, local_lw, local_bl);
    //graphics.set(gname, output);
  }

  void reset() {
    isActive = false;
    t--;
  }
}
