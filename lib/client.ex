defmodule Kaper.Client do

  defmacro __using__(config) do
    quote do
      @conf unquote(config)
      def conf, do: @conf
      def list_tasks(opts \\ %{}) do
        unquote(__MODULE__).list_tasks(conf(), opts)
      end
      def define_task(type, dbrps, script, status \\ :enabled, vars \\ %{}, id \\ "", template_id \\ "") do
        unquote(__MODULE__).define_task(conf(), type, dbrps, script, status, vars, id, template_id)
      end
      def get_task(id, dot_view \\ "attributes", script_format \\ "formatted") do
        unquote(__MODULE__).get_task(conf(), id)
      end
      def delete_task(id) do
        unquote(__MODULE__).delete_task(conf(), id)
      end
      def enable_task(id) do
        unquote(__MODULE__).enable_task(conf(), id)
      end
      def disable_task(id) do
        unquote(__MODULE__).disable_task(conf(), id)
      end
      def define_template(type, script, id \\ "") do
        unquote(__MODULE__).define_template(conf(), type, script, id)
      end
    end
  end

  def list_tasks(conf, opts \\ %{}) do
    do_list_tasks(conf, opts)
  end

  defp do_list_tasks(conf, opts) do
    attrs = remove_empty_values(%{
      "pattern": Dict.get(opts, :pattern),
      "fields": Dict.get(opts, :fields),
      "dot-view": Dict.get(opts, :dotview),
      "script-format": Dict.get(opts, :scriptformat),
      "offset": Dict.get(opts, :offset),
      "limit": Dict.get(opts, :limit),
    })
    query = URI.encode_query(attrs)
    req_url = add_query(url("/kapacitor/v1/tasks", conf[:url]), query)
    request conf, :get, req_url, [], "", ""
  end

  def define_task(conf, type, dbrps, script, status \\ :enabled, vars \\ %{}, id \\ nil, template_id \\ nil) do
    do_define_task(conf, type, dbrps, script, status, vars, id, template_id)
  end

  defp do_define_task(conf, type, dbrps, script, status, vars, id , template_id) do
    attrs = %{
      "type": type,
      "dbrps": dbrps,
      "script": script,
      "status": status,
      "vars": vars,
      "id": id,
      "template_id": template_id,
    }
    req_url = url("/kapacitor/v1/tasks", conf[:url])

    body = Poison.encode!(attrs)
    request conf, :post, req_url, [], "application/json", body
  end

  def enable_task(conf, id) do
    do_update_task_status(conf, id, "enabled")
  end

  def disable_task(conf, id) do
    do_update_task_status(conf, id, "disabled")
  end

  defp do_update_task_status(conf, id, status) do
    attrs = %{
      "status": status,
    }
    req_url = url(Path.join("/kapacitor/v1/tasks/", id), conf[:url])

    body = Poison.encode!(attrs)
    request conf, :patch, req_url, [], "application/json", body
  end

  def delete_task(conf, id) do
    do_delete_task(conf, id)
  end

  defp do_delete_task(conf, id) do
    req_url = url(Path.join("/kapacitor/v1/tasks/", id), conf[:url])

    request conf, :delete, req_url, [], "", ""
  end

  def get_task(conf, id, dot_view \\ "attributes", script_format \\ "formatted") do
    do_get_task(conf, id, dot_view, script_format)
  end

  defp do_get_task(conf, id, dot_view, script_format) do
    attrs = remove_empty_values(%{
      "dot-view": dot_view,
      "script-format": script_format,
    })
    query = URI.encode_query(attrs)
    req_url = add_query(url(Path.join("/kapacitor/v1/tasks/", id), conf[:url]), query)
    request conf, :get, req_url, [], "", ""
  end

  defp remove_empty_values(map) do
    map
      |> Enum.filter(fn {_, v} -> v != nil && v != "" end)
      |> Enum.into(%{})
  end

  defp url(path, domain), do: Path.join([domain, path])

  defp request(conf, method, url, headers, ctype, body) do
    options = case conf[:basic_auth_username] != "" && conf[:basic_auth_password] != "" do
      true ->
        [{:hackney, [basic_auth: {conf[:basic_auth_username], conf[:basic_auth_password]}]}]
      _ ->
        []
    end

    case method do
      :get ->
        HTTPoison.get(url, [], options)
      _    ->
        headers = headers ++ [{'Content-Type', ctype}]
        HTTPoison.request(
          method,
          url,
          body,
          headers,
          options
        )
    end
    |> normalize_response
  end

 defp normalize_response(response) do
    case response do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        {:ok, Poison.decode!(body) |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end) }
      {:ok, %HTTPoison.Response{status_code: 204}} ->
        {:ok, %{}}
      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, body }
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
   end

  defp add_query(url, ""),          do: url
  defp add_query(url, query),       do: url <> "?" <> query

end
