defmodule KaperTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  doctest Kaper

  defmodule KapClient do
    use Kaper.Client, url: "http://0.0.0.0:9092"
  end

  setup_all do
    HTTPoison.start
    :ok
  end

  test "clients can use Client for configuration automation" do
    assert KapClient.__info__(:functions) |> Enum.member?({:list_tasks, 0})
  end

  test "list_tasks returns {:ok, response} if successful" do
    use_cassette "list_tasks" do
      {:ok, response} = KapClient.list_tasks

      assert length(response[:tasks]) == 2
    end
  end

  test "list_tasks returns {:error, :bad_fetch, reason} if internal server error" do
    use_cassette "list_tasks_server_error", custom: true do
      {:error, reason} = KapClient.list_tasks

      assert reason != ""
    end
  end

  test "list_tasks returns {:error, reason} if resource not found" do
    use_cassette "list_tasks_not_found", custom: true do
      {:error, "Resource not found"} = KapClient.list_tasks
    end
  end

  test "define_task returns {:ok, response} if successful" do
    use_cassette "define_task" do
      {:ok, response} = KapClient.define_task "stream", [%{db: "kapacitor_example", rp: "default"}], "stream\n    |from()\n        .measurement('cpu')\n"

      assert response[:id] != ""
    end
  end

  test "define_task returns {:error, reason} if internal server error" do
    use_cassette "define_task_internal_server_error", custom: true do
      {:error, reason} = KapClient.define_task "stream", [%{db: "kapacitor_example", rp: "default"}], "stream\n    |from()\n        .measurement('cpu')\n"

      assert reason == "Internal Server Error"
    end
  end

  test "enable_task returns {:ok, response} if successful" do
    use_cassette "enable_task" do
      {:ok, response} = KapClient.enable_task "5909b578-d8ee-448f-99b0-c4767e37f96f"

      assert response == %{}
    end
  end

  test "enable_task returns {:error, reason} if task is not defined" do
    use_cassette "enable_task_not_defined" do
      {:error, reason} = KapClient.enable_task "abc-123"

      assert reason != ""
    end
  end

  test "disable_task returns {:ok, response} if successful" do
    use_cassette "disable_task" do
      {:ok, response} = KapClient.disable_task "5909b578-d8ee-448f-99b0-c4767e37f96f"

      assert response == %{}
    end
  end

  test "disable_task returns {:error, reason} if task is not defined" do
    use_cassette "disable_task_not_defined" do
      {:error, reason} = KapClient.disable_task "abc-123"

      assert reason != ""
    end
  end

  test "get_task returns {:ok, response} if successful" do
    use_cassette "get_task" do
      {:ok, response} = KapClient.get_task "5909b578-d8ee-448f-99b0-c4767e37f96f"

      assert response[:id] == "5909b578-d8ee-448f-99b0-c4767e37f96f"
    end
  end

  test "get_task returns {:error, reason} if task is not defined" do
    config = [url: "http://0.0.0.0:9092"]
    use_cassette "get_task_not_defined" do
      {:error, reason} = Kaper.Client.get_task config, "abc-123"

      assert reason != ""
    end
  end

  test "delete_task returns {:ok, response} if successful" do
    use_cassette "delete_task" do
      {:ok, response} = KapClient.delete_task "f5d7b98c-b56f-4e5f-8c8b-75cd745ce871"

      assert response == %{}
    end
  end

  test "delete_task returns {:ok, response} if task is not defined" do
    use_cassette "delete_task_not_defined" do
      {:ok, response} = KapClient.delete_task "abc-123"

      assert response == %{}
    end
  end

end
