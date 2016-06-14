defmodule Kaper do

  def start() do
    :application.ensure_all_started(:httpoison)
    :ok
  end

end
