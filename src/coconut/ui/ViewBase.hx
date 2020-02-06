package coconut.ui;

import java.javax.swing.SwingUtilities.getRoot;

@:noCompletion class ViewBase extends coconut.diffing.Widget<java.awt.Component> {

  @:noCompletion var _coco_root:java.awt.Window;

  @:noCompletion inline function _coco_searchRoot(later)
    if (_coco_root == null)
      _coco_root = switch _coco_lastRender.first(later) {
        case null: null;
        case c: cast getRoot(c);
      }

  @:noCompletion override function _coco_initialize(differ, parent, later) {
    super._coco_initialize(differ, parent, later);
    if (parent == null) later(function () {
      _coco_searchRoot(later);
    });
  }

  @:noCompletion override function _coco_performUpdate(later)
    switch this._coco_parent {
      case null:
        var prevFocus =
        if (_coco_root != null)
          _coco_root.getFocusOwner();
        else
          null;

        super._coco_performUpdate(later);

        later(function () {
          _coco_searchRoot(later);

          _coco_lastRender.each(later, c -> c.validate());
          try prevFocus.requestFocusInWindow()
          catch (e:Dynamic) {}
        });

      default:
        super._coco_performUpdate(later);
    }
}