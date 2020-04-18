defmodule Xrt.Slug do
  @version_regex ~r/(?<prefix>.+)-(?<version>\d+)$/

  def custom?(text) do
    text |> parsed_slug != %{}
  end

  def next(text) do
    prefix = text |> custom_slug_prefix
    version = (text |> custom_slug_version) + 1
    "#{prefix}-#{version}"
  end

  defp custom_slug_prefix(text) do
    text |> parsed_slug |> Map.get("prefix")
  end

  defp custom_slug_version(text) do
    version = text |> parsed_slug |> Map.get("version")
    if version != nil, do: version |> Integer.parse() |> elem(0), else: nil
  end

  defp parsed_slug(text) do
    @version_regex |> Regex.named_captures(text) || %{}
  end
end
