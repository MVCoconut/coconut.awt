package ;

import java.javax.swing.*;
import java.javax.swing.border.*;
import coconut.ui.*;
import coconut.ui.Renderer;
import java.awt.*;
import java.awt.event.*;
import tink.state.*;
import coconut.Ui.hxx;

using tink.CoreApi;

typedef Todo = coconut.data.Record<{
  description:String,
  done:Bool,
}>;

abstract Foo(String) {}

class Filler extends Component {
  public function new() {
    super();
    this.setMinimumSize(new Dimension(0, 0));
    this.setMaximumSize(new Dimension(1 << 30, 1 << 30));
  }
}

class RunTests {

  static function main() {
    UIManager.setLookAndFeel(
      UIManager.getSystemLookAndFeelClassName());
    // UIManager.setLookAndFeel("javax.swing.plaf.metal.MetalLookAndFeel");
    var fr = new JFrame();
    fr.setSize(600, 500);

    var filters:coconut.data.List<{ final name:String; final predicate:Todo->Bool; }> = [
      { name: 'All', predicate: _ -> true, },
      { name: 'Active', predicate: t -> !t.done, },
      { name: 'Completed', predicate: t -> t.done, },
    ];

    var desc = new State(''),
        filter = new State(filters.first().force().predicate),
        todos = new ObservableArray<Todo>();

    function add() {
      todos.push(new Todo({
        done: false,
        description: desc.value,
      }));
      desc.set('');
    }

    final line = new Dimension(1 << 30, 25);

    function itemsLeft() {
      var left = 0;
      for (i in todos.values())
        if (!i.done) left++;
      return left;
    }

    Renderer.mount(fr, hxx('
      <Isolated>
        <VBox border=${new EmptyBorder(10, 10, 10, 10)}>
          <HBox maximumSize=${line}>
            <JTextField text=${desc.value} onKeyReleased=${desc.set(event.source.getText())} onActionPerformed=$add />
            <JButton enabled=${desc.value.length > 0} text="Create" maximumSize=${new Dimension(100, 1 << 30)} onMouseClicked=$add />
          </HBox>

          <VBox>
            <for ${item in todos.values()}>
              <if ${filter.value(item)}>
                <HBox>
                  <JCheckBox maximumSize=${line} selected=${item.done} text=${item.description} onItemStateChanged=${item.update({ done: event.getStateChange() == ItemEvent.SELECTED })}/>
                </HBox>
              </if>
            </for>
            <Filler />
          </VBox>

          <HBox maximumSize=${new Dimension(1 << 30, 40)}>

            <Label text=${switch itemsLeft() {
              case 1: '1 item left';
              case left: '$left items left';
            }} preferredSize=${new Dimension(200, 40)} />

            <for ${f in filters}>
              <JToggleButton text=${f.name} selected=${filter.value == f.predicate} onMouseClicked=${filter.set(f.predicate)} />
            </for>

            <Filler />

            <switch ${[for (t in todos.values()) if (t.done) t]}>
              <case ${[]}>
              <case ${completed}>
                <JButton text="Clear Completed" onMouseClicked=${for (t in completed) todos.remove(t)} />
            </switch>

          </HBox>

        </VBox>
      </Isolated>
    '));
    fr.setVisible(true);
    fr.addWindowListener(new WListener());
  }
}

class WListener extends WindowAdapter {
  @:overload override function windowClosing(param1:WindowEvent) {
    param1.getWindow().dispose();
  //   super.windowClosing(param1);
  }
  // public function windowActivated(_) {}
  // public function windowClosed(_) {}
}

class Listener implements ActionListener {
  final cb:Callback<ActionEvent>;
  public function new(cb)
    this.cb = cb;
  public function actionPerformed(e:ActionEvent)
    cb.invoke(e);
}