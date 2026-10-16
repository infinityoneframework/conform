defmodule ConfSchemaTest do
  use ExUnit.Case, async: true
  alias Conform.Schema
  alias Conform.Schema.Mapping

  test "inline validators accept unary functions and reject other arities" do
    validator = fn _ -> :ok end
    assert %{validator: ^validator} = Conform.Schema.Validator.from_quoted({:check, validator})

    for invalid <- [fn -> :ok end, fn _, _ -> :ok end, :invalid] do
      assert_raise Conform.Schema.SchemaError, ~r/it must be a function of arity 1/, fn ->
        Conform.Schema.Validator.from_quoted({:check, invalid})
      end
    end
  end

  test "can load schema from file" do
    path = Path.join(["test", "schemas", "small.schema.exs"])
    %Schema{mappings: [mapping], transforms: transforms} = Conform.Schema.load!(path)

    assert %Mapping{
             name: "log.error.file",
             to: "log.error_file",
             datatype: :binary,
             default: "/var/log/error.log",
             doc: "The location of the error log. Should be a full path, i.e. /var/log/error.log."
           } = mapping

    assert [] = transforms
  end
end
