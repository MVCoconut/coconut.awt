package coconut.ui;

import java.awt.*;
import coconut.diffing.*;

class Renderer {

  static var DIFFER = new coconut.diffing.Differ(new AwtBackend());

  static public function mount(target:Component, virtual:RenderResult)
    DIFFER.render([virtual], target);

  static public function getNative(view:View):Null<Component>
    return getAllNative(view)[0];

  static public function getAllNative(view:View):Array<Component>
    return switch @:privateAccess view._coco_lastRender {
      case null: [];
      case r: r.flatten(null);
    }

  static public inline function updateAll()
    tink.state.Observable.updateAll();
}

private class AwtCursor implements Cursor<Component> {

  var pos:Int;
  var container:Container;
  //TODO: keep child count
  public function new(container:Container, pos:Int) {
    this.container = container;
    this.pos = pos;
  }

  public function close()
    container.validate();

  public function insert(real:Component):Bool {
    var inserted = real.getParent() != container;
    if (pos < container.getComponentCount())
      container.add(real, pos);
    else
      container.add(real);
    pos++;
    return inserted;
  }

  public function delete():Bool
    return
      if (pos < container.getComponentCount()) {
        container.remove(pos);
        true;
      }
      else false;

  public function step():Bool
    return
      if (pos >= container.getComponentCount()) false;
      else ++pos == container.getComponentCount();

  public function current():Component
    return
      if (pos >= container.getComponentCount()) null;
      else container.getComponent(pos);
}

private class AwtBackend implements Applicator<Component> {
  public function new() {}
  var registry:Map<Component, Rendered<Component>> = new Map();

  public function unsetLastRender(target:Component):Rendered<Component> {
    var ret = registry[target];
    registry.remove(target);
    return ret;
  }

  public function setLastRender(target:Component, r:Rendered<Component>):Void
    registry[target] = r;

  public function getLastRender(target:Component):Null<Rendered<Component>>
    return registry[target];

  public function traverseSiblings(target:Component):Cursor<Component> {
    var parent = target.getParent();
    for (i in 0...parent.getComponentCount())
      return new AwtCursor(target.getParent(), i + 1);
    throw 'not found';
  }

  static final NOCURSOR = new AwtCursor(new Container(), 0);

  public function traverseChildren(target:Component):Cursor<Component>
    return
      if (Std.is(target, Container))
        new AwtCursor(cast target, 0);
      else NOCURSOR;

  public function placeholder(forTarget:Widget<Component>):VNode<Component>
    return VNode.native(PLACEHOLDER, null, null, null, null);

  static final PLACEHOLDER = new PlaceHolderType();
}

private final class Placeholder extends Component {}

private class PlaceHolderType implements NodeType<{}, Placeholder> {
  public function new() {}
  public function create(a:{}):Placeholder
    return new Placeholder();

  public function update(target:Placeholder, old:{}, nu:{}):Void {}
}