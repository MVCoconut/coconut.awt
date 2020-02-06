package coconut.awt;

@:forward
abstract EventFrom<Source, E:java.util.EventObject>(E) from E to E {
  public var source(get, never):Source;
    function get_source():Source
      return cast this.getSource();
}