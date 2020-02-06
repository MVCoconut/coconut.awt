package coconut.ui;

@:noCompletion class ViewBase extends coconut.diffing.Widget<java.awt.Component> {
  override function _coco_performUpdate(later) {
    super._coco_performUpdate(later);
    if (this._coco_parent == null)
      _coco_lastRender.each(later, c -> c.validate());
  }
}