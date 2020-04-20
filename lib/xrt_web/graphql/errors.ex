defmodule XrtWeb.Graphql.Errors do
  @moduledoc """
  Helpers to handle errors on grapqhl resolvers
  """

  @typep resolver_function :: (any, any, any -> any)

  @spec handle_errors(resolver_function()) :: resolver_function()
  def handle_errors(fun) do
    fn source, args, info ->
      case Absinthe.Resolution.call(fun, source, args, info) do
        {:error, %Ecto.Changeset{} = changeset} ->
          {:error, %{message: format_errors(changeset)}}

        val ->
          val
      end
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  @spec error(atom() | String.t(), String.t(), Keyword.t()) :: %{
          extensions: %{code: String.t(), context: [map()]},
          message: String.t()
        }
  def error(code, message, opts \\ [])

  def error(code, message, opts) when is_atom(code) do
    error(Atom.to_string(code), message, opts)
  end

  def error(code, message, opts) do
    code = if Keyword.get(opts, :upcase, true), do: String.upcase(code), else: code

    context =
      opts
      |> Keyword.get(:context, [])
      |> Enum.map(fn {k, v} -> %{"key" => to_string(k), "value" => to_string(v)} end)

    %{extensions: %{code: code, context: context}, message: message}
  end
end
