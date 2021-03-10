defmodule MusterWeb.GameMonitor do
  use GenServer

  @impl true
  def init(processes) do
    {:ok, processes}
  end

  @impl true
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, opts)
  end

  def monitor(callback) do
    GenServer.call(__MODULE__, {:monitor, callback})
  end

  def handle_call({:monitor, callback}, {pid, _ref}, processes) do
    Process.monitor(pid)
    {:reply, :ok, Map.put(processes, pid, callback)}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, processes) do
    {callback, processes} = Map.pop(processes, pid)
    Task.start(fn -> callback.() end)
    {:noreply, processes}
  end
end
