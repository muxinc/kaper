defmodule KaperTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  doctest Kaper

  setup_all do
    HTTPoison.start
    :ok
  end

  test "clients can use Client for configuration automation" do
    defmodule KapClient do
      ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
      use Kaper.Client, url: "http://0.0.0.0:9092"
    end

    assert KapClient.__info__(:functions) |> Enum.member?({:list_tasks, 0})
  end

  test "list_tasks returns {:ok, response} if successful" do
    config = [url: "http://0.0.0.0:9092"]
    use_cassette "list_tasks" do
      {:ok, response} = Kaper.Client.list_tasks config

      assert length(response[:tasks]) == 2
    end
  end

  test "list_tasks returns {:error, :bad_fetch, reason} if internal server error" do
    config = [url: "http://0.0.0.0:9092"]
    use_cassette "list_tasks_server_error", custom: true do
      {:error, reason} = Kaper.Client.list_tasks config

      assert reason != ""
    end
  end

  test "list_tasks returns {:error, reason} if resource not found" do
    config = [url: "http://0.0.0.0:9092"]
    use_cassette "list_tasks_not_found", custom: true do
      {:error, "Resource not found"} = Kaper.Client.list_tasks config
    end
  end

  test "define_task returns {:ok, response} if successful" do
    config = [url: "http://0.0.0.0:9092"]
    use_cassette "define_task" do
      {:ok, response} = Kaper.Client.define_task config, "stream", [%{db: "kapacitor_example", rp: "default"}], "stream\n    |from()\n        .measurement('cpu')\n"

      assert response[:id] != ""
    end
  end

  test "define_task returns {:error, reason} if internal server error" do
    config = [url: "http://0.0.0.0:9092"]
    use_cassette "define_task_internal_server_error", custom: true do
      {:error, reason} = Kaper.Client.define_task config, "stream", [%{db: "kapacitor_example", rp: "default"}], "stream\n    |from()\n        .measurement('cpu')\n"

      assert reason == "Internal Server Error"
    end
  end

  test "enable_task returns {:ok} if successful" do
    config = [url: "http://0.0.0.0:9092"]
    use_cassette "enable_task" do
      {:ok} = Kaper.Client.enable_task config, "5909b578-d8ee-448f-99b0-c4767e37f96f"
    end
  end

  test "enable_task returns {:error, reason} if task is not defined" do
    config = [url: "http://0.0.0.0:9092"]
    use_cassette "enable_task_not_defined" do
      {:error, reason} = Kaper.Client.enable_task config, "abc-123"

      assert reason != ""
    end
  end

  test "disable_task returns {:ok} if successful" do
    config = [url: "http://0.0.0.0:9092"]
    use_cassette "disable_task" do
      {:ok} = Kaper.Client.disable_task config, "5909b578-d8ee-448f-99b0-c4767e37f96f"
    end
  end

  test "disable_task returns {:error, reason} if task is not defined" do
    config = [url: "http://0.0.0.0:9092"]
    use_cassette "disable_task_not_defined" do
      {:error, reason} = Kaper.Client.disable_task config, "abc-123"

      assert reason != ""
    end
  end

  test "get_task returns {:ok, response} if successful" do
    config = [url: "http://0.0.0.0:9092"]
    use_cassette "get_task" do
      {:ok, response} = Kaper.Client.get_task config, "5909b578-d8ee-448f-99b0-c4767e37f96f"

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

  test "delete_task returns {:ok} if successful" do
    config = [url: "http://0.0.0.0:9092"]
    use_cassette "delete_task" do
      {:ok} = Kaper.Client.delete_task config, "f5d7b98c-b56f-4e5f-8c8b-75cd745ce871"
    end
  end

  test "delete_task returns {:ok} if task is not defined" do
    config = [url: "http://0.0.0.0:9092"]
    use_cassette "delete_task_not_defined" do
      {:ok} = Kaper.Client.delete_task config, "abc-123"
    end
  end

end
