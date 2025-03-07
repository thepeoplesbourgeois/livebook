defmodule Livebook.CompletionTest.Utils do
  @moduledoc false

  @doc """
  Returns `{binding, env}` resulting from evaluating
  the given block of code in a fresh context.
  """
  defmacro eval(do: block) do
    binding = []
    env = :elixir.env_for_eval([])
    {_, binding, env} = :elixir.eval_quoted(block, binding, env)

    quote do
      {unquote(Macro.escape(binding)), unquote(Macro.escape(env))}
    end
  end
end

defmodule Livebook.CompletionTest do
  use ExUnit.Case, async: true

  import Livebook.CompletionTest.Utils

  alias Livebook.Completion

  test "completion when no hint given" do
    {binding, env} = eval(do: nil)

    length_item = %{
      label: "length/1",
      kind: :function,
      detail: "Kernel.length(list)",
      documentation: """
      Returns the length of `list`.

      ```
      @spec length(list()) ::
        non_neg_integer()
      ```\
      """,
      insert_text: "length"
    }

    assert length_item in Completion.get_completion_items("", binding, env)
    assert length_item in Completion.get_completion_items("Enum.map(list, ", binding, env)
  end

  @tag :erl_docs
  test "Erlang module completion" do
    {binding, env} = eval(do: nil)

    assert [
             %{
               label: "zlib",
               kind: :module,
               detail: "module",
               documentation:
                 "This module provides an API for the zlib library (www.zlib.net). It is used to compress and decompress data. The data format is described by RFC 1950, RFC 1951, and RFC 1952.",
               insert_text: "zlib"
             }
           ] = Completion.get_completion_items(":zl", binding, env)
  end

  test "Erlang module no completion" do
    {binding, env} = eval(do: nil)

    assert [] = Completion.get_completion_items(":unknown", binding, env)
  end

  test "Erlang module multiple values completion" do
    {binding, env} = eval(do: nil)

    assert [
             %{
               label: "user",
               kind: :module,
               detail: "module",
               documentation: _user_doc,
               insert_text: "user"
             },
             %{
               label: "user_drv",
               kind: :module,
               detail: "module",
               documentation: _user_drv_doc,
               insert_text: "user_drv"
             },
             %{
               label: "user_sup",
               kind: :module,
               detail: "module",
               documentation: _user_sup_doc,
               insert_text: "user_sup"
             }
           ] = Completion.get_completion_items(":user", binding, env)
  end

  @tag :erl_docs
  test "Erlang root completion" do
    {binding, env} = eval(do: nil)

    lists_item = %{
      label: "lists",
      kind: :module,
      detail: "module",
      documentation: "This module contains functions for list processing.",
      insert_text: "lists"
    }

    assert lists_item in Completion.get_completion_items(":", binding, env)
    assert lists_item in Completion.get_completion_items("  :", binding, env)
  end

  test "Elixir proxy" do
    {binding, env} = eval(do: nil)

    assert %{
             label: "Elixir",
             kind: :module,
             detail: "module",
             documentation: nil,
             insert_text: "Elixir"
           } in Completion.get_completion_items("E", binding, env)
  end

  test "Elixir module completion" do
    {binding, env} = eval(do: nil)

    assert [
             %{
               label: "Enum",
               kind: :module,
               detail: "module",
               documentation: "Provides a set of algorithms to work with enumerables.",
               insert_text: "Enum"
             },
             %{
               label: "Enumerable",
               kind: :module,
               detail: "module",
               documentation: "Enumerable protocol used by `Enum` and `Stream` modules.",
               insert_text: "Enumerable"
             }
           ] = Completion.get_completion_items("En", binding, env)

    assert [
             %{
               label: "Enumerable",
               kind: :module,
               detail: "module",
               documentation: "Enumerable protocol used by `Enum` and `Stream` modules.",
               insert_text: "Enumerable"
             }
           ] = Completion.get_completion_items("Enumera", binding, env)
  end

  test "Elixir type completion" do
    {binding, env} = eval(do: nil)

    assert [
             %{
               label: "from/0",
               kind: :type,
               detail: "typespec",
               documentation: "Tuple describing the client of a call request.",
               insert_text: "from"
             }
           ] = Completion.get_completion_items("GenServer.fr", binding, env)

    assert [
             %{
               label: "name/0",
               kind: :type,
               detail: "typespec",
               documentation: _name_doc,
               insert_text: "name"
             },
             %{
               label: "name_all/0",
               kind: :type,
               detail: "typespec",
               documentation: _name_all_doc,
               insert_text: "name_all"
             }
           ] = Completion.get_completion_items(":file.nam", binding, env)
  end

  test "Elixir completion with self" do
    {binding, env} = eval(do: nil)

    assert [
             %{
               label: "Enumerable",
               kind: :module,
               detail: "module",
               documentation: "Enumerable protocol used by `Enum` and `Stream` modules.",
               insert_text: "Enumerable"
             }
           ] = Completion.get_completion_items("Enumerable", binding, env)
  end

  test "Elixir completion on modules from load path" do
    {binding, env} = eval(do: nil)

    assert %{
             label: "Jason",
             kind: :module,
             detail: "module",
             documentation: "A blazing fast JSON parser and generator in pure Elixir.",
             insert_text: "Jason"
           } in Completion.get_completion_items("Jas", binding, env)
  end

  test "Elixir no completion" do
    {binding, env} = eval(do: nil)

    assert [] = Completion.get_completion_items(".", binding, env)
    assert [] = Completion.get_completion_items("Xyz", binding, env)
    assert [] = Completion.get_completion_items("x.Foo", binding, env)
    assert [] = Completion.get_completion_items("x.Foo.get_by", binding, env)
  end

  test "Elixir root submodule completion" do
    {binding, env} = eval(do: nil)

    assert [
             %{
               label: "Access",
               kind: :module,
               detail: "module",
               documentation: "Key-based access to data structures.",
               insert_text: "Access"
             }
           ] = Completion.get_completion_items("Elixir.Acce", binding, env)
  end

  test "Elixir submodule completion" do
    {binding, env} = eval(do: nil)

    assert [
             %{
               label: "ANSI",
               kind: :module,
               detail: "module",
               documentation: "Functionality to render ANSI escape sequences.",
               insert_text: "ANSI"
             }
           ] = Completion.get_completion_items("IO.AN", binding, env)
  end

  test "Elixir submodule no completion" do
    {binding, env} = eval(do: nil)

    assert [] = Completion.get_completion_items("IEx.Xyz", binding, env)
  end

  test "Elixir function completion" do
    {binding, env} = eval(do: nil)

    assert [
             %{
               label: "version/0",
               kind: :function,
               detail: "System.version()",
               documentation: """
               Elixir version information.

               ```
               @spec version() :: String.t()
               ```\
               """,
               insert_text: "version"
             }
           ] = Completion.get_completion_items("System.ve", binding, env)
  end

  @tag :erl_docs
  test "Erlang function completion" do
    {binding, env} = eval(do: nil)

    assert %{
             label: "gzip/1",
             kind: :function,
             detail: "zlib.gzip/1",
             documentation: """
             Compresses data with gz headers and checksum.

             ```
             @spec gzip(data) :: compressed
             when data: iodata(),
                  compressed: binary()
             ```\
             """,
             insert_text: "gzip"
           } in Completion.get_completion_items(":zlib.gz", binding, env)
  end

  test "function completion with arity" do
    {binding, env} = eval(do: nil)

    assert %{
             label: "concat/1",
             kind: :function,
             detail: "Enum.concat(enumerables)",
             documentation: """
             Given an enumerable of enumerables, concatenates the `enumerables` into
             a single list.

             ```
             @spec concat(t()) :: t()
             ```\
             """,
             insert_text: "concat"
           } in Completion.get_completion_items("Enum.concat/", binding, env)
  end

  test "function completion same name with different arities" do
    {binding, env} = eval(do: nil)

    assert [
             %{
               label: "concat/1",
               kind: :function,
               detail: "Enum.concat(enumerables)",
               documentation: """
               Given an enumerable of enumerables, concatenates the `enumerables` into
               a single list.

               ```
               @spec concat(t()) :: t()
               ```\
               """,
               insert_text: "concat"
             },
             %{
               label: "concat/2",
               kind: :function,
               detail: "Enum.concat(left, right)",
               documentation: """
               Concatenates the enumerable on the `right` with the enumerable on the
               `left`.

               ```
               @spec concat(t(), t()) :: t()
               ```\
               """,
               insert_text: "concat"
             }
           ] = Completion.get_completion_items("Enum.concat", binding, env)
  end

  test "function completion when has default args then documentation all arities have docs" do
    {binding, env} = eval(do: nil)

    assert [
             %{
               label: "join/1",
               kind: :function,
               detail: ~S{Enum.join(enumerable, joiner \\ "")},
               documentation: """
               Joins the given `enumerable` into a string using `joiner` as a
               separator.

               ```
               @spec join(t(), String.t()) ::
                 String.t()
               ```\
               """,
               insert_text: "join"
             },
             %{
               label: "join/2",
               kind: :function,
               detail: ~S{Enum.join(enumerable, joiner \\ "")},
               documentation: """
               Joins the given `enumerable` into a string using `joiner` as a
               separator.

               ```
               @spec join(t(), String.t()) ::
                 String.t()
               ```\
               """,
               insert_text: "join"
             }
           ] = Completion.get_completion_items("Enum.jo", binding, env)
  end

  test "function completion using a variable bound to a module" do
    {binding, env} =
      eval do
        mod = System
      end

    assert [
             %{
               label: "version/0",
               kind: :function,
               detail: "System.version()",
               documentation: """
               Elixir version information.

               ```
               @spec version() :: String.t()
               ```\
               """,
               insert_text: "version"
             }
           ] = Completion.get_completion_items("mod.ve", binding, env)
  end

  test "map atom key completion" do
    {binding, env} =
      eval do
        map = %{
          foo: 1,
          bar_1: ~r/pattern/,
          bar_2: true
        }
      end

    assert [
             %{
               label: "bar_1",
               kind: :field,
               detail: "field",
               documentation: ~s{```\n~r/pattern/\n```},
               insert_text: "bar_1"
             },
             %{
               label: "bar_2",
               kind: :field,
               detail: "field",
               documentation: ~s{```\ntrue\n```},
               insert_text: "bar_2"
             },
             %{
               label: "foo",
               kind: :field,
               detail: "field",
               documentation: ~s{```\n1\n```},
               insert_text: "foo"
             }
           ] = Completion.get_completion_items("map.", binding, env)

    assert [
             %{
               label: "foo",
               kind: :field,
               detail: "field",
               documentation: ~s{```\n1\n```},
               insert_text: "foo"
             }
           ] = Completion.get_completion_items("map.f", binding, env)
  end

  test "nested map atom key completion" do
    {binding, env} =
      eval do
        map = %{
          nested: %{
            deeply: %{
              foo: 1,
              bar_1: 23,
              bar_2: 14,
              mod: System
            }
          }
        }
      end

    assert [
             %{
               label: "nested",
               kind: :field,
               detail: "field",
               documentation: """
               ```
               %{
                 deeply: %{
                   bar_1: 23,
                   bar_2: 14,
                   foo: 1,
                   mod: System
                 }
               }
               ```\
               """,
               insert_text: "nested"
             }
           ] = Completion.get_completion_items("map.nest", binding, env)

    assert [
             %{
               label: "foo",
               kind: :field,
               detail: "field",
               documentation: ~s{```\n1\n```},
               insert_text: "foo"
             }
           ] = Completion.get_completion_items("map.nested.deeply.f", binding, env)

    assert [
             %{
               label: "version/0",
               kind: :function,
               detail: "System.version()",
               documentation: """
               Elixir version information.

               ```
               @spec version() :: String.t()
               ```\
               """,
               insert_text: "version"
             }
           ] = Completion.get_completion_items("map.nested.deeply.mod.ve", binding, env)

    assert [] = Completion.get_completion_items("map.non.existent", binding, env)
  end

  test "map string key completion is not supported" do
    {binding, env} =
      eval do
        map = %{"foo" => 1}
      end

    assert [] = Completion.get_completion_items("map.f", binding, env)
  end

  test "autocompletion off a bound variable only works for modules and maps" do
    {binding, env} =
      eval do
        num = 5
        map = %{nested: %{num: 23}}
      end

    assert [] = Completion.get_completion_items("num.print", binding, env)
    assert [] = Completion.get_completion_items("map.nested.num.f", binding, env)
  end

  test "autocompletion using access syntax does is not supported" do
    {binding, env} =
      eval do
        map = %{nested: %{deeply: %{num: 23}}}
      end

    assert [] = Completion.get_completion_items("map[:nested][:deeply].n", binding, env)
    assert [] = Completion.get_completion_items("map[:nested].deeply.n", binding, env)
    assert [] = Completion.get_completion_items("map.nested.[:deeply].n", binding, env)
  end

  test "macro completion" do
    {binding, env} = eval(do: nil)

    assert [
             %{
               label: "is_nil/1",
               kind: :function,
               detail: "Kernel.is_nil(term)",
               documentation: "Returns `true` if `term` is `nil`, `false` otherwise.",
               insert_text: "is_nil"
             }
           ] = Completion.get_completion_items("Kernel.is_ni", binding, env)
  end

  test "special forms completion" do
    {binding, env} = eval(do: nil)

    assert [
             %{
               label: "quote/2",
               kind: :function,
               detail: "Kernel.SpecialForms.quote(opts, block)",
               documentation: "Gets the representation of any expression.",
               insert_text: "quote"
             }
           ] = Completion.get_completion_items("quot", binding, env)
  end

  test "kernel import completion" do
    {binding, env} = eval(do: nil)

    assert [
             %{
               label: "put_in/2",
               kind: :function,
               detail: "Kernel.put_in(path, value)",
               documentation: "Puts a value in a nested structure via the given `path`.",
               insert_text: "put_in"
             },
             %{
               label: "put_in/3",
               kind: :function,
               detail: "Kernel.put_in(data, keys, value)",
               documentation: """
               Puts a value in a nested structure.

               ```
               @spec put_in(
                 Access.t(),
                 [term(), ...],
                 term()
               ) :: Access.t()
               ```\
               """,
               insert_text: "put_in"
             }
           ] = Completion.get_completion_items("put_i", binding, env)
  end

  test "variable name completion" do
    {binding, env} =
      eval do
        number = 3
        numbats = ["numbat", "numbat"]
        nothing = nil
      end

    assert [
             %{
               label: "numbats",
               kind: :variable,
               detail: "variable",
               documentation: ~s{```\n["numbat", "numbat"]\n```},
               insert_text: "numbats"
             }
           ] = Completion.get_completion_items("numba", binding, env)

    assert [
             %{
               label: "numbats",
               kind: :variable,
               detail: "variable",
               documentation: ~s{```\n["numbat", "numbat"]\n```},
               insert_text: "numbats"
             },
             %{
               label: "number",
               kind: :variable,
               detail: "variable",
               documentation: ~s{```\n3\n```},
               insert_text: "number"
             }
           ] = Completion.get_completion_items("num", binding, env)

    assert [
             %{
               label: "nothing",
               kind: :variable,
               detail: "variable",
               documentation: ~s{```\nnil\n```},
               insert_text: "nothing"
             },
             %{label: "node/0"},
             %{label: "node/1"},
             %{label: "not/1"}
           ] = Completion.get_completion_items("no", binding, env)
  end

  test "completion of manually imported functions and macros" do
    {binding, env} =
      eval do
        import Enum
        import System, only: [version: 0]
        import Protocol
      end

    assert [
             %{label: "take/2"},
             %{label: "take_every/2"},
             %{label: "take_random/2"},
             %{label: "take_while/2"}
           ] = Completion.get_completion_items("take", binding, env)

    assert %{
             label: "version/0",
             kind: :function,
             detail: "System.version()",
             documentation: """
             Elixir version information.

             ```
             @spec version() :: String.t()
             ```\
             """,
             insert_text: "version"
           } in Completion.get_completion_items("v", binding, env)

    assert [
             %{label: "derive/2"},
             %{label: "derive/3"}
           ] = Completion.get_completion_items("der", binding, env)
  end

  test "ignores quoted variables when performing variable completion" do
    {binding, env} =
      eval do
        quote do
          var!(my_var_1, Elixir) = 1
        end

        my_var_2 = 2
      end

    assert [
             %{label: "my_var_2"}
           ] = Completion.get_completion_items("my_var", binding, env)
  end

  test "completion inside expression" do
    {binding, env} = eval(do: nil)

    assert [
             %{label: "Enum"},
             %{label: "Enumerable"}
           ] = Completion.get_completion_items("1 En", binding, env)

    assert [
             %{label: "Enum"},
             %{label: "Enumerable"}
           ] = Completion.get_completion_items("foo(En", binding, env)

    assert [
             %{label: "Enum"},
             %{label: "Enumerable"}
           ] = Completion.get_completion_items("Test En", binding, env)

    assert [
             %{label: "Enum"},
             %{label: "Enumerable"}
           ] = Completion.get_completion_items("foo(x,En", binding, env)

    assert [
             %{label: "Enum"},
             %{label: "Enumerable"}
           ] = Completion.get_completion_items("[En", binding, env)

    assert [
             %{label: "Enum"},
             %{label: "Enumerable"}
           ] = Completion.get_completion_items("{En", binding, env)
  end

  test "ampersand completion" do
    {binding, env} = eval(do: nil)

    assert [
             %{label: "Enum"},
             %{label: "Enumerable"}
           ] = Completion.get_completion_items("&En", binding, env)

    assert [
             %{label: "all?/1"},
             %{label: "all?/2"}
           ] = Completion.get_completion_items("&Enum.al", binding, env)

    assert [
             %{label: "all?/1"},
             %{label: "all?/2"}
           ] = Completion.get_completion_items("f = &Enum.al", binding, env)
  end

  test "negation operator completion" do
    {binding, env} = eval(do: nil)

    assert [
             %{label: "is_binary/1"}
           ] = Completion.get_completion_items("!is_bin", binding, env)
  end

  test "pin operator completion" do
    {binding, env} =
      eval do
        my_variable = 2
      end

    assert [
             %{label: "my_variable"}
           ] = Completion.get_completion_items("^my_va", binding, env)
  end

  defmodule SublevelTest.LevelA.LevelB do
  end

  test "Elixir completion sublevel" do
    {binding, env} = eval(do: nil)

    assert [
             %{label: "LevelA"}
           ] =
             Completion.get_completion_items(
               "Livebook.CompletionTest.SublevelTest.",
               binding,
               env
             )
  end

  test "complete aliases of Elixir modules" do
    {binding, env} =
      eval do
        alias List, as: MyList
      end

    assert [
             %{label: "MyList"}
           ] = Completion.get_completion_items("MyL", binding, env)

    assert [
             %{label: "to_integer/1"},
             %{label: "to_integer/2"}
           ] = Completion.get_completion_items("MyList.to_integ", binding, env)
  end

  @tag :erl_docs
  test "complete aliases of Erlang modules" do
    {binding, env} =
      eval do
        alias :lists, as: EList
      end

    assert [
             %{label: "EList"}
           ] = Completion.get_completion_items("EL", binding, env)

    assert [
             %{label: "map/2"},
             %{label: "mapfoldl/3"},
             %{label: "mapfoldr/3"}
           ] = Completion.get_completion_items("EList.map", binding, env)

    assert %{
             label: "max/1",
             kind: :function,
             detail: "lists.max/1",
             documentation: """
             Returns the first element of List that compares greater than or equal to all other elements of List.

             ```
             @spec max(list) :: max
             when list: [t, ...],
                  max: t,
                  t: term()
             ```\
             """,
             insert_text: "max"
           } in Completion.get_completion_items("EList.", binding, env)

    assert [] = Completion.get_completion_items("EList.Invalid", binding, env)
  end

  test "completion for functions added when compiled module is reloaded" do
    {binding, env} = eval(do: nil)

    {:module, _, bytecode, _} =
      defmodule Sample do
        def foo(), do: 0
      end

    assert [
             %{label: "foo/0"}
           ] = Completion.get_completion_items("Livebook.CompletionTest.Sample.foo", binding, env)

    Code.compiler_options(ignore_module_conflict: true)

    defmodule Sample do
      def foo(), do: 0
      def foobar(), do: 0
    end

    assert [
             %{label: "foo/0"},
             %{label: "foobar/0"}
           ] = Completion.get_completion_items("Livebook.CompletionTest.Sample.foo", binding, env)
  after
    Code.compiler_options(ignore_module_conflict: false)
    :code.purge(Sample)
    :code.delete(Sample)
  end

  defmodule MyStruct do
    defstruct [:my_val]
  end

  test "completion for struct names" do
    {binding, env} = eval(do: nil)

    assert [
             %{label: "MyStruct"}
           ] = Completion.get_completion_items("Livebook.CompletionTest.MyStr", binding, env)
  end

  test "completion for struct keys" do
    {binding, env} =
      eval do
        struct = %Livebook.CompletionTest.MyStruct{}
      end

    assert [
             %{label: "my_val"}
           ] = Completion.get_completion_items("struct.my", binding, env)
  end

  test "ignore invalid Elixir module literals" do
    {binding, env} = eval(do: nil)

    defmodule(:"Elixir.Livebook.CompletionTest.Unicodé", do: nil)

    assert [] = Completion.get_completion_items("Livebook.CompletionTest.Unicod", binding, env)
  after
    :code.purge(:"Elixir.Livebook.CompletionTest.Unicodé")
    :code.delete(:"Elixir.Livebook.CompletionTest.Unicodé")
  end
end
