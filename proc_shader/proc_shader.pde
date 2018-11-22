import de.looksgood.ani.*;
int n = 5;
int a_n; //current amount of animations
Integer inactive = new Integer(0);
Integer lineH = new Integer(1);
Integer lineV = new Integer(2);
Integer ring = new Integer(3);
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
  graphics.set("res", float(width), float(height));
  for (int i = 0; i<n; i++) {
    animations.add(new Animation(inactive, i, 1.0, 0.0, 1.0));
  }
}

void draw() {
  for (Animation a : animations) {
    a.update();
    print("g" + a.target, "s:" + a.state, round(a.progress, 1));
    print(" // ");
  }
  println();
  background(0);
  rect(0, 0, width, height);
  shader(graphics);

  String txt_fps = String.format(getClass().getName()+ "   [size %d/%d]   [fps %6.2f]", width, height, frameRate);
  surface.setTitle(txt_fps);

}

private static double round (double value, int precision) {
  int scale = (int) Math.pow(10, precision);
  return (double) Math.round(value * scale) / scale;
}

void keyPressed() {
  if (keyCode==DOWN && a_n < n) {
    boolean found = false;
    int id = 0;
    while (found == false) {
      if (animations.get(id).state == inactive) {
        animations.set(id, new Animation(ring, id, 5.0, 0.0, 1.0));
        found = true;
      }
      else id++;
    }
    a_n++;
  }
}

class Animation {
  PVector output = new PVector(0.0, 0.0, 0.0);
  float progress; //animation progress (normalised)
  float local_lw, local_bl;
  int state;
  int target;
  Ani ani;
  // state of object // output target // speed // start // end
  Animation(int s, int t, float localspeed, float start, float end) {
    progress = start;
    local_lw = linewidth;
    local_bl = bleed;
    state = s;
    ani = new Ani(this, localspeed, "progress", end, Ani.getDefaultEasing(), "onEnd:reset");
    target = t;
  }

  void update() {
    PVector output = new PVector(progress+float(state), local_lw, local_bl);
    graphics.set("g"+target, output);
  }

  void reset() {
    state = inactive;
    /*
    when the initial Animation objects gets added to animations, their Ani
    objects runs and thus resets n times, causing a_n to be subtracted below 0.
    The following line prevents this initial error.
    */
    if (a_n>0) a_n--;
  }
}
