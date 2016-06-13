defmodule Kaper do

  def start do
    ensure_started HTTPoison
    :ok
  end

  defp ensure_started(module) do
    case module.start do
      :ok -> :ok
      {:error, {:already_started, _module}} -> :ok
    end
  end

end
