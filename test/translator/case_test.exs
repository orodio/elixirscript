defmodule ElixirScript.Translator.Case.Test do
  use ShouldI
  import ElixirScript.TestHelper

  should "translate case" do

    ex_ast = quote do
      case data do
        :ok -> value
        :error -> nil
      end
    end

    js_code = """
     Patterns.defmatch(Patterns.make_case([Kernel.SpecialForms.atom('ok')],function()    {
             return     value;
           }),Patterns.make_case([Kernel.SpecialForms.atom('error')],function()    {
             return     null;
           })).call(this,data)
    """

    assert_translation(ex_ast, js_code)

    ex_ast = quote do
      case data do
        false -> value = 13
        true  -> true
      end
    end

    js_code = """
     Patterns.defmatch(Patterns.make_case([false],function()    {
             let [value0] = Patterns.match(Patterns.variable(),13);
             return     value0;
           }),Patterns.make_case([true],function()    {
             return     true;
           })).call(this,data)
    """

    assert_translation(ex_ast, js_code)



    ex_ast = quote do
      case data do
        false -> value = 13
        _  -> true
      end
    end

    js_code = """
     Patterns.defmatch(Patterns.make_case([false],function()    {
             let [value0] = Patterns.match(Patterns.variable(),13);
             return     value0;
           }),Patterns.make_case([Patterns.wildcard()],function()    {
             return     true;
           })).call(this,data)
    """

    assert_translation(ex_ast, js_code)
  end

  should "translate case with guard" do
    ex_ast = quote do
      case data do
        number when number in [1,2,3,4] -> 
          value = 13
        _  -> 
          true
      end
    end

    js_code = """
     Patterns.defmatch(Patterns.make_case([Patterns.variable()],function(number)    {
             let [value0] = Patterns.match(Patterns.variable(),13);
             return     value0;
           },function(number)    {
             return     Kernel.__in__(number,Kernel.SpecialForms.list(1,2,3,4));
           }),Patterns.make_case([Patterns.wildcard()],function()    {
             return     true;
           })).call(this,data)
    """

    assert_translation(ex_ast, js_code)
  end

  should "translate case with multiple statements in body" do
    ex_ast = quote do
      case data do
        :ok -> 
          Logger.info("info")
          Todo.add(data)
        :error -> 
          nil
      end
    end

    js_code = """
     Patterns.defmatch(Patterns.make_case([Kernel.SpecialForms.atom('ok')],function()    {
             console.info('info');
             return     Todo.add(data);
           }),Patterns.make_case([Kernel.SpecialForms.atom('error')],function()    {
             return     null;
           })).call(this,data)
    """

    assert_translation(ex_ast, js_code)
  end

  should "translate case with destructing" do
    ex_ast = quote do
      case data do
        { one, two } -> 
          Logger.info(one)
        :error -> 
          nil
      end
    end

    js_code = """
     Patterns.defmatch(Patterns.make_case([Kernel.SpecialForms.tuple(Patterns.variable(),Patterns.variable())],function(one,two)    {
             return     console.info(one);
           }),Patterns.make_case([Kernel.SpecialForms.atom('error')],function()    {
             return     null;
           })).call(this,data)
    """

    assert_translation(ex_ast, js_code)
  end

  should "translate case with nested destructing" do
    ex_ast = quote do
      case data do
        { {one, two} , three } -> 
          Logger.info(one)
        :error -> 
          nil
      end
    end

    js_code = """
     Patterns.defmatch(Patterns.make_case([Kernel.SpecialForms.tuple(Kernel.SpecialForms.tuple(Patterns.variable(),Patterns.variable()),Patterns.variable())],function(one,two,three)    {
             return     console.info(one);
           }),Patterns.make_case([Kernel.SpecialForms.atom('error')],function()    {
             return     null;
           })).call(this,data)
    """

    assert_translation(ex_ast, js_code)

    ex_ast = quote do
      case data do
        { one, {two, three} } -> 
          Logger.info(one)
        :error -> 
          nil
      end
    end

    js_code = """
     Patterns.defmatch(Patterns.make_case([Kernel.SpecialForms.tuple(Patterns.variable(),Kernel.SpecialForms.tuple(Patterns.variable(),Patterns.variable()))],function(one,two,three)    {
             return     console.info(one);
           }),Patterns.make_case([Kernel.SpecialForms.atom('error')],function()    {
             return     null;
           })).call(this,data)

    """

    assert_translation(ex_ast, js_code)


    ex_ast = quote do
      case data do
        %AStruct{key: %BStruct{ key2: value }} -> 
          Logger.info(value)
        :error -> 
          nil
      end
    end

    js_code = """
     Patterns.defmatch(Patterns.make_case([{
             [Kernel.SpecialForms.atom('__struct__')]: Kernel.SpecialForms.atom('AStruct'),     [Kernel.SpecialForms.atom('key')]: {
             [Kernel.SpecialForms.atom('__struct__')]: Kernel.SpecialForms.atom('BStruct'),     [Kernel.SpecialForms.atom('key2')]: Patterns.variable()
       }
       }],function(value)    {
             return     console.info(value);
           }),Patterns.make_case([Kernel.SpecialForms.atom('error')],function()    {
             return     null;
           })).call(this,data)
    """

    assert_translation(ex_ast, js_code)


    ex_ast = quote do
      case data do
        %AStruct{key: %BStruct{ key2: value, key3: %CStruct{ key4: value2 } }} -> 
          Logger.info(value)
        :error -> 
          nil
      end
    end

    js_code = """
     Patterns.defmatch(Patterns.make_case([{
             [Kernel.SpecialForms.atom('__struct__')]: Kernel.SpecialForms.atom('AStruct'),     [Kernel.SpecialForms.atom('key')]: {
             [Kernel.SpecialForms.atom('__struct__')]: Kernel.SpecialForms.atom('BStruct'),     [Kernel.SpecialForms.atom('key2')]: Patterns.variable(),     [Kernel.SpecialForms.atom('key3')]: {
             [Kernel.SpecialForms.atom('__struct__')]: Kernel.SpecialForms.atom('CStruct'),     [Kernel.SpecialForms.atom('key4')]: Patterns.variable()
       }
       }
       }],function(value,value2)    {
             return     console.info(value);
           }),Patterns.make_case([Kernel.SpecialForms.atom('error')],function()    {
             return     null;
           })).call(this,data)
    """

    assert_translation(ex_ast, js_code)
  end
end