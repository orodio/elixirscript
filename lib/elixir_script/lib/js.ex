defmodule ElixirScript.Lib.JS do

  @doc """
  Creates new JavaScript objects.

  ex:
    JS.new User, ["first_name", "last_name"]
  """
  defmacro new(module, params)


  @doc """
  Updates an existing JavaScript object.

  ex:
    JS.update elem, "width", 100
  """
  defmacro update(object, property, value)


  @doc """
  Imports a JavaScript module.

  Elixir modules can use the normal `import`, `alias` and `require`,
  but JavaScript modules work differently and have to be imported
  using this.

  If module is not a list, then it is treated as a default import, 
  otherwise it is not. 

  ex:
    JS.import A, "a" #translates to "import {default as A} from 'a'"

    JS.import [A, B, C], "a" #translates to "import {A, B, C} from 'a'"
  """
  defmacro import(module, from)


  @doc """
  Turns an ElixirScript data structure into a JavaScript one.
  """
  defmacro to_js(value)


  @doc """
  Turns an ElixirScript data structure into JSON.
  """
  defmacro to_json(value)

end