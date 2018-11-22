import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import de.looksgood.ani.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class proc_shader extends PApplet {


int n = 5;
int a_n; //current amount of animations
Integer inactive = new Integer(0);
Integer lineH = new Integer(1);
Integer lineV = new Integer(2);
Integer ring = new Integer(3);
PShader graphics;
ArrayList<Animation> animations = new ArrayList<Animation>();
float linewidth = .1f;
float bleed = 0.001f;

public void setup() {
  
  noStroke();
  Ani.init(this);
  Ani.setDefaultEasing(Ani.LINEAR);
  graphics = loadShader("data/graphics.glsl");
  graphics.set("res", PApplet.parseFloat(width), PApplet.parseFloat(height));
  for (int i = 0; i<n; i++) {
    animations.add(new Animation(inactive, i, 1.0f, 0.0f, 1.0f));
  }
}

public void draw() {
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

public void keyPressed() {
  if (keyCode==DOWN && a_n < n) {
    boolean found = false;
    int id = 0;
    while (found == false) {
      if (animations.get(id).state == inactive) {
        animations.set(id, new Animation(ring, id, 5.0f, 0.0f, 1.0f));
        found = true;
      }
      else id++;
    }
    a_n++;
  }
}

class Animation {
  PVector output = new PVector(0.0f, 0.0f, 0.0f);
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

  public void update() {
    PVector output = new PVector(progress+PApplet.parseFloat(state), local_lw, local_bl);
    graphics.set("g"+target, output);
  }

  public void reset() {
    state = inactive;
    /*
    when the initial Animation objects gets added to animations, their Ani
    objects runs and thus resets n times, causing a_n to be subtracted below 0.
    The following line prevents this initial error.
    */
    if (a_n>0) a_n--;
  }
}
  public void settings() {  size(640, 360, P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "proc_shader" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
