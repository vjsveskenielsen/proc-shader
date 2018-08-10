/**
 * Nebula.
 *
 * From CoffeeBreakStudios.com (CBS)
 * Ported from the webGL version in GLSL Sandbox:
 * http://glsl.heroku.com/e#3265.2
 */

//PShader nebula;
import de.looksgood.ani.*;

PShader rings;
ArrayList<Animation> animations = new ArrayList<Animation>();
float[] r_progresses = new float[2];

void updateArray(){
  for (int i = 0; i<r_progresses.length) {
    r_progresses[i] = 0.;
  }
}

void setup() {
  size(640, 360, P2D);
  noStroke();
  Ani.init(this);
  Ani.setDefaultEasing(Ani.LINEAR);
  //nebula = loadShader("nebula.glsl");
  //nebula.set("resolution", float(width), float(height));
  rings = loadShader("data/rings_test.glsl");
  rings.set("resolution", float(width), float(height));
}

void draw() {q
  background(0);

  if (animations.size()>0) {
    for (int i = animations.size() - 1; i >= 0; i--) {
      Animation a = animations.get(i);
      if (!a.active) {
        animations.remove(i);
      } else {
        a.update();
      }
    }
    shader(rings);
    rect(0, 0, width, height);
  }

  String txt_fps = String.format(getClass().getName()+ "   [size %d/%d]   [fps %6.2f]", width, height, frameRate);
  surface.setTitle(txt_fps);

}

void keyPressed() {
  if (keyCode==DOWN && animations.size()<2) animations.add(new Animation("ring", 2., 1.0, 0.));
}

class Animation {
  boolean active;
  float progress; //animation progress (normalised)
  String type; // easing type
  String target;
  Ani ani;
  // type animation // speed // start // end
  Animation(String _type, float localspeed, float start, float end) {
    active = true;
    progress = start;
    type = _type;
    ani = new Ani(this, localspeed, "progress", end, Ani.getDefaultEasing(), "onEnd:killObject");
    ani.start();
  }
  void update() {
    if (type=="ring") rings.set(target, a.progress);
  }

  void killObject() {
    active = false;
  }
}
